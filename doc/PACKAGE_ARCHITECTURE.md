# AQ Package Architecture — Архитектура экосистемы пакетов

**Версия:** 2.0
**Статус:** ОБЯЗАТЕЛЬНО к соблюдению при создании новых пакетов

---

## Часть 1. Философия: aq_schema как единый источник истины

### 1.1 Что живёт в aq_schema

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

### 1.2 Ключевые постулаты

1. **aq_schema — единственный источник истины**
   - Все доменные модели (WorkflowGraph, InstructionGraph, AqStudioProject и т.д.)
   - Все интерфейсы (IHand, IEngineTransport, VaultStorage и т.д.)
   - Все схемы данных (Storable интерфейсы: DirectStorable, VersionedStorable, LoggedStorable)
   - Все валидаторы и типы ошибок

2. **Пакеты не зависят друг от друга**
   - `aq_graph_engine` НЕ знает о `aq_worker`
   - `dart_vault` НЕ знает о `aq_security`
   - `aq_mcp_core` НЕ знает о `aq_queue`
   - Все взаимодействие идёт через интерфейсы из `aq_schema`

3. **Клиент максимально тонкий**
   - Клиентское приложение НЕ пишет ни строчки бизнес-логики
   - Клиент просто подключает пакет и получает готовый сервис
   - Вся логика реализована на уровне пакета (и на клиенте, и на сервере)

4. **Пакет = Клиент + Сервер**
   - Каждый пакет содержит две части: клиентскую и серверную
   - Сервер реализует работу, выдаёт результат
   - Клиент (из того же пакета) знает как работать с сервером
   - Благодаря этому: один набор тестов проверяет всё

### 1.3 Стратегия экспорта — тематические наборы

Пакет `aq_schema` экспортирует не отдельные файлы, а **тематические наборы**.
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

## Часть 2. Структура пакета

### 2.1 Единая структура для всех пакетов

Каждый пакет в экосистеме AQ должен следовать единой структуре:

```
my_package/
├── lib/
│   ├── my_package.dart              # Главный экспорт (ТОЛЬКО клиентская часть)
│   ├── client/                      # Клиентская часть (экспортируется)
│   │   ├── my_service_client.dart   # Клиент сервиса
│   │   └── my_repository.dart       # Репозиторий (если это дата-слой)
│   ├── server/                      # Серверная часть (НЕ экспортируется в main)
│   │   ├── my_service_server.dart   # Серверная реализация
│   │   └── storage/                 # Storage реализации (ТОЛЬКО на сервере)
│   ├── shared/                      # Общие утилиты (если нужны)
│   │   └── my_protocol.dart         # Протокол взаимодействия
│   └── server.dart                  # Отдельный экспорт для серверной части
├── test/
│   ├── integration/                 # Интеграционные тесты (клиент + сервер)
│   └── unit/                        # Юнит-тесты
└── pubspec.yaml
```

### 2.2 Правила экспорта

**КРИТИЧЕСКИ ВАЖНО:**

1. **Главный файл пакета (`lib/my_package.dart`)** экспортирует **ТОЛЬКО клиентскую часть**:
   ```dart
   // lib/my_package.dart
   library my_package;

   export 'client/my_service_client.dart';
   export 'client/my_repository.dart';
   // НЕ экспортируем server/ и storage/
   ```

2. **Серверная часть** экспортируется через **отдельный файл** (`lib/server.dart`):
   ```dart
   // lib/server.dart
   library my_package.server;

   export 'server/my_service_server.dart';
   export 'server/storage/my_storage.dart';
   ```

3. **Storage реализации живут ТОЛЬКО на сервере**:
   - Клиент получает только Repository
   - Storage остаётся на сервере и не передаётся клиенту

### 2.3 Регистрация доменов: Строго из aq_schema

**ПРАВИЛО:** Все домены, которые регистрируются в пакетах, должны быть определены в `aq_schema`.

#### Где определяются домены

```
aq_schema/
├── lib/
│   ├── graph/
│   │   └── graphs/
│   │       ├── workflow_graph.dart      # WorkflowGraph implements VersionedStorable
│   │       ├── instruction_graph.dart   # InstructionGraph implements VersionedStorable
│   │       └── prompt_graph.dart        # PromptGraph implements VersionedStorable
│   ├── studio_project/
│   │   └── aq_studio_project.dart       # AqStudioProject implements DirectStorable
│   └── data_layer/
│       └── storable/
│           ├── storable.dart            # Базовый интерфейс
│           ├── direct_storable.dart     # Простое хранение
│           ├── versioned_storable.dart  # С версионированием
│           └── logged_storable.dart     # С аудитом
```

#### Как регистрировать

```dart
// В серверном приложении (server_apps/aq_studio_data_service)
import 'package:aq_schema/aq_schema.dart';
import 'package:dart_vault/server.dart';

registry
  // Все модели строго из aq_schema!
  ..register(DomainRegistration(
      collection: WorkflowGraph.kCollection,      // из aq_schema
      mode: StorageMode.versioned,
      fromMap: WorkflowGraph.fromMap,             // из aq_schema
  ))
  ..register(DomainRegistration(
      collection: AqStudioProject.kCollection,    // из aq_schema
      mode: StorageMode.direct,
      fromMap: AqStudioProject.fromMap,           // из aq_schema
  ));
```

---

## Часть 3. Клиентские интерфейсы и типизированные клиенты

### 3.1 Единая точка входа через интерфейсы

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

### 3.2 Типизированные клиенты для разных потребителей

Каждый сервис реализует интерфейсы из `aq_schema` и выдаёт **типизированных клиентов** —
разных для разных потребителей. Клиент ресурса не совпадает с клиентом пользователя.

#### 3.2.1 Сервис безопасности — aq_auth

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

#### 3.2.2 Слой данных — dart_vault

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

#### 3.2.3 Графовый движок — aq_graph_engine

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

#### 3.2.4 Сервис инструментов — aq_tool_service

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

#### 3.2.5 Сервис песочницы — aq_sandbox

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

### 3.3 Сводная карта импортов

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

### 3.4 Порядок инициализации (точка сборки)

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

## Часть 4. Примеры реализации пакетов

### 4.1 Пример: dart_vault (дата-слой)

#### Что видит клиент

```dart
// В клиентском приложении
import 'package:dart_vault/dart_vault.dart';

// Клиент делает handshake и получает готовый репозиторий
await Vault.connect('http://localhost:8765');

final workflows = Vault.instance.versioned<WorkflowGraph>(
  collection: WorkflowGraph.kCollection,
  fromMap: WorkflowGraph.fromMap,
);

// Всё! Клиент не знает о PostgreSQL, Supabase, или способах хранения
await workflows.createEntity(myWorkflow);
```

#### Что происходит на сервере

```dart
// В серверном приложении
import 'package:dart_vault/server.dart'; // Отдельный импорт!

// Сервер регистрирует домены из aq_schema
final registry = VaultRegistry(
  storageFactory: (tenantId) => PostgresVaultStorage(pool: pg, tenantId: tenantId),
  deployer: PostgresSchemaDeployer(pool: pg),
);

registry
  ..register(DomainRegistration(
      collection: WorkflowGraph.kCollection,
      mode: StorageMode.versioned,
      fromMap: WorkflowGraph.fromMap,
      indexes: [VaultIndex(name: 'idx_name', field: 'name')],
  ))
  ..register(DomainRegistration(
      collection: InstructionGraph.kCollection,
      mode: StorageMode.versioned,
      fromMap: InstructionGraph.fromMap,
  ));

await registry.deploy(); // Создаёт таблицы если нужно
```

#### Handshake протокол

1. **Клиент подключается**: `Vault.connect('http://localhost:8765')`
2. **Сервер отвечает** списком доступных коллекций:
   ```json
   {
     "serverVersion": "0.3.0",
     "tenantId": "user-123",
     "collections": [
       {"name": "workflows", "mode": "versioned", "schemaVersion": "1.0.0"},
       {"name": "instructions", "mode": "versioned", "schemaVersion": "1.0.0"}
     ],
     "capabilities": ["direct", "versioned", "logged", "artifact", "vector"],
     "compatible": true
   }
   ```
3. **Клиент получает полный репозиторий** — готов к работе!

### 4.2 Пример: aq_security (авторизация)

#### Что видит клиент

```dart
import 'package:aq_security/aq_security.dart';

// Инициализация
await AQSecurityClient.init(
  'http://localhost:8080',
  jwtSecret: 'secret',
);

// Использование
final result = await AQSecurityClient.instance.signIn(
  email: 'user@example.com',
  password: 'password',
);

if (result.success) {
  print('Token: ${result.token}');
}
```

#### Что происходит на сервере

```dart
import 'package:aq_security/server.dart'; // Отдельный импорт!

// Сервер регистрирует провайдеры из aq_schema
final authService = AQSecurityServer(
  storage: PostgresSecurityStorage(pool: pg),
  jwtSecret: 'secret',
);

// Обработка запросов
router.post('/auth/signin', (Request req) async {
  final body = await req.readAsString();
  final result = await authService.signIn(jsonDecode(body));
  return Response.ok(jsonEncode(result.toMap()));
});
```

### 4.3 Пример: aq_graph_engine (графовый движок)

#### Что видит клиент

```dart
import 'package:aq_graph_engine/aq_graph_engine.dart';

// Клиент получает транспорт (локальный или удалённый)
final transport = LocalEngineTransport(
  tools: toolRegistry,
  runRepo: runRepository,
  graphRepo: graphRepository,
);

// Запуск графа
final stream = transport.run(GraphRunRequest(
  runId: 'run-123',
  blueprintId: 'workflow-456',
  context: {'projectId': 'proj-789'},
));

await for (final event in stream) {
  print('Event: ${event.type}');
}
```

#### Что происходит на сервере (worker)

```dart
import 'package:aq_graph_engine/server.dart'; // Отдельный импорт!

// Worker регистрирует hands из aq_schema
final worker = GraphWorker(
  transport: RemoteEngineTransport(endpoint: 'http://localhost:8765'),
  handsRegistry: WorkerHandsRegistry()
    ..register('llm_request', LlmRequestHand())
    ..register('file_write', FileWriteHand()),
);

await worker.start();
```

---

## Часть 5. Тестирование и преимущества

### 5.1 Тестирование: Один пакет = Один набор тестов

Благодаря тому, что клиент и сервер в одном пакете, тесты проверяют всё сразу:

```dart
// test/integration/vault_integration_test.dart
import 'package:dart_vault/dart_vault.dart';
import 'package:dart_vault/server.dart';
import 'package:aq_schema/aq_schema.dart';

void main() {
  test('Client-Server integration', () async {
    // Запускаем сервер
    final registry = VaultRegistry(
      storageFactory: (tid) => InMemoryVaultStorage(),
    );
    registry.register(DomainRegistration(
      collection: 'test_docs',
      mode: StorageMode.versioned,
      fromMap: TestDoc.fromMap,
    ));

    // Подключаем клиента
    await Vault.connect('http://localhost:8765');

    // Тестируем
    final repo = Vault.instance.versioned<TestDoc>(
      collection: 'test_docs',
      fromMap: TestDoc.fromMap,
    );

    final node = await repo.createEntity(TestDoc(id: '1', title: 'Test'));
    expect(node.status, VersionStatus.draft);
  });
}
```

### 5.2 Преимущества архитектуры

#### 1. Нулевое дублирование кода
- Домены определены один раз в `aq_schema`
- Не нужно отдельно описывать для сервера и клиента
- Не нужны прослойки и адаптеры

#### 2. Автоматическая синхронизация
- Изменил модель в `aq_schema` → обновил версию пакета
- Клиент и сервер автоматически получают изменения
- Handshake проверяет совместимость версий

#### 3. Простота разработки
- Клиент не пишет логику — просто использует пакет
- Сервер регистрирует домены — всё остальное автоматически
- Один набор тестов проверяет всё

#### 4. Изоляция и модульность
- Пакеты не зависят друг от друга
- Можно заменить реализацию без изменения интерфейса
- Легко добавлять новые пакеты

#### 5. Безопасность
- Storage живёт только на сервере
- Клиент не знает о способах хранения
- Все операции идут через контролируемый API

#### 6. Типизация клиентов (принцип наименьших привилегий)
- Воркер получает `ResourceClient` — не получает `AdminClient`
- Узел в графе получает `ISandboxContext` — не получает `ISandboxRegistry`
- Каждый потребитель видит ровно тот API, который ему необходим

---

## Часть 6. Чек-лист создания нового пакета

При создании нового пакета в экосистеме AQ, следуй этому чек-листу:

### Шаг 1: Определить домены в aq_schema

- [ ] Создать модели с интерфейсами (DirectStorable/VersionedStorable/LoggedStorable)
- [ ] Добавить `kCollection` константу
- [ ] Добавить `fromMap` и `toMap` методы
- [ ] Определить клиентские интерфейсы в соответствующем наборе (`clients.dart`)
- [ ] Экспортировать из соответствующего тематического набора (`graph.dart`, `security.dart`, и т.д.)

### Шаг 2: Создать структуру пакета

- [ ] `lib/client/` — клиентская часть
- [ ] `lib/server/` — серверная часть
- [ ] `lib/my_package.dart` — экспорт клиента
- [ ] `lib/server.dart` — экспорт сервера

### Шаг 3: Реализовать клиента

- [ ] Handshake с сервером (если применимо)
- [ ] Получение сервиса/репозитория
- [ ] Простой API для использования
- [ ] Типизированные клиенты для разных потребителей (User/Resource/Admin/Engine)
- [ ] Реализация интерфейса из `aq_schema/clients.dart`

### Шаг 4: Реализовать сервер

- [ ] Регистрация доменов из aq_schema
- [ ] Storage реализация (только на сервере!)
- [ ] Обработка запросов
- [ ] Handshake endpoint (если применимо)

### Шаг 5: Написать тесты

- [ ] Интеграционные тесты (клиент + сервер)
- [ ] Юнит-тесты для логики
- [ ] Проверка handshake (если применимо)
- [ ] Тесты для каждого типа клиента

### Шаг 6: Документация

- [ ] README с примерами использования
- [ ] Описание API
- [ ] Примеры для клиента и сервера
- [ ] Описание типизированных клиентов

---

## Заключение

`aq_schema` — конституция платформы: общий язык, контракты интерфейсов,
клиентские абстракции. Пакеты реализуют сервисы согласно этим контрактам.
Приложения собирают реализации и регистрируют через `AQPlatform.init()`.
Потребители работают только через `IInterface.instance`.

Эта архитектура позволяет строить масштабируемую экосистему пакетов, где:
- Клиент максимально прост
- Сервер легко расширяется
- Всё тестируется автоматически
- Нет дублирования кода
- Изменения синхронизируются автоматически
- Типизация клиентов обеспечивает принцип наименьших привилегий

**Следуй этим принципам при создании любого нового пакета в AQ экосистеме!**

