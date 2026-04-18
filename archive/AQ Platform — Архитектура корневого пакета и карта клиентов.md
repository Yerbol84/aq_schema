# AQ Platform — Архитектура корневого пакета и карта клиентов

---

## 1. Корневой пакет `aq_schema` — философия

### Что живёт здесь

`aq_schema` — это **общий язык платформы**. Не реализации, не HTTP, не SQLite.
Только то, что справедливо для любого пакета и любого приложения одновременно:

| Живёт в aq_schema | Не живёт в aq_schema |
|---|---|
| Доменные модели (Graph, Node, RunContext) | HTTP-клиенты, Drift-таблицы |
| Интерфейсы сервисов (IAQAuthService) | Конкретные реализации сервисов |
| Клиентские интерфейсы (IAQGraphEngineClient) | Бизнес-логика пакетов |
| Переиспользуемые утилиты (ConditionEvaluator) | UI-компоненты |
| Контракты безопасности (AQApiKeyClaims, AQRole) | LLM SDK, MCP транспорт |
| Sandbox политики и интерфейсы | Реальное создание процессов |

**Правило одной проверки:** если код нужен в двух разных пакетах — он переезжает в `aq_schema`.
Если нужен только внутри одного пакета — остаётся там.

---

## 2. Стратегия экспорта — наборы вместо файлов

Пакет экспортирует не отдельные файлы, а **тематические наборы**.
Потребитель импортирует ровно тот набор, который ему нужен:

```dart
import 'package:aq_schema/graph.dart';        // графы, узлы, runner контракты
import 'package:aq_schema/security.dart';     // auth, roles, claims, policies
import 'package:aq_schema/data.dart';         // vault, storable, query models
import 'package:aq_schema/tools.dart';        // AQToolService, LLM/Vault interfaces
import 'package:aq_schema/sandbox.dart';      // ISandbox, SandboxPolicy, events
import 'package:aq_schema/worker.dart';       // WorkerJob, JobStatus, queue contracts
import 'package:aq_schema/clients.dart';      // все клиентские интерфейсы + .instance
```

Каждый набор — отдельный barrel-файл в корне `lib/`:

```
pkgs/aq_schema/lib/
├── aq_schema.dart        ← полный набор (только для тестов и schema-aware пакетов)
├── graph.dart            ← набор: графовый домен
├── security.dart         ← набор: безопасность
├── data.dart             ← набор: слой данных
├── tools.dart            ← набор: инструменты
├── sandbox.dart          ← набор: песочница
├── worker.dart           ← набор: воркеры и очереди
└── clients.dart          ← набор: клиентские интерфейсы всех сервисов
```

---

## 3. Клиентские интерфейсы — единая точка входа

Каждый сервис платформы объявляет в `aq_schema/clients.dart` свой клиентский интерфейс.
Интерфейс содержит статическое поле `instance` — оно возвращает реализацию,
зарегистрированную при инициализации приложения или пакета.

```dart
// Единая точка регистрации — вызывается при старте приложения/воркера
AQPlatform.init(
  auth:    MyAuthClient(),
  engine:  MyGraphEngineClient(),
  vault:   MyVaultClient(),
  tools:   MyToolServiceClient(),
  sandbox: MySandboxClient(),
);

// Любой код в системе получает клиент через интерфейс:
final client = IAQGraphEngineClient.instance;  // зарегистрированная реализация
final auth    = IAQAuthClient.instance;
```

```dart
// Пример интерфейса
abstract interface class IAQGraphEngineClient {
  static IAQGraphEngineClient get instance => AQPlatform.resolve();

  Stream<GraphRunEvent> run(GraphRunRequest request);
  Future<void> resume(String runId, UserInputResponse input);
  Future<void> cancel(String runId);
  Future<GraphRunStatus> getStatus(String runId);
}
```

**Задача приложения** — правильно инициализировать. Задача потребителя — использовать
через интерфейс, не зная о реализации.

---

## 4. Карта сервисов и клиентов

Каждый сервис реализует интерфейсы из `aq_schema` и выдаёт **типизированных клиентов** —
разных для разных потребителей. Клиент ресурса не совпадает с клиентом пользователя.

---

### 4.1 Сервис безопасности — `aq_auth`

**Что делает:** Аутентификация, авторизация, выдача и валидация JWT и API-ключей,
управление ролями и политиками доступа.

**Интерфейсы в `security.dart`:**
```
IAQAuthService           — серверный интерфейс (login, issue token, validate)
IAQRbacService           — управление ролями и политиками
AQTokenClaims            — payload JWT (userId, projectId, roles, apiKeyRef)
AQApiKeyClaims           — payload API-ключа (projectId, scope[], rateLimit)
AQRole, AQPermission     — модели RBAC
AQPolicy                 — политика доступа (rules, resource patterns)
```

**Типизированные клиенты:**

| Клиент | Интерфейс | Получает | Не получает |
|--------|-----------|---------|------------|
| Пользователь (UI app) | `IAQAuthUserClient` | login, logout, currentToken, refreshToken | API-ключи ресурсов, роли других пользователей |
| Ресурс/Воркер (server) | `IAQAuthResourceClient` | loginWithApiKey, validateToken, getApiKeyClaims | Управление пользователями, сессии |
| Администратор | `IAQAuthAdminClient` | + управление ролями, выдача ключей проектам | — |
| Движок (внутри пакета) | `IAQAuthEngineClient` | validateToken offline, extractClaims — нет HTTP | — |

```dart
// В приложении:
final auth = IAQAuthUserClient.instance;
await auth.loginWithCredentials(email, password);

// В воркере:
final auth = IAQAuthResourceClient.instance;
await auth.loginWithApiKey(config.apiKey);
final claims = auth.validateToken(incomingJwt);
```

---

### 4.2 Слой данных — `dart_vault`

**Что делает:** Хранение и версионирование доменных объектов (графы, артефакты, run-записи).
Абстрагирует конкретное хранилище (PostgreSQL, SQLite, in-memory).

**Интерфейсы в `data.dart`:**
```
IVaultStorage            — CRUD + query + versioning
IRunRepository           — создание/обновление/suspend run-записей
IGraphRepository         — загрузка графов по blueprintId
VaultQuery, VaultFilter  — DSL запросов
Storable, Versionable    — контракты для хранимых объектов
AccessGrant              — политика доступа к объекту
```

**Типизированные клиенты:**

| Клиент | Интерфейс | Получает |
|--------|-----------|---------|
| Приложение/UI | `IAQVaultUserClient` | CRUD своих объектов в рамках projectId |
| Движок | `IAQVaultEngineClient` | read-only загрузка графов, запись run-state |
| Воркер | `IAQVaultWorkerClient` | = EngineClient, инициализируется через RemoteVaultStorage |
| Администратор | `IAQVaultAdminClient` | + cross-tenant query, миграции |

---

### 4.3 Графовый движок — `aq_graph_engine`

**Что делает:** Выполняет WorkflowGraph, InstructionGraph, PromptGraph.
Suspend/Resume, retry, join strategies, метрики.

**Интерфейсы в `graph.dart`:**
```
IAQGraphEngineClient     — клиентский интерфейс (run, resume, cancel, status)
IEngineTransport         — транспорт (local/http/custom)
IWorkflowNode            — базовый интерфейс узла workflow
IInstructionNode         — узел instruction
IPromptNode              — узел prompt
GraphRunRequest          — запрос на запуск
GraphRunEvent (sealed)   — события выполнения
GraphRunStatus           — текущий статус
```

**Типизированные клиенты:**

| Клиент | Режим | Примечание |
|--------|-------|-----------|
| Flutter/Desktop app | remote | HTTP + SSE к серверу |
| Server-side сервис | local | InProcess, LocalEngineTransport |
| Другой сервис | remote | то же HTTP API |
| Тест | mock | MockEngineTransport, без IO |

Все режимы — один интерфейс `IAQGraphEngineClient`. Режим выбирается при `AQPlatform.init()`.

---

### 4.4 Сервис инструментов — `aq_tool_service`

**Что делает:** Предоставляет движку доступ к LLM, хранилищу артефактов
и произвольным именованным инструментам (включая MCP-серверы).

**Интерфейсы в `tools.dart`:**
```
AQToolService            — главный фасад (llm, vault, callTool, availableTools)
IAQLlmService            — complete(), stream()
IAQVaultService          — read(), write(), query(), delete()
AQToolDescriptor         — описание инструмента (для tool-use в LLM)
AQLlmMessage/Response    — модели запроса/ответа к LLM
AQVaultItem/Query        — модели для vault операций
```

**Типизированные клиенты:**

| Клиент | Интерфейс | Примечание |
|--------|-----------|-----------|
| Узел в графе | `AQToolService` | через RunContext и DI в execute() |
| Движок | `AQToolService` | передаётся при инициализации GraphEngine |
| Тест | `MockAQToolService` | заглушки с очередью ответов |

`AQToolService` — DI-зависимость, передаётся явно при сборке движка.
Одна реализация на весь lifetime воркера или приложения.

---

### 4.5 UI Builder движка — `aq_graph_ui` *(Flutter-only)*

**Что делает:** Визуальный редактор графов. Реагирует на события движка,
отображает состояние выполнения, форму для UserInputNode, прогресс узлов.

**Использует из `graph.dart`:**
```
IAQGraphEngineClient     — подписка на события, resume с вводом пользователя
GraphRunEvent (sealed)   — userInputRequired, statusChanged, log, error
WorkflowGraph            — модель для рендера узлов и рёбер
IWorkflowNode.nodeType   — определяет иконку и форму узла в UI
```

**Типизированные клиенты:**

| Клиент | Интерфейс | Получает |
|--------|-----------|---------|
| Graph canvas | `IAQGraphEditorClient` | load/save/validate граф, структура узлов |
| Run monitor | `IAQGraphEngineClient` | subscribe на события run в реальном времени |
| Input form | `IAQGraphEngineClient` | resume(runId, userInput) |

`IAQGraphEditorClient` — интерфейс в `graph.dart`, реализация в `aq_graph_ui`.

---

### 4.6 Сервис песочницы — `aq_sandbox`

**Что делает:** Создаёт изолированное пространство для выполнения графа
когда простого доступа к инструментам недостаточно. Нужен когда граф
должен работать с реальной средой: файловая система, процессы ОС, временная БД.

**Когда нужна песочница:**
- Граф пишет/читает файлы в рамках сессии (не артефакты в vault, а рабочие файлы)
- Граф запускает процессы (компилятор, тесты, скрипты, git)
- Граф создаёт временную БД или окружение для своей работы
- Нужна изоляция между разными run-сессиями одного проекта

**Когда песочница не нужна:**
- Граф только обращается к LLM и vault — `AQToolService` достаточно
- Все операции в памяти или через внешние API

**Интерфейсы в `sandbox.dart`:**
```
ISandbox                 — lifecycle: create, dispose
ISandboxContext          — RunContext реализует этот интерфейс
ISandboxCapable          — узел заявляет что ему нужна sandbox
ISandboxRegistry         — реестр доступных типов sandbox
ISandboxAsEnvironment    — sandbox предоставляет окружение (PATH, env vars)
ISandboxAsProcess        — sandbox запускает дочерние процессы
SandboxPolicy            — что разрешено (fs:read, fs:write, network, exec)
SandboxPolicyViolation   — нарушение политики
```

**Типизированные клиенты:**

| Клиент | Интерфейс | Получает |
|--------|-----------|---------|
| Узел (ISandboxCapable) | `ISandboxContext` | read/write в своём namespace, exec если разрешено policy |
| Движок | `ISandboxRegistry` | создать/уничтожить sandbox для run |
| Администратор | `IAQSandboxAdminClient` | квоты, активные sandbox, принудительное уничтожение |
| Тест | `FallbackSandbox` (unrestricted) | всё разрешено, уже в aq_schema |

**Виды sandbox (реализуются в `aq_sandbox`):**
```
LocalFsSandbox           — изолированная директория /tmp/aq/{runId}/
DockerSandbox            — Docker-контейнер с монтированием и сетевой изоляцией
WasmSandbox              — WebAssembly runtime (браузер / edge)
InMemorySandbox          — только память (лёгкие графы, тесты)
```

---

## 5. Сводная карта: что импортирует каждый пакет

| Пакет / Приложение | graph | security | data | tools | sandbox | clients |
|---|:---:|:---:|:---:|:---:|:---:|:---:|
| `aq_graph_engine` | ✅ | ✅ claims | ✅ repos | ✅ | ✅ context | — |
| `aq_auth` | — | ✅ | ✅ storable | — | — | — |
| `dart_vault` | — | ✅ access | ✅ | — | — | — |
| `aq_tool_service` | — | ✅ claims | ✅ vault | ✅ | — | — |
| `aq_sandbox` | — | ✅ policy | — | — | ✅ | — |
| `graph_engine_server` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| `aq_graph_worker` | ✅ | ✅ | ✅ | ✅ | опц. | ✅ |
| Flutter app | ✅ | ✅ | ✅ | — | — | ✅ |

---

## 6. Порядок инициализации (точка сборки)

```dart
// main.dart приложения или воркера

// 1. Auth — первым, остальные могут требовать токен
final auth = RemoteAuthClient(serverUrl: authUrl);
await auth.loginWithApiKey(apiKey);

// 2. Vault — после auth (нужен токен)
final vault = RemoteVaultClient(endpoint: vaultUrl, auth: auth);

// 3. Tools — может зависеть от vault
final tools = AQToolServiceBuilder()
  .withLlm(AnthropicService(apiKey: llmKey))
  .withVault(VaultToolAdapter(vault))
  .withMcp('filesystem', McpStdioTransport('npx @mcp/server-filesystem /data'))
  .build();

// 4. Engine — после tools и vault
final engine = GraphEngineService.local(
  tools: tools,
  runRepo: VaultRunRepository(vault),
  graphRepo: VaultGraphRepository(vault),
  auth: auth,
);

// 5. Регистрация всего в AQPlatform
AQPlatform.init(auth: auth, vault: vault, tools: tools, engine: engine);

// Теперь в любом месте кода — без знания о реализациях:
final stream = IAQGraphEngineClient.instance.run(request);
final token  = await IAQAuthUserClient.instance.currentToken;
```

**Правило:** код внутри пакетов никогда не создаёт клиент самостоятельно.
Только запрашивает через `IInterface.instance`.
Только точка сборки (main, test setup) знает о конкретных классах.

---

## 7. Итог

`aq_schema` — конституция платформы: общий язык, контракты интерфейсов,
клиентские абстракции. Пакеты реализуют сервисы согласно этим контрактам.
Приложения собирают реализации и регистрируют через `AQPlatform.init()`.
Потребители работают только через `IInterface.instance`.

Типизация клиентов обеспечивает принцип наименьших привилегий:
воркер получает `ResourceClient` — не получает `AdminClient`.
Узел в графе получает `ISandboxContext` — не получает `ISandboxRegistry`.
Каждый потребитель видит ровно тот API, который ему необходим.