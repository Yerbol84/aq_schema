# AQSandbox + AQTools — План реализации

> **Версия:** 1.0  
> **Горизонт:** 8 фаз, последовательных.  
> Каждая фаза завершается работающим сценарием — не абстракцией.  
> Ориентир: сценарии из AQ Tools & Sandbox — Архитектурная спецификация.

---

## Принцип планирования

**Фаза = рабочий сценарий.** Не "добавлены интерфейсы" и не "написан код".
Каждая фаза заканчивается тем, что кто-то может сделать что-то конкретное,
чего не мог сделать раньше. Это критерий приёмки.

**Порядок фаз продиктован зависимостями:**
- `aq_schema` меняется первой — всё остальное от неё зависит
- Registry раньше Runtime — Runtime знает о Registry
- InMemory/LocalFs раньше Docker — Docker сложнее и зависит от daemon
- Простые subject kinds раньше сложных — git_repo требует Docker
- Публичный API последний — сначала убедились что внутренности работают

---

## Фаза 0 — Фундамент: изменения aq_schema

**Цель:** Добавить новые доменные модели без ломки существующего кода.
Все новые интерфейсы идут в существующие barrel-файлы.

**Критерий приёмки:** `dart analyze` проходит без ошибок на всех пакетах.
Существующие тесты зелёные.

### Задачи

#### 0.1 aq_schema/tools.dart — расширение

Добавить без удаления существующего:

```dart
// ДОБАВИТЬ в aq_schema/tools.dart

class SemVer { ... }             // парсинг и сравнение "1.2.3"
class SemVerRange { ... }        // ">=1.0.0 <2.0.0", "^1.2.0"

class ToolRef {
  final String name;
  final SemVer? exactVersion;
  final SemVerRange? range;
  final String? namespace;       // "aq/llm", "community/git"
}

sealed class ToolCapability {}
class NetOutCap extends ToolCapability { final String hostPattern; }
class FsReadCap extends ToolCapability { final String pathPattern; }
class FsWriteCap extends ToolCapability { final String pathPattern; }
class ProcSpawnCap extends ToolCapability { final List<String> allowedBinaries; }
class DockerCap extends ToolCapability { final List<String> allowedImages; }

class ToolContract {
  final ToolRef ref;
  final String description;
  final Map<String, dynamic> inputSchema;
  final Map<String, dynamic> outputSchema;
  final List<ToolCapability> requiredCaps;
  final List<ToolCapability> optionalCaps;
  final String? deprecatedSince;
  final ToolRef? replacedBy;
}

abstract interface class IAQToolRegistry {
  static IAQToolRegistry get instance => AQPlatform.resolve();
  Future<ToolContract> resolve(ToolRef ref);
  Future<List<ToolContract>> listAvailable({...});
  Future<void> install(ToolPackageManifest manifest);
  Future<void> activate(ToolRef ref);
  Future<void> deactivate(ToolRef ref, {Duration gracePeriod});
  Stream<ToolLifecycleEvent> get lifecycleEvents;
}

abstract interface class IAQToolRuntime {
  static IAQToolRuntime get instance => AQPlatform.resolve();
  Future<ToolResult> call(ToolRef ref, Map<String, dynamic> args, RunContext ctx);
  Stream<ToolResultChunk> callStream(ToolRef ref, Map<String, dynamic> args, RunContext ctx);
  Future<CircuitBreakerStatus> getCircuitStatus(ToolRef ref);
}
```

#### 0.2 aq_schema/sandbox.dart — новые типы

```dart
// ДОБАВИТЬ в aq_schema/sandbox.dart

// --- Capabilities ---
sealed class ToolCapability {}  // (уже добавлены в tools.dart, ссылка сюда)

// --- RunContext (расширить существующий) ---
// Добавить nullable capability contexts к RunContext
extension RunContextCapabilities on RunContext {
  IFsContext? get fs;      // null если FsReadCap/FsWriteCap не granted
  INetContext? get net;     // null если NetOutCap не granted
  IProcContext? get proc;   // null если ProcSpawnCap не granted
}

abstract interface class IFsContext {
  Future<String> read(String relativePath);
  Future<void> write(String relativePath, String content);
  Future<List<String>> list({String? subDir});
  Future<bool> exists(String relativePath);
  Future<void> delete(String relativePath);
}

abstract interface class IProcContext {
  Future<ProcResult> run(String binary, List<String> args, {
    String? workingSubDir,
    Duration? timeout,
    Map<String, String>? extraEnv,
  });
}

abstract interface class INetContext {
  Future<HttpResponse> get(String url, {Map<String, String>? headers});
  Future<HttpResponse> post(String url, {Object? body, Map<String, String>? headers});
}

// --- ISandboxProvider ---
abstract interface class ISandboxProvider {
  static ISandboxProvider? get instance => AQPlatform.tryResolve();
  Future<ISandboxHandle> create(SandboxSpec spec);
  Future<ISandboxHandle?> get(String sandboxId);
  Future<List<SandboxRuntimeType>> availableRuntimes();
}

enum SandboxRuntimeType { inMemory, localFs, docker, vm, wasm }

// --- AQSubject domain ---
class AQSubjectDescriptor { ... }   // полная схема (см. AQSubject документ)
class AQSubjectMeta { ... }
class AQSubjectSpec { ... }
class SubjectInput { ... }
class SubjectOutput { ... }
sealed class SubjectEvent {}

abstract interface class ISubjectSession {
  String get sessionId;
  Future<SubjectOutput> send(SubjectInput input);
  Stream<SubjectOutputChunk> sendStream(SubjectInput input);
  Stream<SubjectEvent> get events;
  Future<SubjectSessionResult> dispose({bool saveArtifacts = true});
}

abstract interface class IAQSubjectRegistry {
  static IAQSubjectRegistry get instance => AQPlatform.resolve();
  Future<AQSubjectRecord> register(AQSubjectDescriptor descriptor);
  Future<AQSubjectRecord> get(String subjectId);
  Future<void> provision(String subjectId);
  Future<ISubjectSession> createSession(String subjectId, SessionConfig config);
}
```

#### 0.3 aq_schema/clients.dart — регистрация новых клиентов

```dart
// AQPlatform.init() расширяется:
AQPlatform.init(
  auth: ...,
  vault: ...,
  tools: ...,
  toolRegistry: ...,    // НОВОЕ
  toolRuntime: ...,     // НОВОЕ
  sandbox: ...,         // НОВОЕ (ISandboxProvider)
  subjectRegistry: ..., // НОВОЕ
  engine: ...,
);
```

#### 0.4 Добавить FallbackSandbox (unrestricted, для тестов)

```dart
// aq_schema/sandbox.dart
class FallbackSandbox implements ISandboxProvider {
  // Все capabilities granted, LocalFs runtime, нет лимитов
  // Только для тестов и development
}
```

**Оценка:** 3–4 дня. 0 риска поломки — только добавление.

---

## Фаза 1 — AQToolRegistry: реестр инструментов

**Цель:** Инструменты регистрируются с версиями. Движок запрашивает инструмент
по версионному диапазону — получает совместимую версию. Две версии одного инструмента
работают параллельно.

**Критерий приёмки:**
```dart
// Этот код работает
final registry = IAQToolRegistry.instance;

await registry.install(ToolPackageManifest.fromYaml(manifestYaml));
await registry.activate(ToolRef('llm_complete', namespace: 'aq/llm', range: '^2.0.0'));

// Резолюция — возвращает v2.0.0
final contract = await registry.resolve(
  ToolRef('llm_complete', namespace: 'aq/llm', range: '^2.0.0'),
);

// Старый граф хочет v1.x — получает v1.9.5 (если установлена)
final oldContract = await registry.resolve(
  ToolRef('llm_complete', namespace: 'aq/llm', range: '>=1.0.0 <2.0.0'),
);
```

### Задачи

#### 1.1 Пакет `aq_tool_registry`

```
pkgs/aq_tool_registry/
├── lib/
│   ├── aq_tool_registry.dart     ← клиентский экспорт
│   └── client/
│       └── registry_client.dart  ← IAQToolRegistry impl (HTTP или in-process)
├── lib_server/
│   ├── registry_server.dart      ← HTTP сервер реестра
│   ├── store/
│   │   ├── in_memory_tool_store.dart  ← для тестов
│   │   └── postgres_tool_store.dart   ← для production
│   └── resolver/
│       └── semver_resolver.dart       ← "^2.0.0" → "2.1.0"
└── test/
    ├── unit/semver_resolver_test.dart
    └── integration/registry_integration_test.dart
```

#### 1.2 ToolPackageManifest парсер

```dart
class ToolPackageManifest {
  factory ToolPackageManifest.fromYaml(String yaml) { ... }
  factory ToolPackageManifest.fromJson(Map<String, dynamic> json) { ... }

  final String packageName;
  final String packageVersion;
  final String minEngineVersion;
  final List<ToolDefinition> tools;
}

class ToolDefinition {
  final String name;
  final SemVer version;
  final String namespace;
  final ToolRef? replacedBy;
  final String? deprecatedSince;
  final String entryDartClass;           // "lib/tools/llm_complete_v2.dart#LlmCompleteV2Tool"
  final List<ToolCapability> requiredCaps;
  final List<ToolCapability> optionalCaps;
  final Duration? timeout;
}
```

#### 1.3 SemVer resolver

Логика: "^2.0.0" означает ">=2.0.0 <3.0.0". Из доступных версий выбирается
самая новая в диапазоне. Если не найдена → `ToolVersionNotFoundException`.

#### 1.4 Lifecycle events

```dart
sealed class ToolLifecycleEvent {}
class ToolInstalledEvent extends ToolLifecycleEvent { final ToolRef ref; }
class ToolActivatedEvent extends ToolLifecycleEvent { final ToolRef ref; }
class ToolDeactivatingEvent extends ToolLifecycleEvent {
  final ToolRef ref;
  final int activeCallsCount;  // ждём пока они завершатся
}
class ToolDeactivatedEvent extends ToolLifecycleEvent { final ToolRef ref; }
class ToolErrorEvent extends ToolLifecycleEvent { final ToolRef ref; final String error; }
```

**Оценка:** 5–7 дней.

---

## Фаза 2 — AQSandbox Core: InMemory + LocalFs runtime

**Цель:** Первые два runtime работают. Субъект типа `llm_endpoint` можно запустить
в InMemorySandbox. Субъект типа `script` — в LocalFsSandbox с изолированной директорией.

**Критерий приёмки (сценарий A из спецификации — упрощённый):**
```dart
// Зарегистрировать LLM-субъект
final record = await IAQSubjectRegistry.instance.register(
  AQSubjectDescriptor.fromJson(llmSubjectJson),
);

// Создать сессию
final session = await IAQSubjectRegistry.instance.createSession(
  record.subjectId,
  SessionConfig(sandboxPolicy: SandboxPolicy.development()),
);

// Вызвать
final output = await session.send(SubjectInput(data: {
  'messages': [{'role': 'user', 'content': 'Привет!'}]
}));

print(output.data['text']); // ответ от LLM

await session.dispose();
```

### Задачи

#### 2.1 Пакет `aq_sandbox` — скелет

```
pkgs/aq_sandbox/
├── lib/
│   ├── aq_sandbox.dart           ← клиентский экспорт
│   └── client/
│       ├── sandbox_client.dart   ← IAQSandboxClient impl
│       └── subject_registry_client.dart  ← IAQSubjectRegistry impl
├── lib_server/
│   ├── sandbox_server.dart       ← HTTP сервер (для distributed mode)
│   ├── runtimes/
│   │   ├── in_memory_runtime.dart
│   │   └── local_fs_runtime.dart
│   ├── policy/
│   │   └── capability_enforcer.dart
│   ├── provisioner/
│   │   └── provisioner_registry.dart
│   └── session/
│       ├── session_manager.dart
│       └── tools_proxy.dart      ← local HTTP proxy для инструментов в sandbox
└── test/
```

#### 2.2 InMemoryRuntime

Самый простой runtime. Нет FS, нет процессов. Только `env` и `vault`.
Используется для: `llm_endpoint`, `api_endpoint`, `prompt_template`.

```dart
class InMemoryRuntime implements ISandboxRuntime {
  @override
  Future<RunContext> provision(SandboxSpec spec) async {
    // Создаём RunContext с только разрешёнными contexts
    // NetOutCap granted? → создаём INetContext с ограничениями по host
    // FsReadCap / FsWriteCap? → null (нет FS в InMemory)
    // ProcSpawnCap? → null (нет процессов в InMemory)
    return RunContext.minimal(
      sandboxId: spec.sandboxId,
      net: spec.policy.allows(NetOutCap) ? InMemoryNetContext(spec) : null,
    );
  }
}
```

#### 2.3 LocalFsRuntime

Создаёт изолированную директорию `/var/aq/sandboxes/{sandboxId}/`.
`IFsContext.read('file.txt')` → читает `/var/aq/sandboxes/{sandboxId}/file.txt`.
Выход за пределы — `PathTraversalException` ещё на уровне path normalization.

```dart
class LocalFsRuntime implements ISandboxRuntime {
  final String basePath;  // /var/aq/sandboxes

  @override
  Future<RunContext> provision(SandboxSpec spec) async {
    final workDir = '$basePath/${spec.sandboxId}';
    await Directory(workDir).create(recursive: true);

    return RunContext(
      sandboxId: spec.sandboxId,
      fs: LocalFsContext(rootDir: workDir),
      proc: spec.policy.allows(ProcSpawnCap)
          ? LocalProcContext(workDir: workDir, policy: spec.policy)
          : null,
      net: spec.policy.allows(NetOutCap)
          ? ProxiedNetContext(allowedHosts: spec.policy.allowedHosts)
          : null,
    );
  }

  @override
  Future<void> dispose(String sandboxId, SandboxDisposalSpec disposal) async {
    final workDir = '$basePath/$sandboxId';
    if (disposal.saveArtifacts) {
      await _saveToVault(workDir, disposal.vaultDestination);
    }
    if (disposal.cleanup) {
      await Directory(workDir).delete(recursive: true);
    }
  }
}
```

#### 2.4 CapabilityEnforcer

```dart
class CapabilityEnforcer {
  /// Проверить при создании RunContext: capabilities соответствуют политике
  GrantedCapabilities negotiate({
    required List<ToolCapability> requested,
    required SandboxPolicy policy,
  }) {
    final granted = <ToolCapability>[];
    for (final cap in requested) {
      if (policy.allows(cap)) {
        granted.add(cap);
      }
      // Не granted → просто не добавляем. ctx.proc == null.
    }
    return GrantedCapabilities(granted);
  }
}
```

#### 2.5 SubjectRegistry (in-process, phase 2)

Пока — in-memory реестр. Субъекты не персистируются. Достаточно для тестирования.
Provisioner для `llm_endpoint` просто валидирует endpoint + credentials.

#### 2.6 Tools Proxy (ключевой компонент)

Local HTTP server внутри sandbox-сессии. Субъект знает только `AQ_TOOLS_ENDPOINT`.

```
GET  /health              → {"ok": true}
POST /llm/chat            → проксирует в настроенный LLM provider
POST /llm/embed           → проксирует embedding endpoint
POST /vault/read          → IAQVaultService.read()
POST /vault/write         → IAQVaultService.write()
POST /tools/{toolName}    → IAQToolRuntime.call()
GET  /tools               → список доступных инструментов
```

**Оценка:** 7–10 дней. Это самая объёмная фаза — здесь закладывается фундамент runtime.

---

## Фаза 3 — Первые Subject Kinds: llm_endpoint, api_endpoint, prompt_template

**Цель:** Пользователь может зарегистрировать реальный LLM (любой OpenAI-compatible),
запустить сессию, получить ответы. Prompt template работает через LLM endpoint.

**Критерий приёмки (Сценарий B из спецификации):**
```dart
// Зарегистрировать GPT-4o
final gptSubject = await registry.register(
  AQSubjectDescriptor.fromJson(gpt4oDescriptorJson),
);

// Зарегистрировать Claude
final claudeSubject = await registry.register(
  AQSubjectDescriptor.fromJson(claudeDescriptorJson),
);

// Провизионировать оба (просто проверка endpoint + credentials)
await registry.provision(gptSubject.subjectId);
await registry.provision(claudeSubject.subjectId);

// Запустить один и тот же тест на обоих
final [resultA, resultB] = await Future.wait([
  _runEval(gptSubject.subjectId, testCases),
  _runEval(claudeSubject.subjectId, testCases),
]);
```

### Задачи

#### 3.1 LlmSubjectProvisioner

```dart
class LlmSubjectProvisioner implements ISubjectProvisioner {
  @override
  String get kind => 'llm_endpoint';

  @override
  Future<ArtifactRecord> provision(AQSubjectSpec spec) async {
    // 1. Resolve API key from vault
    final apiKey = await _resolveSecret(spec.source.apiKeyRef);

    // 2. Validate endpoint (GET /models or equivalent)
    await _validateEndpoint(spec.source.baseUrl, apiKey);

    // 3. Create artifact — просто конфиг, не код
    return ArtifactRecord(
      kind: ArtifactKind.config,
      data: {
        'base_url': spec.source.baseUrl,
        'model': spec.source.model,
        'resolved_api_key': apiKey,  // encrypted in artifact store
      },
    );
  }
}
```

#### 3.2 LlmSubjectSessionFactory

Создаёт `ISubjectSession` которая:
- Получает `send(input)` → интерпретирует как chat messages
- Отправляет в реальный LLM endpoint
- Возвращает `SubjectOutput`

```dart
class LlmSubjectSession implements ISubjectSession {
  final LlmEndpointConfig _config;
  final HttpClient _client;

  @override
  Future<SubjectOutput> send(SubjectInput input) async {
    final messages = input.data['messages'] as List;
    final response = await _client.post(
      '${_config.baseUrl}/chat/completions',
      body: {'model': _config.model, 'messages': messages},
      headers: {'Authorization': 'Bearer ${_config.apiKey}'},
    );
    return SubjectOutput(
      success: true,
      data: {
        'text': response.choices.first.message.content,
        'usage': response.usage.toMap(),
      },
    );
  }
}
```

#### 3.3 ApiSubjectProvisioner + Session

Для `api_endpoint` kind. Provisioner проверяет доступность URL.
Session проксирует HTTP запросы к внешнему API.

#### 3.4 PromptTemplateProvisioner + Session

```dart
class PromptTemplateSession implements ISubjectSession {
  final String _template;
  final ISubjectSession _llmSession;  // разрешённый llm_ref

  @override
  Future<SubjectOutput> send(SubjectInput input) async {
    // 1. Рендерить шаблон с переменными из input
    final rendered = _renderTemplate(_template, input.data);

    // 2. Отправить в LLM сессию
    return await _llmSession.send(SubjectInput(data: {
      'messages': [{'role': 'user', 'content': rendered}]
    }));
  }
}
```

**Оценка:** 5–6 дней.

---

## Фаза 4 — AQToolRuntime: маршрутизация и MCP

**Цель:** Инструменты из реестра вызываются через Runtime. MCP-серверы подключаются
как external tools. Tools Proxy в sandbox маршрутизирует вызовы субъекта к реальным инструментам.

**Критерий приёмки:**
```dart
// Субъект внутри sandbox вызывает tools через proxy endpoint
// Этот вызов через AQ_TOOLS_ENDPOINT → ToolsProxy → ToolRuntime → MCP Server
POST /tools/filesystem/read
{"path": "analysis.md"}
→ {"content": "..."} // содержимое файла из MCP filesystem сервера
```

### Задачи

#### 4.1 Пакет `aq_tool_runtime`

```
pkgs/aq_tool_runtime/
├── lib/
│   ├── aq_tool_runtime.dart
│   └── client/
│       └── runtime_client.dart        ← IAQToolRuntime impl
├── lib/
│   └── executors/
│       ├── local_executor.dart        ← Dart class call
│       ├── mcp_executor.dart          ← MCP JSON-RPC
│       ├── grpc_executor.dart
│       └── http_executor.dart
└── lib/
    └── circuit_breaker/
        └── circuit_breaker.dart
```

#### 4.2 McpExecutor

```dart
class McpExecutor implements IAQToolExecutor {
  final McpTransport _transport;  // stdio или http

  @override
  Future<ToolResult> execute(
    Map<String, dynamic> args,
    RunContext ctx,
  ) async {
    // MCP JSON-RPC tools/call
    final response = await _transport.call(
      method: 'tools/call',
      params: {'name': descriptor.name, 'arguments': args},
    );
    return ToolResult.fromMcpResponse(response);
  }
}
```

#### 4.3 CircuitBreaker

```dart
class CircuitBreaker {
  final int failureThreshold;   // N ошибок → OPEN
  final Duration recoveryTimeout; // время до HALF_OPEN

  // CLOSED → OPEN → HALF_OPEN → CLOSED
  Future<T> call<T>(Future<T> Function() fn) async {
    if (_state == CircuitState.open) {
      if (DateTime.now().isBefore(_openUntil)) {
        throw ToolCircuitOpenException(_ref);
      }
      _state = CircuitState.halfOpen;
    }
    try {
      final result = await fn();
      _onSuccess();
      return result;
    } catch (e) {
      _onFailure();
      rethrow;
    }
  }
}
```

#### 4.4 ToolsProxy интеграция с Runtime

```dart
// В ToolsProxy — при вызове /tools/{toolName}
Future<Response> handleToolCall(String toolName, Map args, RunContext ctx) async {
  // 1. Резолвить инструмент из реестра
  final contract = await IAQToolRegistry.instance.resolve(
    ToolRef(toolName),  // latest доступная версия
  );

  // 2. Вызвать через runtime
  final result = await IAQToolRuntime.instance.call(
    contract.ref, args, ctx,
  );

  return Response.ok(result.output);
}
```

**Оценка:** 6–8 дней.

---

## Фаза 5 — Docker Runtime + GitRepo и Script subjects

**Цель:** Субъекты с реальным кодом работают в изолированных Docker-контейнерах.
Сценарий A из спецификации работает полностью — агент в git_repo запускается,
получает LLM через proxy, результаты возвращаются.

**Критерий приёмки (Сценарий A полностью):**
```dart
// Это должно работать end-to-end
final subject = await registry.register(AQSubjectDescriptor.fromJson({
  "spec": {
    "kind": "git_repo",
    "source": {
      "url": "https://github.com/user/my-agent",
      "branch": "main",
      "entrypoint": "bin/agent.dart"
    },
    "runtime": { "preferred": "docker", "image": "dart:3.4-sdk" },
    "tools": {
      "llm": { "provider": "anthropic", "model": "claude-haiku-4" }
    }
  }
}));

await registry.provision(subject.subjectId); // клонирует репо, строит образ

final session = await registry.createSession(subject.subjectId, config);
final result = await session.send(SubjectInput(data: {'task': 'Найди баги'}));
// Агент внутри Docker вызвал LLM через AQ_TOOLS_ENDPOINT → получил ответ
// → вернул результат через stdout
```

### Задачи

#### 5.1 DockerRuntime

```dart
class DockerRuntime implements ISandboxRuntime {
  final DockerClient _docker;
  final WarmPool _warmPool;

  @override
  Future<RunContext> provision(SandboxSpec spec) async {
    // 1. Получить контейнер из warm pool или создать новый
    final container = await _warmPool.acquire(spec.imageTag);

    // 2. Создать volume для workdir
    final volume = await _docker.createVolume(spec.sandboxId);

    // 3. Запустить Tools Proxy внутри контейнера (как sidecar)
    await _startToolsProxy(container, spec.toolsConfig);

    // 4. Инжектировать env vars
    await _docker.setEnv(container.id, {
      'AQ_SESSION_ID': spec.sessionId,
      'AQ_TOOLS_ENDPOINT': 'http://localhost:${toolsProxyPort}',
      'AQ_LLM_BASE_URL': 'http://localhost:${toolsProxyPort}/llm',
      'AQ_WORK_DIR': '/workspace',
      ...spec.envOverrides,
    });

    return DockerRunContext(
      containerId: container.id,
      volumeId: volume.id,
      sandboxId: spec.sandboxId,
    );
  }

  @override
  Future<void> dispose(String sandboxId, SandboxDisposalSpec disposal) async {
    // Сохранить артефакты если нужно, затем удалить контейнер и volume
  }
}
```

#### 5.2 WarmPool

```dart
class WarmPool {
  final int poolSize;
  final String defaultImage;
  final _available = Queue<ContainerHandle>();
  final _inUse = <String, ContainerHandle>{};

  /// Предварительно поднять N контейнеров
  Future<void> initialize() async {
    for (int i = 0; i < poolSize; i++) {
      final container = await _docker.create(defaultImage);
      _available.add(container);
    }
  }

  Future<ContainerHandle> acquire(String imageTag) async {
    if (_available.isNotEmpty && imageTag == defaultImage) {
      final c = _available.removeFirst();
      _inUse[c.id] = c;
      _replenish();  // пополнить пул в фоне
      return c;
    }
    return await _docker.create(imageTag);  // cold start
  }
}
```

#### 5.3 GitRepoProvisioner

```dart
class GitRepoProvisioner implements ISubjectProvisioner {
  @override
  String get kind => 'git_repo';

  @override
  Future<ArtifactRecord> provision(AQSubjectSpec spec) async {
    final tmpDir = await _createTmpDir();

    // 1. Клонировать (shallow clone для скорости)
    await _git.clone(spec.source.url, tmpDir,
      branch: spec.source.branch,
      depth: 1,
    );

    // 2. Выполнить build steps
    for (final step in spec.source.build?.steps ?? []) {
      await _proc.run(step, workingDir: tmpDir);
    }

    // 3. Упаковать в zip-артефакт → сохранить в vault/кеш
    final zipPath = await _zip(tmpDir);
    final artifactId = await _artifactCache.store(zipPath,
      cacheKey: spec.source.build?.cacheKey,
    );

    return ArtifactRecord(
      kind: ArtifactKind.archive,
      artifactId: artifactId,
    );
  }
}
```

#### 5.4 GitRepoSession

```dart
class GitRepoSession implements ISubjectSession {
  final DockerRunContext _ctx;
  final AQSubjectSpec _spec;

  @override
  Future<SubjectOutput> send(SubjectInput input) async {
    // 1. Распаковать артефакт в /workspace контейнера
    await _extractArtifact(_spec.artifactId, _ctx.containerId, '/workspace');

    // 2. Запустить entrypoint с input через stdin
    final result = await _docker.exec(
      _ctx.containerId,
      command: _spec.source.entrypoint,
      stdin: jsonEncode(input.data),
      timeout: _spec.resources.maxExecutionDuration,
    );

    return SubjectOutput(
      success: result.exitCode == 0,
      data: jsonDecode(result.stdout),
      error: result.exitCode != 0 ? result.stderr : null,
    );
  }
}
```

**Оценка:** 10–14 дней. Самая сложная фаза технически — Docker integration.

---

## Фаза 6 — GraphSubject: интеграция AQ Graph Engine

**Цель:** AQ Graph Workflow регистрируется как субъект. Движок запускает граф
через AQSandbox, а не напрямую. Тяжёлая работа (вызовы LLM, файловые операции)
происходит внутри sandbox с изоляцией.

**Критерий приёмки:**
```dart
// AQ Graph Worker — использует субъекты для запуска графов
// Движок не знает о Docker, MCP, конкретных LLM

final subjectId = await _ensureGraphSubjectRegistered(blueprintId, versionId);

final session = await IAQSubjectRegistry.instance.createSession(
  subjectId,
  SessionConfig(
    sandboxPolicy: project.sandboxPolicy,
    toolConfig: ToolConfig.fromProject(project),
  ),
);

final result = await session.send(SubjectInput(data: run.inputs));
await for (final event in session.events) {
  runEventBus.emit(event.toGraphRunEvent(run.id));
}
await session.dispose(saveArtifacts: run.config.saveArtifacts);
```

### Задачи

#### 6.1 AqGraphSubjectProvisioner

```dart
class AqGraphSubjectProvisioner implements ISubjectProvisioner {
  @override
  String get kind => 'aq_graph';

  @override
  Future<ArtifactRecord> provision(AQSubjectSpec spec) async {
    // Граф уже в vault — просто загружаем и кешируем
    final graph = await IAQVaultClient.instance.loadGraph(
      spec.source.blueprintId,
      versionId: spec.source.versionId,
    );

    return ArtifactRecord(
      kind: ArtifactKind.graphBlueprint,
      data: graph.toJson(),
    );
  }
}
```

#### 6.2 AqGraphSession

```dart
class AqGraphSession implements ISubjectSession {
  final IAQGraphEngineClient _engine;
  final $Graph _graph;
  final ToolConfig _toolConfig;

  @override
  Future<SubjectOutput> send(SubjectInput input) async {
    // Субъект-граф запускается через движок — но движок получает инструменты
    // которые маршрутизируются через текущую sandbox-сессию
    final runStream = _engine.run(GraphRunRequest(
      graph: _graph,
      inputs: input.data,
      toolsProvider: SandboxedToolProvider(_toolConfig),
    ));

    SubjectOutput? finalOutput;
    await for (final event in runStream) {
      _eventsController.add(event.toSubjectEvent());
      if (event is GraphCompletedEvent) {
        finalOutput = SubjectOutput.fromGraphResult(event.result);
      }
    }
    return finalOutput!;
  }
}
```

#### 6.3 Миграция AQ Graph Worker

Существующий воркер рефакторится: вместо прямого вызова движка — регистрирует
субъект и создаёт сессию. Это изменение прозрачно для пользователей AQ Studio.

```dart
// БЫЛО в GraphWorker:
final result = await graphEngine.run(graph, inputs: run.inputs);

// СТАЛО:
final session = await _getOrCreateSession(run);
final result = await session.send(SubjectInput(data: run.inputs));
```

**Оценка:** 8–10 дней.

---

## Фаза 7 — Публичный REST API + SDK

**Цель:** Внешний разработчик может использовать AQSandbox через HTTP API
или Dart SDK без знания внутренностей. Полные сценарии A, B, C из спецификации
работают через API.

**Критерий приёмки:** curl-команды из документации работают против dev-сервера.

### Задачи

#### 7.1 REST API сервер

```
POST   /api/v1/subjects                       ← register
POST   /api/v1/subjects/{id}/provision        ← provision
POST   /api/v1/subjects/{id}/sessions         ← createSession
POST   /api/v1/sessions/{id}/invoke           ← send (JSON или SSE stream)
DELETE /api/v1/sessions/{id}                  ← dispose
GET    /api/v1/sessions/{id}/events           ← SSE event stream

POST   /api/v1/workspaces/{ws}/tools          ← install tool package
GET    /api/v1/workspaces/{ws}/tools          ← list tools
DELETE /api/v1/workspaces/{ws}/tools/{name}   ← uninstall

GET    /api/v1/subjects/{id}                  ← get
GET    /api/v1/subjects                       ← list
DELETE /api/v1/subjects/{id}                  ← delete
```

#### 7.2 Subject descriptor validation endpoint

```http
POST /api/v1/subjects/validate
Content-Type: application/json

{...descriptor...}

→ 200 OK
{
  "valid": true,
  "warnings": [],
  "resolved_capabilities": ["NET_OUT:api.anthropic.com"],
  "estimated_runtime": "inMemory"
}

→ 400 Bad Request (если невалидно)
{
  "valid": false,
  "errors": [
    {"field": "spec.source.url", "message": "Repository not accessible"}
  ]
}
```

#### 7.3 Dart SDK (клиентская библиотека)

```dart
// pub.dev: aq_sandbox_client

final client = AQSandboxClient(
  baseUrl: 'https://sandbox.aq.dev',
  apiKey: 'your-api-key',
);

// Fluent API
final session = await client
  .subject(fromJson: myDescriptor)
  .provision()
  .createSession(policy: 'strict');

await for (final event in session.events) {
  print(event);
}

final result = await session.send({'task': 'do something'});
await session.dispose();
```

#### 7.4 OpenAPI spec + документация

Автогенерация OpenAPI spec из роутов. Postman collection для быстрого старта.

**Оценка:** 6–8 дней.

---

## Фаза 8 — Polygon Mode + Marketplace

**Цель:** Сценарий C (polygon) работает. Пользователи могут публиковать
ToolPackages в marketplace. WASM runtime для edge-сценариев.

### Задачи

#### 8.1 Polygon Mode

```dart
// Polygon = именованный набор субъектов + политика + seed данные

final polygon = await client.createPolygon(PolygonConfig(
  name: 'regression-v2',
  subjects: [
    SubjectOverride(subjectId: 'my-agent', toolOverrides: {
      'llm': LlmConfig.mock(responses: testResponses),
    }),
  ],
  databases: [
    DbSeed(name: 'main', seedFile: 'fixtures/test-data.sql'),
  ],
  dispose: DisposePolicy.afterSuite,
));

await polygon.runSuite(regressionTestSuite);
// Всё изолировано, всё воспроизводимо
```

#### 8.2 ToolPackage Marketplace

```
GET    /api/v1/marketplace/tools           ← поиск публичных пакетов
POST   /api/v1/marketplace/tools/publish   ← опубликовать
GET    /api/v1/marketplace/tools/{name}    ← details + changelog
POST   /api/v1/workspaces/{ws}/tools/install?from=marketplace&name=...
```

#### 8.3 WasmRuntime

Для инструментов и субъектов скомпилированных в WASM. Работает в браузере
и на edge без Docker.

**Оценка:** 12–15 дней.

---

## Сводная таблица фаз

| Фаза | Что даёт | Оценка | Сценарий |
|---|---|---|---|
| 0 — aq_schema | Все интерфейсы задекларированы | 3–4 дня | — |
| 1 — ToolRegistry | Версионированные инструменты | 5–7 дней | — |
| 2 — Sandbox Core | InMemory + LocalFs runtime | 7–10 дней | Базовый LLM вызов |
| 3 — Первые kinds | llm_endpoint, api, prompt | 5–6 дней | Сценарий B (сравнение LLM) |
| 4 — ToolRuntime | MCP + circuit breaker | 6–8 дней | Внешние инструменты |
| 5 — Docker + Git | git_repo, script subjects | 10–14 дней | **Сценарий A** (код-агент) |
| 6 — GraphSubject | AQ Graph через sandbox | 8–10 дней | AQ Studio интеграция |
| 7 — REST API | Публичный API + SDK | 6–8 дней | Внешние пользователи |
| 8 — Polygon + Market | Полигоны, marketplace | 12–15 дней | **Сценарий C** (polygon) |
| **Итого** | | **62–82 дня** | Все сценарии |

---

## Зависимости между фазами

```
0 (schema)
    ├──► 1 (registry)
    │       └──► 4 (runtime) ──────────┐
    └──► 2 (sandbox core)              │
             ├──► 3 (kinds) ───────────┤
             │       └──► 5 (docker) ──┤
             │                │        │
             │                ▼        ▼
             └──────────► 6 (graph) ──► 7 (api) ──► 8 (polygon)
```

Фазы 1 и 2 можно делать параллельно (разные команды, нет зависимости друг от друга).
Фаза 3 зависит от 2. Фазы 4 и 5 зависят от 1 и 2. Фаза 6 зависит от 5.

---

## Что НЕ входит в план (сознательно)

**Billing и quota enforcement** — отдельный трек после фазы 7. Без публичных пользователей квоты не нужны.

**Multi-region deployment** — после стабильной single-region. Преждевременная оптимизация.

**VM Runtime (Firecracker)** — после Docker. Docker покрывает 90% сценариев. Firecracker нужен только для сценариев с самым высоким уровнем изоляции.

**UI для управления sandbox** — после REST API. API первичен. UI — второй слой поверх него.

---

*Документ v1.0. AQ Platform. 2026.*