# AQSubject — Модель испытуемого

> **Статус:** VISION  
> **Назначение:** Центральная абстракция для AQSandbox.  
> Описывает **что такое испытуемый**, как он регистрируется, как с ним работает система,
> и как выглядит протокол взаимодействия.

---

## 1. Зачем нужна абстракция

AQSandbox должен уметь принять и запустить в изолированной среде **что угодно**:
- LLM-модель по API-ключу и URL
- GitHub-репозиторий с кодом
- Готовый HTTP API (чужой сервис)
- Prompt-шаблон (без кода — просто текст)
- Docker-образ
- AQ Graph (воркфлоу)
- Python-скрипт в 20 строк

Для системы это принципиально разные вещи. Для пользователя — нет.
Пользователь думает: "я хочу запустить мой агент в sandbox и дать ему инструменты".
Агент — это то что есть у него. Что именно — GitHub репо, API, скрипт — не суть.

**AQSubject** — это абстракция, которая позволяет системе говорить с любым из этих вариантов
через единый язык, не знакомя пользователя с деталями инфраструктуры.

> Аналоги в мире: Kubernetes Pod (что запускать) — не знает о нодах и планировщике.
> AWS Lambda Function (что выполнить) — не знает о серверах. Docker Container Spec —
> описывает что нужно, а не как это обеспечить.

---

## 2. Что такое AQSubject

`AQSubject` — это **декларативное описание испытуемого**: что он из себя представляет,
как его запустить, как с ним разговаривать, что ему нужно для работы.

Это не экземпляр выполнения. Это **определение** — как recipe в кулинарии.
Из одного `AQSubject` можно создать N параллельных сессий с разными параметрами.

Три ключевых свойства:

**Kind** — тип субъекта. Определяет как система его провизионирует.
Пользователь объявляет kind один раз; система знает что с ним делать.

**Source** — откуда взять. Git URL, Docker image, API endpoint, inline code, ссылка на граф.
Всё что нужно чтобы получить артефакт для запуска.

**Interface** — как разговаривать. Протокол, по которому sandbox отправляет входные данные
и получает результаты. HTTP, stdio, MCP, прямой вызов Dart.

---

## 3. Каталог типов субъектов

| Kind | Что это | Source | Interface |
|---|---|---|---|
| `llm_endpoint` | LLM API (любой совместимый) | URL + api_key_ref | OpenAI-compatible HTTP |
| `git_repo` | GitHub/GitLab репозиторий | repo URL + branch + entrypoint | stdio / HTTP (после сборки) |
| `docker_image` | Docker образ | image:tag + command | stdio / HTTP |
| `api_endpoint` | Любой HTTP API | base_url + auth | HTTP |
| `prompt_template` | Текстовый шаблон | inline text + variable_schema | LLM (через llm_endpoint) |
| `script` | Inline код | source code + language | stdio |
| `mcp_server` | MCP-совместимый сервер | command или URL | MCP JSON-RPC |
| `aq_graph` | AQ Graph воркфлоу | blueprintId + versionId | AQ GraphEngine protocol |
| `wasm_module` | WASM-компонент | .wasm файл или URL | WASM component interface |

Система расширяема. Новые kinds добавляются через `SubjectKindPlugin` в реестр.
Встроенные kinds покрывают 90% сценариев с первого дня.

---

## 4. AQSubjectDescriptor — JSON Schema

Это главный файл который пишет пользователь. Всё остальное выводится из него.

```json
{
  "$schema": "https://aq.dev/schemas/subject/v1",
  "kind": "AQSubject",
  "apiVersion": "v1",

  "metadata": {
    "name": "my-code-agent",
    "namespace": "my-workspace",
    "version": "1.2.0",
    "description": "Агент для рефакторинга Dart-кода",
    "labels": {
      "team": "backend",
      "env": "experiment"
    }
  },

  "spec": {
    "kind": "git_repo",

    "source": {
      "url": "https://github.com/user/my-agent",
      "branch": "main",
      "entrypoint": "bin/agent.dart",
      "build": {
        "steps": ["dart pub get"],
        "cache_key": "pubspec.lock"
      }
    },

    "interface": {
      "protocol": "stdio",
      "input_schema": {
        "type": "object",
        "properties": {
          "task": { "type": "string" },
          "context": { "type": "string" }
        },
        "required": ["task"]
      },
      "output_schema": {
        "type": "object",
        "properties": {
          "result": { "type": "string" },
          "files_changed": { "type": "array", "items": { "type": "string" } }
        }
      }
    },

    "runtime": {
      "preferred": "docker",
      "fallback": "local_fs",
      "image": "dart:3.4-sdk",
      "working_dir": "/workspace"
    },

    "capabilities": {
      "required": [
        "FS_READ:/workspace",
        "FS_WRITE:/workspace",
        "PROC_SPAWN:dart",
        "NET_OUT:api.anthropic.com"
      ],
      "optional": [
        "NET_OUT:api.github.com"
      ]
    },

    "tools": {
      "llm": {
        "provider": "anthropic",
        "model": "claude-sonnet-4-6",
        "api_key_ref": "$secrets.ANTHROPIC_KEY"
      },
      "builtin": ["vault_read", "vault_write", "git_commit"],
      "mcp": [
        {
          "name": "filesystem",
          "transport": "stdio",
          "command": "npx @mcp/server-filesystem /workspace"
        }
      ]
    },

    "resources": {
      "max_memory_mb": 512,
      "max_cpu_percent": 50,
      "max_execution_minutes": 10,
      "max_disk_mb": 2048
    },

    "secrets": {
      "ANTHROPIC_KEY": {
        "source": "user_vault",
        "key": "integrations/anthropic/api_key"
      }
    }
  }
}
```

### 4.1 Пример: LLM Endpoint

```json
{
  "$schema": "https://aq.dev/schemas/subject/v1",
  "kind": "AQSubject",
  "apiVersion": "v1",
  "metadata": {
    "name": "gpt4o-subject",
    "version": "1.0.0"
  },
  "spec": {
    "kind": "llm_endpoint",
    "source": {
      "base_url": "https://api.openai.com/v1",
      "api_key_ref": "$secrets.OPENAI_KEY",
      "model": "gpt-4o"
    },
    "interface": {
      "protocol": "openai_compatible",
      "supports_streaming": true,
      "supports_tool_use": true
    },
    "capabilities": {
      "required": ["NET_OUT:api.openai.com"]
    },
    "resources": {
      "max_execution_minutes": 5
    },
    "secrets": {
      "OPENAI_KEY": {
        "source": "user_vault",
        "key": "integrations/openai/api_key"
      }
    }
  }
}
```

### 4.2 Пример: Prompt Template (без кода)

```json
{
  "$schema": "https://aq.dev/schemas/subject/v1",
  "kind": "AQSubject",
  "apiVersion": "v1",
  "metadata": {
    "name": "code-review-prompt",
    "version": "2.1.0"
  },
  "spec": {
    "kind": "prompt_template",
    "source": {
      "template": "Ты опытный разработчик Dart/Flutter.\nПроверь следующий код:\n\n{{code}}\n\nНайди: ошибки, code smells, нарушения принципов SOLID.\nДай оценку по шкале 1-10.",
      "variables": {
        "code": { "type": "string", "description": "Dart-код для ревью" }
      }
    },
    "interface": {
      "protocol": "prompt_eval",
      "llm_ref": "gpt4o-subject"
    },
    "capabilities": {}
  }
}
```

### 4.3 Пример: AQ Graph (воркфлоу как субъект)

```json
{
  "$schema": "https://aq.dev/schemas/subject/v1",
  "kind": "AQSubject",
  "apiVersion": "v1",
  "metadata": {
    "name": "aq-workflow-subject",
    "version": "1.0.0"
  },
  "spec": {
    "kind": "aq_graph",
    "source": {
      "blueprint_id": "wf-abc123",
      "version_id": "v-xyz456"
    },
    "interface": {
      "protocol": "aq_engine",
      "input_mapping": {
        "task": "graph.inputs.user_task"
      }
    },
    "tools": {
      "llm": {
        "provider": "anthropic",
        "model": "claude-sonnet-4-6",
        "api_key_ref": "$secrets.ANTHROPIC_KEY"
      }
    }
  }
}
```

---

## 5. Lifecycle субъекта

### 5.1 Фазы

```
DEFINED           — дескриптор создан, не запускается
    │
    ▼ validate()
VALIDATED         — схема проверена, capabilities возможны
    │
    ▼ provision()
PROVISIONED       — артефакт получен (код клонирован, образ спулен)
    │
    ▼ session_create()
SESSION_ACTIVE    — изолированная среда создана, субъект готов
    │
    ├── interact() x N    — входные данные → результаты (может быть цикличным)
    │
    ▼ session_dispose()
SESSION_CLOSED    — среда очищена, артефакты сохранены
    │
    └── DEFINED   — субъект готов к следующей сессии
```

**DEFINED → PROVISIONED** происходит один раз (или при изменении source).
Артефакт кешируется. Повторный запуск берёт из кеша.

**PROVISIONED → SESSION_ACTIVE** происходит каждый раз при запуске.
Создаётся новая изолированная среда из готового артефакта.
Docker: `docker run` из уже спулённого образа → 200ms.
Git: zip артефакта распаковывается → 50ms.

### 5.2 Диаграмма: provision vs session

```
[SubjectDescriptor]
        │
        ▼
[Provisioner]
  ├── GitRepoProvisioner → клонирует → dart pub get → zip артефакта → кеш
  ├── DockerProvisioner  → docker pull → warm pool
  ├── LlmProvisioner     → validates endpoint + credentials
  └── PromptProvisioner  → validates template + resolves llm_ref

        │ артефакт готов
        ▼
[ArtifactCache] ──────────────────────────────────┐
                                                   │
[Session Request]                                  │
  SandboxPolicy + Inputs + ToolConfig             │
        │                                          │ берёт из кеша
        ▼                                          │
[SessionFactory] ◄─────────────────────────────────┘
  ├── создаёт SandboxRuntime (Docker/LocalFs/InMemory)
  ├── монтирует артефакт в /workspace
  ├── инжектирует secrets из vault
  ├── конфигурирует tools (LLM endpoint, MCP servers)
  └── запускает entrypoint или server
        │
        ▼
[SandboxSession]
  ├── session.send(input) → вызов через интерфейс субъекта
  ├── session.events → поток событий (logs, tool_calls, progress)
  └── session.dispose() → сохранение артефактов, очистка
```

---

## 6. SubjectProtocol — как sandbox разговаривает с субъектом

После provisioning система не знает что внутри sandbox — GitHub репо или LLM API.
Она знает только протокол через который с ним разговаривать.

Все протоколы нормализуются к одному интерфейсу — `ISubjectSession`:

```dart
abstract interface class ISubjectSession {
  /// Отправить входные данные, получить результат
  Future<SubjectOutput> send(SubjectInput input);

  /// Потоковый ответ (для LLM streaming, long-running tasks)
  Stream<SubjectOutputChunk> sendStream(SubjectInput input);

  /// Поток событий от субъекта (logs, tool calls, progress)
  Stream<SubjectEvent> get events;

  /// Текущее состояние
  SubjectSessionStatus get status;

  /// Завершить сессию
  Future<SubjectSessionResult> dispose({bool saveArtifacts = true});
}
```

```dart
class SubjectInput {
  final Map<String, dynamic> data;     // по схеме input_schema
  final String? correlationId;         // для трассировки
  final Map<String, String>? metadata; // произвольные метаданные
}

class SubjectOutput {
  final bool success;
  final Map<String, dynamic> data;   // по схеме output_schema
  final String? error;
  final SubjectOutputMeta meta;
}

sealed class SubjectEvent {}
class SubjectLogEvent extends SubjectEvent {
  final String message;
  final LogLevel level;
}
class SubjectToolCallEvent extends SubjectEvent {
  final String toolName;
  final Map<String, dynamic> args;
  final Map<String, dynamic>? result;
}
class SubjectProgressEvent extends SubjectEvent {
  final double progress;   // 0.0–1.0
  final String? label;
}
```

### 6.1 Как каждый протокол реализует ISubjectSession

**stdio протокол** (git_repo, script, docker с stdio):
```
session.send(input) 
  → JSON.encode(input) → write to stdin
  → read stdout → JSON.decode → SubjectOutput
```

**HTTP протокол** (api_endpoint, git_repo с HTTP сервером):
```
session.send(input) 
  → POST /invoke {body: input}
  → response body → SubjectOutput
```

**openai_compatible протокол** (llm_endpoint):
```
session.send(input)
  → POST /v1/chat/completions {messages: input.data['messages']}
  → response → SubjectOutput{data: {text: content, tool_calls: ...}}
```

**prompt_eval протокол** (prompt_template):
```
session.send({code: "..."})
  → render template with variables
  → get llm_ref session
  → send rendered prompt via openai_compatible
  → SubjectOutput
```

**aq_engine протокол** (aq_graph):
```
session.send(input)
  → IAQGraphEngineClient.instance.run(GraphRunRequest)
  → Stream<GraphRunEvent> → map to Stream<SubjectEvent>
  → on completion → SubjectOutput
```

**mcp протокол** (mcp_server):
```
session.send({tool: "name", args: {...}})
  → MCP JSON-RPC tools/call
  → SubjectOutput
```

---

## 7. SandboxSession API — что видит пользователь снаружи

Это HTTP REST API который пользователь (или его код) использует для работы с AQSandbox.

### 7.1 Регистрация субъекта

```http
POST /api/v1/subjects
Content-Type: application/json
Authorization: Bearer {api_key}

{
  "$schema": "https://aq.dev/schemas/subject/v1",
  "kind": "AQSubject",
  ...  // SubjectDescriptor
}

→ 201 Created
{
  "subject_id": "subj_abc123",
  "name": "my-code-agent",
  "version": "1.2.0",
  "status": "defined",
  "validation": { "ok": true },
  "links": {
    "provision": "/api/v1/subjects/subj_abc123/provision",
    "sessions": "/api/v1/subjects/subj_abc123/sessions"
  }
}
```

### 7.2 Провизионирование (однократно)

```http
POST /api/v1/subjects/{subject_id}/provision

→ 202 Accepted
{
  "provision_id": "prov_xyz789",
  "status": "provisioning",
  "stream": "/api/v1/provisions/prov_xyz789/events"
}

GET /api/v1/provisions/prov_xyz789/events (SSE)
→ data: {"type": "log", "message": "Cloning repository..."}
→ data: {"type": "log", "message": "Running dart pub get..."}
→ data: {"type": "completed", "artifact_id": "art_def456", "cached": false}
```

### 7.3 Создание сессии

```http
POST /api/v1/subjects/{subject_id}/sessions
Content-Type: application/json

{
  "sandbox_policy": "strict",           // именованная политика или inline
  "tool_overrides": {
    "llm": {
      "model": "claude-haiku-4",        // переопределить модель для этой сессии
      "api_key_ref": "$secrets.MY_KEY"
    }
  },
  "environment": {
    "DEBUG": "true"
  },
  "timeout_minutes": 15
}

→ 201 Created
{
  "session_id": "sess_ghi012",
  "subject_id": "subj_abc123",
  "status": "active",
  "sandbox_info": {
    "runtime": "docker",
    "container_id": "c_jkl345",
    "sandbox_id": "sbx_mno678"
  },
  "links": {
    "send": "/api/v1/sessions/sess_ghi012/invoke",
    "events": "/api/v1/sessions/sess_ghi012/events",
    "dispose": "/api/v1/sessions/sess_ghi012"
  }
}
```

### 7.4 Вызов субъекта

```http
POST /api/v1/sessions/{session_id}/invoke
Content-Type: application/json

{
  "input": {
    "task": "Найди memory leaks в этом коде",
    "context": "Flutter приложение"
  },
  "stream": true   // потоковый ответ через SSE
}

→ 200 OK (SSE если stream: true)
data: {"type": "progress", "progress": 0.1, "label": "Анализируем код..."}
data: {"type": "tool_call", "tool": "llm_complete", "args": {"prompt": "..."}}
data: {"type": "tool_result", "tool": "llm_complete", "result": "..."}
data: {"type": "progress", "progress": 0.9}
data: {"type": "output", "data": {"result": "Найдено 2 потенциальных утечки...", "files_changed": []}}
data: {"type": "done"}
```

### 7.5 Завершение сессии

```http
DELETE /api/v1/sessions/{session_id}
Content-Type: application/json

{
  "save_artifacts": true,
  "vault_destination": "experiments/run-2026-01-15"
}

→ 200 OK
{
  "session_id": "sess_ghi012",
  "status": "disposed",
  "duration_seconds": 47,
  "artifacts_saved": ["workspace/output.md", "workspace/report.json"],
  "tool_calls_count": 12,
  "tokens_used": 3420
}
```

---

## 8. Handshake: субъект внутри sandbox

Когда субъект (git_repo, script) стартует внутри sandbox, он получает конфигурацию
своих инструментов через единый механизм — **environment injection**:

```bash
# Переменные окружения которые субъект получает при старте
AQ_SESSION_ID=sess_ghi012
AQ_SUBJECT_ID=subj_abc123
AQ_TOOLS_ENDPOINT=http://localhost:8765    # локальный tools proxy в sandbox
AQ_LLM_BASE_URL=http://localhost:8765/llm  # OpenAI-compatible proxy
AQ_LLM_MODEL=claude-sonnet-4-6
AQ_VAULT_ENDPOINT=http://localhost:8765/vault
AQ_WORK_DIR=/workspace
AQ_SECRETS_DIR=/run/secrets               # секреты доступны как файлы
```

**AQ_TOOLS_ENDPOINT** — это локальный proxy внутри sandbox, который:
- Принимает OpenAI-compatible запросы к LLM
- Проксирует в настроенный LLM provider с правильным API ключом
- Проксирует vault операции
- Маршрутизирует MCP вызовы
- Логирует все вызовы в audit log

Субъект (любой язык, любой фреймворк) использует стандартный OpenAI SDK
и получает доступ к LLM, vault и инструментам — без знания об AQ.

```python
# Python-агент внутри sandbox — использует стандартный OpenAI SDK
import os
from openai import OpenAI

client = OpenAI(
    base_url=os.environ['AQ_LLM_BASE_URL'],
    api_key='not-needed'  # proxy не требует ключ — он у sandbox
)

response = client.chat.completions.create(
    model=os.environ['AQ_LLM_MODEL'],
    messages=[{"role": "user", "content": "Analyze this code..."}]
)
```

```dart
// Dart-агент — то же самое
final client = AnthropicClient(
  baseUrl: Platform.environment['AQ_LLM_BASE_URL']!,
  apiKey: 'injected-by-sandbox',
);
```

**Важно:** субъект не знает какой LLM используется. Не знает какой API ключ.
Не знает что он в sandbox. Он знает только что есть endpoint — и это достаточно.

---

## 9. Связь с AQ Platform (принцип типизированных клиентов)

`AQSubject` — новый доменный объект в `aq_schema`.

```dart
// aq_schema/sandbox.dart — добавляется

/// Дескриптор субъекта — определение испытуемого
class AQSubjectDescriptor {
  final String kind;       // "git_repo", "llm_endpoint", "aq_graph", ...
  final AQSubjectMeta metadata;
  final AQSubjectSpec spec;
}

/// Интерфейс реестра субъектов
abstract interface class IAQSubjectRegistry {
  static IAQSubjectRegistry get instance => AQPlatform.resolve();

  Future<AQSubjectRecord> register(AQSubjectDescriptor descriptor);
  Future<AQSubjectRecord> get(String subjectId);
  Future<void> provision(String subjectId);
  Future<ISubjectSession> createSession(String subjectId, SessionConfig config);
  Future<List<AQSubjectRecord>> list({String? namespace, String? kind});
}

/// Клиент для сессии — что получает потребитель
abstract interface class ISubjectSession {
  String get sessionId;
  Future<SubjectOutput> send(SubjectInput input);
  Stream<SubjectOutputChunk> sendStream(SubjectInput input);
  Stream<SubjectEvent> get events;
  Future<SubjectSessionResult> dispose({bool saveArtifacts = true});
}
```

**Типизированные клиенты по потребителям:**

| Потребитель | Клиент | Что получает |
|---|---|---|
| Пользователь через UI | `IAQSubjectUserClient` | register, provision, createSession, list своих субъектов |
| AQ Graph Engine | `IAQSubjectEngineClient` | createSession для aq_graph субъектов |
| CI/CD / Polygon | `IAQSubjectCiClient` | createSession + dispose с artifact saving |
| Администратор | `IAQSubjectAdminClient` | + cross-workspace list, force-dispose, billing |
| Тест | `MockSubjectRegistry` | заглушки с очередью заготовленных ответов |

---

## 10. Граф как субъект — интеграция AQStudio

AQ Graph Engine — один из потребителей AQSandbox, не привилегированный.
Граф регистрируется как `AQSubject` с kind = `aq_graph`.

```dart
// AQ Graph Worker — точка интеграции

// 1. При запуске run — создать субъект из графа (или взять из кеша)
final subjectId = await IAQSubjectRegistry.instance.ensureRegistered(
  AQSubjectDescriptor(
    kind: 'aq_graph',
    metadata: AQSubjectMeta(name: 'workflow-${blueprintId}'),
    spec: AQSubjectSpec.aqGraph(
      blueprintId: blueprintId,
      versionId: versionId,
      tools: toolConfig,         // LLM, vault, MCP — из конфига проекта
    ),
  ),
);

// 2. Создать сессию для этого run
final session = await IAQSubjectRegistry.instance.createSession(
  subjectId,
  SessionConfig(
    sandboxPolicy: project.sandboxPolicy,
    timeout: run.timeoutMinutes,
  ),
);

// 3. Граф работает через сессию — движок просто слушает события
final result = await session.send(SubjectInput(data: run.inputs));
await for (final event in session.events) {
  // GraphRunEvent → маппим в SubjectEvent → UI получает обновления
  runEventBus.emit(event.toRunEvent(run.id));
}

// 4. По завершении
final outcome = await session.dispose(saveArtifacts: run.saveArtifacts);
```

Движок не знает о Docker, о MCP, о конкретных LLM. Он знает `ISubjectSession`.
Тяжёлая работа — в AQSandbox.

---

## Итог: что решает AQSubject

| Вопрос | Ответ |
|---|---|
| Что запускать? | `spec.kind` + `spec.source` |
| Как это получить? | Provisioner по kind |
| Где запускать? | `spec.runtime` → AQSandbox выбирает Runtime |
| С чем работать? | `spec.tools` + `spec.capabilities` |
| Как разговаривать? | `spec.interface.protocol` → SubjectProtocol adapter |
| Насколько безопасно? | `spec.resources` + SandboxPolicy |
| Кто управляет? | `IAQSubjectRegistry` + `IAQSandboxClient` |

**AQSubject — это то, что у пользователя есть.**  
**AQSandbox — это то, что пользователь получает от нас.**  
**AQToolRuntime — это то, чем субъект может пользоваться внутри.**

*Документ v1.0. AQ Platform. 2026.*