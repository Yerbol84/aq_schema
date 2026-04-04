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
