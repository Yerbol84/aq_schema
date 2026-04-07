# Дамп проекта aq_schema

**Всего обработано файлов:** 128
**Включено:** 99
**Пропущено:** 29

## Включённые файлы

| Файл | Строк | Размер (байт) |
|------|-------|---------------|
| `./.gitignore` |        3 |       86 |
| `./analysis_options.yaml` |       30 |     1038 |
| `./lib/adapter/adapter_models.dart` |      260 |     8530 |
| `./lib/aq_schema.dart` |       58 |     2738 |
| `./lib/auth/models/auth_context.dart` |      315 |    11271 |
| `./lib/data_layer/aq_domains.dart` |      105 |     3485 |
| `./lib/data_layer/models/access_grant.dart` |       19 |      534 |
| `./lib/data_layer/models/access_level.dart` |       15 |      380 |
| `./lib/data_layer/models/field_diff.dart` |       35 |      818 |
| `./lib/data_layer/models/increment_type.dart` |        2 |      103 |
| `./lib/data_layer/models/log_entry.dart` |       92 |     2944 |
| `./lib/data_layer/models/log_operation.dart` |       12 |      279 |
| `./lib/data_layer/models/query/page_result.dart` |       41 |     1075 |
| `./lib/data_layer/models/query/vault_filter.dart` |       16 |      447 |
| `./lib/data_layer/models/query/vault_index.dart` |       20 |      535 |
| `./lib/data_layer/models/query/vault_operator.dart` |       89 |     2708 |
| `./lib/data_layer/models/query/vault_query.dart` |      120 |     3618 |
| `./lib/data_layer/models/query/vault_sort.dart` |        7 |      179 |
| `./lib/data_layer/models/semver.dart` |       49 |     1416 |
| `./lib/data_layer/models/version_node.dart` |      130 |     4583 |
| `./lib/data_layer/models/version_status.dart` |       24 |      655 |
| `./lib/data_layer/storable/artifact_entry.dart` |       28 |      855 |
| `./lib/data_layer/storable/direct_storable.dart` |        4 |      161 |
| `./lib/data_layer/storable/logged_storable.dart` |        9 |      352 |
| `./lib/data_layer/storable/sql_query_translator.dart` |       65 |     1886 |
| `./lib/data_layer/storable/storable.dart` |       21 |      807 |
| `./lib/data_layer/storable/versioned_storable.dart` |       11 |      342 |
| `./lib/data_layer/storage/artifact_storage.dart` |       54 |     2683 |
| `./lib/data_layer/storage/buffered_storage.dart` |      106 |     6695 |
| `./lib/data_layer/storage/vault_storage.dart` |       78 |     3740 |
| `./lib/data_layer/storage/vector_storage.dart` |      114 |     4488 |
| `./lib/graph/core/graph_def.dart` |       62 |     2912 |
| `./lib/graph/engine/i_hand.dart` |       25 |     1263 |
| `./lib/graph/engine/run_context.dart` |      166 |     5834 |
| `./lib/graph/engine/tool_registry.dart` |       28 |      961 |
| `./lib/graph/graph.dart` |       28 |      909 |
| `./lib/graph/graphs/contract_schema.dart` |      326 |    11852 |
| `./lib/graph/graphs/instruction_graph.dart` |      267 |     7940 |
| `./lib/graph/graphs/prompt_graph.dart` |      214 |     5833 |
| `./lib/graph/graphs/workflow_graph.dart` |      245 |     6914 |
| `./lib/graph/graphs/workflow/i_workflow_run.dart` |        1 |       31 |
| `./lib/graph/logging/workflow_event_logger.dart` |      161 |     4464 |
| `./lib/graph/transport/analysis_options.yaml` |        0 |       39 |
| `./lib/graph/transport/interfaces/i_engine_transport.dart` |       27 |     1302 |
| `./lib/graph/transport/messages/run_event.dart` |      138 |     3909 |
| `./lib/graph/transport/messages/run_request.dart` |       61 |     2236 |
| `./lib/graph/transport/messages/run_status.dart` |       27 |      678 |
| `./lib/graph/transport/messages/user_input_response.dart` |       44 |     1431 |
| `./lib/graph/validation/graph_contract_validator.dart` |       59 |     2034 |
| `./lib/mcp/models/mcp_capabilities.dart` |      131 |     3673 |
| `./lib/mcp/models/mcp_error.dart` |      149 |     4868 |
| `./lib/mcp/models/mcp_request.dart` |      259 |     8219 |
| `./lib/mcp/models/mcp_tool.dart` |      117 |     3093 |
| `./lib/mcp/schemas/initialize_response.json` |       77 |     2265 |
| `./lib/mcp/schemas/tools_call_response.json` |       64 |     1858 |
| `./lib/mcp/validators/mcp_validator.dart` |      213 |     7578 |
| `./lib/queue/in_memory_job_queue.dart` |      294 |     8910 |
| `./lib/queue/job_queue.dart` |       90 |     3312 |
| `./lib/queue/models/queue_job_status.dart` |       54 |     1716 |
| `./lib/queue/roles/job_consumer.dart` |       57 |     2050 |
| `./lib/queue/roles/job_worker_client.dart` |      108 |     4162 |
| `./lib/sandbox/interfaces/i_sandbox_actor.dart` |       26 |     1205 |
| `./lib/sandbox/interfaces/i_sandbox_as_chat.dart` |       54 |     2541 |
| `./lib/sandbox/interfaces/i_sandbox_as_environment.dart` |       51 |     2522 |
| `./lib/sandbox/interfaces/i_sandbox_as_function.dart` |       33 |     1640 |
| `./lib/sandbox/interfaces/i_sandbox_as_process.dart` |       54 |     2409 |
| `./lib/sandbox/interfaces/i_sandbox_capable.dart` |       28 |     1535 |
| `./lib/sandbox/interfaces/i_sandbox_context.dart` |       72 |     3698 |
| `./lib/sandbox/interfaces/i_sandbox_event.dart` |       25 |      902 |
| `./lib/sandbox/interfaces/i_sandbox_item.dart` |       17 |      835 |
| `./lib/sandbox/interfaces/i_sandbox_registry.dart` |       22 |      903 |
| `./lib/sandbox/interfaces/i_sandbox_schema.dart` |       18 |      786 |
| `./lib/sandbox/interfaces/i_sandbox.dart` |       31 |     1835 |
| `./lib/sandbox/policy/sandbox_capabilities.dart` |       41 |     2183 |
| `./lib/sandbox/policy/sandbox_policy_violation.dart` |       21 |      695 |
| `./lib/sandbox/policy/sandbox_policy.dart` |      118 |     4479 |
| `./lib/sandbox/sandbox_policy_test.dart` |      103 |     3396 |
| `./lib/sandbox/sandbox.dart` |       29 |      991 |
| `./lib/security/interfaces/i_session_repository.dart` |       35 |     1237 |
| `./lib/security/interfaces/i_user_repository.dart` |       30 |     1141 |
| `./lib/security/models/aq_api_key.dart` |      255 |     7717 |
| `./lib/security/models/aq_profile.dart` |       61 |     1662 |
| `./lib/security/models/aq_role.dart` |      116 |     3254 |
| `./lib/security/models/aq_session.dart` |      122 |     3563 |
| `./lib/security/models/aq_tenant.dart` |      107 |     2856 |
| `./lib/security/models/aq_token_claims.dart` |      157 |     4286 |
| `./lib/security/models/aq_user.dart` |      137 |     3956 |
| `./lib/security/security.dart` |       32 |     1654 |
| `./lib/security/storable/security_domains.dart` |       92 |     4338 |
| `./lib/security/storable/security_storables.dart` |      237 |     7413 |
| `./lib/security/token/token_codec.dart` |      124 |     4516 |
| `./lib/security/token/token_validator.dart` |       95 |     2901 |
| `./lib/studio_project/aq_studio_project.dart` |       77 |     1946 |
| `./lib/validator/aq_schema_validator.dart` |       50 |     1680 |
| `./lib/validator/aq_validation_result.dart` |       20 |      449 |
| `./lib/worker/models/worker_models.dart` |      448 |    13951 |
| `./lib/worker/validators/worker_validator.dart` |      209 |     7416 |
| `./pubspec.yaml` |       16 |      306 |
| `./README.md` |        2 |      122 |

---

## Пропущенные файлы

| Файл | Причина |
|------|---------|
| `./lib/.DS_Store` | бинарный файл |
| `./lib/adapter/.DS_Store` | бинарный файл |
| `./lib/adapter/schemas/adapter_error_response.json` | бинарный файл |
| `./lib/adapter/schemas/adapter_status.json` | бинарный файл |
| `./lib/aq_deploy.schema.json` | бинарный файл |
| `./lib/auth/.DS_Store` | бинарный файл |
| `./lib/auth/schemas/auth_context.json` | бинарный файл |
| `./lib/auth/schemas/auth_result.json` | бинарный файл |
| `./lib/auth/schemas/auth_token_payload.json` | бинарный файл |
| `./lib/data_layer/models/.DS_Store` | бинарный файл |
| `./lib/mcp/.DS_Store` | бинарный файл |
| `./lib/mcp/doc/sprint_plan.html` | исключён по шаблону |
| `./lib/mcp/doc/startegy.html` | исключён по шаблону |
| `./lib/mcp/schemas/initialize.json` | бинарный файл |
| `./lib/mcp/schemas/mcp_error.json` | бинарный файл |
| `./lib/mcp/schemas/mcp_tool.json` | бинарный файл |
| `./lib/mcp/schemas/tools_call_request.json` | бинарный файл |
| `./lib/mcp/schemas/tools_list_response.json` | бинарный файл |
| `./lib/queue/schemas/queue_job_status.json` | бинарный файл |
| `./lib/sandbox/schema/sandbox_base.schema.json` | бинарный файл |
| `./lib/sandbox/schema/sandbox_event.schema.json` | бинарный файл |
| `./lib/sandbox/schema/sandbox_item.schema.json` | бинарный файл |
| `./lib/sandbox/schema/sandbox_policy.schema.json` | бинарный файл |
| `./lib/security/schema/auth_schema.json` | бинарный файл |
| `./lib/worker/schemas/worker_health.json` | бинарный файл |
| `./lib/worker/schemas/worker_job.json` | бинарный файл |
| `./lib/worker/schemas/worker_registration_response.json` | бинарный файл |
| `./lib/worker/schemas/worker_registration.json` | бинарный файл |
| `./lib/worker/schemas/worker_result.json` | бинарный файл |

---

## Содержимое включённых файлов

### Файл: `./.gitignore` (строк:        3, размер:       86 байт)

```
# https://dart.dev/guides/libraries/private-files
# Created by `dart pub`
.dart_tool/
```

### Файл: `./analysis_options.yaml` (строк:       30, размер:     1038 байт)

```yaml
# This file configures the static analysis results for your project (errors,
# warnings, and lints).
#
# This enables the 'recommended' set of lints from `package:lints`.
# This set helps identify many issues that may lead to problems when running
# or consuming Dart code, and enforces writing Dart using a single, idiomatic
# style and format.
#
# If you want a smaller set of lints you can change this to specify
# 'package:lints/core.yaml'. These are just the most critical lints
# (the recommended set includes the core lints).
# The core lints are also what is used by pub.dev for scoring packages.

include: package:lints/recommended.yaml

# Uncomment the following section to specify additional rules.

# linter:
#   rules:
#     - camel_case_types

# analyzer:
#   exclude:
#     - path/to/excluded/files/**

# For more information about the core and recommended set of lints, see
# https://dart.dev/go/core-lints

# For additional information about configuring this file, see
# https://dart.dev/guides/language/analysis-options
```

### Файл: `./lib/adapter/adapter_models.dart` (строк:      260, размер:     8530 байт)

```dart
/// Модели для протоколов адаптера.
///
/// Эти типы соответствуют JSON-схемам в:
///   - adapter/schemas/adapter_status.json
///   - adapter/schemas/adapter_error_response.json
///   - worker/schemas/worker_registration_response.json
///
/// Все внешние протоколы адаптера декларируются здесь.
/// Приложение aq_mcp_adapter не создаёт протокольные модели самостоятельно —
/// только использует эти типы.
library;

// ══════════════════════════════════════════════════════════
//  WorkerRegistrationResponse
// ══════════════════════════════════════════════════════════

/// Ответ адаптера воркеру при успешной регистрации.
///
/// Соответствует: worker/schemas/worker_registration_response.json
///
/// Воркер читает [queueKey] и начинает BRPOP на этом Redis-ключе.
final class WorkerRegistrationResponse {
  const WorkerRegistrationResponse({
    required this.workerId,
    required this.queueKey,
    required this.registeredAt,
    this.adapterVersion = '0.1.0',
  });

  factory WorkerRegistrationResponse.fromJson(Map<String, dynamic> json) =>
      WorkerRegistrationResponse(
        workerId: json['worker_id'] as String,
        queueKey: json['queue_key'] as String,
        registeredAt: json['registered_at'] as int,
        adapterVersion: (json['adapter_version'] as String?) ?? '0.1.0',
      );

  final String workerId;

  /// Redis LIST ключ для BRPOP. Формат: aq:queue:jobs:{worker_id}
  final String queueKey;

  final int registeredAt;
  final String adapterVersion;

  Map<String, dynamic> toJson() => {
        'ok': true,
        'worker_id': workerId,
        'queue_key': queueKey,
        'adapter_version': adapterVersion,
        'registered_at': registeredAt,
      };
}

// ══════════════════════════════════════════════════════════
//  AdapterStatus
// ══════════════════════════════════════════════════════════

/// Статус адаптера для GET / и GET /health.
///
/// Соответствует: adapter/schemas/adapter_status.json
///
/// Используется браузером, мониторингом, Docker healthcheck.
final class AdapterStatus {
  const AdapterStatus({
    required this.ok,
    required this.status,
    required this.mcp,
    required this.workers,
    required this.tools,
    required this.timestamp,
    this.queue,
    this.uptimeSeconds,
  });

  final bool ok;
  final AdapterLifecycleStatus status;
  final McpStatus mcp;
  final WorkersStatus workers;
  final ToolsStatus tools;
  final QueueStatus? queue;
  final int timestamp;
  final int? uptimeSeconds;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'ok': ok,
      'status': status.value,
      'mcp': mcp.toJson(),
      'workers': workers.toJson(),
      'tools': tools.toJson(),
      'timestamp': timestamp,
    };
    if (queue != null) map['queue'] = queue!.toJson();
    if (uptimeSeconds != null) map['uptime_seconds'] = uptimeSeconds;
    return map;
  }
}

/// Жизненный цикл адаптера.
enum AdapterLifecycleStatus {
  starting('starting'),
  ready('ready'),
  degraded('degraded'),
  stopping('stopping');

  const AdapterLifecycleStatus(this.value);
  final String value;
}

/// MCP-специфичный статус.
final class McpStatus {
  const McpStatus({
    required this.initialized,
    required this.protocolVersion,
    required this.serverName,
    required this.serverVersion,
    this.transport = 'http',
  });

  final bool initialized;
  final String protocolVersion;
  final String serverName;
  final String serverVersion;
  final String transport;

  Map<String, dynamic> toJson() => {
        'initialized': initialized,
        'protocol_version': protocolVersion,
        'server_name': serverName,
        'server_version': serverVersion,
        'transport': transport,
      };
}

/// Статус зарегистрированных воркеров.
final class WorkersStatus {
  const WorkersStatus({required this.count, required this.registered});

  final int count;
  final List<WorkerStatusEntry> registered;

  Map<String, dynamic> toJson() => {
        'count': count,
        'registered': registered.map((w) => w.toJson()).toList(),
      };
}

/// Краткая информация об одном воркере для статус-ответа.
final class WorkerStatusEntry {
  const WorkerStatusEntry({
    required this.workerId,
    required this.toolCount,
    this.language,
    this.status = 'healthy',
  });

  final String workerId;
  final int toolCount;
  final String? language;
  final String status;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'worker_id': workerId,
      'tool_count': toolCount,
      'status': status,
    };
    if (language != null) map['language'] = language;
    return map;
  }
}

/// Статус инструментов.
final class ToolsStatus {
  const ToolsStatus({required this.count, required this.names});

  final int count;
  final List<String> names;

  Map<String, dynamic> toJson() => {'count': count, 'names': names};
}

/// Статус соединения с Redis.
final class QueueStatus {
  const QueueStatus({required this.connected, required this.host});

  final bool connected;
  final String host;

  Map<String, dynamic> toJson() => {'connected': connected, 'host': host};
}

// ══════════════════════════════════════════════════════════
//  AdapterErrorResponse
// ══════════════════════════════════════════════════════════

/// Стандартный ответ при ошибках HTTP-эндпоинтов адаптера.
///
/// Соответствует: adapter/schemas/adapter_error_response.json
///
/// НЕ используется для MCP JSON-RPC ошибок (те используют McpError).
/// Только для HTTP-эндпоинтов: /workers/register, /workers/health, /health.
final class AdapterErrorResponse {
  const AdapterErrorResponse({
    required this.error,
    required this.code,
    this.details = const [],
  });

  final String error;
  final AdapterErrorCode code;
  final List<String> details;

  Map<String, dynamic> toJson() => {
        'ok': false,
        'error': error,
        'code': code.value,
        if (details.isNotEmpty) 'details': details,
      };

  // ── Convenience constructors ───────────────────────────

  static AdapterErrorResponse validationFailed(List<String> errors) =>
      AdapterErrorResponse(
        error: 'Request validation failed',
        code: AdapterErrorCode.validationFailed,
        details: errors,
      );

  static AdapterErrorResponse schemaViolation(String detail) =>
      AdapterErrorResponse(
        error: 'Schema violation: $detail',
        code: AdapterErrorCode.schemaViolation,
      );

  static AdapterErrorResponse internalError([String? detail]) =>
      AdapterErrorResponse(
        error: detail ?? 'Internal server error',
        code: AdapterErrorCode.internalError,
      );

  static AdapterErrorResponse queueUnavailable() =>
      AdapterErrorResponse(
        error: 'Redis queue is not available',
        code: AdapterErrorCode.queueUnavailable,
      );
}

/// Машино-читаемые коды ошибок адаптера.
enum AdapterErrorCode {
  validationFailed('validation_failed'),
  schemaViolation('schema_violation'),
  workerIdConflict('worker_id_conflict'),
  internalError('internal_error'),
  queueUnavailable('queue_unavailable');

  const AdapterErrorCode(this.value);
  final String value;
}
```

### Файл: `./lib/aq_schema.dart` (строк:       58, размер:     2738 байт)

```dart
/// aq_schema — Core JSON schemas, Dart models, validators and abstract interfaces.
///
/// This is the single source of truth for the MCP Dart Ecosystem.
/// All other packages (aq_mcp_core, aq_queue, aq_auth, aq_mcp_adapter, aq_worker)
/// depend ONLY on this package — never on each other except through this.
///
/// Domains:
///   mcp/    — MCP protocol types (tools, requests, responses, errors)
///   worker/ — Worker protocol types (jobs, results, registration, health)
///   queue/  — Queue abstractions (job status, JobQueue, WorkerRegistry interfaces)
///   auth/   — Auth types (token payload, context, result, provider interface)
library aq_schema;

// ── MCP domain ────────────────────────────────────────────

export 'worker/models/worker_models.dart';
export 'mcp/models/mcp_capabilities.dart';
export 'mcp/models/mcp_error.dart';
export 'mcp/models/mcp_request.dart';
export 'mcp/models/mcp_tool.dart';
export 'mcp/validators/mcp_validator.dart';
export 'auth/models/auth_context.dart';
export 'worker/validators/worker_validator.dart';
export 'queue/models/queue_job_status.dart';
export 'queue/job_queue.dart';
export 'queue/roles/job_consumer.dart';
export 'queue/roles/job_worker_client.dart';

export 'graph/graph.dart';
export 'graph/graphs/workflow/i_workflow_run.dart';
export 'studio_project/aq_studio_project.dart';
export 'data_layer/models/query/vault_query.dart';
export 'data_layer/models/query/vault_sort.dart';
export 'data_layer/models/query/vault_operator.dart';
export 'data_layer/models/query/vault_index.dart';
export 'data_layer/models/query/vault_filter.dart';
export 'data_layer/models/query/page_result.dart';
export 'data_layer/models/access_grant.dart';
export 'data_layer/models/access_level.dart';
export 'data_layer/models/field_diff.dart';
export 'data_layer/models/increment_type.dart';
export 'data_layer/models/log_entry.dart';
export 'data_layer/models/log_operation.dart';
export 'data_layer/models/semver.dart';
export 'data_layer/models/version_node.dart';
export 'data_layer/models/version_status.dart';
export 'data_layer/storable/artifact_entry.dart';
export 'data_layer/storage/artifact_storage.dart';
export 'data_layer/storable/direct_storable.dart';
export 'data_layer/storable/logged_storable.dart';
export 'data_layer/storable/sql_query_translator.dart';
export 'data_layer/storable/storable.dart';
export 'data_layer/storage/vault_storage.dart';
export 'data_layer/storage/vector_storage.dart';
export 'data_layer/storable/versioned_storable.dart';
export 'sandbox/sandbox.dart';
export 'data_layer/aq_domains.dart';
export 'data_layer/storage/buffered_storage.dart';
```

### Файл: `./lib/auth/models/auth_context.dart` (строк:      315, размер:    11271 байт)

```dart
/// Auth domain models and abstract interfaces.
///
/// v1 uses MockAuthProvider (always success).
/// v2 will plug in JwtAuthProvider / OAuth2AuthProvider without
/// changing any other packages in the ecosystem.
library;

// ══════════════════════════════════════════════════════════
//  Enums
// ══════════════════════════════════════════════════════════

/// Authorization mechanism type.
enum AuthType {
  bearer('bearer'),
  apikey('apikey'),
  oauth2('oauth2'),
  oauth2Token('oauth2_token'),
  none('none'),
  mock('mock');

  const AuthType(this.value);
  final String value;

  static AuthType fromString(String s) => switch (s) {
        'bearer' => AuthType.bearer,
        'apikey' => AuthType.apikey,
        'oauth2' => AuthType.oauth2,
        'oauth2_token' => AuthType.oauth2Token,
        'mock' => AuthType.mock,
        _ => AuthType.none,
      };
}

/// Reason why auth validation failed.
enum AuthFailureReason {
  tokenMissing('token_missing'),
  tokenExpired('token_expired'),
  tokenInvalid('token_invalid'),
  tokenRevoked('token_revoked'),
  scopeInsufficient('scope_insufficient'),
  serviceUnavailable('service_unavailable');

  const AuthFailureReason(this.value);
  final String value;

  static AuthFailureReason fromString(String s) => AuthFailureReason.values
      .firstWhere((e) => e.value == s, orElse: () => AuthFailureReason.tokenInvalid);
}

// ══════════════════════════════════════════════════════════
//  AuthTokenPayload — raw incoming token from MCP client
// ══════════════════════════════════════════════════════════

/// Raw token payload passed in `params._aq_auth` by MCP client.
/// This is the input — not yet validated.
final class AuthTokenPayload {
  const AuthTokenPayload({
    required this.type,
    this.token,
    this.oauth2,
  });

  factory AuthTokenPayload.fromJson(Map<String, dynamic> json) {
    final oauth2Raw = json['oauth2'] as Map<String, dynamic>?;
    return AuthTokenPayload(
      type: AuthType.fromString((json['type'] as String?) ?? 'none'),
      token: json['token'] as String?,
      oauth2: oauth2Raw != null ? OAuth2TokenPayload.fromJson(oauth2Raw) : null,
    );
  }

  final AuthType type;
  final String? token;
  final OAuth2TokenPayload? oauth2;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'type': type.value};
    if (token != null) map['token'] = token;
    if (oauth2 != null) map['oauth2'] = oauth2!.toJson();
    return map;
  }

  static const empty = AuthTokenPayload(type: AuthType.none);
}

/// OAuth2 token data inside [AuthTokenPayload].
final class OAuth2TokenPayload {
  const OAuth2TokenPayload({
    required this.accessToken,
    required this.tokenType,
    this.refreshToken,
    this.expiresIn,
    this.scope,
  });

  factory OAuth2TokenPayload.fromJson(Map<String, dynamic> json) =>
      OAuth2TokenPayload(
        accessToken: json['access_token'] as String,
        tokenType: json['token_type'] as String,
        refreshToken: json['refresh_token'] as String?,
        expiresIn: json['expires_in'] as int?,
        scope: json['scope'] as String?,
      );

  final String accessToken;
  final String tokenType;
  final String? refreshToken;
  final int? expiresIn;
  final String? scope;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'access_token': accessToken,
      'token_type': tokenType,
    };
    if (refreshToken != null) map['refresh_token'] = refreshToken;
    if (expiresIn != null) map['expires_in'] = expiresIn;
    if (scope != null) map['scope'] = scope;
    return map;
  }
}

// ══════════════════════════════════════════════════════════
//  AuthContext — internal validated state
// ══════════════════════════════════════════════════════════

/// Validated auth state. Created by [AuthProvider] after successful validation.
/// Passed into the Redis queue alongside the job — never contains raw tokens.
final class AuthContext {
  const AuthContext({
    required this.type,
    required this.validated,
    required this.timestamp,
    this.subject,
    this.scopes = const [],
    this.claims,
    this.expiresAt,
    this.isMock = false,
  });

  factory AuthContext.fromJson(Map<String, dynamic> json) => AuthContext(
        type: AuthType.fromString(json['type'] as String),
        validated: json['validated'] as bool,
        timestamp: json['timestamp'] as int,
        subject: json['subject'] as String?,
        scopes: (json['scopes'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        claims: json['claims'] as Map<String, dynamic>?,
        expiresAt: json['expires_at'] as int?,
        isMock: (json['_mock'] as bool?) ?? false,
      );

  final AuthType type;
  final bool validated;
  final int timestamp;
  final String? subject;
  final List<String> scopes;
  final Map<String, dynamic>? claims;
  final int? expiresAt;

  /// AQ EXTENSION: true when MockAuthProvider was used.
  final bool isMock;

  bool get isExpired {
    if (expiresAt == null) return false;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return now >= expiresAt!;
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'type': type.value,
      'validated': validated,
      'timestamp': timestamp,
    };
    if (subject != null) map['subject'] = subject;
    if (scopes.isNotEmpty) map['scopes'] = scopes;
    if (claims != null) map['claims'] = claims;
    if (expiresAt != null) map['expires_at'] = expiresAt;
    if (isMock) map['_mock'] = true;
    return map;
  }

  /// Pre-built mock context used by [MockAuthProvider].
  static AuthContext mockContext() => AuthContext(
        type: AuthType.mock,
        validated: true,
        subject: 'mock-user',
        scopes: const ['*'],
        isMock: true,
        timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      );

  /// Pre-built unauthenticated context for tools that don't require auth.
  static AuthContext anonymous() => AuthContext(
        type: AuthType.none,
        validated: true,
        timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      );

  @override
  String toString() =>
      'AuthContext(type: ${type.value}, subject: $subject, mock: $isMock)';
}

// ══════════════════════════════════════════════════════════
//  AuthResult — validation output
// ══════════════════════════════════════════════════════════

/// Result returned by [AuthProvider.validate].
final class AuthResult {
  const AuthResult({
    required this.success,
    required this.timestamp,
    this.context,
    this.failureReason,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    final ctxRaw = json['context'] as Map<String, dynamic>?;
    final errorStr = json['error'] as String?;
    return AuthResult(
      success: json['success'] as bool,
      timestamp: json['timestamp'] as int,
      context: ctxRaw != null ? AuthContext.fromJson(ctxRaw) : null,
      failureReason: errorStr != null
          ? AuthFailureReason.fromString(errorStr)
          : null,
    );
  }

  /// True when token was accepted.
  final bool success;

  /// Populated when [success] is true.
  final AuthContext? context;

  /// Populated when [success] is false.
  final AuthFailureReason? failureReason;

  final int timestamp;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'success': success,
      'timestamp': timestamp,
    };
    if (context != null) map['context'] = context!.toJson();
    if (failureReason != null) map['error'] = failureReason!.value;
    return map;
  }

  /// Pre-built mock success result.
  static AuthResult mock() => AuthResult(
        success: true,
        context: AuthContext.mockContext(),
        timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      );

  /// Pre-built failure result.
  static AuthResult failure(AuthFailureReason reason) => AuthResult(
        success: false,
        failureReason: reason,
        timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      );

  @override
  String toString() =>
      'AuthResult(success: $success, reason: ${failureReason?.value})';
}

// ══════════════════════════════════════════════════════════
//  AuthProvider — abstract interface
// ══════════════════════════════════════════════════════════

/// Abstract interface for authentication providers.
///
/// v1: [MockAuthProvider] — always returns success, logs calls.
/// v2: JwtAuthProvider, OAuth2AuthProvider — real validation.
///
/// Upper packages (aq_auth, aq_mcp_adapter) depend only on this interface.
/// Swap implementation without changing any other packages.
abstract interface class AuthProvider {
  /// Whether this provider is the mock stub (v1).
  bool get isMock;

  /// Validates a raw token payload from the MCP client.
  Future<AuthResult> validate(AuthTokenPayload tokenPayload);

  /// Refreshes an expired [AuthContext] (OAuth2 only).
  /// Default impl returns the same context unchanged.
  Future<AuthContext> refresh(AuthContext expiredContext);

  /// Checks whether the given context has all [requiredScopes].
  bool hasScope(AuthContext ctx, List<String> requiredScopes);
}

// ══════════════════════════════════════════════════════════
//  AuthMiddleware — abstract interface
// ══════════════════════════════════════════════════════════

/// Middleware interface used by the adapter to gate requests.
///
/// Separates "can this request proceed?" (authenticate)
/// from "can this principal use this tool?" (authorize).
abstract interface class AuthMiddleware {
  /// Authenticates the raw token payload.
  /// Returns a validated [AuthResult].
  Future<AuthResult> authenticate(AuthTokenPayload? payload);

  /// Checks if the authenticated [AuthContext] is allowed to use [toolName].
  Future<bool> authorize(AuthContext ctx, String toolName);
}
```

### Файл: `./lib/data_layer/aq_domains.dart` (строк:      105, размер:     3485 байт)

```dart
import 'package:aq_schema/aq_schema.dart';

/// Describes how a single domain should be stored.
enum StorageKind { direct, versioned, logged }

/// Domain descriptor — everything the data layer needs to manage one domain.
///
/// Both the client (to create the right repository) and the server
/// (to create the right tables) read from [AqDomains.all].
/// One list. One source of truth.
final class DomainDescriptor<T extends Storable> {
  final String collection;
  final StorageKind kind;
  final T Function(Map<String, dynamic>) fromMap;
  final List<VaultIndex> indexes;

  const DomainDescriptor._({
    required this.collection,
    required this.kind,
    required this.fromMap,
    this.indexes = const [],
  });

  factory DomainDescriptor.direct({
    required String collection,
    required T Function(Map<String, dynamic>) fromMap,
    List<VaultIndex> indexes = const [],
  }) =>
      DomainDescriptor._(
          collection: collection,
          kind: StorageKind.direct,
          fromMap: fromMap,
          indexes: indexes);

  factory DomainDescriptor.versioned({
    required String collection,
    required T Function(Map<String, dynamic>) fromMap,
    List<VaultIndex> indexes = const [],
  }) =>
      DomainDescriptor._(
          collection: collection,
          kind: StorageKind.versioned,
          fromMap: fromMap,
          indexes: indexes);

  factory DomainDescriptor.logged({
    required String collection,
    required T Function(Map<String, dynamic>) fromMap,
    List<VaultIndex> indexes = const [],
  }) =>
      DomainDescriptor._(
          collection: collection,
          kind: StorageKind.logged,
          fromMap: fromMap,
          indexes: indexes);
}

/// All AQ Studio domains.
///
/// Server auto-creates tables from this list.
/// Client auto-creates repositories from this list.
/// Add a domain here once — it works everywhere.
class AqDomains {
  AqDomains._();

  static final List<DomainDescriptor> all = [
    // ── Projects ──────────────────────────────────────────────────────────────
    DomainDescriptor.direct(
      collection: AqStudioProject.kCollection,
      fromMap: AqStudioProject.fromMap,
      indexes: [
        VaultIndex(name: 'idx_proj_type', field: 'projectType'),
        VaultIndex(name: 'idx_proj_opened', field: 'lastOpened'),
      ],
    ),

    // ── Graphs ────────────────────────────────────────────────────────────────
    DomainDescriptor.versioned(
      collection: WorkflowGraph.kCollection,
      fromMap: WorkflowGraph.fromMap,
      indexes: [
        VaultIndex(name: 'idx_wf_owner', field: 'ownerId'),
        VaultIndex(name: 'idx_wf_name', field: 'name'),
      ],
    ),

    DomainDescriptor.versioned(
      collection: InstructionGraph.kCollection,
      fromMap: InstructionGraph.fromMap,
      indexes: [
        VaultIndex(name: 'idx_ig_owner', field: 'ownerId'),
        VaultIndex(name: 'idx_ig_name', field: 'name'),
      ],
    ),

    DomainDescriptor.versioned(
      collection: PromptGraph.kCollection,
      fromMap: PromptGraph.fromMap,
      indexes: [
        VaultIndex(name: 'idx_pg_owner', field: 'ownerId'),
        VaultIndex(name: 'idx_pg_name', field: 'name'),
      ],
    ),
  ];
}
```

### Файл: `./lib/data_layer/models/access_grant.dart` (строк:       19, размер:      534 байт)

```dart
import 'access_level.dart';

/// Grants [level] access to [actorId] on a versioned entity.
final class AccessGrant {
  final String actorId;
  final AccessLevel level;

  const AccessGrant({required this.actorId, required this.level});

  Map<String, dynamic> toMap() => {
        'actorId': actorId,
        'level': level.name,
      };

  factory AccessGrant.fromMap(Map<String, dynamic> m) => AccessGrant(
        actorId: m['actorId'] as String,
        level: AccessLevel.fromString(m['level'] as String? ?? 'read'),
      );
}
```

### Файл: `./lib/data_layer/models/access_level.dart` (строк:       15, размер:      380 байт)

```dart
/// Access level for cross-tenant or cross-user sharing.
enum AccessLevel {
  read,
  write,
  admin;

  static AccessLevel fromString(String s) => AccessLevel.values.firstWhere(
        (v) => v.name == s,
        orElse: () => AccessLevel.read,
      );

  bool get canRead => true;
  bool get canWrite => this == write || this == admin;
  bool get canAdmin => this == admin;
}
```

### Файл: `./lib/data_layer/models/field_diff.dart` (строк:       35, размер:      818 байт)

```dart
import 'dart:convert';

/// Records the before/after values of a single field change.
final class FieldDiff {
  final dynamic before;
  final dynamic after;

  const FieldDiff({this.before, this.after});

  Map<String, dynamic> toMap() => {
        'before': _safeJson(before),
        'after': _safeJson(after),
      };

  factory FieldDiff.fromMap(Map<String, dynamic> m) => FieldDiff(
        before: m['before'],
        after: m['after'],
      );

  dynamic _safeJson(dynamic v) {
    if (v == null || v is String || v is num || v is bool) return v;
    if (v is Map || v is List) {
      try {
        jsonEncode(v); // validate
        return v;
      } catch (_) {
        return v.toString();
      }
    }
    return v.toString();
  }

  @override
  String toString() => 'FieldDiff($before → $after)';
}
```

### Файл: `./lib/data_layer/models/increment_type.dart` (строк:        2, размер:      103 байт)

```dart
/// Which semver component to bump when publishing a draft.
enum IncrementType { major, minor, patch }
```

### Файл: `./lib/data_layer/models/log_entry.dart` (строк:       92, размер:     2944 байт)

```dart
import 'dart:convert';
import 'log_operation.dart';
import 'field_diff.dart';

/// An immutable record of one change to a [LoggedStorable] entity.
final class LogEntry {
  final String entryId;
  final String entityId;
  final String collectionId;
  final String changedBy;
  final DateTime changedAt;
  final LogOperation operation;

  /// Field-level diffs. Key = field name.
  final Map<String, FieldDiff> diff;

  /// Full snapshot of the entity after this change.
  /// Non-null when [LoggedRepository] was created with captureFullSnapshot=true.
  final Map<String, dynamic>? snapshot;

  /// For rollback entries: the entry this rolled back to.
  final String? rollbackToEntryId;

  const LogEntry({
    required this.entryId,
    required this.entityId,
    required this.collectionId,
    required this.changedBy,
    required this.changedAt,
    required this.operation,
    this.diff = const {},
    this.snapshot,
    this.rollbackToEntryId,
  });

  Map<String, dynamic> toMap() => {
        'entryId': entryId,
        'entityId': entityId,
        'collectionId': collectionId,
        'changedBy': changedBy,
        'changedAt': changedAt.toIso8601String(),
        'operation': operation.name,
        'diff': jsonEncode(
          diff.map((k, v) => MapEntry(k, v.toMap())),
        ),
        'snapshot': snapshot != null ? jsonEncode(snapshot) : null,
        'rollbackToEntryId': rollbackToEntryId,
      };

  factory LogEntry.fromMap(Map<String, dynamic> m) {
    // Decode diff
    final rawDiff = m['diff'];
    final Map<String, FieldDiff> diff;
    if (rawDiff is String && rawDiff.isNotEmpty) {
      final decoded = jsonDecode(rawDiff) as Map<String, dynamic>? ?? {};
      diff = decoded.map(
        (k, v) => MapEntry(k, FieldDiff.fromMap(v as Map<String, dynamic>)),
      );
    } else if (rawDiff is Map) {
      diff = (rawDiff as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, FieldDiff.fromMap(v as Map<String, dynamic>)),
      );
    } else {
      diff = {};
    }

    // Decode snapshot
    final rawSnap = m['snapshot'];
    Map<String, dynamic>? snapshot;
    if (rawSnap is String && rawSnap.isNotEmpty) {
      snapshot = jsonDecode(rawSnap) as Map<String, dynamic>?;
    } else if (rawSnap is Map) {
      snapshot = Map<String, dynamic>.from(rawSnap);
    }

    return LogEntry(
      entryId: m['entryId'] as String,
      entityId: m['entityId'] as String,
      collectionId: m['collectionId'] as String? ?? '',
      changedBy: m['changedBy'] as String? ?? '',
      changedAt: DateTime.tryParse(m['changedAt'] as String? ?? '') ?? DateTime.now(),
      operation: LogOperation.fromString(m['operation'] as String? ?? 'updated'),
      diff: diff,
      snapshot: snapshot,
      rollbackToEntryId: m['rollbackToEntryId'] as String?,
    );
  }

  @override
  String toString() =>
      'LogEntry($entryId op:${operation.name} by:$changedBy at:${changedAt.toIso8601String()})';
}
```

### Файл: `./lib/data_layer/models/log_operation.dart` (строк:       12, размер:      279 байт)

```dart
/// The type of operation recorded in a [LogEntry].
enum LogOperation {
  created,
  updated,
  deleted,
  rollback;

  static LogOperation fromString(String s) => LogOperation.values.firstWhere(
        (v) => v.name == s,
        orElse: () => LogOperation.updated,
      );
}
```

### Файл: `./lib/data_layer/models/query/page_result.dart` (строк:       41, размер:     1075 байт)

```dart
/// A single page of query results with pagination metadata.
final class PageResult<T> {
  /// Items on this page.
  final List<T> items;

  /// Total number of records matching the query (across all pages).
  final int total;

  /// The offset used to produce this page.
  final int offset;

  /// The limit used to produce this page.
  final int limit;

  const PageResult({
    required this.items,
    required this.total,
    required this.offset,
    required this.limit,
  });

  /// Whether there is a next page available.
  bool get hasMore => offset + items.length < total;

  /// Current page number (1-based).
  int get page => limit > 0 ? (offset ~/ limit) + 1 : 1;

  /// Total number of pages.
  int get totalPages => limit > 0 ? (total / limit).ceil() : 1;

  PageResult<R> map<R>(R Function(T) convert) => PageResult(
        items: items.map(convert).toList(),
        total: total,
        offset: offset,
        limit: limit,
      );

  @override
  String toString() =>
      'PageResult(page=$page/$totalPages, items=${items.length}, total=$total)';
}
```

### Файл: `./lib/data_layer/models/query/vault_filter.dart` (строк:       16, размер:      447 байт)

```dart
import 'vault_operator.dart';

/// A single filter predicate in a [VaultQuery].
final class VaultFilter {
  final String field;
  final VaultOperator operator;
  final dynamic value;

  const VaultFilter(this.field, this.operator, this.value);

  /// Evaluate this filter against a single stored record map.
  bool matches(Map<String, dynamic> record) {
    final fieldValue = record[field];
    return operator.evaluate(fieldValue, value);
  }
}
```

### Файл: `./lib/data_layer/models/query/vault_index.dart` (строк:       20, размер:      535 байт)

```dart
/// Index definition for a collection field.
///
/// Register an index via [DirectRepository.registerIndex] or
/// pass [indexes] to [Vault.direct] / [Vault.versioned] / [Vault.logged].
final class VaultIndex {
  /// Logical name of the index (must be unique within a collection).
  final String name;

  /// The field name this index covers.
  final String field;

  /// Whether index entries must be unique.
  final bool unique;

  const VaultIndex({
    required this.name,
    required this.field,
    this.unique = false,
  });
}
```

### Файл: `./lib/data_layer/models/query/vault_operator.dart` (строк:       89, размер:     2708 байт)

```dart
/// Comparison operators for [VaultFilter].
enum VaultOperator {
  equals,
  notEquals,
  contains,
  startsWith,
  greaterThan,
  greaterOrEqual,
  lessThan,
  lessOrEqual,
  isNull,
  isNotNull,
  inList,
  notInList;

  /// Evaluate this operator against [fieldValue] and [filterValue].
  bool evaluate(dynamic fieldValue, dynamic filterValue) {
    switch (this) {
      case VaultOperator.equals:
        return _str(fieldValue) == _str(filterValue);
      case VaultOperator.notEquals:
        return _str(fieldValue) != _str(filterValue);
      case VaultOperator.contains:
        return _str(fieldValue).contains(_str(filterValue));
      case VaultOperator.startsWith:
        return _str(fieldValue).startsWith(_str(filterValue));
      case VaultOperator.greaterThan:
        return _cmp(fieldValue, filterValue) > 0;
      case VaultOperator.greaterOrEqual:
        return _cmp(fieldValue, filterValue) >= 0;
      case VaultOperator.lessThan:
        return _cmp(fieldValue, filterValue) < 0;
      case VaultOperator.lessOrEqual:
        return _cmp(fieldValue, filterValue) <= 0;
      case VaultOperator.isNull:
        return fieldValue == null;
      case VaultOperator.isNotNull:
        return fieldValue != null;
      case VaultOperator.inList:
        final list = filterValue as List?;
        return list?.map(_str).contains(_str(fieldValue)) ?? false;
      case VaultOperator.notInList:
        final list = filterValue as List?;
        return !(list?.map(_str).contains(_str(fieldValue)) ?? false);
    }
  }

  String _str(dynamic v) => v?.toString() ?? '';

  int _cmp(dynamic a, dynamic b) {
    if (a is num && b is num) return a.compareTo(b);
    final sa = _str(a);
    final sb = _str(b);
    final na = num.tryParse(sa);
    final nb = num.tryParse(sb);
    if (na != null && nb != null) return na.compareTo(nb);
    return sa.compareTo(sb);
  }

  /// SQL operator string for [SqlQueryTranslator] implementations.
  String get sql {
    switch (this) {
      case VaultOperator.equals:
        return '=';
      case VaultOperator.notEquals:
        return '!=';
      case VaultOperator.contains:
        return 'ILIKE';
      case VaultOperator.startsWith:
        return 'ILIKE';
      case VaultOperator.greaterThan:
        return '>';
      case VaultOperator.greaterOrEqual:
        return '>=';
      case VaultOperator.lessThan:
        return '<';
      case VaultOperator.lessOrEqual:
        return '<=';
      case VaultOperator.isNull:
        return 'IS NULL';
      case VaultOperator.isNotNull:
        return 'IS NOT NULL';
      case VaultOperator.inList:
        return 'IN';
      case VaultOperator.notInList:
        return 'NOT IN';
    }
  }
}
```

### Файл: `./lib/data_layer/models/query/vault_query.dart` (строк:      120, размер:     3618 байт)

```dart
import 'vault_filter.dart';
import 'vault_operator.dart';
import 'vault_sort.dart';

/// Immutable query descriptor for dart_vault.
///
/// Build queries with the fluent API:
///
/// ```dart
/// final q = VaultQuery()
///     .where('status', VaultOperator.equals, 'active')
///     .where('score', VaultOperator.greaterThan, 50)
///     .orderBy('createdAt', descending: true)
///     .page(limit: 20, offset: 0);
/// ```
final class VaultQuery {
  final List<VaultFilter> filters;
  final VaultSort? sort;
  final int? limit;
  final int? offset;

  const VaultQuery({
    this.filters = const [],
    this.sort,
    this.limit,
    this.offset,
  });

  // ── Fluent builder ─────────────────────────────────────────────────────────

  VaultQuery where(String field, VaultOperator operator, dynamic value) =>
      VaultQuery(
        filters: [...filters, VaultFilter(field, operator, value)],
        sort: sort,
        limit: limit,
        offset: offset,
      );

  VaultQuery orderBy(String field, {bool descending = false}) => VaultQuery(
        filters: filters,
        sort: VaultSort(field: field, descending: descending),
        limit: limit,
        offset: offset,
      );

  /// Set pagination parameters.
  VaultQuery page({required int limit, int offset = 0}) => VaultQuery(
        filters: filters,
        sort: sort,
        limit: limit,
        offset: offset,
      );

  /// Set the maximum number of records to return.
  VaultQuery withLimit(int limit) => VaultQuery(
        filters: filters,
        sort: sort,
        limit: limit,
        offset: offset,
      );

  /// Set the number of records to skip.
  VaultQuery withOffset(int offset) => VaultQuery(
        filters: filters,
        sort: sort,
        limit: limit,
        offset: offset,
      );

  // ── In-memory application ──────────────────────────────────────────────────

  /// Apply this query to an in-memory list of maps.
  /// Used by [InMemoryVaultStorage]; SQL-capable backends bypass this.
  List<Map<String, dynamic>> apply(List<Map<String, dynamic>> all) {
    var result = all.where((m) {
      for (final f in filters) {
        if (!f.matches(m)) return false;
      }
      return true;
    }).toList();

    if (sort != null) {
      result.sort((a, b) {
        final av = _comparable(a[sort!.field]);
        final bv = _comparable(b[sort!.field]);
        final cmp = av.compareTo(bv);
        return sort!.descending ? -cmp : cmp;
      });
    }

    if (offset != null && offset! > 0) {
      result = result.skip(offset!).toList();
    }
    if (limit != null) {
      result = result.take(limit!).toList();
    }

    return result;
  }

  /// Apply only the filter predicates — without sort / pagination.
  /// Used internally for [count] and [queryPage] total calculation.
  List<Map<String, dynamic>> applyFiltersOnly(
    List<Map<String, dynamic>> all,
  ) =>
      all.where((m) {
        for (final f in filters) {
          if (!f.matches(m)) return false;
        }
        return true;
      }).toList();

  // ── Helpers ────────────────────────────────────────────────────────────────

  Comparable _comparable(dynamic v) {
    if (v == null) return '';
    if (v is Comparable) return v;
    return v.toString();
  }
}
```

### Файл: `./lib/data_layer/models/query/vault_sort.dart` (строк:        7, размер:      179 байт)

```dart
/// Sort descriptor for [VaultQuery].
final class VaultSort {
  final String field;
  final bool descending;

  const VaultSort({required this.field, this.descending = false});
}
```

### Файл: `./lib/data_layer/models/semver.dart` (строк:       49, размер:     1416 байт)

```dart
/// Semantic version (major.minor.patch).
final class Semver implements Comparable<Semver> {
  final int major;
  final int minor;
  final int patch;

  const Semver(this.major, this.minor, this.patch);

  factory Semver.parse(String s) {
    final parts = s.split('.');
    if (parts.length != 3) throw FormatException('Invalid semver: $s');
    return Semver(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  static const Semver zero = Semver(0, 0, 0);
  static const Semver initial = Semver(1, 0, 0);

  Semver incrementMajor() => Semver(major + 1, 0, 0);
  Semver incrementMinor() => Semver(major, minor + 1, 0);
  Semver incrementPatch() => Semver(major, minor, patch + 1);

  @override
  int compareTo(Semver other) {
    if (major != other.major) return major.compareTo(other.major);
    if (minor != other.minor) return minor.compareTo(other.minor);
    return patch.compareTo(other.patch);
  }

  bool operator >(Semver other) => compareTo(other) > 0;
  bool operator >=(Semver other) => compareTo(other) >= 0;
  bool operator <(Semver other) => compareTo(other) < 0;

  @override
  bool operator ==(Object other) =>
      other is Semver &&
      major == other.major &&
      minor == other.minor &&
      patch == other.patch;

  @override
  int get hashCode => Object.hash(major, minor, patch);

  @override
  String toString() => '$major.$minor.$patch';
}
```

### Файл: `./lib/data_layer/models/version_node.dart` (строк:      130, размер:     4583 байт)

```dart
// pkgs/aq_schema/lib/data_layer/models/version_node.dart
import 'dart:convert';
import 'version_status.dart';
import 'semver.dart';
import '../storage/buffered_storage.dart';

/// A single node in the version graph of an entity.
///
/// [localState] — состояние записи в локальном буфере.
/// null — буфер не используется или запись синхронизирована.
/// [VaultRecordState.dirty] — запись изменена локально, flush не сделан.
/// [VaultRecordState.localOnly] — запись создана локально, в удалённой БД её нет.
/// [VaultRecordState.synced] — запись получена из удалённой БД, изменений нет.
final class VersionNode {
  final String nodeId;
  final String entityId;
  final String? parentNodeId;
  final VersionStatus status;
  final Semver? version;
  final int sequenceNumber;
  final String createdBy;
  final DateTime createdAt;
  final Map<String, dynamic> data;
  final bool isCurrent;
  final String branch;

  /// Состояние в локальном буфере. null если буфер не используется.
  final VaultRecordState? localState;

  /// true если запись содержит несохранённые локальные изменения.
  bool get isLocallyModified =>
      localState == VaultRecordState.dirty ||
      localState == VaultRecordState.localOnly;

  const VersionNode({
    required this.nodeId,
    required this.entityId,
    this.parentNodeId,
    required this.status,
    this.version,
    required this.sequenceNumber,
    required this.createdBy,
    required this.createdAt,
    required this.data,
    required this.isCurrent,
    this.branch = 'main',
    this.localState,
  });

  Map<String, dynamic> toMap() => {
        'nodeId': nodeId,
        'entityId': entityId,
        'parentNodeId': parentNodeId,
        'status': status.name,
        'version': version?.toString(),
        'sequenceNumber': sequenceNumber,
        'createdBy': createdBy,
        'createdAt': createdAt.toIso8601String(),
        'data': jsonEncode(data),
        'isCurrent': isCurrent,
        'branch': branch,
        // _ls намеренно не сериализуем — он не часть домена
      };

  factory VersionNode.fromMap(Map<String, dynamic> m) {
    final rawData = m['data'];
    final Map<String, dynamic> data;
    if (rawData is String) {
      data = (jsonDecode(rawData) as Map<String, dynamic>?) ?? {};
    } else if (rawData is Map) {
      data = Map<String, dynamic>.from(rawData);
    } else {
      data = {};
    }

    // Читаем состояние буфера если оно есть
    final lsRaw = m[IBufferedStorage.kStateKey] as String?;
    final localState = lsRaw != null
        ? VaultRecordState.values.firstWhere(
            (e) => e.name == lsRaw,
            orElse: () => VaultRecordState.synced,
          )
        : null;

    return VersionNode(
      nodeId: m['nodeId'] as String,
      entityId: m['entityId'] as String,
      parentNodeId: m['parentNodeId'] as String?,
      status: VersionStatus.fromString(m['status'] as String? ?? 'draft'),
      version:
          m['version'] != null ? Semver.parse(m['version'] as String) : null,
      sequenceNumber: m['sequenceNumber'] as int? ?? 1,
      createdBy: m['createdBy'] as String? ?? '',
      createdAt:
          DateTime.tryParse(m['createdAt'] as String? ?? '') ?? DateTime.now(),
      data: data,
      isCurrent: m['isCurrent'] as bool? ?? false,
      branch: m['branch'] as String? ?? 'main',
      localState: localState,
    );
  }

  VersionNode copyWith({
    VersionStatus? status,
    Semver? version,
    bool? isCurrent,
    Map<String, dynamic>? data,
    String? branch,
    VaultRecordState? localState,
  }) =>
      VersionNode(
        nodeId: nodeId,
        entityId: entityId,
        parentNodeId: parentNodeId,
        status: status ?? this.status,
        version: version ?? this.version,
        sequenceNumber: sequenceNumber,
        createdBy: createdBy,
        createdAt: createdAt,
        data: data ?? this.data,
        isCurrent: isCurrent ?? this.isCurrent,
        branch: branch ?? this.branch,
        localState: localState ?? this.localState,
      );

  @override
  String toString() =>
      'VersionNode(${nodeId.substring(0, 8)} v${version ?? 'draft'} '
      '[$status] branch:$branch${localState != null ? ' ls:${localState!.name}' : ''})';
}
```

### Файл: `./lib/data_layer/models/version_status.dart` (строк:       24, размер:      655 байт)

```dart
/// Lifecycle state of a [VersionNode].
///
/// Allowed transitions:
///   draft → published  (via publishDraft)
///   published → snapshot (via snapshotVersion)
///   any → deleted      (via deleteVersion)
enum VersionStatus {
  draft,
  published,
  snapshot,
  deleted;

  static VersionStatus fromString(String s) =>
      VersionStatus.values.firstWhere(
        (v) => v.name == s,
        orElse: () => VersionStatus.draft,
      );

  bool get isDraft => this == draft;
  bool get isPublished => this == published;
  bool get isSnapshot => this == snapshot;
  bool get isDeleted => this == deleted;
  bool get isEditable => this == draft;
}
```

### Файл: `./lib/data_layer/storable/artifact_entry.dart` (строк:       28, размер:      855 байт)

```dart
import 'direct_storable.dart';

/// Metadata record for a stored artifact (file).
///
/// The binary content is managed by [ArtifactStorage]; this model holds
/// only the metadata that is stored in [VaultStorage] (key-value).
abstract interface class ArtifactEntry implements DirectStorable {
  /// Logical storage key / path (e.g. "projects/abc/report.pdf").
  String get storageKey;

  /// Original file name as provided by the user.
  String get fileName;

  /// MIME content type (e.g. "application/pdf", "image/png").
  String get contentType;

  /// File size in bytes.
  int get sizeBytes;

  /// SHA-256 checksum of the raw content (hex string).
  String get checksum;

  /// Arbitrary metadata map (tags, project ID, run ID, etc.).
  Map<String, String> get meta;

  /// UTC timestamp when this artifact was created.
  DateTime get createdAt;
}
```

### Файл: `./lib/data_layer/storable/direct_storable.dart` (строк:        4, размер:      161 байт)

```dart
import 'storable.dart';

/// Marker interface for direct (plain) storage — no version metadata.
abstract interface class DirectStorable implements Storable {}
```

### Файл: `./lib/data_layer/storable/logged_storable.dart` (строк:        9, размер:      352 байт)

```dart
import 'storable.dart';

/// Marker interface for logged storage.
/// Every change is automatically recorded as a [LogEntry] with field diffs.
abstract interface class LoggedStorable implements Storable {
  /// Fields whose changes are tracked in the log.
  /// Empty set means ALL fields from [toMap()] are tracked.
  Set<String> get trackedFields;
}
```

### Файл: `./lib/data_layer/storable/sql_query_translator.dart` (строк:       65, размер:     1886 байт)

```dart
import 'package:aq_schema/aq_schema.dart';

/// Optional interface for storage backends that support SQL-level query
/// translation (pushdown optimisation).
///
/// When a [VaultStorage] implementation also implements [SqlQueryTranslator],
/// repositories will call [toSql] instead of filtering records in-memory,
/// enabling the database engine to use indexes and optimise execution plans.
///
/// ## Usage
///
/// ```dart
/// class PostgresVaultStorage implements VaultStorage, SqlQueryTranslator {
///   @override
///   SqlFragment toSql(VaultQuery query) {
///     final wheres = <String>[];
///     final params  = <Object?>[];
///     for (final f in query.filters) {
///       wheres.add('${f.field} ${f.operator.sql} \$${params.length + 1}');
///       params.add(f.value);
///     }
///     return SqlFragment(
///       where: wheres.isEmpty ? null : wheres.join(' AND '),
///       orderBy: query.sortField,
///       limit: query.limit,
///       offset: query.offset,
///       params: params,
///     );
///   }
/// }
/// ```
abstract interface class SqlQueryTranslator {
  /// Translate [query] into a [SqlFragment] for native SQL execution.
  SqlFragment toSql(VaultQuery query);
}

/// Holds the parts of a translated SQL query.
final class SqlFragment {
  /// WHERE clause (without "WHERE" keyword), e.g. `"name = $1 AND active = $2"`.
  final String? where;

  /// ORDER BY column name (without direction).
  final String? orderBy;

  /// ASC / DESC direction string.
  final String orderDirection;

  /// LIMIT value, or null for no limit.
  final int? limit;

  /// OFFSET value, or null.
  final int? offset;

  /// Positional parameters matching placeholders in [where].
  final List<Object?> params;

  const SqlFragment({
    this.where,
    this.orderBy,
    this.orderDirection = 'ASC',
    this.limit,
    this.offset,
    this.params = const [],
  });
}
```

### Файл: `./lib/data_layer/storable/storable.dart` (строк:       21, размер:      807 байт)

```dart
/// Base interface that every model stored in dart_vault must implement.
abstract interface class Storable {
  /// Unique record identifier (UUID recommended).
  String get id;

  /// Name of the storage collection (table/bucket) for this domain.
  /// Must be snake_case. Used by both client (creates repository)
  /// and server (creates table). Same name = same storage.
  ///
  /// Example: 'workflow_graphs', 'projects', 'workflow_runs'
  String get collectionName;

  /// Serialise to Map for storage.
  /// Must return JSON-safe types only: String, num, bool, null, List, Map.
  Map<String, dynamic> toMap();

  /// Values to be written to the index on save.
  /// Key = index name, value = value to index.
  /// Return empty map if no fields need indexing.
  Map<String, dynamic> get indexFields;
}
```

### Файл: `./lib/data_layer/storable/versioned_storable.dart` (строк:       11, размер:      342 байт)

```dart
import 'storable.dart';

/// Marker interface for versioned storage.
/// Entities have semver lifecycle, branching, and access control.
abstract interface class VersionedStorable implements Storable {
  /// Owner of this entity (user/tenant ID).
  String get ownerId;

  /// Access grants for other actors.
  List<Object> get accessGrants;
}
```

### Файл: `./lib/data_layer/storage/artifact_storage.dart` (строк:       54, размер:     2683 байт)

```dart
/// Backend interface for binary file storage.
///
/// dart_vault separates concerns:
/// - [VaultStorage]    — key/value metadata (JSON)
/// - [ArtifactStorage] — binary content (bytes)
///
/// Implementations:
/// - [LocalArtifactStorage]    — files on the local filesystem (`dart:io`)
/// - `S3ArtifactStorage`       — implement using your HTTP client of choice
/// - `SupabaseArtifactStorage` — Supabase Storage API
///
/// ## Key format
///
/// Keys are hierarchical slash-separated paths:
///   `{tenantId}/{collection}/{id}/{fileName}`
///
/// The [ArtifactRepository] builds keys automatically.
/// You can use any path scheme that fits your storage backend.
abstract interface class ArtifactStorage {
  // ── Write ──────────────────────────────────────────────────────────────────

  /// Store [bytes] under [key].  Overwrites if [key] already exists.
  Future<void> put(String key, List<int> bytes, {String? contentType});

  // ── Read ───────────────────────────────────────────────────────────────────

  Future<List<int>?> get(String key);

  Future<bool> exists(String key);

  /// Returns the content length in bytes, or null if key does not exist.
  Future<int?> size(String key);

  // ── Stream ─────────────────────────────────────────────────────────────────

  /// Stream content in chunks for large files.
  Stream<List<int>> stream(String key);

  // ── Delete ─────────────────────────────────────────────────────────────────

  Future<void> delete(String key);

  /// Delete all keys with the given [prefix].
  Future<void> deleteByPrefix(String prefix);

  // ── List ───────────────────────────────────────────────────────────────────

  /// List all keys with the given [prefix].
  Future<List<String>> list(String prefix);

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  Future<void> dispose();
}
```

### Файл: `./lib/data_layer/storage/buffered_storage.dart` (строк:      106, размер:     6695 байт)

```dart
// pkgs/aq_schema/lib/data_layer/storage/buffered_storage.dart
//
// Интерфейс локального буфера записей.
// LocalBufferVaultStorage в dart_vault реализует этот интерфейс.
// Приложение получает Vault.instance.buffer и через него управляет буфером.
library;

import 'package:aq_schema/aq_schema.dart';

import 'vault_storage.dart';

// ══════════════════════════════════════════════════════════════════════════════
// VaultRecordState — состояние конкретной записи
// ══════════════════════════════════════════════════════════════════════════════

/// Состояние записи в буфере.
enum VaultRecordState {
  /// Запись получена из удалённого хранилища, локальных изменений нет.
  /// Хранится в буфере как кэш для быстрого доступа.
  synced,

  /// Запись есть в удалённом хранилище, но была изменена локально.
  /// Flush отправит изменения в удалённое хранилище.
  dirty,

  /// Запись существует только локально, в удалённом хранилище её нет.
  /// Flush создаст её в удалённом хранилище.
  localOnly,
}

// ══════════════════════════════════════════════════════════════════════════════
// IBufferedStorage — публичный интерфейс буфера
// ══════════════════════════════════════════════════════════════════════════════

/// Расширение [VaultStorage] с поддержкой локального рабочего буфера.
///
/// ## Принцип работы
///
/// Все записи читаются и пишутся через буфер (InMemoryVaultStorage).
/// Запись в удалённое хранилище происходит только по команде [flush].
///
/// Чтение: буфер → удалённое (с кэшированием в буфере как [VaultRecordState.synced]).
/// Запись: только в буфер, метка [VaultRecordState.dirty] или [localOnly].
/// Flush: dirty/localOnly → удалённое хранилище.
/// Discard: сбросить локальные изменения, восстановить из удалённого.
///
/// ## Состояние записи
///
/// Каждая запись в буфере несёт ключ [kStateKey] со значением из [VaultRecordState].
/// [VersionNode.fromMap] читает это поле и выставляет [VersionNode.localState].
/// Domain-модели (WorkflowGraph и т.д.) поле игнорируют — они не знают о нём.
///
/// ## Использование
///
/// ```dart
/// // Проверить есть ли несохранённые изменения
/// final unsaved = Vault.instance.buffer?.isDirty(WorkflowGraph.kCollection, graphId) ?? false;
///
/// // Сохранить в удалённую БД
/// await Vault.instance.buffer?.flush(WorkflowGraph.kCollection, id: graphId);
///
/// // Отбросить локальные изменения
/// await Vault.instance.buffer?.discard(WorkflowGraph.kCollection, id: graphId);
///
/// // Узнать оригинал до локальных изменений
/// final original = Vault.instance.buffer?.getOriginal(WorkflowGraph.kCollection, graphId);
/// ```
abstract interface class IBufferedStorage implements VaultStorage {
  /// Ключ, добавляемый в raw Map для передачи состояния.
  /// Значение — строка из [VaultRecordState.name].
  /// Используется [VersionNode.fromMap] и другими внутренними читателями.
  /// Domain-модели этот ключ игнорируют.
  static const kStateKey = '_ls';

  // ── Состояние ─────────────────────────────────────────────────────────────

  /// true если запись изменена или создана локально (dirty или localOnly).
  bool isDirty(String collection, String id);

  /// Состояние конкретной записи. null если записи нет в буфере.
  VaultRecordState? stateOf(String collection, String id);

  /// Все ID с несохранёнными изменениями в коллекции.
  Set<String> dirtyIds(String collection);

  /// Данные записи до локальных изменений.
  /// null если запись не менялась или была создана только локально.
  Map<String, dynamic>? getOriginal(String collection, String id);

  // ── Команды ───────────────────────────────────────────────────────────────

  /// Записать dirty/localOnly записи в удалённое хранилище.
  /// [id] = null → всю коллекцию.
  Future<void> flush(String collection, {String? id});

  /// Сбросить локальные изменения. Восстанавливает оригинал из удалённого.
  /// [id] = null → всю коллекцию.
  Future<void> discard(String collection, {String? id});

  /// Предзагрузить запись из удалённого хранилища в буфер.
  /// После warmup запись доступна мгновенно без обращения к сети.
  Future<void> warmup(String collection, String id);

  /// Предзагрузить несколько записей одним запросом.
  Future<void> warmupAll(String collection, {VaultQuery? query});
}
```

### Файл: `./lib/data_layer/storage/vault_storage.dart` (строк:       78, размер:     3740 байт)

```dart
import 'package:aq_schema/aq_schema.dart';

/// Core storage backend interface.
///
/// All three repositories depend only on this abstraction.
/// Implement it for Supabase, PostgreSQL, Hive, etc., or use
/// the built-in [InMemoryVaultStorage] / [SupabaseVaultStorage].
///
/// ## Serialisation contract
/// All values passed to [put] / [putAll] must be JSON-safe:
/// String, num, bool, null, List<dynamic>, Map<String, dynamic>.
/// The storage layer MUST NOT call `.toString()` on arbitrary objects.
abstract interface class VaultStorage {
  // ── Collections ────────────────────────────────────────────────────────────

  /// Ensure the collection exists (idempotent).
  Future<void> ensureCollection(String collection);

  // ── CRUD ───────────────────────────────────────────────────────────────────

  Future<void> put(String collection, String id, Map<String, dynamic> data);
  Future<Map<String, dynamic>?> get(String collection, String id);
  Future<void> delete(String collection, String id);
  Future<bool> exists(String collection, String id);

  /// Batch write — more efficient than multiple [put] calls.
  Future<void> putAll(
    String collection,
    Map<String, Map<String, dynamic>> entries,
  );

  // ── Queries ────────────────────────────────────────────────────────────────

  /// Returns all records matching [query].
  /// For large datasets, prefer [queryPage] to avoid loading everything.
  Future<List<Map<String, dynamic>>> query(
    String collection,
    VaultQuery query,
  );

  /// Returns a page of results using [query.limit] and [query.offset].
  /// [PageResult.total] reflects the count of all matching records.
  Future<PageResult<Map<String, dynamic>>> queryPage(
    String collection,
    VaultQuery query,
  );

  Future<int> count(String collection, VaultQuery query);

  // ── Indexes ────────────────────────────────────────────────────────────────

  Future<void> createIndex(String collection, VaultIndex index);

  /// Update index entries for a record after it was written.
  Future<void> updateIndex(
    String collection,
    String id,
    Map<String, dynamic> indexData,
  );

  Future<void> removeFromIndex(String collection, String id);

  // ── Transactions ───────────────────────────────────────────────────────────

  /// Run [action] inside a storage transaction.
  /// On failure, all writes performed inside [action] must be rolled back.
  Future<T> transaction<T>(Future<T> Function(VaultStorage tx) action);

  // ── Reactivity ─────────────────────────────────────────────────────────────

  /// Emits an event whenever any record in [collection] is modified.
  Stream<void> watchChanges(String collection);

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  Future<void> clear(String collection);
  Future<void> dispose();
}
```

### Файл: `./lib/data_layer/storage/vector_storage.dart` (строк:      114, размер:     4488 байт)

```dart
import 'package:aq_schema/aq_schema.dart';

/// A single vector entry stored in a [VectorStorage] collection.
final class VectorEntry {
  /// Unique ID within the collection (maps back to a source document chunk).
  final String id;

  /// The embedding vector.
  final List<double> vector;

  /// Arbitrary metadata payload (source document ID, chunk index, text, etc.).
  final Map<String, dynamic> payload;

  const VectorEntry({
    required this.id,
    required this.vector,
    required this.payload,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'vector': vector,
        'payload': payload,
      };

  factory VectorEntry.fromMap(Map<String, dynamic> m) => VectorEntry(
        id: m['id'] as String,
        vector: ((m['vector'] as List?) ?? []).cast<double>(),
        payload: (m['payload'] as Map<String, dynamic>?) ?? {},
      );
}

/// Result of a vector similarity search.
final class VectorSearchResult {
  final String id;
  final double score; // cosine similarity in [0, 1]
  final Map<String, dynamic> payload;

  const VectorSearchResult({
    required this.id,
    required this.score,
    required this.payload,
  });

  @override
  String toString() =>
      'VectorSearchResult(id:$id score:${score.toStringAsFixed(4)})';
}

/// Backend interface for approximate-nearest-neighbour (ANN) vector search.
///
/// dart_vault keeps this separate from [VaultStorage] because vector databases
/// have fundamentally different query semantics (ANN, cosine distance, filters
/// on payload) that do not map cleanly to the key-value query DSL.
///
/// Implementations:
/// - [InMemoryVectorStorage]   — brute-force cosine search, no index (dev/test)
/// - `QdrantVectorStorage`     — Qdrant HTTP API (production, recommended)
/// - `PgVectorStorage`         — Supabase/pgvector via RPC (production)
///
/// ## Multi-tenancy
///
/// Pass a [tenantId]-prefixed collection name (handled by [KnowledgeVault]):
///   `alice__documents_vectors`
abstract interface class VectorStorage {
  // ── Collections ────────────────────────────────────────────────────────────

  /// Ensure the named collection exists with the given [vectorSize].
  /// The [distance] metric is backend-specific; pass `"cosine"` by default.
  Future<void> ensureCollection(
    String collection, {
    required int vectorSize,
    String distance = 'cosine',
  });

  Future<void> deleteCollection(String collection);

  // ── Write ──────────────────────────────────────────────────────────────────

  /// Insert or update a single vector entry.
  Future<void> upsert(String collection, VectorEntry entry);

  /// Batch upsert — more efficient than multiple [upsert] calls.
  Future<void> upsertAll(String collection, List<VectorEntry> entries);

  Future<void> delete(String collection, String id);

  /// Delete all entries whose payload matches [filter].
  Future<void> deleteWhere(String collection, VaultQuery filter);

  // ── Search ─────────────────────────────────────────────────────────────────

  /// ANN search: find the [limit] entries most similar to [queryVector].
  ///
  /// [filter] optionally restricts the search to entries whose payload
  /// satisfies the filter predicates (payload pushdown when supported).
  Future<List<VectorSearchResult>> search(
    String collection,
    List<double> queryVector, {
    int limit = 10,
    double scoreThreshold = 0.0,
    VaultQuery? filter,
  });

  // ── Read ───────────────────────────────────────────────────────────────────

  Future<VectorEntry?> getById(String collection, String id);
  Future<List<VectorEntry>> getAll(String collection, {VaultQuery? filter});
  Future<int> count(String collection, {VaultQuery? filter});

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  Future<void> dispose();
}
```

### Файл: `./lib/graph/core/graph_def.dart` (строк:       62, размер:     2912 байт)

```dart
// Базовые абстракции графа — Узел, Ребро, Граф.
// Все конкретные графы (Workflow, Instruction, Prompt) наследуют отсюда.
import 'package:meta/meta.dart';

// ─────────────────────────────────────────────────────────────────────────────
// БАЗОВЫЙ УЗЕЛ
// ─────────────────────────────────────────────────────────────────────────────

@immutable
abstract class $Node {
  String get id;

  const $Node();

  $Node copyWith();
}

// ─────────────────────────────────────────────────────────────────────────────
// БАЗОВОЕ РЕБРО (связь между узлами)
// ─────────────────────────────────────────────────────────────────────────────

@immutable
abstract class $Edge {
  String get id;
  String get sourceId;
  String get targetId;
  String get branchName;

  const $Edge();

  $Edge copyWith();
}

// ─────────────────────────────────────────────────────────────────────────────
// БАЗОВЫЙ ГРАФ (контейнер узлов и рёбер)
// N — тип узла (например, WorkflowNode), E — тип ребра (например, WorkflowEdge)
// ─────────────────────────────────────────────────────────────────────────────

@immutable
abstract class $Graph<N extends $Node, E extends $Edge> {
  // Map для O(1) доступа по ID
  final Map<String, N> nodes;
  final Map<String, E> edges;

  const $Graph({required this.nodes, required this.edges});

  $Graph<N, E> addNode(N node);
  $Graph<N, E> removeNode(String nodeId);
  $Graph<N, E> addEdge(E edge);
  $Graph<N, E> removeEdge(String edgeId);

  /// Проверка целостности: нет ли рёбер, ссылающихся на несуществующие узлы
  bool validate() {
    for (final edge in edges.values) {
      if (!nodes.containsKey(edge.sourceId) ||
          !nodes.containsKey(edge.targetId)) {
        return false;
      }
    }
    return true;
  }
}
```

### Файл: `./lib/graph/engine/i_hand.dart` (строк:       25, размер:     1263 байт)

```dart
import 'package:aq_schema/aq_schema.dart';

import 'run_context.dart';

abstract class IHand {
  /// Уникальный технический ID (например: 'fs_write_file')
  String get id;

  /// Описание для LLM (что делает этот инструмент)
  String get description;

  /// Схема параметров в формате OpenAI Function Calling.
  /// LLM будет читать это, чтобы понять, какие аргументы передавать.
  Map<String, dynamic> get toolSchema;

  /// Главный метод исполнения.
  /// [args] - Аргументы, переданные из узла графа ИЛИ сгенерированные LLM.
  /// [context] - Наш "Рюкзак" с данными текущего запуска.
  /// Возвращает результат (Map, String, bool и т.д.)
  Future<dynamic> execute(Map<String, dynamic> args, RunContext context);

  /// Флаг, указывающий, является ли инструмент системным (доступным только AI Builder'у).
  /// По умолчанию false - обычные инструменты видны в Tools Lab.
  bool get isSystemTool => false;
}
```

### Файл: `./lib/graph/engine/run_context.dart` (строк:      166, размер:     5834 байт)

```dart
// pkgs/aq_schema/lib/graph/engine/run_context.dart

import 'dart:convert';
import '../../sandbox/interfaces/i_sandbox_context.dart';
import '../../sandbox/interfaces/i_sandbox.dart';
import '../../sandbox/interfaces/i_sandbox_as_environment.dart';
import '../../sandbox/interfaces/i_sandbox_event.dart';
import '../../sandbox/policy/sandbox_policy.dart';

class RunContext implements ISandboxContext {
  // ── Идентификация ────────────────────────────────────────────────────
  @override
  final String runId;
  @override
  final String projectId;
  @override
  final String projectPath;
  @override
  final String currentBranch;

  // ── Состояние ────────────────────────────────────────────────────────
  @override
  final Map<String, dynamic> state = {};

  // ── Sandbox ──────────────────────────────────────────────────────────
  @override
  final ISandbox sandbox;

  @override
  SandboxPolicy get activePolicy {
    final s = sandbox;
    return s is ISandboxAsEnvironment ? s.effectivePolicy : s.policy;
  }

  // ── Логирование (реализация, не часть ISandboxContext) ───────────────
  // Приватное поле — callback передаётся в конструктор как раньше.
  // Публичный метод log() — удовлетворяет вызывающим context.log(...).
  // Существующий код вне класса не меняется.
  final void Function(
    String message, {
    String type,
    int depth,
    required String branch,
    String? details,
  }) _log;

  void log(
    String message, {
    String type = 'info',
    int depth = 0,
    required String branch,
    String? details,
  }) =>
      _log(message, type: type, depth: depth, branch: branch, details: details);

  // ── Конструктор ──────────────────────────────────────────────────────
  // Параметр называется `log` как раньше — все места создания RunContext
  // работают без изменений.
  RunContext({
    required this.runId,
    required this.projectId,
    required this.projectPath,
    required void Function(
      String, {
      String type,
      int depth,
      required String branch,
      String? details,
    }) log,
    this.currentBranch = 'main',
    ISandbox? sandbox,
  })  : _log = log,
        sandbox = sandbox ?? _FallbackSandbox(runId);

  // ── Методы состояния ─────────────────────────────────────────────────
  @override
  void setVar(String key, dynamic value) {
    state[key] = value;
    _log('Memory updated: [$key]',
        type: 'system', depth: 0, branch: currentBranch);
  }

  @override
  dynamic getVar(String name) {
    if (!name.contains('.')) return state[name];
    final parts = name.split('.');
    dynamic current = state[parts[0]];
    for (int i = 1; i < parts.length; i++) {
      if (current is Map) {
        current = current[parts[i]];
      } else {
        return null;
      }
    }
    return current;
  }

  @override
  ISandboxContext cloneForBranch(String branchName) {
    final newCtx = RunContext(
      runId: runId,
      projectId: projectId,
      projectPath: projectPath,
      log: _log,
      currentBranch: branchName,
      sandbox: sandbox,
    );
    newCtx.state.addAll(state);
    return newCtx;
  }

  // ── Сериализация (без изменений) ─────────────────────────────────────
  Map<String, dynamic> toJson() => {
        'runId': runId,
        'projectId': projectId,
        'projectPath': projectPath,
        'state': state,
        'currentBranch': currentBranch,
      };

  factory RunContext.fromJson(
    Map<String, dynamic> json,
    void Function(
      String, {
      String type,
      int depth,
      required String branch,
      String? details,
    }) log, {
    ISandbox? sandbox,
  }) {
    final ctx = RunContext(
      runId: json['runId'] as String,
      projectId: json['projectId'] as String,
      projectPath: json['projectPath'] as String,
      currentBranch: json['currentBranch'] as String? ?? 'main',
      log: log,
      sandbox: sandbox,
    );
    if (json['state'] != null) {
      ctx.state.addAll(Map<String, dynamic>.from(json['state'] as Map));
    }
    return ctx;
  }
}

// ── Fallback sandbox (backward compat) ────────────────────────────────────────
// Используется пока WorkflowRunner не передаёт реальный sandbox.
// Не ограничивает ничего. Будет заменён в Sprint 2 когда WorkflowRunner
// реализует ISandboxAsProcess и передаёт себя в RunContext.

class _FallbackSandbox implements ISandbox {
  const _FallbackSandbox(this._id);
  final String _id;

  @override
  String get sandboxId => _id;
  @override
  String get displayName => 'Unrestricted';
  @override
  SandboxPolicy get policy => SandboxPolicy.unrestricted;
  @override
  Stream<ISandboxEvent> get events => const Stream.empty();
  @override
  Future<void> dispose() async {}
}
```

### Файл: `./lib/graph/engine/tool_registry.dart` (строк:       28, размер:      961 байт)

```dart
import 'i_hand.dart';

class ToolRegistry {
  final Map<String, IHand> _hands = {};

  /// Регистрация нового инструмента при старте приложения
  void register(IHand hand) {
    _hands[hand.id] = hand;
  }

  List<IHand> get registeredHands => _hands.values.toList();

  /// Получить инструмент по ID
  IHand? getHand(String id) => _hands[id];

  /// Получить список всех схем (для отправки в промпт LLM)
  List<Map<String, dynamic>> getAllSchemas() {
    return _hands.values.map((h) => h.toolSchema).toList();
  }

  /// Получить схемы только определенной категории (по префиксу, например 'fs_')
  List<Map<String, dynamic>> getSchemasByCategory(String prefix) {
    return _hands.values
        .where((h) => h.id.startsWith(prefix))
        .map((h) => h.toolSchema)
        .toList();
  }
}
```

### Файл: `./lib/graph/graph.dart` (строк:       28, размер:      909 байт)

```dart
// Граф-домен пакета aq_schema.
// Импортируй этот файл чтобы получить доступ ко всем граф-типам.

// Core abstractions
export 'core/graph_def.dart';

// Graph models
export 'graphs/workflow_graph.dart';
export 'graphs/instruction_graph.dart';
export 'graphs/prompt_graph.dart';
export 'graphs/contract_schema.dart';

// Engine primitives (pure Dart, no Flutter)
export 'engine/run_context.dart';
export 'engine/i_hand.dart';
export 'engine/tool_registry.dart';

// Logging
export 'logging/workflow_event_logger.dart';

// Validation
export 'validation/graph_contract_validator.dart';
// Transport
export 'transport/messages/run_event.dart';
export 'transport/messages/run_request.dart';
export 'transport/messages/run_status.dart';
export 'transport/messages/user_input_response.dart';
export 'transport/interfaces/i_engine_transport.dart';
```

### Файл: `./lib/graph/graphs/contract_schema.dart` (строк:      326, размер:    11852 байт)

```dart
import 'package:json_schema/json_schema.dart';

/// Схема контракта для валидации входных и выходных данных инструкций.
/// Соответствует JSON Schema Draft 7.
class ContractSchema {
  /// Идентификатор схемы (опционально)
  final String? id;

  /// Название схемы для отображения
  final String name;

  /// Описание схемы
  final String description;

  /// JSON Schema Draft 7 в виде Map
  final Map<String, dynamic> schema;

  /// Дата создания схемы
  final DateTime createdAt;

  /// Дата последнего обновления
  final DateTime updatedAt;

  ContractSchema({
    this.id,
    required this.name,
    required this.description,
    required this.schema,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Создает схему контракта по умолчанию для инструкций.
  /// Соответствует текущей структуре контрактов AQ Studio.
  factory ContractSchema.defaultInstructionContract() {
    return ContractSchema(
      name: 'Стандартный контракт инструкции',
      description: 'Базовая схема для входных и выходных данных инструкций',
      schema: {
        '\$schema': 'http://json-schema.org/draft-07/schema#',
        'type': 'object',
        'properties': {
          'inputs': {
            'type': 'array',
            'description': 'Входные параметры инструкции',
            'items': {
              'type': 'object',
              'properties': {
                'name': {'type': 'string', 'description': 'Имя параметра'},
                'type': {
                  'type': 'string',
                  'enum': ['string', 'number', 'boolean', 'object', 'array'],
                  'description': 'Тип данных параметра',
                },
                'description': {
                  'type': 'string',
                  'description': 'Описание параметра',
                },
                'required': {
                  'type': 'boolean',
                  'description': 'Обязательность параметра',
                  'default': true,
                },
                'default': {
                  'description': 'Значение по умолчанию',
                  'oneOf': [
                    {'type': 'string'},
                    {'type': 'number'},
                    {'type': 'boolean'},
                    {'type': 'object'},
                    {'type': 'array'},
                  ],
                },
              },
              'required': ['name', 'type'],
              'additionalProperties': false,
            },
          },
          'outputs': {
            'type': 'array',
            'description': 'Выходные параметры инструкции',
            'items': {
              'type': 'object',
              'properties': {
                'name': {'type': 'string', 'description': 'Имя параметра'},
                'type': {
                  'type': 'string',
                  'enum': ['string', 'number', 'boolean', 'object', 'array'],
                  'description': 'Тип данных параметра',
                },
                'description': {
                  'type': 'string',
                  'description': 'Описание параметра',
                },
              },
              'required': ['name', 'type'],
              'additionalProperties': false,
            },
          },
        },
        'required': ['inputs', 'outputs'],
        'additionalProperties': false,
      },
    );
  }

  /// Создает схему контракта для конкретного типа узла.
  /// Например, для узла типа 'userInputRequest' может быть специфичная схема.
  factory ContractSchema.forNodeType(String nodeType) {
    switch (nodeType) {
      case 'userInputRequest':
        return ContractSchema(
          name: 'Контракт запроса ввода пользователя',
          description: 'Схема для узлов, запрашивающих ввод от пользователя',
          schema: {
            '\$schema': 'http://json-schema.org/draft-07/schema#',
            'type': 'object',
            'properties': {
              'message': {
                'type': 'string',
                'description': 'Сообщение для пользователя',
              },
              'inputFields': {
                'type': 'array',
                'description': 'Поля для ввода',
                'items': {
                  'type': 'object',
                  'properties': {
                    'name': {'type': 'string'},
                    'label': {'type': 'string'},
                    'type': {
                      'type': 'string',
                      'enum': ['text', 'number', 'boolean', 'select'],
                    },
                    'required': {'type': 'boolean'},
                    'options': {
                      'type': 'array',
                      'items': {'type': 'string'},
                    },
                  },
                  'required': ['name', 'label', 'type'],
                },
              },
            },
            'required': ['message'],
          },
        );
      case 'validationCheck':
        return ContractSchema(
          name: 'Контракт проверки валидации',
          description: 'Схема для узлов проверки условий',
          schema: {
            '\$schema': 'http://json-schema.org/draft-07/schema#',
            'type': 'object',
            'properties': {
              'condition': {
                'type': 'string',
                'description': 'Условие для проверки в формате выражения',
              },
              'errorMessage': {
                'type': 'string',
                'description': 'Сообщение об ошибке при невыполнении условия',
              },
            },
            'required': ['condition'],
          },
        );
      default:
        return ContractSchema.defaultInstructionContract();
    }
  }

  /// Проверяет, соответствует ли контракт данной схеме.
  /// Возвращает список ошибок валидации.
  Future<List<SchemaValidationError>> validateContract(
    Map<String, dynamic> contract,
  ) async {
    try {
      // Используем JsonSchema.create для создания схемы из Dart-объекта
      final jsonSchema = await JsonSchema.create(schema);
      final validation = jsonSchema.validate(contract);

      if (validation.isValid) {
        return [];
      } else {
        return validation.errors.map((error) {
          return SchemaValidationError(
            path: error.schemaPath,
            message: error.message,
            detail:
                null, // Поле detail может отсутствовать в ValidationError пакета
          );
        }).toList();
      }
    } catch (e) {
      return [
        SchemaValidationError(
          path: '/',
          message: 'Ошибка при создании схемы валидации: $e',
        ),
      ];
    }
  }

  /// Проверяет, совместима ли данная схема с устаревшим форматом контракта.
  /// Возвращает true, если контракт может быть автоматически преобразован.
  bool isCompatibleWithLegacyFormat(Map<String, dynamic> legacyContract) {
    // Проверяем наличие обязательных полей inputs и outputs
    if (legacyContract['inputs'] is! List ||
        legacyContract['outputs'] is! List) {
      return false;
    }

    // Проверяем структуру каждого элемента
    final inputs = legacyContract['inputs'] as List;
    final outputs = legacyContract['outputs'] as List;

    for (final input in inputs) {
      if (input is! Map<String, dynamic>) return false;
      if (input['name'] == null || input['type'] == null) return false;
    }

    for (final output in outputs) {
      if (output is! Map<String, dynamic>) return false;
      if (output['name'] == null || output['type'] == null) return false;
    }

    return true;
  }

  /// Преобразует устаревший формат контракта в формат, соответствующий схеме.
  Map<String, dynamic> convertLegacyContract(
    Map<String, dynamic> legacyContract,
  ) {
    if (!isCompatibleWithLegacyFormat(legacyContract)) {
      throw ArgumentError('Контракт несовместим с устаревшим форматом');
    }

    final inputs = (legacyContract['inputs'] as List).map((item) {
      final map = item as Map<String, dynamic>;
      return {
        'name': map['name'],
        'type': map['type'],
        'description': map['description'] ?? '',
        'required': map['required'] ?? true,
        if (map.containsKey('default')) 'default': map['default'],
      };
    }).toList();

    final outputs = (legacyContract['outputs'] as List).map((item) {
      final map = item as Map<String, dynamic>;
      return {
        'name': map['name'],
        'type': map['type'],
        'description': map['description'] ?? '',
      };
    }).toList();

    return {'inputs': inputs, 'outputs': outputs};
  }

  /// Сериализация в JSON
  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'name': name,
    'description': description,
    'schema': schema,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  /// Десериализация из JSON
  factory ContractSchema.fromJson(Map<String, dynamic> json) {
    return ContractSchema(
      id: json['id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String,
      schema: json['schema'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Копия с обновленными полями
  ContractSchema copyWith({
    String? id,
    String? name,
    String? description,
    Map<String, dynamic>? schema,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ContractSchema(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      schema: schema ?? this.schema,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Ошибка валидации контракта (переименовано, чтобы избежать конфликта с ValidationError из json_schema)
class SchemaValidationError {
  /// Путь к полю в схеме
  final String path;

  /// Сообщение об ошибке
  final String message;

  /// Детальная информация об ошибке
  final String? detail;

  SchemaValidationError({
    required this.path,
    required this.message,
    this.detail,
  });

  @override
  String toString() {
    return detail != null ? '$path: $message ($detail)' : '$path: $message';
  }
}
```

### Файл: `./lib/graph/graphs/instruction_graph.dart` (строк:      267, размер:     7940 байт)

```dart
import 'package:aq_schema/graph/core/graph_def.dart';
import 'package:aq_schema/graph/graphs/contract_schema.dart';
import 'package:aq_schema/aq_schema.dart';

enum InstructionNodeType {
  stepDescription,
  userInputRequest,
  validationCheck,
  systemAction;

  String toJson() => name;
  static InstructionNodeType fromJson(String json) => values.byName(json);
}

class InstructionNode extends $Node {
  @override
  final String id;
  final InstructionNodeType type;
  final Map<String, dynamic> payload;

  const InstructionNode({
    required this.id,
    required this.type,
    this.payload = const {},
  });

  @override
  InstructionNode copyWith({
    String? id,
    InstructionNodeType? type,
    Map<String, dynamic>? payload,
  }) =>
      InstructionNode(
        id: id ?? this.id,
        type: type ?? this.type,
        payload: payload ?? this.payload,
      );

  String? get comment => payload['comment'] as String?;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.toJson(),
        'payload': payload,
      };

  factory InstructionNode.fromJson(Map<String, dynamic> json) =>
      InstructionNode(
        id: json['id'] as String,
        type: InstructionNodeType.fromJson(json['type'] as String),
        payload: (json['payload'] as Map<String, dynamic>?) ?? {},
      );
}

class InstructionEdge extends $Edge {
  @override
  final String id;
  @override
  final String sourceId;
  @override
  final String targetId;
  @override
  final String branchName;
  final String trigger;

  const InstructionEdge({
    required this.id,
    required this.sourceId,
    required this.targetId,
    required this.trigger,
    this.branchName = 'main',
  });

  @override
  InstructionEdge copyWith({
    String? id,
    String? sourceId,
    String? targetId,
    String? trigger,
    String? branchName,
  }) =>
      InstructionEdge(
        id: id ?? this.id,
        sourceId: sourceId ?? this.sourceId,
        targetId: targetId ?? this.targetId,
        trigger: trigger ?? this.trigger,
        branchName: branchName ?? this.branchName,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'sourceId': sourceId,
        'targetId': targetId,
        'trigger': trigger,
        'branchName': branchName,
      };

  factory InstructionEdge.fromJson(Map<String, dynamic> json) =>
      InstructionEdge(
        id: json['id'] as String,
        sourceId: json['sourceId'] as String,
        targetId: json['targetId'] as String,
        trigger: json['trigger'] as String,
        branchName: json['branchName'] as String? ?? 'main',
      );
}

/// Instruction graph — a reusable AI instruction with contract (inputs/outputs).
/// Implements [VersionedStorable]: every save creates a semver version.
/// [ownerId] = projectId.
class InstructionGraph extends $Graph<InstructionNode, InstructionEdge>
    implements VersionedStorable {
  static const kCollection = 'instruction_graphs';

  @override
  final String id;

  @override
  final String ownerId; // projectId

  @override
  final List<AccessGrant> accessGrants;

  final String name;

  /// Inputs/outputs contract — what this instruction accepts and returns.
  final Map<String, dynamic> contract;

  /// Test cases for TDD-style validation.
  final List<Map<String, dynamic>> tests;

  final ContractSchema? contractSchema;

  @override
  String get collectionName => kCollection;

  const InstructionGraph({
    required this.id,
    required this.ownerId,
    required this.name,
    super.nodes = const {},
    super.edges = const {},
    this.contract = const {'inputs': [], 'outputs': []},
    this.tests = const [],
    this.contractSchema,
    this.accessGrants = const [],
  });

  factory InstructionGraph.empty({
    String id = 'id',
    String projectId = 'id',
    String name = 'name',
  }) =>
      InstructionGraph(id: id, ownerId: projectId, name: name);

  // ── $Graph ──────────────────────────────────────────────────────────────────

  @override
  InstructionGraph addNode(InstructionNode node) =>
      _copy(nodes: {...nodes, node.id: node});

  @override
  InstructionGraph removeNode(String nodeId) => _copy(
        nodes: Map.from(nodes)..remove(nodeId),
        edges: Map.from(edges)
          ..removeWhere((_, e) => e.sourceId == nodeId || e.targetId == nodeId),
      );

  @override
  InstructionGraph addEdge(InstructionEdge edge) =>
      _copy(edges: {...edges, edge.id: edge});

  @override
  InstructionGraph removeEdge(String edgeId) =>
      _copy(edges: Map.from(edges)..remove(edgeId));

  InstructionGraph updateContract(Map<String, dynamic> newContract) =>
      _copy(contract: newContract);

  InstructionGraph updateTests(List<Map<String, dynamic>> newTests) =>
      _copy(tests: newTests);

  // ── Storable ────────────────────────────────────────────────────────────────

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'ownerId': ownerId,
        'name': name,
        'nodes': nodes.values.map((n) => n.toJson()).toList(),
        'edges': edges.values.map((e) => e.toJson()).toList(),
        'contract': contract,
        'tests': tests,
        if (contractSchema != null) 'contractSchema': contractSchema!.toJson(),
        'accessGrants': accessGrants.map((g) => g.toMap()).toList(),
      };

  @override
  Map<String, dynamic> get indexFields => {
        'ownerId': ownerId,
        'name': name,
      };

  static InstructionGraph fromMap(Map<String, dynamic> m) {
    final nList = ((m['nodes'] as List?) ?? [])
        .map((e) => InstructionNode.fromJson(e as Map<String, dynamic>));
    final eList = ((m['edges'] as List?) ?? [])
        .map((e) => InstructionEdge.fromJson(e as Map<String, dynamic>));
    return InstructionGraph(
      id: m['id'] as String,
      ownerId: m['ownerId'] as String? ?? '',
      name: m['name'] as String? ?? '',
      nodes: {for (var n in nList) n.id: n},
      edges: {for (var e in eList) e.id: e},
      contract: (m['contract'] as Map<String, dynamic>?) ??
          {'inputs': [], 'outputs': []},
      tests: ((m['tests'] as List?) ?? []).cast<Map<String, dynamic>>(),
      contractSchema: m['contractSchema'] != null
          ? ContractSchema.fromJson(m['contractSchema'] as Map<String, dynamic>)
          : null,
      accessGrants: ((m['accessGrants'] as List?) ?? [])
          .whereType<Map<String, dynamic>>()
          .map(AccessGrant.fromMap)
          .toList(),
    );
  }

  InstructionGraph copyWith({
    String? name,
    Map<String, InstructionNode>? nodes,
    Map<String, InstructionEdge>? edges,
    Map<String, dynamic>? contract,
    List<Map<String, dynamic>>? tests,
    List<AccessGrant>? accessGrants,
  }) =>
      _copy(
          name: name,
          nodes: nodes,
          edges: edges,
          contract: contract,
          tests: tests,
          accessGrants: accessGrants);

  InstructionGraph _copy({
    String? name,
    Map<String, InstructionNode>? nodes,
    Map<String, InstructionEdge>? edges,
    Map<String, dynamic>? contract,
    List<Map<String, dynamic>>? tests,
    ContractSchema? contractSchema,
    List<AccessGrant>? accessGrants,
  }) =>
      InstructionGraph(
        id: id,
        ownerId: ownerId,
        name: name ?? this.name,
        nodes: nodes ?? this.nodes,
        edges: edges ?? this.edges,
        contract: contract ?? this.contract,
        tests: tests ?? this.tests,
        contractSchema: contractSchema ?? this.contractSchema,
        accessGrants: accessGrants ?? this.accessGrants,
      );

  ContractSchema getContractSchema() =>
      contractSchema ?? ContractSchema.defaultInstructionContract();
}
```

### Файл: `./lib/graph/graphs/prompt_graph.dart` (строк:      214, размер:     5833 байт)

```dart
import 'package:aq_schema/graph/core/graph_def.dart';
import 'package:aq_schema/aq_schema.dart';

enum PromptNodeType {
  textBlock,
  variable,
  fileContext;

  String toJson() => name;
  static PromptNodeType fromJson(String json) => values.byName(json);
}

class PromptNode extends $Node {
  @override
  final String id;
  final PromptNodeType type;
  final Map<String, dynamic> data;

  const PromptNode({
    required this.id,
    required this.type,
    this.data = const {},
  });

  @override
  PromptNode copyWith({
    String? id,
    PromptNodeType? type,
    Map<String, dynamic>? data,
  }) =>
      PromptNode(
        id: id ?? this.id,
        type: type ?? this.type,
        data: data ?? this.data,
      );

  String? get comment => data['comment'] as String?;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.toJson(),
        'data': data,
      };

  factory PromptNode.fromJson(Map<String, dynamic> json) => PromptNode(
        id: json['id'] as String,
        type: PromptNodeType.fromJson(json['type'] as String),
        data: (json['data'] as Map<String, dynamic>?) ?? {},
      );
}

class PromptEdge extends $Edge {
  @override
  final String id;
  @override
  final String sourceId;
  @override
  final String targetId;
  @override
  final String branchName;

  const PromptEdge({
    required this.id,
    required this.sourceId,
    required this.targetId,
    this.branchName = 'main',
  });

  @override
  PromptEdge copyWith({
    String? id,
    String? sourceId,
    String? targetId,
    String? branchName,
  }) =>
      PromptEdge(
        id: id ?? this.id,
        sourceId: sourceId ?? this.sourceId,
        targetId: targetId ?? this.targetId,
        branchName: branchName ?? this.branchName,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'sourceId': sourceId,
        'targetId': targetId,
        'branchName': branchName,
      };

  factory PromptEdge.fromJson(Map<String, dynamic> json) => PromptEdge(
        id: json['id'] as String,
        sourceId: json['sourceId'] as String,
        targetId: json['targetId'] as String,
        branchName: json['branchName'] as String? ?? 'main',
      );
}

/// Prompt graph — an LLM prompt template with variable blocks.
/// Implements [VersionedStorable]: prompts are versioned like graphs.
/// [ownerId] = projectId.
class PromptGraph extends $Graph<PromptNode, PromptEdge>
    implements VersionedStorable {
  static const kCollection = 'prompt_graphs';

  @override
  final String id;

  @override
  final String ownerId; // projectId

  @override
  final List<AccessGrant> accessGrants;

  final String name;

  @override
  String get collectionName => kCollection;

  const PromptGraph({
    required this.id,
    required this.ownerId,
    required this.name,
    super.nodes = const {},
    super.edges = const {},
    this.accessGrants = const [],
  });

  factory PromptGraph.empty({
    String id = 'id',
    String projectId = 'id',
    String name = 'name',
  }) =>
      PromptGraph(id: id, ownerId: projectId, name: name);

  // ── $Graph ──────────────────────────────────────────────────────────────────

  @override
  PromptGraph addNode(PromptNode node) =>
      _copy(nodes: {...nodes, node.id: node});

  @override
  PromptGraph removeNode(String nodeId) => _copy(
        nodes: Map.from(nodes)..remove(nodeId),
        edges: Map.from(edges)
          ..removeWhere((_, e) => e.sourceId == nodeId || e.targetId == nodeId),
      );

  @override
  PromptGraph addEdge(PromptEdge edge) =>
      _copy(edges: {...edges, edge.id: edge});

  @override
  PromptGraph removeEdge(String edgeId) =>
      _copy(edges: Map.from(edges)..remove(edgeId));

  // ── Storable ────────────────────────────────────────────────────────────────

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'ownerId': ownerId,
        'name': name,
        'nodes': nodes.values.map((n) => n.toJson()).toList(),
        'edges': edges.values.map((e) => e.toJson()).toList(),
        'accessGrants': accessGrants.map((g) => g.toMap()).toList(),
      };

  @override
  Map<String, dynamic> get indexFields => {
        'ownerId': ownerId,
        'name': name,
      };

  static PromptGraph fromMap(Map<String, dynamic> m) {
    final nList = ((m['nodes'] as List?) ?? [])
        .map((e) => PromptNode.fromJson(e as Map<String, dynamic>));
    final eList = ((m['edges'] as List?) ?? [])
        .map((e) => PromptEdge.fromJson(e as Map<String, dynamic>));
    return PromptGraph(
      id: m['id'] as String,
      ownerId: m['ownerId'] as String? ?? '',
      name: m['name'] as String? ?? '',
      nodes: {for (var n in nList) n.id: n},
      edges: {for (var e in eList) e.id: e},
      accessGrants: ((m['accessGrants'] as List?) ?? [])
          .whereType<Map<String, dynamic>>()
          .map(AccessGrant.fromMap)
          .toList(),
    );
  }

  PromptGraph copyWith({
    String? name,
    Map<String, PromptNode>? nodes,
    Map<String, PromptEdge>? edges,
    List<AccessGrant>? accessGrants,
  }) =>
      _copy(name: name, nodes: nodes, edges: edges, accessGrants: accessGrants);

  PromptGraph _copy({
    String? name,
    Map<String, PromptNode>? nodes,
    Map<String, PromptEdge>? edges,
    List<AccessGrant>? accessGrants,
  }) =>
      PromptGraph(
        id: id,
        ownerId: ownerId,
        name: name ?? this.name,
        nodes: nodes ?? this.nodes,
        edges: edges ?? this.edges,
        accessGrants: accessGrants ?? this.accessGrants,
      );
}
```

### Файл: `./lib/graph/graphs/workflow_graph.dart` (строк:      245, размер:     6914 байт)

```dart
import 'package:aq_schema/graph/core/graph_def.dart';
import 'package:aq_schema/aq_schema.dart';

enum WorkflowNodeType {
  llmAction,
  fileWrite,
  fileRead,
  gitCommit,
  subGraph,
  manualReview,
  fileUpload,
  userInput,
  coCreationChat,
  runInstruction;

  String toJson() => name;
  static WorkflowNodeType fromJson(String json) => values.byName(json);
}

enum WorkflowEdgeType {
  onSuccess,
  onError,
  conditional;

  String toJson() => name;
  static WorkflowEdgeType fromJson(String json) => values.byName(json);
}

class WorkflowNode extends $Node {
  @override
  final String id;
  final WorkflowNodeType type;
  final Map<String, dynamic> config;

  const WorkflowNode({
    required this.id,
    required this.type,
    this.config = const {},
  });

  @override
  WorkflowNode copyWith({
    String? id,
    WorkflowNodeType? type,
    Map<String, dynamic>? config,
  }) =>
      WorkflowNode(
        id: id ?? this.id,
        type: type ?? this.type,
        config: config ?? this.config,
      );

  String? get comment => config['comment'] as String?;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.toJson(),
        'config': config,
      };

  factory WorkflowNode.fromJson(Map<String, dynamic> json) => WorkflowNode(
        id: json['id'] as String,
        type: WorkflowNodeType.fromJson(json['type'] as String),
        config: (json['config'] as Map<String, dynamic>?) ?? {},
      );
}

class WorkflowEdge extends $Edge {
  @override
  final String id;
  @override
  final String sourceId;
  @override
  final String targetId;
  @override
  final String branchName;
  final WorkflowEdgeType type;
  final String? conditionExpression;

  const WorkflowEdge({
    required this.id,
    required this.sourceId,
    required this.targetId,
    this.branchName = 'main',
    this.type = WorkflowEdgeType.onSuccess,
    this.conditionExpression,
  });

  @override
  WorkflowEdge copyWith({
    String? id,
    String? sourceId,
    String? targetId,
    String? branchName,
    WorkflowEdgeType? type,
    String? conditionExpression,
  }) =>
      WorkflowEdge(
        id: id ?? this.id,
        sourceId: sourceId ?? this.sourceId,
        targetId: targetId ?? this.targetId,
        branchName: branchName ?? this.branchName,
        type: type ?? this.type,
        conditionExpression: conditionExpression ?? this.conditionExpression,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'sourceId': sourceId,
        'targetId': targetId,
        'branchName': branchName,
        'type': type.toJson(),
        'conditionExpression': conditionExpression,
      };

  factory WorkflowEdge.fromJson(Map<String, dynamic> json) => WorkflowEdge(
        id: json['id'] as String,
        sourceId: json['sourceId'] as String,
        targetId: json['targetId'] as String,
        branchName: json['branchName'] as String? ?? 'main',
        type: WorkflowEdgeType.fromJson(json['type'] as String),
        conditionExpression: json['conditionExpression'] as String?,
      );
}

/// Workflow graph — a project's automation flow.
/// Implements [VersionedStorable]: every save creates a semver version.
/// [ownerId] = projectId — the project this graph belongs to.
class WorkflowGraph extends $Graph<WorkflowNode, WorkflowEdge>
    implements VersionedStorable {
  /// Storage collection name — shared between client and server.
  static const kCollection = 'workflow_graphs';

  @override
  final String id;

  @override
  final String ownerId; // projectId

  @override
  final List<AccessGrant> accessGrants;

  /// Human-readable name shown in the project panel.
  final String name;

  @override
  String get collectionName => kCollection;

  const WorkflowGraph({
    required this.id,
    required this.ownerId,
    required this.name,
    super.nodes = const {},
    super.edges = const {},
    this.accessGrants = const [],
  });

  factory WorkflowGraph.empty({
    String id = 'id',
    String projectId = 'projectid',
    String name = 'projectName',
  }) =>
      WorkflowGraph(id: id, ownerId: projectId, name: name);

  // ── $Graph overrides ────────────────────────────────────────────────────────

  @override
  WorkflowGraph addNode(WorkflowNode node) =>
      _copy(nodes: {...nodes, node.id: node});

  @override
  WorkflowGraph removeNode(String nodeId) => _copy(
        nodes: Map.from(nodes)..remove(nodeId),
        edges: Map.from(edges)
          ..removeWhere((_, e) => e.sourceId == nodeId || e.targetId == nodeId),
      );

  @override
  WorkflowGraph addEdge(WorkflowEdge edge) =>
      _copy(edges: {...edges, edge.id: edge});

  @override
  WorkflowGraph removeEdge(String edgeId) =>
      _copy(edges: Map.from(edges)..remove(edgeId));

  // ── Storable ────────────────────────────────────────────────────────────────

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'ownerId': ownerId,
        'name': name,
        'nodes': nodes.values.map((n) => n.toJson()).toList(),
        'edges': edges.values.map((e) => e.toJson()).toList(),
        'accessGrants': accessGrants.map((g) => g.toMap()).toList(),
      };

  @override
  Map<String, dynamic> get indexFields => {
        'ownerId': ownerId,
        'name': name,
      };

  /// Deserialise from storage map.
  static WorkflowGraph fromMap(Map<String, dynamic> m) {
    final nList = ((m['nodes'] as List?) ?? [])
        .map((e) => WorkflowNode.fromJson(e as Map<String, dynamic>));
    final eList = ((m['edges'] as List?) ?? [])
        .map((e) => WorkflowEdge.fromJson(e as Map<String, dynamic>));
    return WorkflowGraph(
      id: m['id'] as String,
      ownerId: m['ownerId'] as String? ?? '',
      name: m['name'] as String? ?? '',
      nodes: {for (var n in nList) n.id: n},
      edges: {for (var e in eList) e.id: e},
      accessGrants: ((m['accessGrants'] as List?) ?? [])
          .whereType<Map<String, dynamic>>()
          .map(AccessGrant.fromMap)
          .toList(),
    );
  }

  WorkflowGraph copyWith({
    String? name,
    Map<String, WorkflowNode>? nodes,
    Map<String, WorkflowEdge>? edges,
    List<AccessGrant>? accessGrants,
  }) =>
      _copy(name: name, nodes: nodes, edges: edges, accessGrants: accessGrants);

  WorkflowGraph _copy({
    String? name,
    Map<String, WorkflowNode>? nodes,
    Map<String, WorkflowEdge>? edges,
    List<AccessGrant>? accessGrants,
  }) =>
      WorkflowGraph(
        id: id,
        ownerId: ownerId,
        name: name ?? this.name,
        nodes: nodes ?? this.nodes,
        edges: edges ?? this.edges,
        accessGrants: accessGrants ?? this.accessGrants,
      );
}
```

### Файл: `./lib/graph/graphs/workflow/i_workflow_run.dart` (строк:        1, размер:       31 байт)

```dart
abstract class IWorkflowRun {}
```

### Файл: `./lib/graph/logging/workflow_event_logger.dart` (строк:      161, размер:     4464 байт)

```dart
/// ✅ Typedef для функции логирования из WorkflowRunner
typedef WorkflowLog =
    void Function(
      String message, {
      String type,
      int depth,
      required String branch,
      String? details,
    });

/// ✅ WorkflowEventLogger - красивое логирование действий пользователя
class WorkflowEventLogger {
  final WorkflowLog _log;

  WorkflowEventLogger(this._log);

  /// Логировать действие пользователя
  void logUserAction(String actionType, Map<String, dynamic> data) {
    switch (actionType) {
      case 'button_clicked':
        _logButtonClick(data);
        break;
      case 'form_submitted':
        _logFormSubmit(data);
        break;
      case 'input_changed':
        _logInputChange(data);
        break;
      case 'workflow_resumed':
        _logWorkflowResume(data);
        break;
      case 'action_failed':
        _logActionFailed(data);
        break;
      case 'navigate_requested':
        _logNavigate(data);
        break;
      default:
        _log(
          "📌 User action: $actionType",
          type: 'user_action',
          branch: 'interaction',
          details: data.toString(),
        );
    }
  }

  void _logButtonClick(Map<String, dynamic> data) {
    final buttonId = data['button_id'] ?? 'unknown';
    final label = data['label'] ?? 'Submit';
    final targetVar = data['target_var'] ?? 'unknown';

    _log(
      "👆 User clicked: $label",
      type: 'user_action',
      branch: 'interaction',
      details: 'button=$buttonId, target=$targetVar',
    );

    if (data['collected_data'] != null) {
      final collected = data['collected_data'] as Map;
      collected.forEach((key, value) {
        _log(
          "   ├─ $key = ${_formatValue(value)}",
          type: 'user_data',
          branch: 'interaction',
          depth: 1,
        );
      });
    }
  }

  void _logFormSubmit(Map<String, dynamic> data) {
    final formId = data['form_id'] ?? 'form';
    final fieldCount = (data['fields'] as List?)?.length ?? 0;

    _log(
      "📝 Form submitted: $formId",
      type: 'user_action',
      branch: 'interaction',
      details: 'fields=$fieldCount',
    );

    if (data['validation_errors'] != null) {
      _log(
        "   ⚠️ Validation errors",
        type: 'warning',
        branch: 'interaction',
        depth: 1,
      );
      (data['validation_errors'] as List).forEach((error) {
        _log("   └─ $error", type: 'warning', branch: 'interaction', depth: 2);
      });
    }
  }

  void _logInputChange(Map<String, dynamic> data) {
    final componentId = data['component_id'] ?? 'unknown';
    final oldValue = data['old_value'];
    final newValue = data['new_value'];

    _log(
      "✏️ Input changed: $componentId",
      type: 'user_action',
      branch: 'interaction',
      details: '${_formatValue(oldValue)} → ${_formatValue(newValue)}',
    );
  }

  void _logWorkflowResume(Map<String, dynamic> data) {
    final runId = (data['run_id'] as String?)?.substring(0, 8) ?? 'unknown';

    _log(
      "⚡ Workflow resumed",
      type: 'success',
      branch: 'system',
      details: 'run=$runId',
    );

    if (data['injected'] != null) {
      final injected = data['injected'] as Map;
      injected.forEach((key, value) {
        _log(
          "   ├─ \$$key = ${_formatValue(value)}",
          type: 'success',
          branch: 'system',
          depth: 1,
        );
      });
    }
  }

  void _logActionFailed(Map<String, dynamic> data) {
    final actionType = data['action'] ?? 'unknown';
    final error = data['error'] ?? 'unknown error';

    _log(
      "❌ Action failed: $actionType",
      type: 'error',
      branch: 'system',
      details: error,
    );
  }

  void _logNavigate(Map<String, dynamic> data) {
    final target = data['target'] ?? 'unknown';

    _log("🔗 Navigate to: $target", type: 'user_action', branch: 'interaction');
  }

  /// Форматировать значение для логов
  String _formatValue(dynamic value) {
    if (value == null) return 'null';
    if (value is String) return '"$value"';
    if (value is bool) return value ? 'true' : 'false';
    if (value is List) return '[${value.length} items]';
    if (value is Map) return '{${value.length} keys}';
    if (value is double) return value.toStringAsFixed(2);
    return value.toString();
  }
}
```

### Файл: `./lib/graph/transport/analysis_options.yaml` (строк:        0, размер:       39 байт)

```yaml
include: package:lints/recommended.yaml```

### Файл: `./lib/graph/transport/interfaces/i_engine_transport.dart` (строк:       27, размер:     1302 байт)

```dart
// Интерфейс транспорта между клиентом и движком.
//
// Локальная реализация (desktop): вызывает движок напрямую в том же процессе.
// Удалённая реализация (web service): отправляет HTTP запросы к серверу.
// В обоих случаях клиент работает одинаково — через этот интерфейс.

import '../messages/run_request.dart';
import '../messages/run_event.dart';
import '../messages/user_input_response.dart';

abstract class IEngineTransport {
  /// Запустить граф.
  /// Возвращает Stream событий — клиент слушает его и обновляет UI.
  Stream<GraphRunEvent> run(GraphRunRequest request);

  /// Отправить ответ пользователя когда граф ждёт ввода.
  Future<void> respondToInput(UserInputResponse response);

  /// Отменить выполнение.
  Future<void> cancel(String runId);

  /// Проверить доступность движка (для удалённого транспорта — health check).
  Future<bool> isAvailable();

  /// Освободить ресурсы.
  void dispose();
}
```

### Файл: `./lib/graph/transport/messages/run_event.dart` (строк:      138, размер:     3909 байт)

```dart
// Событие которое движок отправляет клиенту во время выполнения.
// Клиент подписывается на Stream<GraphRunEvent> и получает обновления в реальном времени.

import 'run_status.dart';

/// Тип события
enum GraphRunEventType {
  /// Строка лога (выполнение шагов, системные сообщения)
  log,

  /// Статус изменился (например: running → suspended)
  statusChanged,

  /// Граф завершил выполнение
  completed,

  /// Произошла ошибка
  error,

  /// Движок ждёт ввода пользователя (см. UserInputRequired)
  userInputRequired,
}

class GraphRunEvent {
  final String runId;
  final GraphRunEventType type;
  final DateTime timestamp;

  /// Текст лога (для type == log)
  final String? message;

  /// Тип лога: 'system', 'node', 'error', 'warning', 'user_action', 'start', 'success'
  final String? logType;

  /// Ветка выполнения (для type == log)
  final String? branch;

  /// Глубина вложенности (для type == log)
  final int depth;

  /// Новый статус (для type == statusChanged)
  final GraphRunStatus? newStatus;

  /// Информация о необходимом вводе (для type == userInputRequired)
  final Map<String, dynamic>? inputRequiredPayload;

  /// Ошибка (для type == error)
  final String? errorMessage;

  GraphRunEvent({
    required this.runId,
    required this.type,
    DateTime? timestamp,
    this.message,
    this.logType,
    this.branch,
    this.depth = 0,
    this.newStatus,
    this.inputRequiredPayload,
    this.errorMessage,
  }) : timestamp = timestamp ?? DateTime.now();

  // ─── Удобные фабричные конструкторы ───────────────────────────────────────

  factory GraphRunEvent.log({
    required String runId,
    required String message,
    required String logType,
    required String branch,
    int depth = 0,
  }) {
    return GraphRunEvent(
      runId: runId,
      type: GraphRunEventType.log,
      message: message,
      logType: logType,
      branch: branch,
      depth: depth,
    );
  }

  factory GraphRunEvent.statusChanged({
    required String runId,
    required GraphRunStatus status,
  }) {
    return GraphRunEvent(
      runId: runId,
      type: GraphRunEventType.statusChanged,
      newStatus: status,
    );
  }

  factory GraphRunEvent.completed({required String runId}) {
    return GraphRunEvent(
      runId: runId,
      type: GraphRunEventType.completed,
      newStatus: GraphRunStatus.completed,
    );
  }

  factory GraphRunEvent.error({
    required String runId,
    required String message,
  }) {
    return GraphRunEvent(
      runId: runId,
      type: GraphRunEventType.error,
      errorMessage: message,
      newStatus: GraphRunStatus.failed,
    );
  }

  factory GraphRunEvent.userInputRequired({
    required String runId,
    required Map<String, dynamic> payload,
  }) {
    return GraphRunEvent(
      runId: runId,
      type: GraphRunEventType.userInputRequired,
      inputRequiredPayload: payload,
      newStatus: GraphRunStatus.suspended,
    );
  }

  Map<String, dynamic> toJson() => {
    'runId': runId,
    'type': type.name,
    'timestamp': timestamp.toIso8601String(),
    if (message != null) 'message': message,
    if (logType != null) 'logType': logType,
    if (branch != null) 'branch': branch,
    'depth': depth,
    if (newStatus != null) 'newStatus': newStatus!.toJson(),
    if (inputRequiredPayload != null)
      'inputRequiredPayload': inputRequiredPayload,
    if (errorMessage != null) 'errorMessage': errorMessage,
  };
}
```

### Файл: `./lib/graph/transport/messages/run_request.dart` (строк:       61, размер:     2236 байт)

```dart
// Запрос на запуск графа.
// Клиент (Flutter-приложение) отправляет это движку чтобы начать выполнение.

class GraphRunRequest {
  /// Уникальный ID этого запуска (генерирует клиент, например uuid v4)
  final String runId;

  /// ID проекта
  final String projectId;

  /// Путь к папке проекта на диске (нужен для file hands)
  final String projectPath;

  /// ID blueprint (графа) который нужно запустить
  final String blueprintId;

  /// Начальные переменные — кладутся в RunContext.state перед стартом
  final Map<String, dynamic> initialVariables;

  /// Если не null — это Resume (возобновление после паузы).
  /// Содержит сохранённый JSON состояния RunContext.
  final String? resumeStateJson;

  /// При Resume — ID узла с которого продолжить
  final String? resumeFromNodeId;

  const GraphRunRequest({
    required this.runId,
    required this.projectId,
    required this.projectPath,
    required this.blueprintId,
    this.initialVariables = const {},
    this.resumeStateJson,
    this.resumeFromNodeId,
  });

  bool get isResume => resumeStateJson != null;

  Map<String, dynamic> toJson() => {
    'runId': runId,
    'projectId': projectId,
    'projectPath': projectPath,
    'blueprintId': blueprintId,
    'initialVariables': initialVariables,
    if (resumeStateJson != null) 'resumeStateJson': resumeStateJson,
    if (resumeFromNodeId != null) 'resumeFromNodeId': resumeFromNodeId,
  };

  factory GraphRunRequest.fromJson(Map<String, dynamic> json) {
    return GraphRunRequest(
      runId: json['runId'] as String,
      projectId: json['projectId'] as String,
      projectPath: json['projectPath'] as String,
      blueprintId: json['blueprintId'] as String,
      initialVariables:
          (json['initialVariables'] as Map<String, dynamic>?) ?? {},
      resumeStateJson: json['resumeStateJson'] as String?,
      resumeFromNodeId: json['resumeFromNodeId'] as String?,
    );
  }
}
```

### Файл: `./lib/graph/transport/messages/run_status.dart` (строк:       27, размер:      678 байт)

```dart
// Возможные статусы выполнения графа

enum GraphRunStatus {
  /// Запрос принят, ещё не запущен
  queued,

  /// Выполняется прямо сейчас
  running,

  /// Приостановлен — ждёт ввода от пользователя
  suspended,

  /// Успешно завершён
  completed,

  /// Завершён с ошибкой
  failed,

  /// Отменён пользователем
  cancelled;

  String toJson() => name;
  static GraphRunStatus fromJson(String s) => values.byName(s);

  bool get isTerminal =>
      this == completed || this == failed || this == cancelled;
}
```

### Файл: `./lib/graph/transport/messages/user_input_response.dart` (строк:       44, размер:     1431 байт)

```dart
// Ответ пользователя движку когда граф приостановлен и ждёт ввода.

class UserInputResponse {
  /// ID запуска который ждёт ввода
  final String runId;

  /// ID узла на котором приостановлен граф
  final String nodeId;

  /// Данные введённые пользователем (ключ → значение)
  final Map<String, dynamic> values;

  /// true = пользователь одобрил (для manualReview узлов)
  final bool approved;

  /// Путь к загруженному файлу (для fileUpload узлов)
  final String? uploadedFilePath;

  const UserInputResponse({
    required this.runId,
    required this.nodeId,
    this.values = const {},
    this.approved = true,
    this.uploadedFilePath,
  });

  Map<String, dynamic> toJson() => {
    'runId': runId,
    'nodeId': nodeId,
    'values': values,
    'approved': approved,
    if (uploadedFilePath != null) 'uploadedFilePath': uploadedFilePath,
  };

  factory UserInputResponse.fromJson(Map<String, dynamic> json) {
    return UserInputResponse(
      runId: json['runId'] as String,
      nodeId: json['nodeId'] as String,
      values: (json['values'] as Map<String, dynamic>?) ?? {},
      approved: (json['approved'] as bool?) ?? true,
      uploadedFilePath: json['uploadedFilePath'] as String?,
    );
  }
}
```

### Файл: `./lib/graph/validation/graph_contract_validator.dart` (строк:       59, размер:     2034 байт)

```dart
// Адаптирован из lib/infrastructure/validation/json_schema_validator.dart
// Перенесён в пакет, так как является частью доменной логики графов.
import 'package:json_schema/json_schema.dart';
import '../graphs/contract_schema.dart';

class GraphContractValidator {
  Future<List<SchemaValidationError>> validate({
    required Map<String, dynamic> data,
    required Map<String, dynamic> schema,
  }) async {
    try {
      final jsonSchema = await JsonSchema.create(schema);
      final validation = jsonSchema.validate(data);
      if (validation.isValid) return [];
      return validation.errors
          .map(
            (error) => SchemaValidationError(
              path: error.schemaPath,
              message: error.message,
            ),
          )
          .toList();
    } catch (e) {
      return [SchemaValidationError(path: '/', message: 'Schema error: $e')];
    }
  }

  Future<List<SchemaValidationError>> validateInstructionContract({
    required Map<String, dynamic> contract,
  }) async {
    final defaultSchema = ContractSchema.defaultInstructionContract();
    return await validate(data: contract, schema: defaultSchema.schema);
  }

  Future<List<SchemaValidationError>> validateWithContractSchema({
    required Map<String, dynamic> contract,
    required ContractSchema contractSchema,
  }) async {
    return await validate(data: contract, schema: contractSchema.schema);
  }

  bool isLegacyContractCompatible(Map<String, dynamic> contract) {
    return ContractSchema.defaultInstructionContract()
        .isCompatibleWithLegacyFormat(contract);
  }

  Map<String, dynamic> convertLegacyContract(Map<String, dynamic> contract) {
    return ContractSchema.defaultInstructionContract().convertLegacyContract(
      contract,
    );
  }

  Future<bool> isValid({
    required Map<String, dynamic> data,
    required Map<String, dynamic> schema,
  }) async {
    return (await validate(data: data, schema: schema)).isEmpty;
  }
}
```

### Файл: `./lib/mcp/models/mcp_capabilities.dart` (строк:      131, размер:     3673 байт)

```dart
/// MCP server capabilities advertised during initialize handshake.
library;

/// Server capabilities returned in initialize response.
final class McpCapabilities {
  const McpCapabilities({
    this.tools = const McpToolsCapability(),
    this.logging,
    this.aqExtensions,
  });

  factory McpCapabilities.fromJson(Map<String, dynamic> json) {
    final toolsRaw = json['tools'] as Map<String, dynamic>?;
    final aqRaw = json['_aq_extensions'] as Map<String, dynamic>?;
    return McpCapabilities(
      tools: toolsRaw != null
          ? McpToolsCapability.fromJson(toolsRaw)
          : const McpToolsCapability(),
      logging: json['logging'] as Map<String, dynamic>?,
      aqExtensions: aqRaw != null ? AqExtensions.fromJson(aqRaw) : null,
    );
  }

  final McpToolsCapability tools;
  final Map<String, dynamic>? logging;

  /// AQ EXTENSION: vendor-specific capabilities.
  final AqExtensions? aqExtensions;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'tools': tools.toJson(),
    };
    if (logging != null) map['logging'] = logging;
    if (aqExtensions != null) map['_aq_extensions'] = aqExtensions!.toJson();
    return map;
  }
}

/// Tool-related capabilities subset.
final class McpToolsCapability {
  const McpToolsCapability({this.listChanged = false});

  factory McpToolsCapability.fromJson(Map<String, dynamic> json) =>
      McpToolsCapability(
        listChanged: (json['listChanged'] as bool?) ?? false,
      );

  /// Whether server sends notifications when tool list changes.
  final bool listChanged;

  Map<String, dynamic> toJson() => {'listChanged': listChanged};
}

/// AQ vendor extensions advertised in initialize response.
final class AqExtensions {
  const AqExtensions({
    this.authSupported = false,
    this.authMethods = const [],
    this.asyncJobs = false,
    this.workerCount = 0,
  });

  factory AqExtensions.fromJson(Map<String, dynamic> json) {
    final authRaw = json['auth'] as Map<String, dynamic>?;
    return AqExtensions(
      authSupported: (authRaw?['supported'] as bool?) ?? false,
      authMethods: (authRaw?['methods'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      asyncJobs: (json['async_jobs'] as bool?) ?? false,
      workerCount: (json['worker_count'] as int?) ?? 0,
    );
  }

  final bool authSupported;
  final List<String> authMethods;
  final bool asyncJobs;
  final int workerCount;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'async_jobs': asyncJobs,
      'worker_count': workerCount,
    };
    if (authSupported || authMethods.isNotEmpty) {
      map['auth'] = {
        'supported': authSupported,
        'methods': authMethods,
      };
    }
    return map;
  }
}

/// Server info block in initialize response.
final class McpServerInfo {
  const McpServerInfo({
    required this.name,
    required this.version,
  });

  factory McpServerInfo.fromJson(Map<String, dynamic> json) => McpServerInfo(
        name: json['name'] as String,
        version: json['version'] as String,
      );

  final String name;
  final String version;

  Map<String, dynamic> toJson() => {'name': name, 'version': version};
}

/// Client info block in initialize request.
final class McpClientInfo {
  const McpClientInfo({
    required this.name,
    required this.version,
  });

  factory McpClientInfo.fromJson(Map<String, dynamic> json) => McpClientInfo(
        name: json['name'] as String,
        version: json['version'] as String,
      );

  final String name;
  final String version;

  Map<String, dynamic> toJson() => {'name': name, 'version': version};
}
```

### Файл: `./lib/mcp/models/mcp_error.dart` (строк:      149, размер:     4868 байт)

```dart
/// MCP error codes — JSON-RPC standard + AQ extensions.
///
/// Standard JSON-RPC codes: -32700 .. -32600
/// AQ extension codes:       -32000 .. -32004
library;

/// Error codes used in MCP protocol responses.
abstract final class McpErrorCode {
  // ── JSON-RPC Standard ──────────────────────────────────
  /// Invalid JSON received by server.
  static const int parseError = -32700;

  /// JSON sent is not a valid Request object.
  static const int invalidRequest = -32600;

  /// Method does not exist or is not available.
  static const int methodNotFound = -32601;

  /// Invalid method parameters.
  static const int invalidParams = -32602;

  /// Internal JSON-RPC error.
  static const int internalError = -32603;

  // ── AQ Extensions ─────────────────────────────────────
  /// Worker execution failed (generic).
  static const int workerExecutionFailed = -32000;

  /// Worker did not respond within timeout.
  static const int workerTimeout = -32001;

  /// No worker available for requested tool.
  static const int workerNotAvailable = -32002;

  /// Tool requires authentication but none provided.
  static const int authRequired = -32003;

  /// Provided auth token is invalid or expired.
  static const int authInvalid = -32004;

  /// Human-readable label for a given error code.
  static String label(int code) => switch (code) {
        parseError => 'Parse error',
        invalidRequest => 'Invalid Request',
        methodNotFound => 'Method not found',
        invalidParams => 'Invalid params',
        internalError => 'Internal error',
        workerExecutionFailed => 'Worker execution failed',
        workerTimeout => 'Worker timeout',
        workerNotAvailable => 'Worker not available',
        authRequired => 'Authentication required',
        authInvalid => 'Authentication invalid',
        _ => 'Unknown error',
      };
}

/// Represents a JSON-RPC 2.0 error object embedded in an error response.
final class McpError {
  const McpError({
    required this.code,
    required this.message,
    this.data,
  });

  /// Constructs from a decoded JSON map.
  factory McpError.fromJson(Map<String, dynamic> json) {
    return McpError(
      code: json['code'] as int,
      message: json['message'] as String,
      data: json['data'],
    );
  }

  /// JSON-RPC error code. See [McpErrorCode].
  final int code;

  /// Human-readable error message.
  final String message;

  /// Optional additional error context (any JSON value).
  final Object? data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'code': code,
      'message': message,
    };
    if (data != null) map['data'] = data;
    return map;
  }

  // ── Convenience constructors ───────────────────────────

  static McpError parseError([String? detail]) => McpError(
        code: McpErrorCode.parseError,
        message: McpErrorCode.label(McpErrorCode.parseError),
        data: detail,
      );

  static McpError invalidRequest([String? detail]) => McpError(
        code: McpErrorCode.invalidRequest,
        message: McpErrorCode.label(McpErrorCode.invalidRequest),
        data: detail,
      );

  static McpError methodNotFound(String method) => McpError(
        code: McpErrorCode.methodNotFound,
        message: McpErrorCode.label(McpErrorCode.methodNotFound),
        data: 'Method not found: $method',
      );

  static McpError invalidParams([String? detail]) => McpError(
        code: McpErrorCode.invalidParams,
        message: McpErrorCode.label(McpErrorCode.invalidParams),
        data: detail,
      );

  static McpError internalError([String? detail]) => McpError(
        code: McpErrorCode.internalError,
        message: McpErrorCode.label(McpErrorCode.internalError),
        data: detail,
      );

  static McpError workerTimeout(String jobId) => McpError(
        code: McpErrorCode.workerTimeout,
        message: McpErrorCode.label(McpErrorCode.workerTimeout),
        data: 'job_id: $jobId',
      );

  static McpError workerNotAvailable(String tool) => McpError(
        code: McpErrorCode.workerNotAvailable,
        message: McpErrorCode.label(McpErrorCode.workerNotAvailable),
        data: 'No worker available for tool: $tool',
      );

  static McpError authRequired() => McpError(
        code: McpErrorCode.authRequired,
        message: McpErrorCode.label(McpErrorCode.authRequired),
      );

  static McpError authInvalid([String? reason]) => McpError(
        code: McpErrorCode.authInvalid,
        message: McpErrorCode.label(McpErrorCode.authInvalid),
        data: reason,
      );

  @override
  String toString() => 'McpError(code: $code, message: $message)';
}
```

### Файл: `./lib/mcp/models/mcp_request.dart` (строк:      259, размер:     8219 байт)

```dart
/// MCP JSON-RPC 2.0 request and response models.
library;

import 'package:aq_schema/auth/models/auth_context.dart';

import 'mcp_capabilities.dart';
import 'mcp_error.dart';
import 'mcp_tool.dart';

// ══════════════════════════════════════════════════════════
//  Execution mode
// ══════════════════════════════════════════════════════════

/// AQ EXTENSION: execution mode for tools/call.
enum ExecutionMode {
  sync('sync'),
  async('async');

  const ExecutionMode(this.value);
  final String value;

  static ExecutionMode fromString(String s) =>
      s == 'async' ? ExecutionMode.async : ExecutionMode.sync;
}

// ══════════════════════════════════════════════════════════
//  Content blocks
// ══════════════════════════════════════════════════════════

/// A single content block in a tools/call response.
sealed class McpContentBlock {
  const McpContentBlock();

  factory McpContentBlock.fromJson(Map<String, dynamic> json) {
    return switch (json['type'] as String) {
      'text' => McpTextContent(text: json['text'] as String),
      'image' => McpImageContent(
        data: json['data'] as String,
        mimeType: json['mimeType'] as String,
      ),
      final t => throw FormatException('Unknown content type: $t'),
    };
  }

  Map<String, dynamic> toJson();
}

final class McpTextContent extends McpContentBlock {
  const McpTextContent({required this.text});
  final String text;

  @override
  Map<String, dynamic> toJson() => {'type': 'text', 'text': text};
}

final class McpImageContent extends McpContentBlock {
  const McpImageContent({required this.data, required this.mimeType});
  final String data; // base64
  final String mimeType;

  @override
  Map<String, dynamic> toJson() => {
    'type': 'image',
    'data': data,
    'mimeType': mimeType,
  };
}

// ══════════════════════════════════════════════════════════
//  Requests
// ══════════════════════════════════════════════════════════

/// Generic MCP JSON-RPC request.
sealed class McpRequest {
  const McpRequest({required this.id});

  final Object? id; // String | int | null

  /// Parses raw JSON map into the appropriate [McpRequest] subtype.
  factory McpRequest.fromJson(Map<String, dynamic> json) {
    final method = json['method'] as String?;
    final id = json['id'];
    final params = json['params'] as Map<String, dynamic>? ?? {};

    return switch (method) {
      'initialize' => McpInitializeRequest.fromJson(id, params),
      'tools/list' => McpToolsListRequest(id: id),
      'tools/call' => McpToolsCallRequest.fromJson(id, params),
      _ => McpUnknownRequest(id: id, method: method ?? ''),
    };
  }

  String get method;
}

final class McpInitializeRequest extends McpRequest {
  const McpInitializeRequest({
    required super.id,
    this.protocolVersion,
    this.clientInfo,
  });

  factory McpInitializeRequest.fromJson(
    Object? id,
    Map<String, dynamic> params,
  ) {
    final clientRaw = params['clientInfo'] as Map<String, dynamic>?;
    return McpInitializeRequest(
      id: id,
      protocolVersion: params['protocolVersion'] as String?,
      clientInfo: clientRaw != null ? McpClientInfo.fromJson(clientRaw) : null,
    );
  }

  final String? protocolVersion;
  final McpClientInfo? clientInfo;

  @override
  String get method => 'initialize';
}

final class McpToolsListRequest extends McpRequest {
  const McpToolsListRequest({required super.id});

  @override
  String get method => 'tools/list';
}

final class McpToolsCallRequest extends McpRequest {
  const McpToolsCallRequest({
    required super.id,
    required this.name,
    required this.arguments,
    this.authPayload,
    this.mode = ExecutionMode.sync,
  });

  factory McpToolsCallRequest.fromJson(
    Object? id,
    Map<String, dynamic> params,
  ) {
    final authRaw = params['_aq_auth'] as Map<String, dynamic>?;
    final modeStr = params['_aq_mode'] as String?;
    return McpToolsCallRequest(
      id: id,
      name: params['name'] as String,
      arguments: params['arguments'] as Map<String, dynamic>? ?? {},
      authPayload: authRaw != null ? AuthTokenPayload.fromJson(authRaw) : null,
      mode: modeStr != null
          ? ExecutionMode.fromString(modeStr)
          : ExecutionMode.sync,
    );
  }

  final String name;
  final Map<String, dynamic> arguments;

  /// AQ EXTENSION: optional auth token.
  final AuthTokenPayload? authPayload;

  /// AQ EXTENSION: execution mode.
  final ExecutionMode mode;

  @override
  String get method => 'tools/call';
}

final class McpUnknownRequest extends McpRequest {
  const McpUnknownRequest({required super.id, required this.method});

  @override
  final String method;
}

// ══════════════════════════════════════════════════════════
//  Responses
// ══════════════════════════════════════════════════════════

/// Generic MCP JSON-RPC response (success or error).
sealed class McpResponse {
  const McpResponse({required this.id});
  final Object? id;

  Map<String, dynamic> toJson();
}

/// Successful JSON-RPC response wrapping a result payload.
final class McpSuccessResponse extends McpResponse {
  const McpSuccessResponse({required super.id, required this.result});

  final Map<String, dynamic> result;

  @override
  Map<String, dynamic> toJson() => {
    'jsonrpc': '2.0',
    'id': id,
    'result': result,
  };
}

/// JSON-RPC error response.
final class McpErrorResponse extends McpResponse {
  const McpErrorResponse({required super.id, required this.error});

  final McpError error;

  @override
  Map<String, dynamic> toJson() => {
    'jsonrpc': '2.0',
    'id': id,
    'error': error.toJson(),
  };
}

// ══════════════════════════════════════════════════════════
//  Typed response builders
// ══════════════════════════════════════════════════════════

/// Builds the result map for an initialize response.
final class McpInitializeResult {
  static Map<String, dynamic> build({
    required String protocolVersion,
    required McpCapabilities capabilities,
    required McpServerInfo serverInfo,
  }) => {
    'protocolVersion': protocolVersion,
    'capabilities': capabilities.toJson(),
    'serverInfo': serverInfo.toJson(),
  };
}

/// Builds the result map for a tools/list response.
final class McpToolsListResult {
  static Map<String, dynamic> build(List<McpTool> tools) => {
    'tools': tools.map((t) => t.toJson()).toList(),
  };
}

/// Builds the result map for a tools/call response.
final class McpToolsCallResult {
  static Map<String, dynamic> build({
    required List<McpContentBlock> content,
    bool isError = false,
  }) => {
    'content': content.map((c) => c.toJson()).toList(),
    if (isError) 'isError': true,
  };

  /// Convenience: single text content block (most common case).
  static Map<String, dynamic> text(String text, {bool isError = false}) =>
      build(
        content: [McpTextContent(text: text)],
        isError: isError,
      );

  /// Convenience: job accepted response for async mode.
  static Map<String, dynamic> jobAccepted(String jobId) =>
      text('Job accepted. job_id=$jobId');
}
```

### Файл: `./lib/mcp/models/mcp_tool.dart` (строк:      117, размер:     3093 байт)

```dart
/// MCP Tool — abstract interface and concrete implementation.
library;

import 'package:aq_schema/auth/models/auth_context.dart';
import 'package:meta/meta.dart';

/// Authorization requirement declaration for a tool.
final class AuthRequirement {
  const AuthRequirement({
    required this.required,
    required this.type,
    this.scopes = const [],
  });

  factory AuthRequirement.fromJson(Map<String, dynamic> json) {
    return AuthRequirement(
      required: (json['required'] as bool?) ?? false,
      type: AuthType.fromString((json['type'] as String?) ?? 'none'),
      scopes:
          (json['scopes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  final bool required;
  final AuthType type;
  final List<String> scopes;

  Map<String, dynamic> toJson() => {
    'required': required,
    'type': type.value,
    if (scopes.isNotEmpty) 'scopes': scopes,
  };

  static const none = AuthRequirement(required: false, type: AuthType.none);
}

/// Abstract contract for an MCP tool definition.
///
/// All packages that expose tools must implement this interface.
/// The interface is defined in aq_schema and is the single source of truth
/// for what a tool looks like to the rest of the ecosystem.
abstract interface class McpTool {
  /// Snake-case tool name. Pattern: ^[a-z][a-z0-9_]*$
  String get name;

  /// Human-readable description shown to LLM clients.
  String get description;

  /// JSON Schema (as Dart map) for input parameters.
  Map<String, dynamic> get inputSchema;

  /// AQ extension: authorization requirement for this tool.
  /// null means no auth requirement declared.
  AuthRequirement? get auth;

  /// Serializes to JSON map suitable for tools/list response.
  Map<String, dynamic> toJson();
}

/// Concrete implementation of [McpTool].
@immutable
final class McpToolImpl implements McpTool {
  const McpToolImpl({
    required this.name,
    required this.description,
    required this.inputSchema,
    this.auth,
  });

  factory McpToolImpl.fromJson(Map<String, dynamic> json) {
    final rawAuth = json['_aq_auth'] as Map<String, dynamic>?;
    return McpToolImpl(
      name: json['name'] as String,
      description: json['description'] as String,
      inputSchema: json['inputSchema'] as Map<String, dynamic>,
      auth: rawAuth != null ? AuthRequirement.fromJson(rawAuth) : null,
    );
  }

  @override
  final String name;

  @override
  final String description;

  @override
  final Map<String, dynamic> inputSchema;

  @override
  final AuthRequirement? auth;

  @override
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
      'description': description,
      'inputSchema': inputSchema,
    };
    if (auth != null) {
      map['_aq_auth'] = auth!.toJson();
    }
    return map;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is McpToolImpl && name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'McpTool(name: $name)';
}
```

### Файл: `./lib/mcp/schemas/initialize_response.json` (строк:       77, размер:     2265 байт)

```json
{
  "$schema": "http://json-schema.org/draft-07/schema",
  "$id": "aq:mcp:initialize_response",
  "title": "MCP Initialize Response",
  "description": "Server capabilities response to initialize handshake",
  "type": "object",
  "required": ["jsonrpc", "id", "result"],
  "properties": {
    "jsonrpc": {
      "type": "string",
      "const": "2.0"
    },
    "id": {
      "oneOf": [
        { "type": "string" },
        { "type": "integer" }
      ]
    },
    "result": {
      "type": "object",
      "required": ["protocolVersion", "capabilities", "serverInfo"],
      "properties": {
        "protocolVersion": {
          "type": "string",
          "description": "MCP protocol version supported by server"
        },
        "capabilities": {
          "type": "object",
          "properties": {
            "tools": {
              "type": "object",
              "properties": {
                "listChanged": { "type": "boolean" }
              }
            },
            "logging": { "type": "object" }
          }
        },
        "serverInfo": {
          "type": "object",
          "required": ["name", "version"],
          "properties": {
            "name": { "type": "string" },
            "version": { "type": "string" }
          }
        },
        "_aq_extensions": {
          "description": "AQ EXTENSION: not part of MCP standard, optional vendor field. Standard clients ignore unknown fields per JSON-RPC spec.",
          "type": "object",
          "properties": {
            "auth": {
              "type": "object",
              "properties": {
                "supported": { "type": "boolean" },
                "methods": {
                  "type": "array",
                  "items": {
                    "type": "string",
                    "enum": ["bearer", "apikey", "oauth2", "none"]
                  }
                }
              }
            },
            "async_jobs": {
              "type": "boolean",
              "description": "Whether server supports async job pattern via get_job_status tool"
            },
            "worker_count": {
              "type": "integer",
              "description": "Currently registered worker count"
            }
          }
        }
      }
    }
  }
}
```

### Файл: `./lib/mcp/schemas/tools_call_response.json` (строк:       64, размер:     1858 байт)

```json
{
  "$schema": "http://json-schema.org/draft-07/schema",
  "$id": "aq:mcp:tools_call_response",
  "title": "MCP Tools Call Response",
  "description": "Response from tool execution — content blocks matching MCP spec",
  "type": "object",
  "required": ["jsonrpc", "result"],
  "properties": {
    "jsonrpc": {
      "type": "string",
      "const": "2.0"
    },
    "id": {
      "oneOf": [
        { "type": "string" },
        { "type": "integer" }
      ]
    },
    "result": {
      "type": "object",
      "required": ["content"],
      "properties": {
        "content": {
          "type": "array",
          "minItems": 1,
          "items": {
            "oneOf": [
              {
                "type": "object",
                "required": ["type", "text"],
                "properties": {
                  "type": { "type": "string", "const": "text" },
                  "text": { "type": "string" }
                },
                "additionalProperties": false
              },
              {
                "type": "object",
                "required": ["type", "data", "mimeType"],
                "properties": {
                  "type": { "type": "string", "const": "image" },
                  "data": {
                    "type": "string",
                    "description": "Base64-encoded image data"
                  },
                  "mimeType": {
                    "type": "string",
                    "examples": ["image/png", "image/jpeg", "image/gif"]
                  }
                },
                "additionalProperties": false
              }
            ]
          }
        },
        "isError": {
          "type": "boolean",
          "default": false,
          "description": "True when content describes an error condition (tool-level error, not protocol error)"
        }
      }
    }
  }
}
```

### Файл: `./lib/mcp/validators/mcp_validator.dart` (строк:      213, размер:     7578 байт)

```dart
/// MCP protocol validator.
///
/// Validates incoming JSON-RPC messages against MCP rules.
/// Does NOT depend on any external JSON Schema library — uses
/// hand-coded rules matching the JSON Schema files in mcp/schemas/.
library;

import '../models/mcp_error.dart';
import '../models/mcp_tool.dart';

/// Result of a validation operation.
final class ValidationResult {
  const ValidationResult._({
    required this.isValid,
    this.errors = const [],
  });

  const ValidationResult.ok() : this._(isValid: true);

  const ValidationResult.fail(List<String> errors)
      : this._(isValid: false, errors: errors);

  factory ValidationResult.single(String error) =>
      ValidationResult.fail([error]);

  final bool isValid;
  final List<String> errors;

  String get firstError => errors.isNotEmpty ? errors.first : '';

  @override
  String toString() =>
      isValid ? 'ValidationResult.ok' : 'ValidationResult.fail($errors)';
}

/// Validates MCP protocol JSON objects.
abstract final class McpValidator {
  // ── JSON-RPC base ──────────────────────────────────────

  /// Validates that a raw map is a well-formed JSON-RPC 2.0 message.
  static ValidationResult validateJsonRpc(Map<String, dynamic> json) {
    final errors = <String>[];

    if (json['jsonrpc'] != '2.0') {
      errors.add('jsonrpc must be "2.0", got: ${json['jsonrpc']}');
    }

    if (!json.containsKey('method') && !json.containsKey('result') && !json.containsKey('error')) {
      errors.add('message must contain method, result, or error');
    }

    return errors.isEmpty
        ? const ValidationResult.ok()
        : ValidationResult.fail(errors);
  }

  // ── initialize ─────────────────────────────────────────

  /// Validates an initialize request map.
  static ValidationResult validateInitializeRequest(Map<String, dynamic> json) {
    final errors = <String>[];
    final base = validateJsonRpc(json);
    if (!base.isValid) errors.addAll(base.errors);

    if (json['method'] != 'initialize') {
      errors.add('method must be "initialize"');
    }

    return errors.isEmpty
        ? const ValidationResult.ok()
        : ValidationResult.fail(errors);
  }

  // ── tools/call ─────────────────────────────────────────

  /// Validates a tools/call request map.
  static ValidationResult validateToolsCallRequest(Map<String, dynamic> json) {
    final errors = <String>[];
    final base = validateJsonRpc(json);
    if (!base.isValid) errors.addAll(base.errors);

    if (json['method'] != 'tools/call') {
      errors.add('method must be "tools/call"');
    }

    final params = json['params'] as Map<String, dynamic>?;
    if (params == null) {
      errors.add('params is required for tools/call');
    } else {
      if (params['name'] == null || params['name'] is! String) {
        errors.add('params.name is required and must be a string');
      }
      if (params['arguments'] != null && params['arguments'] is! Map) {
        errors.add('params.arguments must be an object if provided');
      }
      final mode = params['_aq_mode'] as String?;
      if (mode != null && mode != 'sync' && mode != 'async') {
        errors.add('params._aq_mode must be "sync" or "async"');
      }
    }

    return errors.isEmpty
        ? const ValidationResult.ok()
        : ValidationResult.fail(errors);
  }

  // ── McpTool ────────────────────────────────────────────

  /// Validates a tool definition map matches the mcp_tool.json schema.
  static ValidationResult validateTool(Map<String, dynamic> json) {
    final errors = <String>[];

    final name = json['name'];
    if (name == null || name is! String || name.isEmpty) {
      errors.add('tool.name is required and must be a non-empty string');
    } else if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(name)) {
      errors.add(
          'tool.name must match ^[a-z][a-z0-9_]*\$ (snake_case, got: $name)');
    } else if (name.length > 64) {
      errors.add('tool.name must be at most 64 characters');
    }

    final desc = json['description'];
    if (desc == null || desc is! String || desc.isEmpty) {
      errors.add('tool.description is required and must be a non-empty string');
    } else if (desc.length > 1024) {
      errors.add('tool.description must be at most 1024 characters');
    }

    final schema = json['inputSchema'];
    if (schema == null || schema is! Map) {
      errors.add('tool.inputSchema is required and must be an object');
    } else if (schema['type'] == null) {
      errors.add('tool.inputSchema.type is required');
    }

    return errors.isEmpty
        ? const ValidationResult.ok()
        : ValidationResult.fail(errors);
  }

  /// Validates a [McpToolImpl] instance.
  static ValidationResult validateMcpTool(McpToolImpl tool) =>
      validateTool(tool.toJson());

  // ── error response ─────────────────────────────────────

  /// Validates an error response map.
  static ValidationResult validateErrorResponse(Map<String, dynamic> json) {
    final errors = <String>[];

    final error = json['error'] as Map<String, dynamic>?;
    if (error == null) {
      errors.add('error field is required in error response');
      return ValidationResult.fail(errors);
    }

    if (error['code'] == null || error['code'] is! int) {
      errors.add('error.code is required and must be an integer');
    }

    if (error['message'] == null || error['message'] is! String) {
      errors.add('error.message is required and must be a string');
    }

    return errors.isEmpty
        ? const ValidationResult.ok()
        : ValidationResult.fail(errors);
  }

  // ── tool arguments ─────────────────────────────────────

  /// Validates [arguments] against a tool's [inputSchema].
  ///
  /// Only validates required fields and basic types — a full
  /// JSON Schema validator is in aq_queue / aq_worker.
  static ValidationResult validateToolArguments({
    required Map<String, dynamic> inputSchema,
    required Map<String, dynamic> arguments,
    required String toolName,
  }) {
    final errors = <String>[];

    final required =
        (inputSchema['required'] as List<dynamic>?)?.cast<String>() ?? [];

    for (final field in required) {
      if (!arguments.containsKey(field) || arguments[field] == null) {
        errors.add('$toolName: required argument "$field" is missing');
      }
    }

    return errors.isEmpty
        ? const ValidationResult.ok()
        : ValidationResult.fail(errors);
  }

  // ── MCP error codes ────────────────────────────────────

  /// Validates error code is a known MCP / JSON-RPC code.
  static bool isKnownErrorCode(int code) => const {
        McpErrorCode.parseError,
        McpErrorCode.invalidRequest,
        McpErrorCode.methodNotFound,
        McpErrorCode.invalidParams,
        McpErrorCode.internalError,
        McpErrorCode.workerExecutionFailed,
        McpErrorCode.workerTimeout,
        McpErrorCode.workerNotAvailable,
        McpErrorCode.authRequired,
        McpErrorCode.authInvalid,
      }.contains(code);
}
```

### Файл: `./lib/queue/in_memory_job_queue.dart` (строк:      294, размер:     8910 байт)

```dart
/// In-memory implementation of [JobQueue] for testing.
///
/// Use this in unit tests and fast CI pipelines where Redis is not available.
/// The behavior is identical to [RedisJobQueue] (same contract),
/// except all state lives in-memory and is lost when the object is disposed.
///
/// This class is intentionally in aq_schema (not aq_queue) so that:
///   - Workers can test their logic without depending on aq_queue
///   - Consumers can test their logic without depending on aq_queue
///   - Contract tests in aq_queue run the same tests against both impls
library;

import 'dart:async';
import 'dart:collection';

import 'package:aq_schema/queue/job_queue.dart';
import 'package:aq_schema/queue/models/queue_job_status.dart';
import 'package:aq_schema/queue/roles/job_consumer.dart';
import 'package:aq_schema/queue/roles/job_worker_client.dart';
import 'package:aq_schema/worker/models/worker_models.dart';
import 'package:aq_schema/mcp/models/mcp_tool.dart';

/// In-memory [JobQueue] implementation.
///
/// Thread-safe for single-isolate use (Dart's event loop guarantees).
/// NOT suitable for production — state is ephemeral.
///
/// Implements all three interfaces:
///   [JobConsumer] — consumer role
///   [JobWorkerClient] — worker role
///   [JobQueue] — full orchestrator interface
final class InMemoryJobQueue implements JobQueue, JobConsumer, JobWorkerClient {
  InMemoryJobQueue();

  // ── Internal state ─────────────────────────────────────

  // queue key → FIFO list of serialized jobs
  final _queues = <String, Queue<WorkerJobImpl>>{};

  // waiters blocked on BRPOP: queue key → list of completers
  final _waiters = <String, List<Completer<WorkerJobImpl?>>>{};

  // job_id → status
  final _statuses = <String, QueueJobStatus>{};

  // job_id → result
  final _results = <String, WorkerResultImpl>{};

  bool _closed = false;

  static const _globalKey = 'aq:queue:jobs';

  String _workerKey(String workerId) => 'aq:queue:jobs:$workerId';

  // ── JobConsumer / JobQueue ─────────────────────────────

  @override
  Future<String> enqueue(WorkerJobImpl job, {String? workerId}) async {
    _assertOpen();
    final key = workerId != null ? _workerKey(workerId) : _globalKey;

    final status = QueueJobStatus(
      jobId: job.jobId,
      status: JobStatus.pending,
      createdAt: job.createdAt,
    );
    _statuses[job.jobId] = status;

    // Wake up a waiter if any
    final waiters = _waiters[key] ?? [];
    if (waiters.isNotEmpty) {
      final completer = waiters.removeAt(0);
      if (waiters.isEmpty) _waiters.remove(key);
      completer.complete(job);
    } else {
      (_queues[key] ??= Queue()).addLast(job);
    }

    return job.jobId;
  }

  @override
  Future<WorkerResultImpl?> getResult(String jobId) async {
    return _results[jobId];
  }

  @override
  Future<QueueJobStatus> getStatus(String jobId) async {
    return _statuses[jobId] ??
        QueueJobStatus(jobId: jobId, status: JobStatus.pending);
  }

  // ── JobWorkerClient / JobQueue ─────────────────────────

  @override
  Future<WorkerJobImpl?> dequeue({
    String? workerId,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    _assertOpen();
    final key = workerId != null ? _workerKey(workerId) : _globalKey;

    // Check queue first (non-blocking fast path)
    final queue = _queues[key];
    if (queue != null && queue.isNotEmpty) {
      return queue.removeFirst();
    }

    // Block: register waiter and wait
    final completer = Completer<WorkerJobImpl?>();
    (_waiters[key] ??= []).add(completer);

    // Timeout cancels the waiter
    final timer = Timer(timeout, () {
      final list = _waiters[key];
      if (list != null) {
        list.remove(completer);
        if (list.isEmpty) _waiters.remove(key);
      }
      if (!completer.isCompleted) completer.complete(null);
    });

    final result = await completer.future;
    timer.cancel();
    return result;
  }

  @override
  Future<void> setResult(String jobId, WorkerResultImpl result) async {
    _results[jobId] = result;

    final current = _statuses[jobId];
    _statuses[jobId] = QueueJobStatus(
      jobId: jobId,
      status: result.status,
      workerId: current?.workerId,
      workerResult: result,
      createdAt: current?.createdAt,
      startedAt: current?.startedAt,
      completedAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    );
  }

  @override
  Future<void> setStatus(
    String jobId,
    JobStatus status, {
    String? workerId,
  }) async {
    final current = _statuses[jobId];
    _statuses[jobId] = QueueJobStatus(
      jobId: jobId,
      status: status,
      workerId: workerId ?? current?.workerId,
      workerResult: current?.workerResult,
      createdAt: current?.createdAt,
      startedAt: status == JobStatus.running
          ? DateTime.now().millisecondsSinceEpoch ~/ 1000
          : current?.startedAt,
      completedAt: status.isTerminal
          ? DateTime.now().millisecondsSinceEpoch ~/ 1000
          : current?.completedAt,
    );
  }

  // ── JobQueue full interface ────────────────────────────

  @override
  Future<void> close() async {
    _closed = true;
    // Cancel all waiting dequeue calls
    for (final waiters in _waiters.values) {
      for (final c in waiters) {
        if (!c.isCompleted) c.complete(null);
      }
    }
    _waiters.clear();
  }

  // ── Helpers ───────────────────────────────────────────

  void _assertOpen() {
    if (_closed) throw StateError('InMemoryJobQueue is closed');
  }

  /// Returns count of pending jobs in global queue (for assertions in tests).
  int get pendingCount => (_queues[_globalKey] ?? Queue()).length;

  /// Returns count of pending jobs for a specific worker queue.
  int workerQueueCount(String workerId) =>
      (_queues[_workerKey(workerId)] ?? Queue()).length;
}

/// In-memory [WorkerRegistry] for testing.
final class InMemoryWorkerRegistry implements WorkerRegistry {
  final _workers = <String, WorkerRegistration>{};
  final _health = <String, WorkerHealth>{};
  final _missCounts = <String, int>{};

  Timer? _evictionTimer;
  bool _closed = false;

  @override
  Future<void> register(WorkerRegistration registration) async {
    _workers[registration.workerId] = registration;
    _missCounts[registration.workerId] = 0;
  }

  @override
  Future<void> updateHealth(WorkerHealth health) async {
    _health[health.workerId] = health;
    _missCounts[health.workerId] = 0;
  }

  @override
  List<WorkerRegistration> get activeWorkers =>
      List.unmodifiable(_workers.values);

  @override
  WorkerRegistration? findWorker(String toolName) {
    final candidates = _workers.values
        .where((w) => w.tools.any((t) => t.name == toolName))
        .toList();
    if (candidates.isEmpty) return null;
    // Round-robin by rotating list
    final first = candidates.first;
    _workers.remove(first.workerId);
    _workers[first.workerId] = first;
    return first;
  }

  @override
  Future<void> evict(String workerId) async {
    _workers.remove(workerId);
    _health.remove(workerId);
    _missCounts.remove(workerId);
  }

  @override
  List<McpToolImpl> get allTools {
    final seen = <String>{};
    final tools = <McpToolImpl>[];
    for (final w in _workers.values) {
      for (final t in w.tools) {
        if (seen.add(t.name)) tools.add(t);
      }
    }
    return tools;
  }

  @override
  void startEvictionLoop({
    Duration checkInterval = const Duration(seconds: 30),
    int missedChecksBeforeEvict = 3,
  }) {
    _evictionTimer = Timer.periodic(checkInterval, (_) async {
      final toEvict = <String>[];
      for (final workerId in _workers.keys) {
        final lastHealth = _health[workerId];
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final missed =
            lastHealth == null ||
            (now - lastHealth.timestamp) > checkInterval.inSeconds;

        if (missed) {
          _missCounts[workerId] = (_missCounts[workerId] ?? 0) + 1;
          if ((_missCounts[workerId] ?? 0) >= missedChecksBeforeEvict) {
            toEvict.add(workerId);
          }
        } else {
          _missCounts[workerId] = 0;
        }
      }
      for (final id in toEvict) {
        await evict(id);
      }
    });
  }

  @override
  void stopEvictionLoop() {
    _evictionTimer?.cancel();
    _evictionTimer = null;
  }

  @override
  Future<void> close() async {
    stopEvictionLoop();
    _closed = true;
  }

  /// For test assertions.
  bool isRegistered(String workerId) => _workers.containsKey(workerId);
}
```

### Файл: `./lib/queue/job_queue.dart` (строк:       90, размер:     3312 байт)

```dart
/// Abstract queue and registry interfaces — implemented by aq_queue package.
///
/// Defined here in aq_schema so any package can depend on the interface
/// without depending on Redis or any specific broker implementation.
library;

import 'package:aq_schema/mcp/models/mcp_tool.dart';
import 'package:aq_schema/worker/models/worker_models.dart';

import 'models/queue_job_status.dart';

/// Redis key naming convention (for documentation reference).
///
/// aq:queue:jobs               — LIST  (global queue, LPUSH/BRPOP)
/// aq:queue:jobs:{worker_id}   — LIST  (per-worker queue, LPUSH/BRPOP)
/// aq:result:{job_id}          — STRING JSON, TTL 1h
/// aq:status:{job_id}          — STRING JSON, TTL 24h
/// aq:worker:registry          — HASH  {worker_id → JSON registration}
/// aq:worker:health:{worker_id}— STRING JSON, TTL 90s

/// Abstract interface for the Redis job queue.
///
/// The adapter uses this to enqueue jobs and await results.
/// Workers use this to dequeue jobs and write results.
abstract interface class JobQueue {
  /// Enqueues a job and returns its job_id.
  Future<String> enqueue(WorkerJobImpl job, {String? workerId});

  /// Blocks until a job is available in the queue.
  /// Returns null on timeout.
  Future<WorkerJobImpl?> dequeue({
    String? workerId,
    Duration timeout = const Duration(seconds: 5),
  });

  /// Stores the final result for a job.
  /// Sets TTL of 1 hour.
  Future<void> setResult(String jobId, WorkerResultImpl result);

  /// Retrieves the final result for a job.
  /// Returns null if result not yet available or TTL expired.
  Future<WorkerResultImpl?> getResult(String jobId);

  /// Gets the current status of a job (including result if done).
  Future<QueueJobStatus> getStatus(String jobId);

  /// Updates job status (pending → running, etc.).
  Future<void> setStatus(String jobId, JobStatus status, {String? workerId});

  /// Closes queue connections. Call on shutdown.
  Future<void> close();
}

/// Abstract interface for the worker registry.
///
/// The adapter uses this to register workers, aggregate their tools,
/// and evict unhealthy workers.
abstract interface class WorkerRegistry {
  /// Registers a worker. Overwrites if same worker_id exists.
  Future<void> register(WorkerRegistration registration);

  /// Updates health status for a worker. Resets TTL.
  Future<void> updateHealth(WorkerHealth health);

  /// Returns all currently active (healthy or degraded) worker registrations.
  List<WorkerRegistration> get activeWorkers;

  /// Finds any worker that can handle [toolName].
  /// Returns null if no worker is available for that tool.
  WorkerRegistration? findWorker(String toolName);

  /// Removes a worker from the registry (e.g. after missed health checks).
  Future<void> evict(String workerId);

  /// Returns all tools aggregated from all active workers.
  List<McpToolImpl> get allTools;

  /// Starts the health-check eviction loop.
  /// Workers that miss [missedChecksBeforeEvict] consecutive checks are evicted.
  void startEvictionLoop({
    Duration checkInterval = const Duration(seconds: 30),
    int missedChecksBeforeEvict = 3,
  });

  /// Stops the eviction loop cleanly.
  void stopEvictionLoop();

  /// Closes registry connections. Call on shutdown.
  Future<void> close();
}
```

### Файл: `./lib/queue/models/queue_job_status.dart` (строк:       54, размер:     1716 байт)

```dart
/// Queue domain model — job status tracking.
library;

import 'package:aq_schema/worker/models/worker_models.dart';

/// Current status of a job in the queue.
/// Used for polling via the get_job_status tool (AQ extension).
final class QueueJobStatus {
  const QueueJobStatus({
    required this.jobId,
    required this.status,
    this.workerId,
    this.workerResult,
    this.createdAt,
    this.startedAt,
    this.completedAt,
  });

  factory QueueJobStatus.fromJson(Map<String, dynamic> json) {
    final resultRaw = json['result'] as Map<String, dynamic>?;
    return QueueJobStatus(
      jobId: json['job_id'] as String,
      status: JobStatus.fromString(json['status'] as String),
      workerId: json['worker_id'] as String?,
      workerResult: resultRaw != null
          ? WorkerResultImpl.fromJson(resultRaw)
          : null,
      createdAt: json['created_at'] as int?,
      startedAt: json['started_at'] as int?,
      completedAt: json['completed_at'] as int?,
    );
  }

  final String jobId;
  final JobStatus status;
  final String? workerId;
  final WorkerResultImpl? workerResult;
  final int? createdAt;
  final int? startedAt;
  final int? completedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'job_id': jobId, 'status': status.value};
    if (workerId != null) map['worker_id'] = workerId;
    if (workerResult != null) map['result'] = workerResult!.toJson();
    if (createdAt != null) map['created_at'] = createdAt;
    if (startedAt != null) map['started_at'] = startedAt;
    if (completedAt != null) map['completed_at'] = completedAt;
    return map;
  }

  @override
  String toString() => 'QueueJobStatus(id: $jobId, status: ${status.value})';
}
```

### Файл: `./lib/queue/roles/job_consumer.dart` (строк:       57, размер:     2050 байт)

```dart
/// Role contract: Job Consumer (client side).
///
/// A Consumer submits jobs and polls for results.
/// It does NOT dequeue, execute, or manage workers.
///
/// Role separation principle:
///   Consumer  ← enqueue / getResult / getStatus
///   Worker    ← dequeue / setResult / setStatus
///   Registry  ← register / health / evict
///   Adapter   ← all of the above (orchestrator)
///
/// Consumers and Workers NEVER know about each other.
/// They only know the shared contract defined in aq_schema.
library;

import 'package:aq_schema/queue/models/queue_job_status.dart';
import 'package:aq_schema/worker/models/worker_models.dart';

/// The Consumer role interface.
///
/// Implemented by [JobQueue] in aq_queue.
/// Any client that wants to submit jobs should depend only on this interface,
/// not on [JobQueue] which exposes orchestrator-level methods.
///
/// Example usage:
/// ```dart
/// final consumer = RedisJobQueue.connect(...) as JobConsumer;
/// final jobId = await consumer.enqueue(job);
/// final status = await consumer.getStatus(jobId);
/// if (status.status == JobStatus.done) {
///   final result = await consumer.getResult(jobId);
/// }
/// ```
abstract interface class JobConsumer {
  /// Submits a job to the queue.
  ///
  /// If [workerId] is specified, routes the job to that worker's
  /// dedicated queue. Otherwise goes to the global queue.
  ///
  /// Returns the [WorkerJobImpl.jobId] for polling.
  Future<String> enqueue(WorkerJobImpl job, {String? workerId});

  /// Retrieves the final result for a completed job.
  ///
  /// Returns null if the job is not yet done or TTL has expired.
  /// TTL on results is 1 hour.
  ///
  /// Poll [getStatus] first to avoid repeated null returns.
  Future<WorkerResultImpl?> getResult(String jobId);

  /// Returns the current status of a job.
  ///
  /// Includes result when status is [JobStatus.done],
  /// and error when status is [JobStatus.failed] or [JobStatus.timeout].
  /// TTL on status is 24 hours.
  Future<QueueJobStatus> getStatus(String jobId);
}
```

### Файл: `./lib/queue/roles/job_worker_client.dart` (строк:      108, размер:     4162 байт)

```dart
/// Role contract: Job Worker Client (worker side).
///
/// A Worker dequeues jobs, executes them, and writes results.
/// It does NOT submit jobs or query results.
///
/// Workers are stateless by design:
///   1. Dequeue a job
///   2. Update status → running
///   3. Execute (business logic, defined by the worker implementation)
///   4. Write result → done / failed / timeout
///
/// Workers must also register themselves and report health via [WorkerRegistry].
/// These two interfaces together define the full worker contract.
///
/// Workers MUST follow these invariants (enforced by WorkerValidator):
///   - Report health every ≤ 30 seconds
///   - Set result for every dequeued job (including failures)
///   - Respect meta.timeout_ms
///   - Be idempotent (retrying the same job_id is safe)
library;

import 'package:aq_schema/worker/models/worker_models.dart';

/// The Worker role interface for queue interaction.
///
/// Workers implement their business logic and call these methods.
/// The [dequeue] call blocks until a job is available.
///
/// Usage contract enforced in worker_validator.dart:
///   - Every dequeued job MUST have setResult called eventually.
///   - Status MUST transition: pending → running → (done|failed|timeout)
///   - Timeout MUST be respected: honor [JobMeta.timeout].
///
/// Example:
/// ```dart
/// final client = RedisJobQueue.connect(...) as JobWorkerClient;
/// while (running) {
///   final job = await client.dequeue(workerId: myId, timeout: 5.seconds);
///   if (job == null) continue; // timeout, loop
///   try {
///     final result = await myBusinessLogic(job);
///     await client.setResult(job.jobId, WorkerResultImpl.success(...));
///   } catch (e) {
///     await client.setResult(job.jobId, WorkerResultImpl.failure(...));
///   }
/// }
/// ```
abstract interface class JobWorkerClient {
  /// Blocks until a job is available or [timeout] expires.
  ///
  /// Returns null on timeout — this is NORMAL, not an error.
  /// Workers should loop and call dequeue again.
  ///
  /// [workerId] — listen on dedicated worker queue.
  ///   If null, listens on the global queue (round-robin across workers).
  ///
  /// Contract invariant: caller MUST call [setResult] for every
  /// non-null return value, even on failure.
  Future<WorkerJobImpl?> dequeue({
    String? workerId,
    Duration timeout = const Duration(seconds: 5),
  });

  /// Writes the final result to the result store.
  ///
  /// Must be called for EVERY dequeued job without exception.
  /// Failure to call this causes jobs to appear "stuck" to consumers.
  ///
  /// Automatically updates status to the result's [WorkerResultImpl.status].
  Future<void> setResult(String jobId, WorkerResultImpl result);

  /// Updates the intermediate job status.
  ///
  /// Workers MUST call this with [JobStatus.running] immediately after
  /// successfully dequeuing a job, so consumers can observe progress.
  ///
  /// [workerId] is stored in the status for observability.
  Future<void> setStatus(
    String jobId,
    JobStatus status, {
    String? workerId,
  });
}

/// Contract for worker registration and health reporting.
///
/// Separate from [JobWorkerClient] because in some architectures
/// the adapter manages registration on behalf of the worker.
///
/// Workers MUST implement both [JobWorkerClient] and this interface.
abstract interface class WorkerLifecycle {
  /// Called once on worker startup to register capabilities.
  ///
  /// Must be called before [JobWorkerClient.dequeue].
  /// Re-registration with the same [WorkerRegistration.workerId] is
  /// idempotent — overwrites the previous registration.
  Future<void> register(WorkerRegistration registration);

  /// Called periodically (every ≤ 30 seconds) to signal liveness.
  ///
  /// If health is not reported for [evictionThreshold] intervals,
  /// the orchestrator will evict this worker from the registry,
  /// meaning new jobs will no longer be routed to it.
  ///
  /// Workers SHOULD report [WorkerStatus.unhealthy] before intentional
  /// shutdown to allow graceful eviction.
  Future<void> reportHealth(WorkerHealth health);
}
```

### Файл: `./lib/sandbox/interfaces/i_sandbox_actor.dart` (строк:       26, размер:     1205 байт)

```dart
// pkgs/aq_schema/lib/sandbox/interfaces/i_sandbox_actor.dart
//
// РОЛЬ: Исполнитель внутри sandbox.
//
// WorkflowRunner, InstructionRunner, PromptRunner — все акторы.
// Актор получает ISandboxContext от sandbox и производит работу.
//
// Аналогия: если ISandboxContext — это рабочий стол,
// то ISandboxActor — это человек за этим столом.
// Он работает с материалами на столе, следует политике и
// записывает что делает в лог.
//
// Почему "Actor" а не "Runner":
//   "Runner" — техническое слово, привязанное к реализации.
//   "Actor" — роль в системе. Runner реализует Actor, а не наоборот.

import 'i_sandbox_context.dart';

abstract interface class ISandboxActor {
  /// Контекст выполнения этого актора.
  /// Предоставляется sandbox при создании актора.
  ISandboxContext get context;

  /// Запустить работу актора.
  Future<void> run();
}
```

### Файл: `./lib/sandbox/interfaces/i_sandbox_as_chat.dart` (строк:       54, размер:     2541 байт)

```dart
// pkgs/aq_schema/lib/sandbox/interfaces/i_sandbox_as_chat.dart
//
// РОЛЬ: Изолированная среда для диалоговых взаимодействий.
//
// БИЗНЕС-СМЫСЛ: AI Builder, Co-Creation, Chat — это "разговор":
// есть история сообщений, системный контекст (кто ты, что умеешь),
// прикреплённые данные (файлы, артефакты), и непрерывный обмен
// запрос-ответ. История накапливается и влияет на следующие ответы.
//
// ПРИМЕРЫ В ПРОЕКТЕ:
//   BuilderSessionSandbox  — сессия AI Builder (ИИ строит проект)
//   CoCreationSandbox      — совместное создание с агентом
//   ChatSandbox            — обычный чат
//
// КЛЮЧЕВЫЕ СВОЙСТВА:
//   - history: иммутабельная история (List<ISandboxChatMessage>)
//   - context: системный промпт и настройки (ISandboxItem)
//   - attachments: прикреплённые файлы (List<ISandboxAttachment>)
//   - send(): отправить сообщение, получить ответ
//
// В ОТЛИЧИЕ ОТ PROCESS:
//   - Нет фиксированного "результата" — разговор продолжается
//   - Состояние = история. Она только растёт, не меняется
//   - Паттерн: запрос → ответ (не событийный цикл)

import 'i_sandbox.dart';
import 'i_sandbox_item.dart';

abstract interface class ISandboxAsChat implements ISandbox {
  List<ISandboxChatMessage> get history;
  ISandboxItem get context;
  List<ISandboxAttachment> get attachments;

  Future<ISandboxChatMessage> send(ISandboxChatMessage message);
  Future<void> attach(ISandboxAttachment attachment);
  Future<void> clearHistory();

  int get estimatedTokenCount;
}

// ── Chat sub-items ─────────────────────────────────────────────────────────

abstract interface class ISandboxChatMessage implements ISandboxItem {
  /// 'user'|'assistant'|'system'|'tool'
  String get role;
  String get content;
  int get timestamp;
}

abstract interface class ISandboxAttachment implements ISandboxItem {
  String get mimeType;
  String get name;
  int get sizeBytes;
}
```

### Файл: `./lib/sandbox/interfaces/i_sandbox_as_environment.dart` (строк:       51, размер:     2522 байт)

```dart
// pkgs/aq_schema/lib/sandbox/interfaces/i_sandbox_as_environment.dart
//
// РОЛЬ: Изолированная среда как контейнер других сред.
//
// БИЗНЕС-СМЫСЛ: Project — это "среда разработки":
// внутри него запускаются workflows, работает Builder, выполняются
// тесты. Каждый из них — дочерний sandbox. Проект задаёт
// общую политику ("в этом проекте нельзя делать HTTP-запросы")
// и все дочерние получают не больше прав чем родитель.
//
// ПРИМЕРЫ В ПРОЕКТЕ:
//   ProjectSandbox           — проект как контейнер всего
//   DockerEnvironmentSandbox — Docker контейнер (L2+)
//   RemoteEnvironmentSandbox — удалённая машина пользователя
//
// КЛЮЧЕВЫЕ СВОЙСТВА:
//   - children: активные дочерние sandbox-ы
//   - spawnChild(): породить дочерний, НЕ превышающий политику родителя
//   - effectivePolicy: собственная политика ∩ политика родителей
//   - origin: 'managed'|'user'|'remote'
//
// ПРАВИЛО: ISandboxAsFunction, Process, Chat — ЛИСТОВЫЕ.
// Только ISandboxAsEnvironment может содержать другие sandbox-ы.
// Это предотвращает бесконечную вложенность и архитектурный тупик.

import 'i_sandbox.dart';
import '../policy/sandbox_policy.dart';

abstract interface class ISandboxAsEnvironment implements ISandbox {
  List<ISandbox> get children;

  /// Создать дочерний sandbox.
  /// narrowPolicy — сужение родительской политики.
  /// Если narrowPolicy шире родительской → пересечение (дочерний не получит больше).
  T spawnChild<T extends ISandbox>(ISandboxFactory<T> factory);

  ISandbox? getChild(String sandboxId);

  /// Собственная policy ∩ политики всех родителей в цепочке
  SandboxPolicy get effectivePolicy;

  /// 'managed'|'user'|'remote'
  String get origin;
}

abstract interface class ISandboxFactory<T extends ISandbox> {
  T create({
    required ISandboxAsEnvironment parent,
    required SandboxPolicy narrowPolicy,
  });
}
```

### Файл: `./lib/sandbox/interfaces/i_sandbox_as_function.dart` (строк:       33, размер:     1640 байт)

```dart
// pkgs/aq_schema/lib/sandbox/interfaces/i_sandbox_as_function.dart
//
// РОЛЬ: Изолированная среда для атомарных операций.
//
// БИЗНЕС-СМЫСЛ: Instruction или Prompt — это "функция":
// получает набор входных данных, обрабатывает в изоляции, отдаёт результат.
// Нет долгоживущего состояния. Нет внешних событий по ходу работы.
// Один вход — один выход. Так работает большинство инструкций агента.
//
// ПРИМЕРЫ В ПРОЕКТЕ:
//   InstructionRunSandbox — выполнение одной инструкции
//   PromptRunSandbox      — рендеринг одного промпта
//   TestLabSandbox        — изолированный тест инструкции
//
// КЛЮЧЕВЫЕ СВОЙСТВА:
//   - inputSchema: какие данные принимает (ISandboxSchema для валидации)
//   - outputSchema: какой результат гарантирует
//   - call(input): выполнить, получить результат
//   - Повторный вызов безопасен (нет persistent state)

import 'i_sandbox.dart';
import 'i_sandbox_item.dart';
import 'i_sandbox_schema.dart';

abstract interface class ISandboxAsFunction implements ISandbox {
  ISandboxSchema get inputSchema;
  ISandboxSchema get outputSchema;

  Future<ISandboxItem> call(ISandboxItem input);

  int? get lastCalledAt;
  int? get lastCompletedAt;
}
```

### Файл: `./lib/sandbox/interfaces/i_sandbox_as_process.dart` (строк:       54, размер:     2409 байт)

```dart
// pkgs/aq_schema/lib/sandbox/interfaces/i_sandbox_as_process.dart
//
// РОЛЬ: Изолированная среда для долгоживущих процессов.
//
// БИЗНЕС-СМЫСЛ: Workflow — это "процесс":
// он запускается, живёт долго, проходит через множество узлов,
// накапливает состояние, может быть приостановлен и возобновлён,
// реагирует на внешние события (cancel, pause) и генерирует события
// (step_completed, waiting_for_input). В конце — итоговый результат.
//
// ПРИМЕРЫ В ПРОЕКТЕ:
//   WorkflowRunSandbox  — полный запуск workflow
//   AgentTaskSandbox    — долгоживущая задача агента
//
// КЛЮЧЕВЫЕ СВОЙСТВА:
//   - status: жизненный цикл ('preparing'|'active'|'suspended'|'completed'|'failed')
//   - currentState: текущее состояние (ISandboxItem — типизированный снапшот)
//   - send(event): принять внешнее событие (pause, cancel, inject data)
//   - result: итог (null пока не завершён)
//
// В ОТЛИЧИЕ ОТ FUNCTION:
//   - Живёт долго (минуты, часы)
//   - Имеет observable состояние по ходу работы
//   - Может быть приостановлен и возобновлён
//   - Двусторонний обмен событиями

import 'i_sandbox.dart';
import 'i_sandbox_item.dart';
import 'i_sandbox_event.dart';

abstract interface class ISandboxAsProcess implements ISandbox {
  ISandboxItem get initialState;
  ISandboxItem get currentState;

  /// 'preparing'|'active'|'suspended'|'completed'|'failed'|'disposed'
  String get status;

  Future<void> send(ISandboxEvent event);

  ISandboxItem? get result;
  int? get completedAt;
}

abstract final class SandboxProcessStatus {
  static const String preparing = 'preparing';
  static const String active = 'active';
  static const String suspended = 'suspended';
  static const String completed = 'completed';
  static const String failed = 'failed';
  static const String disposed = 'disposed';

  static bool isTerminal(String s) =>
      s == completed || s == failed || s == disposed;
}
```

### Файл: `./lib/sandbox/interfaces/i_sandbox_capable.dart` (строк:       28, размер:     1535 байт)

```dart
// pkgs/aq_schema/lib/sandbox/interfaces/i_sandbox_capable.dart
//
// РОЛЬ: Объявление требований Hand к активной политике.
//
// БИЗНЕС-СМЫСЛ: Каждый Hand знает что ему нужно для работы.
// FsWriteHand не может работать если файловая система закрыта.
// LlmHand не может работать если LLM-вызовы запрещены.
//
// Вместо того чтобы хранить списки флагов (needsFsWrite, needsLlm, ...),
// Hand объявляет ОДИН ключ. InstructionRunner проверяет этот ключ
// в activePolicy перед вызовом execute().
//
// КАК ЭТО РАБОТАЕТ:
//   1. Hand реализует ISandboxCapable и возвращает свой ключ
//   2. InstructionRunner: if (hand is ISandboxCapable)
//   3. policy.permits(hand.requiredCapability) → true/false
//   4. false → emit SandboxPolicyViolationEvent, пропустить шаг
//
// РАСШИРЯЕМОСТЬ:
//   Новая capability = новая константа в SandboxCapabilities +
//   implements ISandboxCapable в нужном Hand.
//   Никаких изменений в SandboxPolicy или ISandboxCapable.

abstract interface class ISandboxCapable {
  /// Ключ capability которую требует этот Hand.
  /// Значения — константы из SandboxCapabilities.
  String get requiredCapability;
}
```

### Файл: `./lib/sandbox/interfaces/i_sandbox_context.dart` (строк:       72, размер:     3698 байт)

```dart
// pkgs/aq_schema/lib/sandbox/interfaces/i_sandbox_context.dart
//
// РОЛЬ: Среда выполнения актора внутри sandbox.
//
// RunContext — это ISandboxContext.
// Он хранит: переменные состояния (state), логи, ветку выполнения,
// ссылку на sandbox-границу и активную политику.
//
// Аналогия: если ISandbox — это комната (граница),
// то ISandboxContext — это рабочий стол внутри неё:
// на нём лежат все инструменты и материалы текущей работы.

import 'i_sandbox.dart';
import '../policy/sandbox_policy.dart';

abstract interface class ISandboxContext {
  // ── Привязка к sandbox ──────────────────────────────────────────────

  /// Sandbox в котором выполняется этот контекст.
  /// Через него — политика, события, иерархия.
  ISandbox get sandbox;

  /// Активная политика. Если sandbox.is ISandboxAsEnvironment →
  /// берёт effectivePolicy (пересечение с родителем).
  /// Иначе → sandbox.policy напрямую.
  SandboxPolicy get activePolicy;

  // ── Состояние выполнения ────────────────────────────────────────────

  /// Переменные текущего выполнения (runtime state).
  /// Заполняется по ходу выполнения шагов агента.
  /// Ключи — имена переменных, значения — любые Dart-объекты.
  Map<String, dynamic> get state;

  /// Читать переменную по имени. Поддерживает dot-notation: 'result.field'.
  dynamic getVar(String name);

  /// Записать переменную.
  void setVar(String key, dynamic value);

  // ── Идентификация ────────────────────────────────────────────────────

  /// ID этого запуска (runId). Совпадает с sandboxId sandbox-а.
  String get runId;

  /// ID проекта в котором выполняется этот контекст.
  String get projectId;

  /// Путь к файлам проекта на диске.
  String get projectPath;

  // ── Ветвление ────────────────────────────────────────────────────────

  /// Текущая ветка выполнения (по умолчанию 'main').
  /// Используется при параллельных ветках workflow.
  String get currentBranch;

  /// Создать клон контекста для новой ветки.
  /// Состояние копируется, sandbox и политика — те же.
  ISandboxContext cloneForBranch(String branchName);

  // ── Логирование ──────────────────────────────────────────────────────

  /// Записать событие в лог. Форвардится в sandbox.events.
  void log(
    String message, {
    required String type,
    required int depth,
    required String branch,
    String? details,
  });
}
```

### Файл: `./lib/sandbox/interfaces/i_sandbox_event.dart` (строк:       25, размер:      902 байт)

```dart
import 'i_sandbox_item.dart';

/// Событие в потоке sandbox.events.
///
/// Реализует ISandboxItem — события это тоже данные.
/// Конкретные реализации создаются в aq_studio:
///   SandboxLogEvent
///   SandboxStateChangeEvent
///   SandboxPolicyViolationEvent
///   SandboxHandEvent
abstract interface class ISandboxEvent implements ISandboxItem {
  /// ID sandbox из которого пришло событие
  String get sandboxId;

  /// Unix timestamp в миллисекундах
  int get timestamp;

  /// Тип события — строка-токен.
  /// Стандартные: 'log' | 'state_change' | 'policy_violation' |
  ///              'hand_started' | 'hand_completed' | 'disposed'
  String get type;

  /// Серьёзность: 'debug' | 'info' | 'warning' | 'error'
  String get severity;
}
```

### Файл: `./lib/sandbox/interfaces/i_sandbox_item.dart` (строк:       17, размер:      835 байт)

```dart
/// Корневой тип для всех данных проходящих через sandbox.
///
/// Всё что входит, выходит или хранится внутри sandbox —
/// реализует этот интерфейс. Никаких голых Map<String, dynamic>.
///
/// Конкретные sub-интерфейсы:
///   ISandboxChatMessage   — сообщение в чат-sandbox
///   ISandboxAttachment    — вложение
///   ISandboxEvent         — событие потока
abstract interface class ISandboxItem {
  /// Уникальный ID этого элемента данных
  String get itemId;

  /// Дискриминатор типа — строка-токен.
  /// Примеры: 'chat_message' | 'file_attachment' | 'sandbox_event'
  String get itemType;
}
```

### Файл: `./lib/sandbox/interfaces/i_sandbox_registry.dart` (строк:       22, размер:      903 байт)

```dart
import 'i_sandbox.dart';

/// Реестр всех активных sandbox-ов — единственный источник правды для UI.
///
/// Реализует: SandboxRegistryService (в aq_studio, Riverpod provider)
/// Использует: SandboxMonitorWidget — видит ТОЛЬКО этот интерфейс
abstract interface class ISandboxRegistry {
  /// Активные sandbox-ы (не в terminal state)
  List<ISandbox> get activeSandboxes;

  /// Stream изменений — UI строится реактивно
  Stream<List<ISandbox>> get stream;

  /// Зарегистрировать при создании
  void register(ISandbox sandbox);

  /// Снять при dispose
  void unregister(String sandboxId);

  /// Найти по ID (включая children рекурсивно в ISandboxAsEnvironment)
  ISandbox? findById(String sandboxId);
}
```

### Файл: `./lib/sandbox/interfaces/i_sandbox_schema.dart` (строк:       18, размер:      786 байт)

```dart
import 'i_sandbox_item.dart';

/// Валидатор — проверяет ISandboxItem на соответствие схеме.
///
/// Реализации:
///   JsonSandboxSchema   — валидация через json_schema пакет
///   AnyAcceptSchema     — принимает всё (для unrestricted)
///   NullRejectSchema    — отклоняет всё (для isolated)
abstract interface class ISandboxSchema {
  /// Уникальный ID схемы (например: 'aq:instruction:input:v1')
  String get schemaId;

  /// Соответствует ли item этой схеме
  bool validate(ISandboxItem item);

  /// Список ошибок валидации. Пустой список = успех.
  List<String> errors(ISandboxItem item);
}
```

### Файл: `./lib/sandbox/interfaces/i_sandbox.dart` (строк:       31, размер:     1835 байт)

```dart
// pkgs/aq_schema/lib/sandbox/interfaces/i_sandbox.dart
//
// РОЛЬ: Граница изолированной среды.
//
// ISandbox — это контейнер. Он не работает сам —
// он определяет границы в которых работают акторы.
//
// Аналогия с Docker:
//   ISandbox = контейнер (граница, политика, ресурсы)
//   ISandboxActor = процесс внутри контейнера
//   ISandboxContext = файловая система + переменные окружения контейнера
//   ISandboxItem = данные передаваемые в/из контейнера

import 'i_sandbox_event.dart';
import '../policy/sandbox_policy.dart';

abstract interface class ISandbox {
  // ── Идентификация ────────────────────────────────────────────────────
  String get sandboxId;
  String get displayName;

  // ── Политика ─────────────────────────────────────────────────────────
  SandboxPolicy get policy;

  // ── Наблюдаемость ────────────────────────────────────────────────────
  /// Hot broadcast stream. Все события из этого sandbox и его детей.
  Stream<ISandboxEvent> get events;

  // ── Жизненный цикл ───────────────────────────────────────────────────
  Future<void> dispose();
}
```

### Файл: `./lib/sandbox/policy/sandbox_capabilities.dart` (строк:       41, размер:     2183 байт)

```dart
/// Реестр известных ключей capability.
///
/// Строки-токены. Не enum — чтобы можно было расширять
/// не изменяя базовых файлов.
///
/// Добавление новой capability:
///   1. Добавить константу здесь
///   2. Добавить в list all
///   3. Добавить в нужные пресеты SandboxPolicy
///   4. Реализовать ISandboxCapable в нужных Hands
abstract final class SandboxCapabilities {
  // ── Файловая система ─────────────────────────────────────────────────
  static const String fsRead = 'fs.read';
  static const String fsWrite = 'fs.write';

  // ── Сеть ─────────────────────────────────────────────────────────────
  static const String network = 'network';

  // ── Модели ───────────────────────────────────────────────────────────
  static const String llm = 'llm';

  // ── MCP инструменты ──────────────────────────────────────────────────
  static const String mcp = 'mcp';

  // ── Выполнение кода ──────────────────────────────────────────────────
  static const String process = 'process';

  // ── Системные операции (builder, CRUD blueprints) ────────────────────
  static const String system = 'system';

  /// Все стандартные ключи. Используется в пресетах SandboxPolicy.
  static const List<String> all = [
    fsRead,
    fsWrite,
    network,
    llm,
    mcp,
    process,
    system,
  ];
}
```

### Файл: `./lib/sandbox/policy/sandbox_policy_violation.dart` (строк:       21, размер:      695 байт)

```dart
import 'package:meta/meta.dart';

/// Нарушение политики sandbox.
/// Бросается InstructionRunner когда ISandboxCapable Hand
/// требует capability которая не разрешена в activePolicy.
@immutable
final class SandboxPolicyViolation implements Exception {
  const SandboxPolicyViolation({
    required this.sandboxId,
    required this.handId,
    required this.requiredCapability,
  });

  final String sandboxId;
  final String handId;
  final String requiredCapability;

  @override
  String toString() => 'SandboxPolicyViolation: hand "$handId" requires '
      '"$requiredCapability" which is not permitted in sandbox "$sandboxId"';
}
```

### Файл: `./lib/sandbox/policy/sandbox_policy.dart` (строк:      118, размер:     4479 байт)

```dart
// pkgs/aq_schema/lib/sandbox/policy/sandbox_policy.dart
import 'package:meta/meta.dart';

import 'sandbox_capabilities.dart';

@immutable
final class SandboxPolicy {
  const SandboxPolicy({
    required this.available, // что есть в среде
    required this.allowed, // что разрешено из available
    this.sessionDir,
    this.timeoutMs,
    this.runtimeLevel = 'local',
    this.dryRun = false,
    this.envVars = const {},
  });

  final List<String> available; // infrastructure
  final List<String> allowed; // authorization

  final String? sessionDir; // куда пишутся файлы
  final int? timeoutMs; // лимит времени
  final String runtimeLevel; // 'local'|'process'|'container'|'remote'
  final bool dryRun; // ничего не записывать
  final Map<String, String> envVars;

  // ── Проверка ─────────────────────────────────────────────────────────

  bool permits(String key) =>
      !dryRun && available.contains(key) && allowed.contains(key);

  // ── Пересечение с родителем ───────────────────────────────────────────
  // Дочерний sandbox НИКОГДА не получает больше прав чем родитель.

  SandboxPolicy intersectWith(SandboxPolicy parent) => SandboxPolicy(
        available: available.where(parent.available.contains).toList(),
        allowed: allowed.where(parent.allowed.contains).toList(),
        sessionDir: sessionDir ?? parent.sessionDir,
        timeoutMs: _min(timeoutMs, parent.timeoutMs),
        runtimeLevel: runtimeLevel,
        dryRun: dryRun || parent.dryRun,
        envVars: {...parent.envVars, ...envVars},
      );

  String resolveFilePath(String path) {
    if (sessionDir == null) return path;
    return '$sessionDir${path.split('/').last}';
  }

  // ── Пресеты ───────────────────────────────────────────────────────────

  static const SandboxPolicy unrestricted = SandboxPolicy(
    available: SandboxCapabilities.all,
    allowed: SandboxCapabilities.all,
  );

  static const SandboxPolicy readOnly = SandboxPolicy(
    available: SandboxCapabilities.all,
    allowed: [SandboxCapabilities.fsRead, SandboxCapabilities.llm],
  );

  static SandboxPolicy testLab({required String runId}) => SandboxPolicy(
        available: SandboxCapabilities.all,
        allowed: [
          SandboxCapabilities.fsRead,
          SandboxCapabilities.fsWrite,
          SandboxCapabilities.llm,
        ],
        sessionDir: '/tmp/aq_sandbox/$runId/',
      );

  static const SandboxPolicy forWorkflow = SandboxPolicy(
    available: SandboxCapabilities.all,
    allowed: [
      SandboxCapabilities.fsRead,
      SandboxCapabilities.fsWrite,
      SandboxCapabilities.llm,
      SandboxCapabilities.mcp,
    ],
  );

  static const SandboxPolicy forBuilder = SandboxPolicy(
    available: SandboxCapabilities.all,
    allowed: SandboxCapabilities.all, // Builder доверенный — всё разрешено
  );

  static const SandboxPolicy isolated = SandboxPolicy(
    available: [],
    allowed: [],
    dryRun: true,
  );

  // ── Сериализация ──────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'available': available,
        'allowed': allowed,
        if (sessionDir != null) 'sessionDir': sessionDir,
        if (timeoutMs != null) 'timeoutMs': timeoutMs,
        'runtimeLevel': runtimeLevel,
        'dryRun': dryRun,
      };

  factory SandboxPolicy.fromJson(Map<String, dynamic> j) => SandboxPolicy(
        available: List<String>.from(j['available'] as List? ?? []),
        allowed: List<String>.from(j['allowed'] as List? ?? []),
        sessionDir: j['sessionDir'] as String?,
        timeoutMs: j['timeoutMs'] as int?,
        runtimeLevel: j['runtimeLevel'] as String? ?? 'local',
        dryRun: j['dryRun'] as bool? ?? false,
      );

  static int? _min(int? a, int? b) {
    if (a == null) return b;
    if (b == null) return a;
    return a < b ? a : b;
  }
}
```

### Файл: `./lib/sandbox/sandbox_policy_test.dart` (строк:      103, размер:     3396 байт)

```dart
import 'package:aq_schema/aq_schema.dart';
import 'package:test/test.dart';

void main() {
  group('SandboxPolicy', () {
    test('permits returns true when in both lists', () {
      final policy = SandboxPolicy(
        available: ['fs.read', 'llm'],
        allowed: ['fs.read', 'llm'],
      );
      expect(policy.permits('fs.read'), isTrue);
      expect(policy.permits('llm'), isTrue);
    });

    test('permits returns false when not in available', () {
      final policy = SandboxPolicy(
        available: ['fs.read'],
        allowed: ['fs.read', 'llm'],
      );
      expect(policy.permits('llm'), isFalse);
    });

    test('permits returns false when not in allowed', () {
      final policy = SandboxPolicy(
        available: ['fs.read', 'llm'],
        allowed: ['fs.read'],
      );
      expect(policy.permits('llm'), isFalse);
    });

    test('permits returns false when dryRun', () {
      final policy = SandboxPolicy(
        available: SandboxCapabilities.all,
        allowed: SandboxCapabilities.all,
        dryRun: true,
      );
      expect(policy.permits('fs.read'), isFalse);
      expect(policy.permits('llm'), isFalse);
    });

    test('intersectWith restricts to parent', () {
      final child = SandboxPolicy(
        available: SandboxCapabilities.all,
        allowed: SandboxCapabilities.all,
      );
      final parent = SandboxPolicy(
        available: ['fs.read', 'llm'],
        allowed: ['fs.read'],
      );
      final effective = child.intersectWith(parent);
      expect(effective.available, containsAll(['fs.read', 'llm']));
      expect(effective.available, isNot(contains('fs.write')));
      expect(effective.allowed, equals(['fs.read']));
    });

    test('intersectWith: dryRun propagates from parent', () {
      final child = SandboxPolicy(
        available: SandboxCapabilities.all,
        allowed: SandboxCapabilities.all,
      );
      final parent = SandboxPolicy(
        available: SandboxCapabilities.all,
        allowed: SandboxCapabilities.all,
        dryRun: true,
      );
      final effective = child.intersectWith(parent);
      expect(effective.dryRun, isTrue);
    });

    test('toJson / fromJson roundtrip', () {
      final policy = SandboxPolicy.forWorkflow;
      final json = policy.toJson();
      final restored = SandboxPolicy.fromJson(json);
      expect(restored.available, equals(policy.available));
      expect(restored.allowed, equals(policy.allowed));
      expect(restored.dryRun, equals(policy.dryRun));
    });

    test('resolveFilePath with sessionDir', () {
      final policy = SandboxPolicy.testLab(runId: 'test123');
      expect(
        policy.resolveFilePath('/some/path/doc.docx'),
        equals('/tmp/aq_sandbox/test123/doc.docx'),
      );
    });

    test('resolveFilePath without sessionDir returns original', () {
      expect(
        SandboxPolicy.unrestricted.resolveFilePath('/some/path/doc.docx'),
        equals('/some/path/doc.docx'),
      );
    });
  });

  group('SandboxCapabilities', () {
    test('all contains all capability keys', () {
      expect(SandboxCapabilities.all, contains(SandboxCapabilities.fsRead));
      expect(SandboxCapabilities.all, contains(SandboxCapabilities.fsWrite));
      expect(SandboxCapabilities.all, contains(SandboxCapabilities.llm));
      expect(SandboxCapabilities.all, contains(SandboxCapabilities.mcp));
    });
  });
}
```

### Файл: `./lib/sandbox/sandbox.dart` (строк:       29, размер:      991 байт)

```dart
// pkgs/aq_schema/lib/sandbox/sandbox.dart

// Items & Schema
export 'interfaces/i_sandbox_item.dart';
export 'interfaces/i_sandbox_schema.dart';

// Roles
export 'interfaces/i_sandbox_context.dart'; // ← RunContext роль
export 'interfaces/i_sandbox_actor.dart'; // ← Runner роль

// Sandbox types (by interface hierarchy, not kind field)
export 'interfaces/i_sandbox.dart';
export 'interfaces/i_sandbox_as_function.dart';
export 'interfaces/i_sandbox_as_process.dart';
export 'interfaces/i_sandbox_as_chat.dart';
export 'interfaces/i_sandbox_as_environment.dart';

// Chat sub-items (из i_sandbox_as_chat.dart — re-export для удобства)
// ISandboxChatMessage, ISandboxAttachment

// Supporting
export 'interfaces/i_sandbox_registry.dart';
export 'interfaces/i_sandbox_event.dart';
export 'interfaces/i_sandbox_capable.dart';

// Policy
export 'policy/sandbox_capabilities.dart';
export 'policy/sandbox_policy.dart';
export 'policy/sandbox_policy_violation.dart';
```

### Файл: `./lib/security/interfaces/i_session_repository.dart` (строк:       35, размер:     1237 байт)

```dart
// pkgs/aq_schema/lib/security/interfaces/i_session_repository.dart

import '../models/aq_session.dart';
import '../models/aq_api_key.dart';
import '../models/aq_tenant.dart';

abstract interface class ISessionRepository {
  Future<AqSession?> findById(String id);
  Future<AqSession> create(AqSession session);
  Future<AqSession> update(AqSession session);
  Future<void> touch(String sessionId, int lastSeenAt);
  Future<void> revoke(String sessionId, String reason);
  Future<void> revokeAllForUser(String userId);
  Future<List<AqSession>> listActiveByUser(String userId);

  /// Used on startup: purge expired sessions.
  Future<int> purgeExpired();
}

abstract interface class IApiKeyRepository {
  Future<AqApiKey?> findByHash(String keyHash);
  Future<AqApiKey?> findById(String id);
  Future<AqApiKey> create(AqApiKey apiKey);
  Future<void> revoke(String id);
  Future<void> updateLastUsed(String id, int timestamp);
  Future<List<AqApiKey>> listByUser(String userId);
}

abstract interface class ITenantRepository {
  Future<AqTenant?> findById(String id);
  Future<AqTenant?> findBySlug(String slug);
  Future<AqTenant> create(AqTenant tenant);
  Future<AqTenant> update(AqTenant tenant);
  Future<List<AqTenant>> list();
}
```

### Файл: `./lib/security/interfaces/i_user_repository.dart` (строк:       30, размер:     1141 байт)

```dart
// pkgs/aq_schema/lib/security/interfaces/i_user_repository.dart

import '../models/aq_user.dart';
import '../models/aq_profile.dart';
import '../models/aq_role.dart';

abstract interface class IUserRepository {
  Future<AqUser?> findById(String id);
  Future<AqUser?> findByEmail(String email);
  Future<AqUser?> findByProvider(String provider, String providerUserId);
  Future<AqUser> create(AqUser user);
  Future<AqUser> update(AqUser user);
  Future<void> updateLastLogin(String userId, int timestamp);
  Future<List<AqUser>> listByTenant(String tenantId);
}

abstract interface class IProfileRepository {
  Future<AqProfile?> findByUserId(String userId);
  Future<AqProfile> upsert(AqProfile profile);
}

abstract interface class IRoleRepository {
  Future<List<AqRole>> findByUser(String userId, String tenantId);
  Future<List<AqRole>> listSystemRoles();
  Future<AqRole?> findByName(String name, {String? tenantId});
  Future<AqRole> create(AqRole role);
  Future<void> assignRole(String userId, String roleId, String tenantId,
      {String? grantedBy});
  Future<void> revokeRole(String userId, String roleId, String tenantId);
}
```

### Файл: `./lib/security/models/aq_api_key.dart` (строк:      255, размер:     7717 байт)

```dart
import 'aq_user.dart';
import 'aq_session.dart';
import 'aq_tenant.dart';
import 'aq_token_claims.dart';

// pkgs/aq_schema/lib/security/models/aq_api_key.dart
//
// Long-lived API key for service accounts (workers, data service, external).
// Raw key shown ONCE on creation. Only hash stored.

final class AqApiKey {
  const AqApiKey({
    required this.id,
    required this.userId,
    required this.tenantId,
    required this.name,
    required this.keyPrefix,
    required this.keyHash,
    required this.permissions,
    required this.isActive,
    required this.createdAt,
    this.lastUsedAt,
    this.expiresAt,
  });

  final String id;
  final String userId;
  final String tenantId;

  /// Human-readable label: 'Graph Worker Production'
  final String name;

  /// First 8 chars — for display only, not auth.
  final String keyPrefix;

  /// SHA-256 hash of the full key — stored, never the raw key.
  final String keyHash;

  final List<String> permissions;
  final bool isActive;
  final int? lastUsedAt;
  final int? expiresAt;
  final int createdAt;

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().millisecondsSinceEpoch ~/ 1000 >= expiresAt!;
  }

  factory AqApiKey.fromJson(Map<String, dynamic> json) => AqApiKey(
        id: json['id'] as String,
        userId: json['userId'] as String,
        tenantId: json['tenantId'] as String,
        name: json['name'] as String,
        keyPrefix: json['keyPrefix'] as String,
        keyHash: json['keyHash'] as String,
        permissions:
            (json['permissions'] as List<dynamic>?)?.cast<String>() ?? [],
        isActive: json['isActive'] as bool? ?? true,
        lastUsedAt: json['lastUsedAt'] as int?,
        expiresAt: json['expiresAt'] as int?,
        createdAt: json['createdAt'] as int,
      );

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'id': id,
      'userId': userId,
      'tenantId': tenantId,
      'name': name,
      'keyPrefix': keyPrefix,
      'keyHash': keyHash,
      'permissions': permissions,
      'isActive': isActive,
      'createdAt': createdAt,
    };
    if (lastUsedAt != null) m['lastUsedAt'] = lastUsedAt;
    if (expiresAt != null) m['expiresAt'] = expiresAt;
    return m;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Auth request / response DTOs
// ─────────────────────────────────────────────────────────────────────────────

/// Incoming auth request. Discriminated by [provider].
final class AuthRequest {
  const AuthRequest({
    required this.provider,
    this.googleCode,
    this.googleRedirectUri,
    this.email,
    this.password,
    this.apiKey,
  });

  final AuthProvider provider;

  // Google OAuth2 code exchange
  final String? googleCode;
  final String? googleRedirectUri;

  // Email/password (future)
  final String? email;
  final String? password;

  // API key (service accounts)
  final String? apiKey;

  factory AuthRequest.google({
    required String code,
    required String redirectUri,
  }) =>
      AuthRequest(
        provider: AuthProvider.google,
        googleCode: code,
        googleRedirectUri: redirectUri,
      );

  factory AuthRequest.apiKey(String key) =>
      AuthRequest(provider: AuthProvider.apiKey, apiKey: key);

  factory AuthRequest.fromJson(Map<String, dynamic> json) => AuthRequest(
        provider: AuthProvider.fromString(json['provider'] as String),
        googleCode: json['googleCode'] as String?,
        googleRedirectUri: json['googleRedirectUri'] as String?,
        email: json['email'] as String?,
        password: json['password'] as String?,
        apiKey: json['apiKey'] as String?,
      );

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{'provider': provider.value};
    if (googleCode != null) m['googleCode'] = googleCode;
    if (googleRedirectUri != null) m['googleRedirectUri'] = googleRedirectUri;
    if (email != null) m['email'] = email;
    if (apiKey != null) m['apiKey'] = apiKey;
    return m;
  }
}

/// Successful auth response.
final class AuthResponse {
  const AuthResponse({
    required this.user,
    required this.tenant,
    required this.tokens,
    required this.session,
  });

  final AqUser user;
  final AqTenant tenant;
  final TokenPair tokens;
  final AqSession session;

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        user: AqUser.fromJson(json['user'] as Map<String, dynamic>),
        tenant: AqTenant.fromJson(json['tenant'] as Map<String, dynamic>),
        tokens: TokenPair.fromJson(json['tokens'] as Map<String, dynamic>),
        session: AqSession.fromJson(json['session'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'user': user.toJson(),
        'tenant': tenant.toJson(),
        'tokens': tokens.toJson(),
        'session': session.toJson(),
      };
}

/// Token validation request (used by workers, data service).
final class ValidateTokenRequest {
  const ValidateTokenRequest({
    required this.token,
    this.requiredPerms = const [],
  });

  final String token;
  final List<String> requiredPerms;

  Map<String, dynamic> toJson() => {
        'token': token,
        if (requiredPerms.isNotEmpty) 'requiredPerms': requiredPerms,
      };

  factory ValidateTokenRequest.fromJson(Map<String, dynamic> json) =>
      ValidateTokenRequest(
        token: json['token'] as String,
        requiredPerms:
            (json['requiredPerms'] as List<dynamic>?)?.cast<String>() ?? [],
      );
}

/// Token validation response.
final class ValidateTokenResponse {
  const ValidateTokenResponse({
    required this.valid,
    this.claims,
    this.permitted,
    this.reason,
  });

  final bool valid;
  final AqTokenClaims? claims;
  final bool? permitted;
  final String? reason;

  factory ValidateTokenResponse.ok(AqTokenClaims claims,
          {bool permitted = true}) =>
      ValidateTokenResponse(valid: true, claims: claims, permitted: permitted);

  factory ValidateTokenResponse.fail(String reason) =>
      ValidateTokenResponse(valid: false, reason: reason);

  factory ValidateTokenResponse.fromJson(Map<String, dynamic> json) =>
      ValidateTokenResponse(
        valid: json['valid'] as bool,
        claims: json['claims'] != null
            ? AqTokenClaims.fromJson(json['claims'] as Map<String, dynamic>)
            : null,
        permitted: json['permitted'] as bool?,
        reason: json['reason'] as String?,
      );

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{'valid': valid};
    if (claims != null) m['claims'] = claims!.toJson();
    if (permitted != null) m['permitted'] = permitted;
    if (reason != null) m['reason'] = reason;
    return m;
  }
}

/// Standard error envelope.
final class SecurityError {
  const SecurityError(
      {required this.code, required this.message, this.details});

  final String code;
  final String message;
  final Map<String, dynamic>? details;

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{'code': code, 'message': message};
    if (details != null) m['details'] = details;
    return m;
  }

  factory SecurityError.fromJson(Map<String, dynamic> json) => SecurityError(
        code: json['code'] as String,
        message: json['message'] as String,
        details: json['details'] as Map<String, dynamic>?,
      );
}
```

### Файл: `./lib/security/models/aq_profile.dart` (строк:       61, размер:     1662 байт)

```dart
// pkgs/aq_schema/lib/security/models/aq_profile.dart
//
// Extended user profile. 1:1 with AqUser.

final class AqProfile {
  const AqProfile({
    required this.userId,
    this.bio,
    this.timezone,
    this.locale,
    this.preferences = const {},
    this.updatedAt,
  });

  final String userId;
  final String? bio;

  /// IANA timezone: 'Europe/Berlin'
  final String? timezone;

  /// BCP-47 locale: 'en-US', 'ru'
  final String? locale;

  final Map<String, dynamic> preferences;
  final int? updatedAt;

  factory AqProfile.fromJson(Map<String, dynamic> json) => AqProfile(
        userId: json['userId'] as String,
        bio: json['bio'] as String?,
        timezone: json['timezone'] as String?,
        locale: json['locale'] as String?,
        preferences: (json['preferences'] as Map<String, dynamic>?) ?? {},
        updatedAt: json['updatedAt'] as int?,
      );

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{'userId': userId};
    if (bio != null) m['bio'] = bio;
    if (timezone != null) m['timezone'] = timezone;
    if (locale != null) m['locale'] = locale;
    if (preferences.isNotEmpty) m['preferences'] = preferences;
    if (updatedAt != null) m['updatedAt'] = updatedAt;
    return m;
  }

  AqProfile copyWith({
    String? bio,
    String? timezone,
    String? locale,
    Map<String, dynamic>? preferences,
    int? updatedAt,
  }) =>
      AqProfile(
        userId: userId,
        bio: bio ?? this.bio,
        timezone: timezone ?? this.timezone,
        locale: locale ?? this.locale,
        preferences: preferences ?? this.preferences,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
```

### Файл: `./lib/security/models/aq_role.dart` (строк:      116, размер:     3254 байт)

```dart
// pkgs/aq_schema/lib/security/models/aq_role.dart
//
// Role and permission assignment.
// Roles can be platform-level (tenantId == null) or tenant-scoped.

/// A named role with a set of permission keys.
final class AqRole {
  const AqRole({
    required this.id,
    required this.name,
    required this.permissions,
    this.description,
    this.tenantId,
    this.isSystem = false,
    this.createdAt,
  });

  final String id;
  final String name;
  final String? description;

  /// null = platform-level role (visible across all tenants).
  final String? tenantId;

  /// Permission keys: 'projects:read', 'agents:run', 'admin:*'
  final List<String> permissions;

  /// System roles cannot be deleted.
  final bool isSystem;
  final int? createdAt;

  bool hasPermission(String perm) {
    if (permissions.contains('*')) return true;
    if (permissions.contains(perm)) return true;
    // wildcard check: 'projects:*' matches 'projects:read'
    final parts = perm.split(':');
    if (parts.length == 2) {
      return permissions.contains('${parts[0]}:*');
    }
    return false;
  }

  factory AqRole.fromJson(Map<String, dynamic> json) => AqRole(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        tenantId: json['tenantId'] as String?,
        permissions: (json['permissions'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        isSystem: json['isSystem'] as bool? ?? false,
        createdAt: json['createdAt'] as int?,
      );

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'id': id,
      'name': name,
      'permissions': permissions,
      'isSystem': isSystem,
    };
    if (description != null) m['description'] = description;
    if (tenantId != null) m['tenantId'] = tenantId;
    if (createdAt != null) m['createdAt'] = createdAt;
    return m;
  }

  @override
  String toString() => 'AqRole(name: $name, perms: ${permissions.length})';
}

/// Assignment of a role to a user within a tenant context.
final class AqUserRole {
  const AqUserRole({
    required this.userId,
    required this.roleId,
    required this.tenantId,
    required this.grantedAt,
    this.grantedBy,
    this.expiresAt,
  });

  final String userId;
  final String roleId;
  final String tenantId;
  final String? grantedBy;
  final int grantedAt;
  final int? expiresAt;

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().millisecondsSinceEpoch ~/ 1000 >= expiresAt!;
  }

  factory AqUserRole.fromJson(Map<String, dynamic> json) => AqUserRole(
        userId: json['userId'] as String,
        roleId: json['roleId'] as String,
        tenantId: json['tenantId'] as String,
        grantedBy: json['grantedBy'] as String?,
        grantedAt: json['grantedAt'] as int,
        expiresAt: json['expiresAt'] as int?,
      );

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'userId': userId,
      'roleId': roleId,
      'tenantId': tenantId,
      'grantedAt': grantedAt,
    };
    if (grantedBy != null) m['grantedBy'] = grantedBy;
    if (expiresAt != null) m['expiresAt'] = expiresAt;
    return m;
  }
}
```

### Файл: `./lib/security/models/aq_session.dart` (строк:      122, размер:     3563 байт)

```dart
// pkgs/aq_schema/lib/security/models/aq_session.dart
//
// Authenticated session. One session per login.
// Session ID is embedded in every JWT (sid claim).

import 'aq_user.dart';

enum SessionStatus {
  active('active'),
  expired('expired'),
  revoked('revoked');

  const SessionStatus(this.value);
  final String value;

  static SessionStatus fromString(String s) =>
      SessionStatus.values.firstWhere((e) => e.value == s,
          orElse: () => SessionStatus.active);
}

final class AqSession {
  const AqSession({
    required this.id,
    required this.userId,
    required this.tenantId,
    required this.status,
    required this.authProvider,
    required this.createdAt,
    required this.expiresAt,
    required this.lastSeenAt,
    this.ipAddress,
    this.userAgent,
    this.deviceHint,
    this.revokedAt,
    this.revokedReason,
  });

  /// Session ID — matches `sid` JWT claim.
  final String id;
  final String userId;
  final String tenantId;
  final SessionStatus status;
  final AuthProvider authProvider;
  final String? ipAddress;
  final String? userAgent;

  /// Short browser/OS hint for UI display.
  final String? deviceHint;

  final int createdAt;
  final int expiresAt;
  final int lastSeenAt;
  final int? revokedAt;
  final String? revokedReason;

  bool get isActive {
    if (status != SessionStatus.active) return false;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return now < expiresAt;
  }

  AqSession copyWith({
    SessionStatus? status,
    int? lastSeenAt,
    int? revokedAt,
    String? revokedReason,
  }) =>
      AqSession(
        id: id,
        userId: userId,
        tenantId: tenantId,
        status: status ?? this.status,
        authProvider: authProvider,
        ipAddress: ipAddress,
        userAgent: userAgent,
        deviceHint: deviceHint,
        createdAt: createdAt,
        expiresAt: expiresAt,
        lastSeenAt: lastSeenAt ?? this.lastSeenAt,
        revokedAt: revokedAt ?? this.revokedAt,
        revokedReason: revokedReason ?? this.revokedReason,
      );

  factory AqSession.fromJson(Map<String, dynamic> json) => AqSession(
        id: json['id'] as String,
        userId: json['userId'] as String,
        tenantId: json['tenantId'] as String,
        status: SessionStatus.fromString(json['status'] as String? ?? 'active'),
        authProvider: AuthProvider.fromString(
            json['authProvider'] as String? ?? 'mock'),
        ipAddress: json['ipAddress'] as String?,
        userAgent: json['userAgent'] as String?,
        deviceHint: json['deviceHint'] as String?,
        createdAt: json['createdAt'] as int,
        expiresAt: json['expiresAt'] as int,
        lastSeenAt: json['lastSeenAt'] as int,
        revokedAt: json['revokedAt'] as int?,
        revokedReason: json['revokedReason'] as String?,
      );

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'id': id,
      'userId': userId,
      'tenantId': tenantId,
      'status': status.value,
      'authProvider': authProvider.value,
      'createdAt': createdAt,
      'expiresAt': expiresAt,
      'lastSeenAt': lastSeenAt,
    };
    if (ipAddress != null) m['ipAddress'] = ipAddress;
    if (userAgent != null) m['userAgent'] = userAgent;
    if (deviceHint != null) m['deviceHint'] = deviceHint;
    if (revokedAt != null) m['revokedAt'] = revokedAt;
    if (revokedReason != null) m['revokedReason'] = revokedReason;
    return m;
  }

  @override
  String toString() => 'AqSession(id: $id, userId: $userId, status: ${status.value})';
}
```

### Файл: `./lib/security/models/aq_tenant.dart` (строк:      107, размер:     2856 байт)

```dart
// pkgs/aq_schema/lib/security/models/aq_tenant.dart
//
// Organization / company entity.
// Every user belongs to exactly one tenant.
// Tenant defines the billing boundary and isolation unit.

/// Subscription plan.
enum TenantPlan {
  free('free'),
  starter('starter'),
  pro('pro'),
  enterprise('enterprise');

  const TenantPlan(this.value);
  final String value;

  static TenantPlan fromString(String s) =>
      TenantPlan.values.firstWhere((e) => e.value == s,
          orElse: () => TenantPlan.free);
}

/// Organization / company.
final class AqTenant {
  const AqTenant({
    required this.id,
    required this.name,
    required this.slug,
    required this.plan,
    required this.isActive,
    required this.createdAt,
    this.ownerId,
    this.logoUrl,
    this.settings = const {},
    this.updatedAt,
  });

  final String id;
  final String name;

  /// URL-safe unique identifier: "acme-corp"
  final String slug;

  final TenantPlan plan;
  final bool isActive;

  /// User ID of the tenant owner.
  final String? ownerId;
  final String? logoUrl;
  final Map<String, dynamic> settings;
  final int createdAt;
  final int? updatedAt;

  factory AqTenant.fromJson(Map<String, dynamic> json) => AqTenant(
        id: json['id'] as String,
        name: json['name'] as String,
        slug: json['slug'] as String,
        plan: TenantPlan.fromString(json['plan'] as String? ?? 'free'),
        isActive: json['isActive'] as bool? ?? true,
        ownerId: json['ownerId'] as String?,
        logoUrl: json['logoUrl'] as String?,
        settings: (json['settings'] as Map<String, dynamic>?) ?? {},
        createdAt: json['createdAt'] as int,
        updatedAt: json['updatedAt'] as int?,
      );

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'id': id,
      'name': name,
      'slug': slug,
      'plan': plan.value,
      'isActive': isActive,
      'createdAt': createdAt,
    };
    if (ownerId != null) m['ownerId'] = ownerId;
    if (logoUrl != null) m['logoUrl'] = logoUrl;
    if (settings.isNotEmpty) m['settings'] = settings;
    if (updatedAt != null) m['updatedAt'] = updatedAt;
    return m;
  }

  AqTenant copyWith({
    String? name,
    String? slug,
    TenantPlan? plan,
    bool? isActive,
    String? ownerId,
    String? logoUrl,
    Map<String, dynamic>? settings,
    int? updatedAt,
  }) =>
      AqTenant(
        id: id,
        name: name ?? this.name,
        slug: slug ?? this.slug,
        plan: plan ?? this.plan,
        isActive: isActive ?? this.isActive,
        ownerId: ownerId ?? this.ownerId,
        logoUrl: logoUrl ?? this.logoUrl,
        settings: settings ?? this.settings,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  String toString() => 'AqTenant(id: $id, slug: $slug, plan: ${plan.value})';
}
```

### Файл: `./lib/security/models/aq_token_claims.dart` (строк:      157, размер:     4286 байт)

```dart
// pkgs/aq_schema/lib/security/models/aq_token_claims.dart
//
// JWT payload model. SHARED between client and server — pure Dart, no deps.
// Both access and refresh tokens use this structure.
//
// Access token:  type='access',  exp=now+900
// Refresh token: type='refresh', exp=now+2592000

import 'aq_user.dart';

enum TokenType {
  access('access'),
  refresh('refresh'),
  id('id');

  const TokenType(this.value);
  final String value;

  static TokenType fromString(String s) =>
      TokenType.values.firstWhere((e) => e.value == s,
          orElse: () => TokenType.access);
}

/// JWT payload. Shared between all nodes — client, server, worker.
final class AqTokenClaims {
  const AqTokenClaims({
    required this.sub,
    required this.tid,
    required this.email,
    required this.type,
    required this.iat,
    required this.exp,
    required this.jti,
    required this.sid,
    this.name,
    this.roles = const [],
    this.perms = const [],
    this.utype = UserType.endUser,
  });

  /// Subject — AqUser.id
  final String sub;

  /// Tenant ID — AqTenant.id
  final String tid;

  final String email;
  final String? name;
  final TokenType type;

  /// Active role names
  final List<String> roles;

  /// Flattened permission keys from all roles
  final List<String> perms;

  /// UserType shortcut — avoids role lookup on every request
  final UserType utype;

  /// Issued at (Unix seconds)
  final int iat;

  /// Expires at (Unix seconds)
  final int exp;

  /// Unique token ID — used for revocation
  final String jti;

  /// Session ID — matches AqSession.id
  final String sid;

  bool get isExpired {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return now >= exp;
  }

  bool hasPermission(String perm) {
    if (perms.contains('*')) return true;
    if (perms.contains(perm)) return true;
    final parts = perm.split(':');
    if (parts.length == 2) return perms.contains('${parts[0]}:*');
    return false;
  }

  bool hasAllPermissions(List<String> required) =>
      required.every(hasPermission);

  factory AqTokenClaims.fromJson(Map<String, dynamic> json) => AqTokenClaims(
        sub: json['sub'] as String,
        tid: json['tid'] as String,
        email: json['email'] as String,
        name: json['name'] as String?,
        type: TokenType.fromString(json['type'] as String? ?? 'access'),
        roles: (json['roles'] as List<dynamic>?)?.cast<String>() ?? [],
        perms: (json['perms'] as List<dynamic>?)?.cast<String>() ?? [],
        utype: UserType.fromString(json['utype'] as String? ?? 'end_user'),
        iat: json['iat'] as int,
        exp: json['exp'] as int,
        jti: json['jti'] as String,
        sid: json['sid'] as String,
      );

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'sub': sub,
      'tid': tid,
      'email': email,
      'type': type.value,
      'utype': utype.value,
      'iat': iat,
      'exp': exp,
      'jti': jti,
      'sid': sid,
    };
    if (name != null) m['name'] = name;
    if (roles.isNotEmpty) m['roles'] = roles;
    if (perms.isNotEmpty) m['perms'] = perms;
    return m;
  }

  @override
  String toString() =>
      'AqTokenClaims(sub: $sub, type: ${type.value}, exp: $exp)';
}

/// Access + Refresh token pair returned on successful auth.
final class TokenPair {
  const TokenPair({
    required this.accessToken,
    required this.refreshToken,
    required this.accessExpiresAt,
    required this.refreshExpiresAt,
    this.tokenType = 'Bearer',
  });

  final String accessToken;
  final String refreshToken;
  final int accessExpiresAt;
  final int refreshExpiresAt;
  final String tokenType;

  factory TokenPair.fromJson(Map<String, dynamic> json) => TokenPair(
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
        accessExpiresAt: json['accessExpiresAt'] as int,
        refreshExpiresAt: json['refreshExpiresAt'] as int,
        tokenType: json['tokenType'] as String? ?? 'Bearer',
      );

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'accessExpiresAt': accessExpiresAt,
        'refreshExpiresAt': refreshExpiresAt,
        'tokenType': tokenType,
      };
}
```

### Файл: `./lib/security/models/aq_user.dart` (строк:      137, размер:     3956 байт)

```dart
// pkgs/aq_schema/lib/security/models/aq_user.dart
//
// Platform user entity. All participants — humans and machines — are AqUsers.

/// What kind of user this is.
enum UserType {
  platformAdmin('platform_admin'),
  developer('developer'),
  endUser('end_user'),
  service('service'); // machine-to-machine

  const UserType(this.value);
  final String value;

  static UserType fromString(String s) =>
      UserType.values.firstWhere((e) => e.value == s,
          orElse: () => UserType.endUser);
}

/// Which identity provider authenticated this user.
enum AuthProvider {
  google('google'),
  emailPassword('email_password'),
  apiKey('api_key'),
  mock('mock');

  const AuthProvider(this.value);
  final String value;

  static AuthProvider fromString(String s) =>
      AuthProvider.values.firstWhere((e) => e.value == s,
          orElse: () => AuthProvider.mock);
}

/// A platform user.
final class AqUser {
  const AqUser({
    required this.id,
    required this.email,
    required this.userType,
    required this.tenantId,
    required this.authProvider,
    required this.isActive,
    required this.createdAt,
    this.displayName,
    this.photoUrl,
    this.providerUserId,
    this.isVerified = false,
    this.lastLoginAt,
    this.updatedAt,
  });

  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final UserType userType;

  /// The tenant this user belongs to.
  final String tenantId;

  final AuthProvider authProvider;

  /// User ID in the external provider (Google `sub`, etc.).
  final String? providerUserId;

  final bool isActive;
  final bool isVerified;
  final int? lastLoginAt;
  final int createdAt;
  final int? updatedAt;

  factory AqUser.fromJson(Map<String, dynamic> json) => AqUser(
        id: json['id'] as String,
        email: json['email'] as String,
        displayName: json['displayName'] as String?,
        photoUrl: json['photoUrl'] as String?,
        userType: UserType.fromString(json['userType'] as String? ?? 'end_user'),
        tenantId: json['tenantId'] as String,
        authProvider: AuthProvider.fromString(
            json['authProvider'] as String? ?? 'mock'),
        providerUserId: json['providerUserId'] as String?,
        isActive: json['isActive'] as bool? ?? true,
        isVerified: json['isVerified'] as bool? ?? false,
        lastLoginAt: json['lastLoginAt'] as int?,
        createdAt: json['createdAt'] as int,
        updatedAt: json['updatedAt'] as int?,
      );

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'id': id,
      'email': email,
      'userType': userType.value,
      'tenantId': tenantId,
      'authProvider': authProvider.value,
      'isActive': isActive,
      'isVerified': isVerified,
      'createdAt': createdAt,
    };
    if (displayName != null) m['displayName'] = displayName;
    if (photoUrl != null) m['photoUrl'] = photoUrl;
    if (providerUserId != null) m['providerUserId'] = providerUserId;
    if (lastLoginAt != null) m['lastLoginAt'] = lastLoginAt;
    if (updatedAt != null) m['updatedAt'] = updatedAt;
    return m;
  }

  AqUser copyWith({
    String? displayName,
    String? photoUrl,
    UserType? userType,
    bool? isActive,
    bool? isVerified,
    int? lastLoginAt,
    int? updatedAt,
  }) =>
      AqUser(
        id: id,
        email: email,
        displayName: displayName ?? this.displayName,
        photoUrl: photoUrl ?? this.photoUrl,
        userType: userType ?? this.userType,
        tenantId: tenantId,
        authProvider: authProvider,
        providerUserId: providerUserId,
        isActive: isActive ?? this.isActive,
        isVerified: isVerified ?? this.isVerified,
        lastLoginAt: lastLoginAt ?? this.lastLoginAt,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  String toString() =>
      'AqUser(id: $id, email: $email, type: ${userType.value})';
}
```

### Файл: `./lib/security/security.dart` (строк:       32, размер:     1654 байт)

```dart
// pkgs/aq_schema/lib/security/security.dart
// AQ Security domain — barrel export.

// ── Models ────────────────────────────────────────────────────────────────────
export 'models/aq_tenant.dart';
export 'models/aq_user.dart';
export 'models/aq_profile.dart';
export 'models/aq_role.dart';
export 'models/aq_session.dart';
export 'models/aq_token_claims.dart';
export 'models/aq_api_key.dart'
    show
        AqApiKey,
        AuthRequest,
        AuthResponse,
        ValidateTokenRequest,
        ValidateTokenResponse,
        SecurityError;

// ── Repository interfaces ─────────────────────────────────────────────────────
export 'interfaces/i_user_repository.dart';
export 'interfaces/i_session_repository.dart';

// ── Shared token logic (pure Dart) ────────────────────────────────────────────
export 'token/token_codec.dart';
export 'token/token_validator.dart';

// ── Storable wrappers ─────────────────────────────────────────────────────────
export 'storable/security_storables.dart';

// ── Domain descriptors (для VaultRegistry на сервере) ─────────────────────────
export 'storable/security_domains.dart';
```

### Файл: `./lib/security/storable/security_domains.dart` (строк:       92, размер:     4338 байт)

```dart
// pkgs/aq_schema/lib/security/storable/security_domains.dart
//
// Описание всех security-доменов для VaultRegistry.
// Сервер читает этот список чтобы:
//   1. Создать таблицы (через PostgresSchemaDeployer)
//   2. Зарегистрировать коллекции в VaultRegistry
//
// Паттерн идентичен AqDomains в aq_schema/lib/adapter/adapter_models.dart.

import 'package:aq_schema/aq_schema.dart';
import 'security_storables.dart';

/// Все security домены — единый источник истины.
/// Сервер и клиент читают этот список.
class AqSecurityDomains {
  AqSecurityDomains._();

  static final List<DomainDescriptor<Storable>> all = [
    // ── Users (Direct) ───────────────────────────────────────────────────────
    DomainDescriptor.direct(
      collection: SecurityCollections.users,
      fromMap: StorableUser.fromMap,
      indexes: [
        VaultIndex(name: 'idx_sec_users_email', field: 'email'),
        VaultIndex(name: 'idx_sec_users_tenant', field: 'tenantId'),
        VaultIndex(name: 'idx_sec_users_provider_id', field: 'providerUserId'),
      ],
    ),

    // ── Tenants (Direct) ─────────────────────────────────────────────────────
    DomainDescriptor.direct(
      collection: SecurityCollections.tenants,
      fromMap: StorableTenant.fromMap,
      indexes: [
        VaultIndex(name: 'idx_sec_tenants_slug', field: 'slug', unique: true),
        VaultIndex(name: 'idx_sec_tenants_owner', field: 'ownerId'),
      ],
    ),

    // ── Profiles (Direct) ────────────────────────────────────────────────────
    DomainDescriptor.direct(
      collection: SecurityCollections.profiles,
      fromMap: StorableProfile.fromMap,
      indexes: [
        VaultIndex(name: 'idx_sec_profiles_user', field: 'userId'),
      ],
    ),

    // ── Roles (Direct) ───────────────────────────────────────────────────────
    DomainDescriptor.direct(
      collection: SecurityCollections.roles,
      fromMap: StorableRole.fromMap,
      indexes: [
        VaultIndex(name: 'idx_sec_roles_name', field: 'name'),
        VaultIndex(name: 'idx_sec_roles_tenant', field: 'tenantId'),
      ],
    ),

    // ── UserRoles (Direct) ───────────────────────────────────────────────────
    DomainDescriptor.direct(
      collection: SecurityCollections.userRoles,
      fromMap: StorableUserRole.fromMap,
      indexes: [
        VaultIndex(name: 'idx_sec_ur_user', field: 'userId'),
        VaultIndex(name: 'idx_sec_ur_tenant', field: 'tenantId'),
      ],
    ),

    // ── Sessions (Logged) ────────────────────────────────────────────────────
    // LoggedStorable → таблица data + data__log
    DomainDescriptor.logged(
      collection: SecurityCollections.sessions,
      fromMap: StorableSession.fromMap,
      indexes: [
        VaultIndex(name: 'idx_sec_sess_user', field: 'userId'),
        VaultIndex(name: 'idx_sec_sess_status', field: 'status'),
        VaultIndex(name: 'idx_sec_sess_expires', field: 'expiresAt'),
      ],
    ),

    // ── ApiKeys (Logged) ─────────────────────────────────────────────────────
    DomainDescriptor.logged(
      collection: SecurityCollections.apiKeys,
      fromMap: StorableApiKey.fromMap,
      indexes: [
        VaultIndex(name: 'idx_sec_apikey_hash', field: 'keyHash', unique: true),
        VaultIndex(name: 'idx_sec_apikey_user', field: 'userId'),
        VaultIndex(name: 'idx_sec_apikey_active', field: 'isActive'),
      ],
    ),
  ];
}
```

### Файл: `./lib/security/storable/security_storables.dart` (строк:      237, размер:     7413 байт)

```dart
// pkgs/aq_schema/lib/security/storable/security_storables.dart
//
// Storable wrappers for all security domain models.
//
// Mapping:
//   AqUser      → DirectStorable   (simple CRUD, no history needed)
//   AqTenant    → DirectStorable
//   AqProfile   → DirectStorable
//   AqRole      → DirectStorable
//   AqUserRole  → DirectStorable
//   AqSession   → LoggedStorable   (audit: active→revoked→expired)
//   AqApiKey    → LoggedStorable   (audit: isActive, lastUsedAt)
//
// DirectRepository  understands DirectStorable
// LoggedRepository  understands LoggedStorable
// VersionedRepository understands VersionedStorable (not used here)

import 'package:aq_schema/data_layer/storable/direct_storable.dart';
import 'package:aq_schema/data_layer/storable/logged_storable.dart';

import '../models/aq_user.dart';
import '../models/aq_tenant.dart';
import '../models/aq_profile.dart';
import '../models/aq_role.dart';
import '../models/aq_session.dart';
import '../models/aq_api_key.dart';

// ── Collection names ──────────────────────────────────────────────────────────

abstract final class SecurityCollections {
  static const users = 'security_users';
  static const tenants = 'security_tenants';
  static const profiles = 'security_profiles';
  static const roles = 'security_roles';
  static const userRoles = 'security_user_roles';
  static const sessions = 'security_sessions';
  static const apiKeys = 'security_api_keys';
  static const all = [
    users,
    tenants,
    profiles,
    roles,
    userRoles,
    sessions,
    apiKeys
  ];
}

// ═══════════════════════════════════════════
//  DirectStorable — simple CRUD entities
// ═══════════════════════════════════════════

final class StorableUser implements DirectStorable {
  StorableUser(this._user);
  final AqUser _user;
  AqUser get domain => _user;

  @override
  String get id => _user.id;
  @override
  Map<String, dynamic> toMap() => _user.toJson();
  @override
  Map<String, dynamic> get indexFields => {
        'email': _user.email,
        'tenantId': _user.tenantId,
        'authProvider': _user.authProvider.value,
        'providerUserId': _user.providerUserId ?? '',
        'userType': _user.userType.value,
        'isActive': _user.isActive,
      };
  static StorableUser fromMap(Map<String, dynamic> m) =>
      StorableUser(AqUser.fromJson(m));

  @override
  // TODO: implement collectionName
  String get collectionName => SecurityCollections.users;
}

final class StorableTenant implements DirectStorable {
  StorableTenant(this._t);
  final AqTenant _t;
  AqTenant get domain => _t;

  @override
  String get id => _t.id;
  @override
  Map<String, dynamic> toMap() => _t.toJson();
  @override
  Map<String, dynamic> get indexFields => {
        'slug': _t.slug,
        'plan': _t.plan.value,
        'isActive': _t.isActive,
        'ownerId': _t.ownerId ?? '',
      };
  static StorableTenant fromMap(Map<String, dynamic> m) =>
      StorableTenant(AqTenant.fromJson(m));

  @override
  // TODO: implement collectionName
  String get collectionName => SecurityCollections.tenants;
}

final class StorableProfile implements DirectStorable {
  StorableProfile(this._p);
  final AqProfile _p;
  AqProfile get domain => _p;

  @override
  String get id => _p.userId; // 1:1 with user
  @override
  Map<String, dynamic> toMap() => _p.toJson();
  @override
  Map<String, dynamic> get indexFields => {
        'userId': _p.userId,
        'locale': _p.locale ?? '',
      };
  static StorableProfile fromMap(Map<String, dynamic> m) =>
      StorableProfile(AqProfile.fromJson(m));

  @override
  // TODO: implement collectionName
  String get collectionName => SecurityCollections.profiles;
}

final class StorableRole implements DirectStorable {
  StorableRole(this._r);
  final AqRole _r;
  AqRole get domain => _r;

  @override
  String get id => _r.id;
  @override
  Map<String, dynamic> toMap() => _r.toJson();
  @override
  Map<String, dynamic> get indexFields => {
        'name': _r.name,
        'tenantId': _r.tenantId ?? '',
        'isSystem': _r.isSystem,
      };
  static StorableRole fromMap(Map<String, dynamic> m) =>
      StorableRole(AqRole.fromJson(m));

  @override
  // TODO: implement collectionName
  String get collectionName => SecurityCollections.roles;
}

final class StorableUserRole implements DirectStorable {
  StorableUserRole(this._ur);
  final AqUserRole _ur;
  AqUserRole get domain => _ur;

  /// Composite PK guarantees uniqueness per assignment.
  @override
  String get id => '${_ur.userId}_${_ur.roleId}_${_ur.tenantId}';
  @override
  Map<String, dynamic> toMap() => _ur.toJson();
  @override
  Map<String, dynamic> get indexFields => {
        'userId': _ur.userId,
        'roleId': _ur.roleId,
        'tenantId': _ur.tenantId,
      };
  static StorableUserRole fromMap(Map<String, dynamic> m) =>
      StorableUserRole(AqUserRole.fromJson(m));

  @override
  // TODO: implement collectionName
  String get collectionName => SecurityCollections.userRoles;
}

// ═══════════════════════════════════════════
//  LoggedStorable — entities with audit trail
// ═══════════════════════════════════════════

/// Session is LoggedStorable — LoggedRepository records a diff
/// on every save(), giving us full audit of status transitions.
final class StorableSession implements LoggedStorable {
  StorableSession(this._s);
  final AqSession _s;
  AqSession get domain => _s;

  @override
  String get id => _s.id;
  @override
  Map<String, dynamic> toMap() => _s.toJson();

  /// Only status-relevant fields in diff log — other fields are static.
  @override
  Set<String> get trackedFields => {
        'status',
        'lastSeenAt',
        'revokedAt',
        'revokedReason',
      };
  @override
  Map<String, dynamic> get indexFields => {
        'userId': _s.userId,
        'tenantId': _s.tenantId,
        'status': _s.status.value,
        'expiresAt': _s.expiresAt,
      };
  static StorableSession fromMap(Map<String, dynamic> m) =>
      StorableSession(AqSession.fromJson(m));

  @override
  // TODO: implement collectionName
  String get collectionName => SecurityCollections.sessions;
}

/// ApiKey is LoggedStorable — track creation, revocation, last-used.
final class StorableApiKey implements LoggedStorable {
  StorableApiKey(this._k);
  final AqApiKey _k;
  AqApiKey get domain => _k;

  @override
  String get id => _k.id;
  @override
  Map<String, dynamic> toMap() => _k.toJson();

  @override
  Set<String> get trackedFields => {'isActive', 'lastUsedAt'};
  @override
  Map<String, dynamic> get indexFields => {
        'userId': _k.userId,
        'tenantId': _k.tenantId,
        'keyHash': _k.keyHash,
        'isActive': _k.isActive,
      };
  static StorableApiKey fromMap(Map<String, dynamic> m) =>
      StorableApiKey(AqApiKey.fromJson(m));

  @override
  // TODO: implement collectionName
  String get collectionName => SecurityCollections.apiKeys;
}
```

### Файл: `./lib/security/token/token_codec.dart` (строк:      124, размер:     4516 байт)

```dart
// pkgs/aq_schema/lib/security/token/token_codec.dart
//
// Pure Dart JWT implementation (HS256).
// Used on BOTH client (decode/verify) and server (sign/verify).
// No external JWT library — only dart:convert and dart:typed_data.
// HMAC-SHA256 requires the 'crypto' package (pure Dart, no native code).
//
// Dependencies: crypto (^3.0.0)

import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

import '../models/aq_token_claims.dart';

/// Low-level JWT codec. Use [TokenValidator] for full validation.
final class TokenCodec {
  const TokenCodec({required this.secret});

  final String secret;

  // ── Encode ────────────────────────────────────────────────────────────────

  /// Sign claims and return compact JWT string.
  String encode(AqTokenClaims claims) {
    final header = _b64({'alg': 'HS256', 'typ': 'JWT'});
    final payload = _b64(claims.toJson());
    final message = '$header.$payload';
    final sig = _sign(message);
    return '$message.$sig';
  }

  // ── Decode ────────────────────────────────────────────────────────────────

  /// Decode without verifying signature. Use [decode] for trusted decode.
  static AqTokenClaims decodeUnverified(String token) {
    final parts = token.split('.');
    if (parts.length != 3) throw const TokenFormatException('Invalid JWT structure');
    final payload = _fromB64(parts[1]);
    return AqTokenClaims.fromJson(payload);
  }

  /// Decode and verify signature. Throws [TokenException] on failure.
  AqTokenClaims decode(String token) {
    final parts = token.split('.');
    if (parts.length != 3) throw const TokenFormatException('Invalid JWT structure');

    // Verify signature
    final message = '${parts[0]}.${parts[1]}';
    final expectedSig = _sign(message);
    if (!_constantTimeEquals(expectedSig, parts[2])) {
      throw const TokenSignatureException('Invalid token signature');
    }

    final payload = _fromB64(parts[1]);
    return AqTokenClaims.fromJson(payload);
  }

  // ── Private ───────────────────────────────────────────────────────────────

  String _sign(String message) {
    final key = utf8.encode(secret);
    final bytes = utf8.encode(message);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(bytes);
    return _base64UrlEncode(Uint8List.fromList(digest.bytes));
  }

  static String _b64(Map<String, dynamic> data) {
    final json = jsonEncode(data);
    return _base64UrlEncode(utf8.encode(json) as Uint8List);
  }

  static Map<String, dynamic> _fromB64(String b64) {
    final normalized = b64.padRight(
      b64.length + (4 - b64.length % 4) % 4,
      '=',
    );
    final decoded = base64Url.decode(normalized);
    return jsonDecode(utf8.decode(decoded)) as Map<String, dynamic>;
  }

  static String _base64UrlEncode(Uint8List bytes) =>
      base64Url.encode(bytes).replaceAll('=', '');

  /// Constant-time string comparison — prevents timing attacks.
  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }
}

// ── Exceptions ────────────────────────────────────────────────────────────────

sealed class TokenException implements Exception {
  const TokenException(this.message);
  final String message;
  @override
  String toString() => '$runtimeType: $message';
}

final class TokenFormatException extends TokenException {
  const TokenFormatException(super.message);
}

final class TokenSignatureException extends TokenException {
  const TokenSignatureException(super.message);
}

final class TokenExpiredException extends TokenException {
  const TokenExpiredException(super.message);
}

final class TokenRevokedException extends TokenException {
  const TokenRevokedException(super.message);
}

final class TokenInvalidTypeException extends TokenException {
  const TokenInvalidTypeException(super.message);
}
```

### Файл: `./lib/security/token/token_validator.dart` (строк:       95, размер:     2901 байт)

```dart
// pkgs/aq_schema/lib/security/token/token_validator.dart
//
// Shared token validation logic. Pure Dart.
// Used identically on client (verify incoming tokens),
// server (validate before processing),
// and worker (check auth before executing jobs).
//
// The validator does NOT check revocation — that requires DB access
// and lives in the server layer (SecurityServer.validateToken).
// Clients and workers call POST /auth/validate for full validation.

import '../models/aq_token_claims.dart';
import 'token_codec.dart';

enum ValidationFailure {
  malformed,
  invalidSignature,
  expired,
  wrongType,
}

final class ValidationResult {
  const ValidationResult._({
    required this.valid,
    this.claims,
    this.failure,
    this.message,
  });

  factory ValidationResult.ok(AqTokenClaims claims) =>
      ValidationResult._(valid: true, claims: claims);

  factory ValidationResult.fail(ValidationFailure failure, String message) =>
      ValidationResult._(valid: false, failure: failure, message: message);

  final bool valid;
  final AqTokenClaims? claims;
  final ValidationFailure? failure;
  final String? message;

  /// Throws [TokenException] if not valid.
  AqTokenClaims get claimsOrThrow {
    if (!valid || claims == null) {
      throw TokenFormatException(message ?? 'Token validation failed');
    }
    return claims!;
  }
}

/// Stateless token validator. Shared across all nodes.
final class TokenValidator {
  const TokenValidator({required this.codec});

  final TokenCodec codec;

  /// Validate access token signature and expiry.
  ValidationResult validateAccess(String token) =>
      _validate(token, expectedType: TokenType.access);

  /// Validate refresh token signature and expiry.
  ValidationResult validateRefresh(String token) =>
      _validate(token, expectedType: TokenType.refresh);

  /// Validate any token type.
  ValidationResult validate(String token) => _validate(token);

  ValidationResult _validate(String token, {TokenType? expectedType}) {
    AqTokenClaims claims;
    try {
      claims = codec.decode(token);
    } on TokenSignatureException catch (e) {
      return ValidationResult.fail(ValidationFailure.invalidSignature, e.message);
    } on TokenFormatException catch (e) {
      return ValidationResult.fail(ValidationFailure.malformed, e.message);
    } catch (e) {
      return ValidationResult.fail(ValidationFailure.malformed, e.toString());
    }

    if (claims.isExpired) {
      return ValidationResult.fail(
        ValidationFailure.expired,
        'Token expired at ${DateTime.fromMillisecondsSinceEpoch(claims.exp * 1000)}',
      );
    }

    if (expectedType != null && claims.type != expectedType) {
      return ValidationResult.fail(
        ValidationFailure.wrongType,
        'Expected ${expectedType.value} token, got ${claims.type.value}',
      );
    }

    return ValidationResult.ok(claims);
  }
}
```

### Файл: `./lib/studio_project/aq_studio_project.dart` (строк:       77, размер:     1946 байт)

```dart
import 'package:aq_schema/aq_schema.dart';

/// AQ Studio project — top-level container.
/// DirectStorable: plain CRUD, no versioning needed.
class AqStudioProject implements DirectStorable {
  static const kCollection = 'projects';

  @override
  final String id;

  @override
  String get collectionName => kCollection;

  final String name;
  final String path;
  final String projectType;
  final DateTime lastOpened;

  const AqStudioProject({
    required this.id,
    required this.name,
    required this.path,
    required this.projectType,
    required this.lastOpened,
  });

  factory AqStudioProject.create({
    required String id,
    required String name,
    required String projectType,
  }) =>
      AqStudioProject(
        id: id,
        name: name,
        path: '',
        projectType: projectType,
        lastOpened: DateTime.now(),
      );

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'path': path,
        'projectType': projectType,
        'lastOpened': lastOpened.toIso8601String(),
      };

  @override
  Map<String, dynamic> get indexFields => {
        'projectType': projectType,
        'lastOpened': lastOpened.toIso8601String(),
      };

  static AqStudioProject fromMap(Map<String, dynamic> m) => AqStudioProject(
        id: m['id'] as String,
        name: m['name'] as String? ?? '',
        path: m['path'] as String? ?? '',
        projectType: m['projectType'] as String? ?? 'coder',
        lastOpened:
            DateTime.tryParse(m['lastOpened'] as String? ?? '') ?? DateTime.now(),
      );

  AqStudioProject copyWith({
    String? name,
    String? path,
    String? projectType,
    DateTime? lastOpened,
  }) =>
      AqStudioProject(
        id: id,
        name: name ?? this.name,
        path: path ?? this.path,
        projectType: projectType ?? this.projectType,
        lastOpened: lastOpened ?? this.lastOpened,
      );
}
```

### Файл: `./lib/validator/aq_schema_validator.dart` (строк:       50, размер:     1680 байт)

```dart
import 'dart:convert';
import 'package:aq_schema/validator/aq_validation_result.dart';
import 'package:json_schema/json_schema.dart';

enum AqSchemaType { ui, mcp, workflow }

class AqSchemaValidator {
  static final Map<String, JsonSchema> _cache = {};

  /// Провалидировать данные против схемы.
  static Future<AqValidationResult> validate(
    Map<String, dynamic> data, {
    AqSchemaType type = AqSchemaType.ui,
    String version = '2.0.0',
  }) async {
    final schemaJson = await _loadSchema(type, version);
    final schema = _cache[_cacheKey(type, version)] ??= JsonSchema.create(
      schemaJson,
    );

    final results = schema.validate(data, parseJson: false);
    return AqValidationResult(
      isValid: results.isValid,
      detectedVersion: version,
      errors: results.errors
          .map((e) => AqValidationError(path: e.schemaPath, message: e.message))
          .toList(),
    );
  }

  /// Автоопределение версии из поля 'version' или '$schema'.
  static Future<AqValidationResult> validateAuto(
    Map<String, dynamic> data,
  ) async {
    final version = data['version'] as String? ?? '2.0.0';
    return validate(data, version: version);
  }

  static String _cacheKey(AqSchemaType type, String version) =>
      '${type.name}:$version';

  static Future<Map<String, dynamic>> _loadSchema(
    AqSchemaType type,
    String version,
  ) async {
    // В Dart-пакете — читаем из assets или встроенной строки
    // В тестах — читаем с диска
    throw UnimplementedError('Implement schema loading for your platform');
  }
}
```

### Файл: `./lib/validator/aq_validation_result.dart` (строк:       20, размер:      449 байт)

```dart
class AqValidationResult {
  final bool isValid;
  final String? detectedVersion;
  final List<AqValidationError> errors;
  final List<String> warnings;

  const AqValidationResult({
    required this.isValid,
    this.detectedVersion,
    this.errors = const [],
    this.warnings = const [],
  });
}

class AqValidationError {
  final String path;
  final String message;

  const AqValidationError({required this.path, required this.message});
}
```

### Файл: `./lib/worker/models/worker_models.dart` (строк:      448, размер:    13951 байт)

```dart
/// Worker domain models — the job contract between adapter and workers.
library;

import 'package:aq_schema/auth/models/auth_context.dart';
import 'package:aq_schema/mcp/models/mcp_tool.dart';

// ══════════════════════════════════════════════════════════
//  Enums
// ══════════════════════════════════════════════════════════

/// Terminal and intermediate job statuses.
enum JobStatus {
  pending('pending'),
  running('running'),
  done('done'),
  failed('failed'),
  timeout('timeout');

  const JobStatus(this.value);
  final String value;

  bool get isTerminal =>
      this == JobStatus.done ||
      this == JobStatus.failed ||
      this == JobStatus.timeout;

  static JobStatus fromString(String s) => JobStatus.values.firstWhere(
    (e) => e.value == s,
    orElse: () => JobStatus.failed,
  );
}

/// Worker health status.
enum WorkerStatus {
  healthy('healthy'),
  degraded('degraded'),
  unhealthy('unhealthy');

  const WorkerStatus(this.value);
  final String value;

  static WorkerStatus fromString(String s) => WorkerStatus.values.firstWhere(
    (e) => e.value == s,
    orElse: () => WorkerStatus.unhealthy,
  );
}

/// Error type categories for result normalization.
enum WorkerErrorType {
  executionError('execution_error'),
  validationError('validation_error'),
  authError('auth_error'),
  timeout('timeout'),
  internal('internal');

  const WorkerErrorType(this.value);
  final String value;

  static WorkerErrorType fromString(String s) => WorkerErrorType.values
      .firstWhere((e) => e.value == s, orElse: () => WorkerErrorType.internal);
}

// ══════════════════════════════════════════════════════════
//  JobMeta
// ══════════════════════════════════════════════════════════

/// Metadata attached to every job by the adapter.
final class JobMeta {
  const JobMeta({
    this.timeoutMs = 30000,
    this.retryCount = 0,
    this.maxRetries = 1,
    this.mode = 'sync',
    this.sourceRequestId,
  });

  factory JobMeta.fromJson(Map<String, dynamic> json) => JobMeta(
    timeoutMs: (json['timeout_ms'] as int?) ?? 30000,
    retryCount: (json['retry_count'] as int?) ?? 0,
    maxRetries: (json['max_retries'] as int?) ?? 1,
    mode: (json['mode'] as String?) ?? 'sync',
    sourceRequestId: json['source_request_id'] as String?,
  );

  final int timeoutMs;
  final int retryCount;
  final int maxRetries;
  final String mode;
  final String? sourceRequestId;

  bool get canRetry => retryCount < maxRetries;
  Duration get timeout => Duration(milliseconds: timeoutMs);

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'timeout_ms': timeoutMs,
      'retry_count': retryCount,
      'max_retries': maxRetries,
      'mode': mode,
    };
    if (sourceRequestId != null) map['source_request_id'] = sourceRequestId;
    return map;
  }
}

// ══════════════════════════════════════════════════════════
//  WorkerJob — the job contract
// ══════════════════════════════════════════════════════════

/// Abstract interface for a job passed through the queue.
abstract interface class WorkerJob {
  String get jobId;
  String get tool;
  Map<String, dynamic> get payload;
  AuthContext? get auth;
  JobMeta? get meta;
}

/// Concrete job implementation placed in Redis queue by adapter.
final class WorkerJobImpl implements WorkerJob {
  const WorkerJobImpl({
    required this.jobId,
    required this.tool,
    required this.payload,
    required this.createdAt,
    this.auth,
    this.meta,
  });

  factory WorkerJobImpl.fromJson(Map<String, dynamic> json) {
    final authRaw = json['auth'] as Map<String, dynamic>?;
    final metaRaw = json['meta'] as Map<String, dynamic>?;
    return WorkerJobImpl(
      jobId: json['job_id'] as String,
      tool: json['tool'] as String,
      payload: json['payload'] as Map<String, dynamic>,
      createdAt: json['created_at'] as int,
      auth: authRaw != null ? AuthContext.fromJson(authRaw) : null,
      meta: metaRaw != null ? JobMeta.fromJson(metaRaw) : null,
    );
  }

  @override
  final String jobId;

  @override
  final String tool;

  @override
  final Map<String, dynamic> payload;

  @override
  final AuthContext? auth;

  @override
  final JobMeta? meta;

  final int createdAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'job_id': jobId,
      'tool': tool,
      'payload': payload,
      'created_at': createdAt,
    };
    if (auth != null) map['auth'] = auth!.toJson();
    if (meta != null) map['meta'] = meta!.toJson();
    return map;
  }

  @override
  String toString() => 'WorkerJob(id: $jobId, tool: $tool)';
}

// ══════════════════════════════════════════════════════════
//  WorkerError
// ══════════════════════════════════════════════════════════

/// Normalized error from a worker.
final class WorkerError {
  const WorkerError({
    required this.code,
    required this.message,
    required this.type,
  });

  factory WorkerError.fromJson(Map<String, dynamic> json) => WorkerError(
    code: json['code'] as int,
    message: json['message'] as String,
    type: WorkerErrorType.fromString(json['type'] as String),
  );

  final int code;
  final String message;
  final WorkerErrorType type;

  Map<String, dynamic> toJson() => {
    'code': code,
    'message': message,
    'type': type.value,
  };

  static WorkerError executionFailed(String message) => WorkerError(
    code: -32000,
    message: message,
    type: WorkerErrorType.executionError,
  );

  static WorkerError validationFailed(String message) => WorkerError(
    code: -32602,
    message: message,
    type: WorkerErrorType.validationError,
  );

  static WorkerError timedOut() => WorkerError(
    code: -32001,
    message: 'Worker timeout',
    type: WorkerErrorType.timeout,
  );

  @override
  String toString() => 'WorkerError(code: $code, type: ${type.value})';
}

// ══════════════════════════════════════════════════════════
//  WorkerResult — abstract interface and impl
// ══════════════════════════════════════════════════════════

/// Abstract interface for a job execution result.
abstract interface class WorkerResult {
  String get jobId;
  JobStatus get status;
  Map<String, dynamic>? get result;
  WorkerError? get error;
}

/// Concrete worker result written to Redis result store.
final class WorkerResultImpl implements WorkerResult {
  const WorkerResultImpl({
    required this.jobId,
    required this.status,
    required this.completedAt,
    this.result,
    this.error,
    this.durationMs,
  });

  factory WorkerResultImpl.fromJson(Map<String, dynamic> json) {
    final errorRaw = json['error'] as Map<String, dynamic>?;
    final resultRaw = json['result'] as Map<String, dynamic>?;
    return WorkerResultImpl(
      jobId: json['job_id'] as String,
      status: JobStatus.fromString(json['status'] as String),
      completedAt: json['completed_at'] as int,
      result: resultRaw,
      error: errorRaw != null ? WorkerError.fromJson(errorRaw) : null,
      durationMs: json['duration_ms'] as int?,
    );
  }

  @override
  final String jobId;

  @override
  final JobStatus status;

  @override
  final Map<String, dynamic>? result;

  @override
  final WorkerError? error;

  final int completedAt;
  final int? durationMs;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'job_id': jobId,
      'status': status.value,
      'completed_at': completedAt,
    };
    if (result != null) map['result'] = result;
    if (error != null) map['error'] = error!.toJson();
    if (durationMs != null) map['duration_ms'] = durationMs;
    return map;
  }

  static WorkerResultImpl success({
    required String jobId,
    required Map<String, dynamic> result,
    int? durationMs,
  }) => WorkerResultImpl(
    jobId: jobId,
    status: JobStatus.done,
    completedAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    result: result,
    durationMs: durationMs,
  );

  static WorkerResultImpl failure({
    required String jobId,
    required WorkerError error,
    int? durationMs,
  }) => WorkerResultImpl(
    jobId: jobId,
    status: JobStatus.failed,
    completedAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    error: error,
    durationMs: durationMs,
  );

  static WorkerResultImpl timedOut(String jobId) => WorkerResultImpl(
    jobId: jobId,
    status: JobStatus.timeout,
    completedAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    error: WorkerError.timedOut(),
  );

  @override
  String toString() => 'WorkerResult(id: $jobId, status: ${status.value})';
}

// ══════════════════════════════════════════════════════════
//  WorkerCapabilities
// ══════════════════════════════════════════════════════════

/// Declared capabilities of a worker.
final class WorkerCapabilities {
  const WorkerCapabilities({
    required this.async,
    required this.concurrency,
    this.streaming = false,
  });

  factory WorkerCapabilities.fromJson(Map<String, dynamic> json) =>
      WorkerCapabilities(
        async: json['async'] as bool,
        concurrency: json['concurrency'] as int,
        streaming: (json['streaming'] as bool?) ?? false,
      );

  final bool async;
  final int concurrency;
  final bool streaming;

  Map<String, dynamic> toJson() => {
    'async': async,
    'concurrency': concurrency,
    'streaming': streaming,
  };
}

// ══════════════════════════════════════════════════════════
//  WorkerRegistration
// ══════════════════════════════════════════════════════════

/// Registration payload sent by worker on startup.
final class WorkerRegistration {
  const WorkerRegistration({
    required this.workerId,
    required this.tools,
    required this.capabilities,
    this.meta,
  });

  factory WorkerRegistration.fromJson(Map<String, dynamic> json) {
    final toolsList = json['tools'] as List<dynamic>;
    final metaRaw = json['meta'] as Map<String, dynamic>?;
    return WorkerRegistration(
      workerId: json['worker_id'] as String,
      tools: toolsList
          .map((t) => McpToolImpl.fromJson(t as Map<String, dynamic>))
          .toList(),
      capabilities: WorkerCapabilities.fromJson(
        json['capabilities'] as Map<String, dynamic>,
      ),
      meta: metaRaw,
    );
  }

  final String workerId;
  final List<McpToolImpl> tools;
  final WorkerCapabilities capabilities;
  final Map<String, dynamic>? meta;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'worker_id': workerId,
      'tools': tools.map((t) => t.toJson()).toList(),
      'capabilities': capabilities.toJson(),
    };
    if (meta != null) map['meta'] = meta;
    return map;
  }

  @override
  String toString() =>
      'WorkerRegistration(id: $workerId, tools: ${tools.map((t) => t.name).toList()})';
}

// ══════════════════════════════════════════════════════════
//  WorkerHealth
// ══════════════════════════════════════════════════════════

/// Periodic health report from worker.
final class WorkerHealth {
  const WorkerHealth({
    required this.workerId,
    required this.status,
    required this.timestamp,
    this.activeJobs = 0,
    this.queueDepth = 0,
    this.uptimeSeconds,
  });

  factory WorkerHealth.fromJson(Map<String, dynamic> json) => WorkerHealth(
    workerId: json['worker_id'] as String,
    status: WorkerStatus.fromString(json['status'] as String),
    timestamp: json['timestamp'] as int,
    activeJobs: (json['active_jobs'] as int?) ?? 0,
    queueDepth: (json['queue_depth'] as int?) ?? 0,
    uptimeSeconds: json['uptime_seconds'] as int?,
  );

  final String workerId;
  final WorkerStatus status;
  final int timestamp;
  final int activeJobs;
  final int queueDepth;
  final int? uptimeSeconds;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'worker_id': workerId,
      'status': status.value,
      'timestamp': timestamp,
      'active_jobs': activeJobs,
      'queue_depth': queueDepth,
    };
    if (uptimeSeconds != null) map['uptime_seconds'] = uptimeSeconds;
    return map;
  }

  @override
  String toString() =>
      'WorkerHealth(id: $workerId, status: ${status.value}, active: $activeJobs)';
}
```

### Файл: `./lib/worker/validators/worker_validator.dart` (строк:      209, размер:     7416 байт)

```dart
/// Worker protocol validator.
///
/// Validates worker registration, job, result and health objects
/// against the rules defined in worker/schemas/*.json files.
library;

import 'package:aq_schema/mcp/validators/mcp_validator.dart';

import '../models/worker_models.dart';

/// Validates worker protocol JSON objects.
abstract final class WorkerValidator {
  // ── WorkerRegistration ────────────────────────────────

  /// Validates a raw worker registration map.
  static ValidationResult validateRegistration(Map<String, dynamic> json) {
    final errors = <String>[];

    final workerId = json['worker_id'];
    if (workerId == null || workerId is! String || workerId.isEmpty) {
      errors.add('worker_id is required and must be a non-empty string');
    } else if (!RegExp(r'^[a-z][a-z0-9-]*$').hasMatch(workerId)) {
      errors.add(
        'worker_id must match ^[a-z][a-z0-9-]*\$ (kebab-case), got: $workerId',
      );
    } else if (workerId.length > 64) {
      errors.add('worker_id must be at most 64 characters');
    }

    final tools = json['tools'];
    if (tools == null || tools is! List || (tools as List).isEmpty) {
      errors.add('tools is required and must be a non-empty array');
    } else {
      for (var i = 0; i < tools.length; i++) {
        final tool = tools[i];
        if (tool is! Map<String, dynamic>) {
          errors.add('tools[$i] must be an object');
          continue;
        }
        final toolResult = McpValidator.validateTool(tool);
        if (!toolResult.isValid) {
          errors.addAll(toolResult.errors.map((e) => 'tools[$i]: $e'));
        }
      }
    }

    final capabilities = json['capabilities'];
    if (capabilities == null || capabilities is! Map) {
      errors.add('capabilities is required and must be an object');
    } else {
      if (capabilities['async'] == null || capabilities['async'] is! bool) {
        errors.add('capabilities.async is required and must be a boolean');
      }
      final concurrency = capabilities['concurrency'];
      if (concurrency == null || concurrency is! int || concurrency < 1) {
        errors.add(
          'capabilities.concurrency is required and must be an integer >= 1',
        );
      }
    }

    return errors.isEmpty
        ? const ValidationResult.ok()
        : ValidationResult.fail(errors);
  }

  /// Validates a [WorkerRegistration] instance.
  static ValidationResult validateWorkerRegistration(WorkerRegistration reg) =>
      validateRegistration(reg.toJson());

  // ── WorkerJob ─────────────────────────────────────────

  /// Validates a raw job map.
  static ValidationResult validateJob(Map<String, dynamic> json) {
    final errors = <String>[];

    final jobId = json['job_id'];
    if (jobId == null || jobId is! String || jobId.isEmpty) {
      errors.add('job_id is required');
    }

    final tool = json['tool'];
    if (tool == null || tool is! String || tool.isEmpty) {
      errors.add('tool is required and must be a string');
    } else if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(tool)) {
      errors.add('tool must match ^[a-z][a-z0-9_]*\$');
    }

    if (json['payload'] == null || json['payload'] is! Map) {
      errors.add('payload is required and must be an object');
    }

    if (json['created_at'] == null || json['created_at'] is! int) {
      errors.add(
        'created_at is required and must be an integer (Unix seconds)',
      );
    }

    final meta = json['meta'] as Map<String, dynamic>?;
    if (meta != null) {
      final mode = meta['mode'] as String?;
      if (mode != null && mode != 'sync' && mode != 'async') {
        errors.add('meta.mode must be "sync" or "async"');
      }
      final timeout = meta['timeout_ms'];
      if (timeout != null && (timeout is! int || timeout < 0)) {
        errors.add('meta.timeout_ms must be a non-negative integer');
      }
    }

    return errors.isEmpty
        ? const ValidationResult.ok()
        : ValidationResult.fail(errors);
  }

  /// Validates a [WorkerJobImpl] instance.
  static ValidationResult validateWorkerJob(WorkerJobImpl job) =>
      validateJob(job.toJson());

  // ── WorkerResult ──────────────────────────────────────

  /// Validates a raw result map.
  static ValidationResult validateResult(Map<String, dynamic> json) {
    final errors = <String>[];

    final jobId = json['job_id'];
    if (jobId == null || jobId is! String || jobId.isEmpty) {
      errors.add('job_id is required');
    }

    final status = json['status'] as String?;
    const terminal = {'done', 'failed', 'timeout'};
    if (status == null || !terminal.contains(status)) {
      errors.add('status must be one of: ${terminal.join(', ')}');
    }

    if (json['completed_at'] == null || json['completed_at'] is! int) {
      errors.add('completed_at is required and must be an integer');
    }

    if (status == 'done' && json['result'] == null) {
      errors.add('result is required when status is "done"');
    }

    if ((status == 'failed' || status == 'timeout') && json['error'] == null) {
      errors.add('error is required when status is "failed" or "timeout"');
    }

    if (json['error'] != null) {
      final error = json['error'] as Map<String, dynamic>?;
      if (error == null) {
        errors.add('error must be an object');
      } else {
        if (error['code'] is! int) errors.add('error.code must be an integer');
        if (error['message'] is! String) {
          errors.add('error.message must be a string');
        }
        const validTypes = {
          'execution_error',
          'validation_error',
          'auth_error',
          'timeout',
          'internal',
        };
        if (!validTypes.contains(error['type'])) {
          errors.add('error.type must be one of: ${validTypes.join(', ')}');
        }
      }
    }

    return errors.isEmpty
        ? const ValidationResult.ok()
        : ValidationResult.fail(errors);
  }

  /// Validates a [WorkerResultImpl] instance.
  static ValidationResult validateWorkerResult(WorkerResultImpl result) =>
      validateResult(result.toJson());

  // ── WorkerHealth ──────────────────────────────────────

  /// Validates a raw health check map.
  static ValidationResult validateHealth(Map<String, dynamic> json) {
    final errors = <String>[];

    final workerId = json['worker_id'];
    if (workerId == null || workerId is! String || workerId.isEmpty) {
      errors.add('worker_id is required');
    }

    const validStatuses = {'healthy', 'degraded', 'unhealthy'};
    final status = json['status'] as String?;
    if (status == null || !validStatuses.contains(status)) {
      errors.add('status must be one of: ${validStatuses.join(', ')}');
    }

    if (json['timestamp'] == null || json['timestamp'] is! int) {
      errors.add('timestamp is required and must be an integer');
    }

    return errors.isEmpty
        ? const ValidationResult.ok()
        : ValidationResult.fail(errors);
  }

  /// Validates a [WorkerHealth] instance.
  static ValidationResult validateWorkerHealth(WorkerHealth health) =>
      validateHealth(health.toJson());
}
```

### Файл: `./pubspec.yaml` (строк:       16, размер:      306 байт)

```yaml
name: aq_schema
description: A sample command-line application.
version: 1.0.0
# repository: https://github.com/my_org/my_repo

environment:
  sdk: ^3.5.4

# Add regular dependencies here.
dependencies:
  path: ^1.9.0
  json_schema: ^5.0.0
  meta: ^1.17.0
dev_dependencies:
  lints: ^6.0.0
  test: ^1.25.6
```

### Файл: `./README.md` (строк:        2, размер:      122 байт)

```markdown
A sample command-line application with an entrypoint in `bin/`, library code
in `lib/`, and example unit test in `test/`.
```

---
**Суммарно строк в включённых файлах:** 8589
**Суммарный размер включённых файлов:** 290596 байт (~283 КБ)
