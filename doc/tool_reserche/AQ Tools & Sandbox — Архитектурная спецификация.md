# AQ Tools & Sandbox — Архитектурная спецификация

> **Версия:** 1.0  
> **Статус:** DRAFT → REVIEW  
> **Охват:** AQToolService (redesign), AQSandbox (standalone product)  
> Документ описывает архитектурные решения, контракты интерфейсов и стратегию развития.  
> Реализация — отдельные треки разработки.

---

## Оглавление

1. [Ключевые архитектурные решения](#1-ключевые-архитектурные-решения)
2. [AQToolService — переработанная архитектура](#2-aqtoolservice--переработанная-архитектура)
   - [AQToolRegistry — реестр и discovery](#21-aqtoolregistry--реестр-и-discovery)
   - [AQToolRuntime — исполнение и маршрутизация](#22-aqtoolruntime--исполнение-и-маршрутизация)
   - [ToolPackage — единица независимого развития](#23-toolpackage--единица-независимого-развития)
   - [ToolContract и capability negotiation](#24-toolcontract-и-capability-negotiation)
3. [AQSandbox — независимый продукт](#3-aqsandbox--независимый-продукт)
   - [Ценностное предложение](#31-ценностное-предложение)
   - [Пользовательские сценарии](#32-пользовательские-сценарии)
   - [Продуктовые отличия от конкурентов](#33-продуктовые-отличия-от-конкурентов)
4. [Техническая архитектура AQSandbox](#4-техническая-архитектура-aqsandbox)
   - [Уровни изоляции](#41-уровни-изоляции)
   - [Capability-based security](#42-capability-based-security)
   - [Среды выполнения (Runtimes)](#43-среды-выполнения-runtimes)
5. [Интеграция: AQToolRuntime ↔ AQSandbox](#5-интеграция-aqtoolruntime--aqsandbox)
6. [Полные интерфейсы (aq_schema)](#6-полные-интерфейсы-aq_schema)
7. [Пакетная структура](#7-пакетная-структура)
8. [Топологии развёртывания](#8-топологии-развёртывания)
9. [Таблица ответственности](#9-таблица-ответственности)
10. [Дорожная карта](#10-дорожная-карта)

---

## 1. Ключевые архитектурные решения

Прежде чем переходить к деталям — три принципиальных решения, из которых вытекает вся остальная архитектура.

### Решение 1: AQToolService разбивается на Registry + Runtime

**Было:** один объект AQToolService = реестр + маршрутизация + LLM + vault + MCP-адаптер.  
**Стало:** два независимых сервиса с чёткими границами.

`AQToolRegistry` — *кто есть и с каким контрактом*. Отвечает за discovery, версионирование, lifecycle инструментов. Меняется редко.

`AQToolRuntime` — *как доставить вызов*. Маршрутизирует к нужному исполнителю, держит circuit breaker, не знает о бизнес-семантике инструментов.

Это то, как устроены зрелые платформы: npm registry ≠ node.js runtime. VS Code Extension Marketplace ≠ Language Server Protocol. Kubernetes API Server ≠ kubelet.

### Решение 2: Инструмент не видит Sandbox

**Было:** `execute(args, ctx, ISandboxContext? sandbox)` — инструмент знает о существовании sandbox и сам решает работать ли через него.  
**Стало:** инструмент пишет код как обычно через `RunContext`. Sandbox перехватывает I/O на уровне transport, не на уровне API.

Аналогия: процесс в Docker не знает что он в Docker. Он просто делает системные вызовы. Namespaces перехватывают их прозрачно. Именно так работает правильная изоляция.

### Решение 3: AQSandbox — самостоятельный продукт

**Было:** вспомогательная подсистема для управления окружением.  
**Стало:** отдельный продукт с собственной ценностью, собственными пользователями, собственным API. AQToolRuntime использует его как опциональный backend, но sandbox живёт и без AQToolService.

Аналог на рынке: E2B (e2b.dev) — sandboxes for AI agents. Modal.com — serverless compute for ML. AWS SageMaker Studio — managed ML environments. AQSandbox занимает эту нишу в экосистеме AQ.

---

## 2. AQToolService — переработанная архитектура

### 2.1 AQToolRegistry — реестр и discovery

Реестр — это источник истины о том, какие инструменты существуют в системе, какие их версии доступны, и каков их контракт. Он не исполняет инструменты. Он их знает.

```dart
// aq_schema/tools.dart

/// Типизированная ссылка на инструмент с версией
class ToolRef {
  final String name;
  final SemVer version;        // точная версия: "2.1.0"
  final String? range;         // диапазон: ">=2.0.0 <3.0.0"
  final String? namespace;     // "aq/llm-complete", "community/git-tools"

  const ToolRef(this.name, {required this.version, this.range, this.namespace});

  /// Проверить совместимость: удовлетворяет ли конкретная версия диапазону
  bool satisfies(SemVer concrete) { ... }
}

/// Полный контракт инструмента — что он умеет и что ему нужно
class ToolContract {
  final ToolRef ref;
  final String description;                 // для LLM tool-use schema
  final Map<String, dynamic> inputSchema;   // JSON Schema
  final Map<String, dynamic> outputSchema;  // JSON Schema
  final List<ToolCapability> requiredCaps;  // без этих — не работает совсем
  final List<ToolCapability> optionalCaps;  // без этих — работает ограниченно
  final String? deprecatedSince;           // версия с которой устарел
  final ToolRef? replacedBy;               // миграционный путь
  final String? changelogUrl;
}

/// Клиентский интерфейс реестра
abstract interface class IAQToolRegistry {
  static IAQToolRegistry get instance => AQPlatform.resolve();

  /// Найти лучшую совместимую версию для запрошенного диапазона
  Future<ToolContract> resolve(ToolRef ref);

  /// Список всех доступных инструментов
  Future<List<ToolContract>> listAvailable({
    String? namePattern,
    String? namespace,
    bool includeDeprecated = false,
  });

  /// Установить пакет инструментов (hot-install без перезапуска)
  Future<void> install(ToolPackageManifest manifest);

  /// Активировать установленный инструмент
  Future<void> activate(ToolRef ref);

  /// Деактивировать без удаления (graceful — ждёт завершения активных вызовов)
  Future<void> deactivate(ToolRef ref, {Duration gracePeriod = const Duration(seconds: 30)});

  /// Удалить инструмент
  Future<void> uninstall(ToolRef ref);

  /// Подписаться на события lifecycle (install, activate, deactivate, error)
  Stream<ToolLifecycleEvent> get lifecycleEvents;

  /// Проверить здоровье конкретного инструмента
  Future<ToolHealthStatus> checkHealth(ToolRef ref);
}

/// Административный клиент — управление глобальными настройками
abstract interface class IAQToolRegistryAdmin {
  static IAQToolRegistryAdmin get instance => AQPlatform.resolve();

  Future<void> setNamespacePolicy(String namespace, ToolNamespacePolicy policy);
  Future<List<ToolUsageStats>> getUsageStats({DateTime? from, DateTime? to});
  Future<void> blacklist(ToolRef ref, {required String reason});
}
```

**Lifecycle инструмента** (по аналогии с VS Code Extension lifecycle):

```
not installed → installed → activated → deactivated → uninstalled
                               ↑_____________↓
```

Переход `activated → deactivated` не прерывает уже выполняющиеся вызовы — они доживают до конца. Новые вызовы в `deactivating` инструмент не принимает.

---

### 2.2 AQToolRuntime — исполнение и маршрутизация

Runtime знает как доставить вызов к нужному исполнителю. Он не знает бизнес-семантику инструментов. Он знает протоколы.

```dart
// aq_schema/tools.dart

abstract interface class IAQToolRuntime {
  static IAQToolRuntime get instance => AQPlatform.resolve();

  /// Вызвать инструмент по ссылке
  Future<ToolResult> call(
    ToolRef ref,
    Map<String, dynamic> args,
    RunContext context,
  );

  /// Потоковый вызов (для инструментов с long-running output)
  Stream<ToolResultChunk> callStream(
    ToolRef ref,
    Map<String, dynamic> args,
    RunContext context,
  );

  /// Проверить что инструмент технически доступен для вызова
  Future<bool> isCallable(ToolRef ref);

  /// Статус circuit breaker для инструмента
  Future<CircuitBreakerStatus> getCircuitStatus(ToolRef ref);
}

/// Результат вызова
class ToolResult {
  final bool success;
  final dynamic output;
  final String? error;
  final ToolResultMeta meta;
}

class ToolResultMeta {
  final Duration elapsed;
  final ToolRef resolvedRef;    // фактическая версия которая выполнила
  final String executorType;    // "local", "mcp", "grpc", "http"
  final String? sandboxId;      // если выполнялось в sandbox
}
```

**Типы исполнителей** (за интерфейсом `IAQToolExecutor`):

| Тип | Протокол | Когда использовать |
|---|---|---|
| `LocalExecutor` | Dart function call | Инструменты встроенные в воркер |
| `McpExecutor` | MCP JSON-RPC (stdio/http) | Сторонние MCP-серверы |
| `GrpcExecutor` | gRPC streaming | Производительные remote tools |
| `HttpExecutor` | REST/SSE | Простые webhook-инструменты |
| `SandboxExecutor` | Через ISandboxProvider | Изолированное выполнение кода |
| `MockExecutor` | In-memory | Тесты |

**Circuit breaker** встроен в runtime — при N последовательных ошибках инструмент переходит в `OPEN` состояние и вызовы отклоняются немедленно с `ToolCircuitOpenException`. После recovery timeout переходит в `HALF_OPEN` и пробует один вызов.

```dart
abstract interface class IAQToolRuntimeAdmin {
  Future<void> resetCircuit(ToolRef ref);
  Future<void> setCircuitPolicy(ToolRef ref, CircuitBreakerPolicy policy);
  Future<List<ToolMetrics>> getMetrics({String? namePattern});
}
```

---

### 2.3 ToolPackage — единица независимого развития

Это ключевая концепция для достижения модульности. Инструмент — не класс, зарегистрированный в Builder. Инструмент — это **пакет** с манифестом, который можно установить, обновить, откатить независимо от движка и остальных инструментов.

```yaml
# aq_tool_package.yaml — манифест пакета инструментов

name: aq-tools-llm
version: 2.1.0
description: "LLM completion and embedding tools for AQ platform"
author: "AQ Team"
min_engine_version: ">=3.0.0"    # минимальная версия движка
min_runtime_version: ">=1.2.0"   # минимальная версия AQToolRuntime

tools:
  - name: llm_complete
    version: 2.0.0
    namespace: aq/llm
    replaces: "llm_complete@1.x"              # миграционный путь
    deprecated_since: null
    entry: lib/tools/llm_complete_v2.dart
    capabilities:                              # декларация возможностей
      required:
        - NET_OUT:api.anthropic.com
        - NET_OUT:api.openai.com
      optional:
        - NET_OUT:*                            # для кастомных endpoint
    timeout: 120s
    retry_policy:
      max_attempts: 3
      backoff: exponential

  - name: llm_complete
    version: 1.9.5                            # СТАРАЯ версия живёт параллельно
    namespace: aq/llm
    deprecated_since: "2025-06-01"
    replaced_by: "aq/llm/llm_complete@2.0.0"
    entry: lib/tools/llm_complete_v1.dart
    capabilities:
      required:
        - NET_OUT:api.anthropic.com

  - name: llm_embed
    version: 1.3.0
    namespace: aq/llm
    entry: lib/tools/llm_embed.dart
    capabilities:
      required:
        - NET_OUT:api.openai.com
        - NET_OUT:api.voyageai.com
```

**Сценарий: старый граф работает на v1, новый граф подключается к v2:**

```dart
// Граф созданный год назад — движок объявляет нужную версию
final ref1 = ToolRef('llm_complete',
  namespace: 'aq/llm',
  range: '>=1.0.0 <2.0.0',  // хочет v1.x
);

// Новый граф — хочет v2
final ref2 = ToolRef('llm_complete',
  namespace: 'aq/llm',
  range: '^2.0.0',           // хочет v2.x
);

// Registry разрешает обе ссылки независимо
// Обе версии работают параллельно на одном воркере
final contract1 = await IAQToolRegistry.instance.resolve(ref1); // → 1.9.5
final contract2 = await IAQToolRegistry.instance.resolve(ref2); // → 2.0.0
```

---

### 2.4 ToolContract и capability negotiation

Вместо `requiresSandbox: bool` — декларативная модель возможностей. Вдохновение: Android permissions, Deno `--allow-net`, WASM Component Model.

```dart
/// Базовый тип capability — что инструмент хочет делать
sealed class ToolCapability {
  const ToolCapability();
}

/// Сетевой доступ (outbound)
class NetOutCap extends ToolCapability {
  final String hostPattern;  // "api.anthropic.com", "*.github.com", "*"
  final int? port;
  const NetOutCap(this.hostPattern, {this.port});
}

/// Чтение файловой системы
class FsReadCap extends ToolCapability {
  final String pathPattern;  // "/work/**", "/tmp/aq/${runId}/**"
  const FsReadCap(this.pathPattern);
}

/// Запись файловой системы
class FsWriteCap extends ToolCapability {
  final String pathPattern;
  const FsWriteCap(this.pathPattern);
}

/// Запуск процессов
class ProcSpawnCap extends ToolCapability {
  final List<String> allowedBinaries;  // ["python3", "git", "node"]
  final bool allowShell;               // false = нельзя /bin/sh
  const ProcSpawnCap(this.allowedBinaries, {this.allowShell = false});
}

/// Доступ к Docker daemon
class DockerCap extends ToolCapability {
  final List<String> allowedImages;  // whitelist образов
  const DockerCap(this.allowedImages);
}

/// Переменные окружения (чтение)
class EnvReadCap extends ToolCapability {
  final List<String> allowedKeys;  // ["API_KEY", "MODEL_NAME"]
  const EnvReadCap(this.allowedKeys);
}
```

**Переговоры о возможностях при запуске run:**

```dart
// RunContext формируется на основе пересечения:
// - что инструмент запросил (contract.requiredCaps + optionalCaps)
// - что политика sandbox разрешила
// - что security сервис подтвердил

final grantedCaps = await IAQSandboxProvider.instance.negotiateCaps(
  requested: contract.requiredCaps + contract.optionalCaps,
  policy: sandboxPolicy,
  context: runContext,
);

// RunContext содержит только то, что фактически предоставлено
final ctx = RunContext.withGrants(
  runId: run.id,
  grantedCaps: grantedCaps,
  // ...
);
```

**Инструмент работает через RunContext, не подозревая о sandbox:**

```dart
class PythonExecTool implements IAQToolExecutor {
  @override
  Future<ToolResult> execute(Map<String, dynamic> args, RunContext ctx) async {
    // ctx.fs — доступен только если FsWriteCap был granted
    // ctx.proc — доступен только если ProcSpawnCap был granted
    // Если нет — выбрасывает CapabilityDeniedException на попытке использования

    await ctx.fs.write('script.py', args['script'].toString());
    final result = await ctx.proc.run('python3', ['script.py']);
    return ToolResult.success(result.stdout);
  }
}

// ctx.fs.write() → под капотом → sandbox перехватывает → пишет в изолированную директорию
// ctx.proc.run() → под капотом → sandbox запускает в контейнере с ограничениями
// Инструмент не знает об этом. Он просто использует ctx.fs и ctx.proc.
```

---

## 3. AQSandbox — независимый продукт

### 3.1 Ценностное предложение

**AQSandbox — это управляемые изолированные среды для разработки и запуска ИИ-агентов, инструментов и рабочих процессов.**

Если вы строите ИИ-агентов или LLM-приложения, вам рано или поздно нужно дать агенту возможность что-то делать: выполнять код, читать файлы, вызывать инструменты, запускать браузер. AQSandbox решает проблему "где и как это делать безопасно".

**Ключевые тезисы:**

— **Для разработчиков ИИ:** создай изолированную среду, подключи LLM или агента, дай ему инструменты и смотри что происходит. Никакой настройки инфраструктуры — sandbox готов за секунды.

— **Для команд:** общие среды, версионированные конфигурации, воспроизводимые эксперименты. Один `sandbox.yaml` — и весь отдел работает в идентичном окружении.

— **Для продакшна:** запуск агентских воркфлоу в изолированных контейнерах с гарантиями: лимиты ресурсов, сетевая политика, audit log каждого действия.

— **Для экспериментов:** полигоны (test polygons) — изолированные среды для тестирования новых LLM-моделей, промптов, цепочек агентов без риска сломать прод.

---

### 3.2 Пользовательские сценарии

**Сценарий A: Разработчик, который строит кодовый агента**

Максим строит агента который анализирует репозиторий и предлагает рефакторинг. Агент должен: читать файлы, запускать линтер, выполнять тесты, коммитить изменения.

Без AQSandbox: Максим настраивает Docker вручную, пишет скрипты изоляции, беспокоится о том что агент не запустит `rm -rf`. Занимает дни.

С AQSandbox:
```yaml
# sandbox.yaml
name: code-agent-env
runtime: docker
image: aq-dart:3.4
capabilities:
  fs: read-write:/workspace
  proc: [dart, git, dart pub]
  net: none
mounts:
  - source: vault://projects/my-project
    target: /workspace
    mode: read-write
```

```dart
final sandbox = await AQSandbox.create('sandbox.yaml');
final agent = CodeRefactorAgent(llm: claude, tools: sandbox.tools);
await agent.run();
// Агент работает в изоляции, Максим видит всё через dashboard
```

**Сценарий B: Команда, которая тестирует новую LLM-модель**

ML-команда хочет сравнить GPT-4o и Claude на одном и том же наборе задач, с одними и теми же инструментами.

```dart
// Создать два идентичных sandbox с разными LLM
final sandboxA = await AQSandbox.create(
  'eval-env.yaml',
  overrides: {'llm': LlmConfig.anthropic('claude-opus-4')},
);
final sandboxB = await AQSandbox.create(
  'eval-env.yaml',
  overrides: {'llm': LlmConfig.openai('gpt-4o')},
);

// Запустить один и тот же граф в обоих sandbox параллельно
final [resultA, resultB] = await Future.wait([
  runWorkflow(graph, sandbox: sandboxA),
  runWorkflow(graph, sandbox: sandboxB),
]);

// Сравнить результаты — качество, стоимость, latency
```

**Сценарий C: Полигон (Test Polygon)**

Продуктовая команда хочет развернуть "полигон" — изолированную копию прод-среды для тестирования агентских воркфлоу перед релизом.

```dart
// Polygon = sandbox с полным набором сервисов прод-среды, но изолированный
final polygon = await AQSandbox.createPolygon(
  baseConfig: 'production.yaml',
  overrides: {
    'db': DbConfig.postgres(seed: 'test-fixtures-v2'),
    'external_apis': ApiConfig.mocked(),  // моки вместо реальных API
    'llm': LlmConfig.anthropic('claude-haiku-4'),  // дешевле для тестов
  },
);

// Запустить regression suite
await polygon.runSuite(regressionTests);
await polygon.dispose();  // всё чисто, никаких следов
```

**Сценарий D: SaaS — пользователи создают свои sandbox**

Если AQSandbox разворачивается как платформа, конечные пользователи могут:
- Создавать свои sandbox через UI
- Выбирать runtime (Docker, VM, WASM)
- Подключать LLM провайдеров (ключи хранятся зашифрованными)
- Подключать агентов и ассистентов
- Публиковать созданные инструменты как пакеты
- Видеть audit log: что агент делал, какие файлы трогал, какие API вызывал

---

### 3.3 Продуктовые отличия от конкурентов

| | E2B | Modal | AWS SageMaker | **AQSandbox** |
|---|---|---|---|---|
| Фокус | Code execution для агентов | Serverless ML compute | Managed ML notebooks | Среды для агентов + AQ инструменты |
| Интеграция с AQ | ❌ | ❌ | ❌ | ✅ нативная |
| Кастомные инструменты | Через SDK | Через Python | ❌ | ✅ ToolPackage |
| Граф-воркфлоу | ❌ | ❌ | ❌ | ✅ AQ Graph Engine |
| Self-hosted | ✅ | ❌ | ❌ | ✅ |
| WASM runtime | ❌ | ❌ | ❌ | ✅ (edge/browser) |
| Audit log | Базовый | ❌ | ✅ | ✅ с capability trace |
| Polígon mode | ❌ | ❌ | ❌ | ✅ |

**Главное отличие:** AQSandbox — это не просто "запусти Python код". Это управляемая среда для всего стека AQ: граф + инструменты + LLM + vault + агенты. Пользователь создаёт среду, конфигурирует её как хочет, и получает полноценный изолированный AQ-рабочий процесс.

---

## 4. Техническая архитектура AQSandbox

### 4.1 Уровни изоляции

Sandbox — это не одна технология. Это слоёная система, где каждый уровень добавляет свой тип изоляции:

```
┌─────────────────────────────────────────────────────┐
│  Уровень 4: Policy Layer                            │
│  CapabilityPolicy, NetworkPolicy, ResourceBudget    │
│  Что разрешено делать? Кто это проверяет?           │
├─────────────────────────────────────────────────────┤
│  Уровень 3: Runtime Layer                           │
│  InMemory | LocalFs | Docker | VM | WASM            │
│  Где это физически выполняется?                     │
├─────────────────────────────────────────────────────┤
│  Уровень 2: Resource Layer                          │
│  Volumes, Network interfaces, Env vars              │
│  С чем работает инструмент?                         │
├─────────────────────────────────────────────────────┤
│  Уровень 1: Identity Layer                          │
│  SandboxId, RunId, TenantId                         │
│  Кто это и чьё это?                                │
└─────────────────────────────────────────────────────┘
```

Инструмент взаимодействует только с уровнями 1 и 2 через `RunContext`. Уровни 3 и 4 — внутренняя ответственность AQSandbox.

---

### 4.2 Capability-based security

Это центральная идея безопасной изоляции. Вдохновение: seL4 microkernel capabilities, Deno permissions, WASM Component Model, Android permissions.

**Принцип:** инструмент не может сделать то, чего нет в его `grantedCaps`. Не "мы запрещаем", а "мы не выдаём возможность". Синтаксически недостижимо, а не просто запрещено.

```dart
// RunContext — это набор granted capabilities, не полный API
class RunContext {
  final String runId;
  final String sandboxId;

  // Доступно только если FsReadCap + FsWriteCap были granted
  final IFsContext? fs;

  // Доступно только если NetOutCap был granted
  final INetContext? net;

  // Доступно только если ProcSpawnCap был granted
  final IProcContext? proc;

  // Доступно только если DockerCap был granted
  final IDockerContext? docker;

  // Переменные окружения — только разрешённые ключи
  final IEnvContext env;

  // Vault доступ — всегда через IAQVaultService, не через FS
  final IAQVaultContext vault;

  // Попытка использовать null-контекст → CapabilityDeniedException
  // Инструмент видит это немедленно, не после выполнения
}
```

**Пример: инструмент пытается сделать запрещённое:**

```dart
// Инструмент объявил только FsReadCap в манифесте
// proc.run() → ctx.proc == null → бросает CapabilityDeniedException
// Это происходит до любого реального syscall

try {
  await ctx.proc!.run('curl', ['https://attacker.com']); // NPE или explicit check
} on CapabilityDeniedException catch (e) {
  // "ProcSpawnCap not granted for this run"
  // Runtime логирует попытку превысить полномочия → audit log
}
```

**IFsContext — не raw File API:**

```dart
abstract interface class IFsContext {
  /// Путь всегда relative к workDir — выход за пределы невозможен
  Future<String> read(String relativePath);
  Future<void> write(String relativePath, String content);
  Future<void> writeBytes(String relativePath, List<int> bytes);
  Future<List<String>> list({String? subDir});
  Future<bool> exists(String relativePath);
  Future<void> delete(String relativePath);

  // Абсолютных путей нет. /etc/passwd недостижим синтаксически.
  // sandbox.workDir() — internal, инструмент его не видит.
}
```

**IProcContext — не exec(String):**

```dart
abstract interface class IProcContext {
  /// Только бинари из allowedBinaries в манифесте
  Future<ProcResult> run(
    String binary,        // проверяется против whitelist при вызове
    List<String> args,
    {
      String? workingSubDir,  // subdir внутри workDir
      Duration? timeout,
      Map<String, String>? extraEnv,  // только non-secret vars
    }
  );

  // exec(String command) — отсутствует. Shell injection невозможен.
  // Нет PATH traversal: "../../usr/bin/python" → rejected
}
```

---

### 4.3 Среды выполнения (Runtimes)

```dart
/// Тип среды выполнения
enum SandboxRuntimeType {
  inMemory,  // только RAM, нет FS, нет proc
  localFs,   // изолированная директория на хосте
  docker,    // Docker контейнер (требует Docker daemon)
  vm,        // MicroVM (firecracker / kata containers)
  wasm,      // WebAssembly runtime
}
```

#### InMemoryRuntime

Нет реальных ресурсов. Только `env` и `vault`. Подходит для LLM-инструментов, HTTP-инструментов, vault-операций. Самый лёгкий и быстрый.

```
Startup: < 1ms
Isolation: логическая (namespace только)
Overhead: ~0
Подходит для: llm_complete, vault_read, http_request
```

#### LocalFsRuntime

Изолированная директория `/var/aq/sandboxes/{sandboxId}/`. `FsContext` работает только внутри неё. `ProcContext` запускает процессы с `cgroup`-ограничениями.

```
Startup: ~10ms
Isolation: файловая (chroot-like) + cgroups
Overhead: минимальный
Подходит для: git_commit, file_transform, code_format
```

#### DockerRuntime

Отдельный Docker-контейнер на каждый sandbox. Полная изоляция: сеть, PID, IPC namespaces. Volumes монтируются из vault.

```
Startup: 2–5s (cold), 200ms (warm pool)
Isolation: контейнерная (все namespaces)
Overhead: ~50MB RAM на контейнер
Подходит для: python_exec, node_exec, browser_automation, db_migrate
```

**Warm pool:** AQSandboxServer держит пул "прогретых" контейнеров. При запросе нового sandbox берётся из пула (200ms startup вместо 5s), настраивается под конкретный run и возвращается в пул после dispose.

#### VmRuntime (Firecracker)

Лёгкие MicroVM через Firecracker (AWS Lambda под капотом использует именно это). Изоляция на уровне ядра — самая сильная.

```
Startup: 125–150ms (Firecracker умеет быстро)
Isolation: полная (отдельное ядро, гипервизор)
Overhead: ~5MB RAM (Firecracker overhead)
Подходит для: критичные задачи, untrusted code, multi-tenant
```

#### WasmRuntime

WebAssembly через `wasmtime` (server) или browser-native (client). Инструменты компилируются в WASM-компонент. Работает везде — на сервере, в браузере, на edge.

```
Startup: ~1ms (инициализация модуля)
Isolation: WASM component model (capability-based by design)
Overhead: зависит от модуля
Подходит для: edge, browser, untrusted plugins, cross-platform tools
```

---

## 5. Интеграция: AQToolRuntime ↔ AQSandbox

Sandbox — опциональный backend для Runtime. Runtime не обязан знать о конкретном типе sandbox. Он общается с sandbox через `ISandboxProvider`.

```dart
// aq_schema/tools.dart — интерфейс провайдера

abstract interface class ISandboxProvider {
  static ISandboxProvider? get instance => AQPlatform.tryResolve();
  // null если sandbox не подключён — инструменты работают без изоляции

  /// Создать sandbox для run
  Future<ISandboxHandle> create(SandboxSpec spec);

  /// Получить существующий (для resume после suspend)
  Future<ISandboxHandle?> get(String sandboxId);

  /// Список доступных runtime типов
  Future<List<SandboxRuntimeType>> availableRuntimes();
}

abstract interface class ISandboxHandle {
  String get sandboxId;
  SandboxRuntimeType get runtimeType;
  SandboxStatus get status;

  /// Создать RunContext с granted capabilities
  Future<RunContext> createContext({
    required List<ToolCapability> requestedCaps,
    required SandboxPolicy policy,
    required String runId,
  });

  Future<void> suspend();
  Future<void> resume();
  Future<void> dispose({bool saveArtifacts = true});
}
```

**Как Runtime решает: использовать sandbox или нет:**

```dart
// Внутри AQToolRuntime.call()

Future<ToolResult> call(ToolRef ref, args, context) async {
  final contract = await registry.resolve(ref);
  final executor = await executorFactory.build(ref);

  RunContext ctx;
  ISandboxHandle? sandboxHandle;

  // Нужен ли sandbox?
  final needsSandbox = _requiresSandbox(contract, context);

  if (needsSandbox) {
    final provider = ISandboxProvider.instance;
    if (provider == null) {
      throw SandboxRequiredException(
        'Tool ${ref.name} requires sandbox but no ISandboxProvider registered',
      );
    }
    sandboxHandle = await provider.create(
      SandboxSpec.fromContract(contract, context.sandboxPolicy),
    );
    ctx = await sandboxHandle.createContext(
      requestedCaps: contract.requiredCaps + contract.optionalCaps,
      policy: context.sandboxPolicy,
      runId: context.runId,
    );
  } else {
    ctx = RunContext.minimal(context);
  }

  try {
    return await _withCircuitBreaker(ref, () => executor.execute(args, ctx));
  } finally {
    await sandboxHandle?.dispose();
  }
}

bool _requiresSandbox(ToolContract contract, EngineContext ctx) {
  // Требует sandbox если:
  // 1. Контракт содержит ProcSpawnCap, DockerCap, или FsWriteCap вне vault
  // 2. Политика engine требует sandbox для всех инструментов
  // 3. Политика sandbox определена явно в RunConfig
  return contract.requiredCaps.any((c) =>
    c is ProcSpawnCap || c is DockerCap ||
    (c is FsWriteCap && !c.pathPattern.startsWith('vault://'))
  ) || ctx.sandboxPolicy?.forceAll == true;
}
```

**SandboxSpec — декларация нужной среды:**

```dart
class SandboxSpec {
  final SandboxRuntimeType preferredRuntime;   // docker, vm, etc.
  final SandboxRuntimeType? fallbackRuntime;   // если предпочтительный недоступен
  final List<SandboxMount> mounts;             // что монтировать
  final SandboxResourceBudget budget;          // RAM, CPU, time
  final SandboxNetworkPolicy networkPolicy;    // whitelist хостов
  final SandboxDisposalSpec disposal;          // что делать по завершении

  factory SandboxSpec.fromContract(ToolContract contract, SandboxPolicy? policy) {
    return SandboxSpec(
      preferredRuntime: _runtimeForCaps(contract.requiredCaps),
      budget: policy?.budget ?? SandboxResourceBudget.defaults(),
      // ...
    );
  }

  static SandboxRuntimeType _runtimeForCaps(List<ToolCapability> caps) {
    if (caps.any((c) => c is DockerCap)) return SandboxRuntimeType.docker;
    if (caps.any((c) => c is ProcSpawnCap)) return SandboxRuntimeType.localFs;
    if (caps.any((c) => c is FsWriteCap)) return SandboxRuntimeType.localFs;
    return SandboxRuntimeType.inMemory;
  }
}
```

---

## 6. Полные интерфейсы (aq_schema)

### 6.1 Barrel файлы

```dart
// aq_schema/tools.dart — набор для работы с инструментами
export 'src/tools/tool_ref.dart';
export 'src/tools/tool_contract.dart';
export 'src/tools/tool_capability.dart';
export 'src/tools/tool_result.dart';
export 'src/tools/tool_package_manifest.dart';
export 'src/tools/i_aq_tool_registry.dart';
export 'src/tools/i_aq_tool_runtime.dart';
export 'src/tools/i_aq_tool_executor.dart';

// aq_schema/sandbox.dart — набор для sandbox
export 'src/sandbox/sandbox_spec.dart';
export 'src/sandbox/sandbox_policy.dart';
export 'src/sandbox/sandbox_capabilities.dart';
export 'src/sandbox/sandbox_resource_budget.dart';
export 'src/sandbox/run_context.dart';
export 'src/sandbox/i_fs_context.dart';
export 'src/sandbox/i_proc_context.dart';
export 'src/sandbox/i_net_context.dart';
export 'src/sandbox/i_docker_context.dart';
export 'src/sandbox/i_sandbox_provider.dart';
export 'src/sandbox/i_sandbox_handle.dart';
export 'src/sandbox/i_aq_sandbox_client.dart';         // для движка
export 'src/sandbox/i_aq_sandbox_admin_client.dart';   // для администраторов
export 'src/sandbox/fallback_sandbox.dart';            // unrestricted, для тестов
```

### 6.2 Ключевые интерфейсы sandbox

```dart
// i_aq_sandbox_client.dart — что видит движок/воркер

abstract interface class IAQSandboxClient {
  static IAQSandboxClient get instance => AQPlatform.resolve();

  /// Создать sandbox
  Future<ISandboxHandle> create(SandboxSpec spec, {String? name});

  /// Получить существующий sandbox (для resume run)
  Future<ISandboxHandle?> get(String sandboxId);

  /// Список активных sandbox для tenant/project
  Future<List<SandboxInfo>> listActive({
    String? projectId,
    String? runId,
  });

  /// Поток событий всех sandbox (status changes, violations, etc.)
  Stream<SandboxEvent> get events;
}

// i_aq_sandbox_admin_client.dart — административные операции

abstract interface class IAQSandboxAdminClient {
  static IAQSandboxAdminClient get instance => AQPlatform.resolve();

  /// Все sandbox в системе
  Future<List<SandboxInfo>> listAll({
    SandboxStatus? status,
    String? tenantId,
    DateTime? createdAfter,
  });

  /// Принудительное завершение
  Future<void> forceKill(String sandboxId, {required String reason});

  /// Текущее потребление ресурсов (для мониторинга)
  Future<SandboxResourceUsage> getClusterUsage();

  /// Квоты для tenant
  Future<SandboxQuota> getQuota(String tenantId);
  Future<void> setQuota(String tenantId, SandboxQuota quota);

  /// Полный audit log
  Stream<SandboxAuditEvent> auditLog({
    String? sandboxId,
    String? tenantId,
    DateTime? from,
    DateTime? to,
    AuditEventType? type,
  });

  /// Настройка warm pool
  Future<void> configureWarmPool(WarmPoolConfig config);
}
```

### 6.3 SandboxPolicy — конфигурация поведения

```dart
class SandboxPolicy {
  /// Принудительно использовать sandbox для всех инструментов
  final bool forceAll;

  /// Предпочтительный runtime
  final SandboxRuntimeType? preferredRuntime;

  /// Лимиты ресурсов
  final SandboxResourceBudget budget;

  /// Сетевая политика
  final SandboxNetworkPolicy network;

  /// Что делать с рабочей директорией после завершения
  final SandboxDisposalSpec disposal;

  /// Политика повторных попыток при sandbox failure
  final SandboxRetryPolicy retry;

  /// Фабричные методы для типовых сценариев
  factory SandboxPolicy.strict() => SandboxPolicy(
    forceAll: true,
    preferredRuntime: SandboxRuntimeType.docker,
    budget: SandboxResourceBudget(
      maxMemoryMb: 512,
      maxCpuPercent: 50,
      maxExecutionTime: Duration(minutes: 10),
      maxDiskMb: 1024,
    ),
    network: SandboxNetworkPolicy.none(),
    disposal: SandboxDisposalSpec.cleanAlways(),
  );

  factory SandboxPolicy.development() => SandboxPolicy(
    forceAll: false,
    preferredRuntime: SandboxRuntimeType.localFs,
    budget: SandboxResourceBudget.generous(),
    network: SandboxNetworkPolicy.all(),
    disposal: SandboxDisposalSpec.keepOnError(),  // для debugging
  );

  factory SandboxPolicy.polygon({required String polygonId}) => SandboxPolicy(
    forceAll: true,
    preferredRuntime: SandboxRuntimeType.docker,
    budget: SandboxResourceBudget.production(),
    network: SandboxNetworkPolicy.mockedExternals(polygonId),
    disposal: SandboxDisposalSpec.saveArtifacts(
      vaultDestination: 'polygons/$polygonId',
    ),
  );
}
```

---

## 7. Пакетная структура

```
pkgs/
├── aq_schema/                           ← единственный источник истины
│   └── lib/
│       ├── tools.dart                   ← ToolRef, ToolContract, capability types,
│       │                                   IAQToolRegistry, IAQToolRuntime
│       ├── sandbox.dart                 ← ISandboxProvider, ISandboxHandle,
│       │                                   RunContext, IFsContext, IProcContext,
│       │                                   SandboxPolicy, SandboxSpec
│       └── clients.dart                 ← IAQToolRegistry.instance,
│                                           IAQSandboxClient.instance

├── aq_tool_registry/                    ← реализация реестра инструментов
│   ├── lib/
│   │   ├── aq_tool_registry.dart        ← клиентский экспорт
│   │   ├── client/
│   │   │   └── registry_client.dart     ← IAQToolRegistry impl
│   │   └── server.dart                  ← серверный экспорт
│   └── lib_server/
│       ├── registry_server.dart         ← HTTP/gRPC сервер реестра
│       ├── store/
│       │   ├── postgres_tool_store.dart ← хранилище манифестов
│       │   └── in_memory_tool_store.dart ← для тестов
│       └── resolver/
│           └── semver_resolver.dart     ← разрешение версий

├── aq_tool_runtime/                     ← исполнение инструментов
│   ├── lib/
│   │   ├── aq_tool_runtime.dart         ← клиентский экспорт
│   │   ├── client/
│   │   │   └── runtime_client.dart      ← IAQToolRuntime impl
│   │   └── executors/
│   │       ├── local_executor.dart      ← Dart function call
│   │       ├── mcp_executor.dart        ← MCP JSON-RPC
│   │       ├── grpc_executor.dart       ← gRPC streaming
│   │       ├── http_executor.dart       ← REST/SSE
│   │       └── sandbox_executor.dart    ← через ISandboxProvider
│   └── lib_server/
│       ├── circuit_breaker.dart
│       └── metrics_collector.dart

├── aq_sandbox/                          ← AQSandbox — самостоятельный продукт
│   ├── lib/
│   │   ├── aq_sandbox.dart              ← публичный клиентский API
│   │   ├── client/
│   │   │   ├── sandbox_client.dart      ← IAQSandboxClient impl
│   │   │   └── sandbox_admin_client.dart
│   │   └── server.dart                  ← серверный экспорт
│   ├── lib_server/
│   │   ├── sandbox_server.dart          ← точка входа сервера
│   │   ├── runtimes/
│   │   │   ├── in_memory_runtime.dart
│   │   │   ├── local_fs_runtime.dart
│   │   │   ├── docker_runtime.dart      ← требует Docker daemon
│   │   │   ├── firecracker_runtime.dart ← требует KVM
│   │   │   └── wasm_runtime.dart        ← wasmtime
│   │   ├── policy/
│   │   │   ├── capability_enforcer.dart ← проверка capabilities при каждом вызове
│   │   │   └── resource_monitor.dart    ← мониторинг CPU/RAM, kill при нарушении
│   │   ├── warm_pool/
│   │   │   └── container_pool.dart      ← пул прогретых контейнеров
│   │   ├── audit/
│   │   │   └── audit_logger.dart        ← лог каждого capability-вызова
│   │   └── security/
│   │       └── security_hook.dart       ← интеграция с IAQSecurityClient
│   └── pubspec.yaml

└── aq_tools_llm/                        ← пример ToolPackage — LLM инструменты
    ├── aq_tool_package.yaml             ← манифест пакета
    ├── lib/
    │   └── tools/
    │       ├── llm_complete_v2.dart     ← IAQToolExecutor (новая версия)
    │       ├── llm_complete_v1.dart     ← IAQToolExecutor (старая, deprecated)
    │       └── llm_embed.dart
    └── pubspec.yaml
```

**Что у `aq_sandbox` есть сервер, а у `aq_tool_runtime` нет:**

`aq_tool_runtime` — stateless маршрутизатор. Он не держит состояние, не владеет процессами. Он может работать как библиотека внутри воркера. Серверная часть не нужна.

`aq_sandbox` — stateful менеджер окружений. Он создаёт и держит контейнеры, мониторит их, управляет пулом. Это требует долгоживущего сервера. Поэтому у него есть `lib_server/`.

---

## 8. Топологии развёртывания

### Топология A: Embedded (desktop / local dev)

Всё в одном процессе. Sandbox = LocalFsRuntime. Подходит для AQ Studio Desktop.

```
[Flutter App]
     │
[AQ Graph Engine]
     │
[AQToolRuntime] ←→ [Local Dart Tools]
     │
[ISandboxProvider = LocalFsSandboxProvider]
     (работает in-process, создаёт /tmp/aq/... директории)
```

### Топология B: Distributed (production server)

```
[Flutter Web / CLI]
     │ HTTPS
[API Gateway + Auth]
     │
[Graph Service]         [Tool Registry Service]
     │                       │ (хранит манифесты инструментов)
[AQToolRuntime]  ────────────┘
     │
[AQSandbox Service]     ← отдельный процесс с Docker daemon
     │
[Docker daemon]
[Warm pool: N containers]
```

### Топология C: AQSandbox as SaaS

```
[User Browser]
     │ HTTPS
[AQSandbox Platform API]
     │
[Tenant Manager]  ─────── [Quota Service]
     │
[Sandbox Scheduler]
     ├── [VM Fleet: Firecracker VMs]
     ├── [Docker Fleet: Containers]
     └── [WASM Workers: Edge nodes]
          │
     [Audit Log Store]
     [Metrics Store]
```

### Топология D: Polygon развёртывание

```
[CI/CD Pipeline]
     │ создаёт Polygon
[AQSandbox.createPolygon(config)]
     │
[Polygon = изолированный namespace]
     ├── [Mock External APIs]
     ├── [Seeded Test DB]
     ├── [AQ Graph Engine]
     └── [Tool Runtime с тестовым LLM]
     │
[Regression Suite Runner]
     │ после завершения
[Polygon.dispose()]  → всё удаляется, artifacts → vault
```

---

## 9. Таблица ответственности

| Ответственность | Engine | ToolRegistry | ToolRuntime | AQSandbox | Security |
|---|:---:|:---:|:---:|:---:|:---:|
| Порядок выполнения узлов | ✅ | ❌ | ❌ | ❌ | ❌ |
| Suspend / Resume run | ✅ | ❌ | ❌ | ✅ среда | ❌ |
| Реестр инструментов и версии | ❌ | ✅ | ❌ | ❌ | ❌ |
| Hot-install инструментов | ❌ | ✅ | ❌ | ❌ | ❌ |
| Semver resolution | ❌ | ✅ | ❌ | ❌ | ❌ |
| Маршрутизация к исполнителю | ❌ | ❌ | ✅ | ❌ | ❌ |
| MCP / gRPC / HTTP адаптеры | ❌ | ❌ | ✅ | ❌ | ❌ |
| Circuit breaker | ❌ | ❌ | ✅ | ❌ | ❌ |
| Создание изолированного окружения | ❌ | ❌ | ❌ | ✅ | ❌ |
| Управление warm pool | ❌ | ❌ | ❌ | ✅ | ❌ |
| Capability enforcement | ❌ | ❌ | ❌ | ✅ | hook |
| Мониторинг ресурсов + auto-kill | ❌ | ❌ | ❌ | ✅ | ❌ |
| Очистка после run | ❌ | ❌ | ❌ | ✅ | ❌ |
| Audit log capability вызовов | ❌ | ❌ | ❌ | ✅ | ❌ |
| Audit log безопасности | ❌ | ❌ | ❌ | ❌ | ✅ |
| Проверка прав пользователя | ❌ | ❌ | ❌ | hook | ✅ |
| Rate limiting (бизнес) | ❌ | ❌ | ❌ | ❌ | ✅ |

---

## 10. Дорожная карта

### Фаза 1 — Фундамент (aq_schema изменения)

- [ ] Добавить `ToolRef`, `SemVer`, `ToolContract` в `aq_schema/tools.dart`
- [ ] Добавить `ToolCapability` sealed class с базовыми типами
- [ ] Добавить `RunContext` с nullable capability contexts
- [ ] Добавить `ISandboxProvider`, `ISandboxHandle` в `aq_schema/sandbox.dart`
- [ ] Добавить `IAQToolRegistry`, `IAQToolRuntime` в `aq_schema/clients.dart`
- [ ] `FallbackSandbox` — unrestricted реализация для тестов

### Фаза 2 — AQToolRegistry

- [ ] `aq_tool_registry` пакет: клиент + серверная часть
- [ ] `InMemoryToolStore` — для тестов и embedded режима
- [ ] `PostgresToolStore` — для production
- [ ] `SemverResolver` — разрешение версий
- [ ] HTTP API реестра
- [ ] `aq_tool_package.yaml` парсер и валидатор

### Фаза 3 — AQToolRuntime

- [ ] `aq_tool_runtime` пакет
- [ ] `LocalExecutor`, `McpExecutor`, `HttpExecutor`
- [ ] `CircuitBreaker` с настраиваемой политикой
- [ ] `SandboxExecutor` — интеграция с `ISandboxProvider`
- [ ] Метрики (calls/s, error rate, latency percentiles)

### Фаза 4 — AQSandbox (базовые runtime)

- [ ] `aq_sandbox` пакет: клиент + серверная часть
- [ ] `InMemoryRuntime` — готов к использованию
- [ ] `LocalFsRuntime` — chroot-like + cgroups
- [ ] `CapabilityEnforcer` — проверка на каждый вызов
- [ ] `ResourceMonitor` — мониторинг + auto-kill
- [ ] `AuditLogger` — лог всех capability вызовов
- [ ] Интеграция с `IAQSecurityClient` (через mock до реализации)

### Фаза 5 — AQSandbox (Docker runtime + продукт)

- [ ] `DockerRuntime` — полный контейнерный isolation
- [ ] `WarmPool` — пул прогретых контейнеров
- [ ] `SandboxSpec.fromContract()` — автоматический выбор runtime
- [ ] API для управления sandbox (dashboard)
- [ ] `createPolygon()` — polygon mode
- [ ] Первые публичные ToolPackages: `aq-tools-llm`, `aq-tools-git`, `aq-tools-python`

### Фаза 6 — Экосистема

- [ ] `aq-tools-*` маркетплейс
- [ ] WASM runtime — для edge и browser
- [ ] Firecracker VM runtime — для максимальной изоляции
- [ ] Multi-tenant SaaS топология
- [ ] Billing и quota management

---

## Приложение: три вопроса системы

Любое архитектурное решение в этой системе можно проверить тремя вопросами:

**ЧТО и КАК делает инструмент?**  
→ Ответ в `ToolContract` + реализации `IAQToolExecutor`  
→ Хранится и управляется через `AQToolRegistry`  
→ Доставляется через `AQToolRuntime`

**ГДЕ и С ЧЕМ это происходит?**  
→ Ответ в `SandboxSpec` + выбранном `SandboxRuntime`  
→ Создаётся и управляется через `AQSandbox`  
→ Инструмент видит только `RunContext` — он не знает ответа на этот вопрос

**КТО и ИМЕЕТ ЛИ ПРАВО?**  
→ Ответ в `IAQSecurityClient`  
→ AQSandbox и AQToolRuntime вызывают security как hook, не принимают решение сами

Если новое требование ломает эту схему — это сигнал пересмотреть проектирование, а не добавлять исключение.

---

*Документ v1.0. AQ Platform Architecture. 2026.*