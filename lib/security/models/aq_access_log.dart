// pkgs/aq_schema/lib/security/models/aq_access_log.dart
//
// Модель для журнала доступа к ресурсам.
// Используется для аудита попыток доступа (успешных и неуспешных).

/// Запись в журнале доступа к ресурсам
///
/// Каждая попытка доступа к защищённому ресурсу должна логироваться.
/// Backend должен сохранять эти записи для аудита и анализа безопасности.
final class AqAccessLog {
  const AqAccessLog({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.tenantId,
    required this.resource,
    required this.action,
    required this.allowed,
    required this.timestamp,
    this.reason,
    this.ipAddress,
    this.userAgent,
    this.metadata,
  });

  static const String kCollection = 'rbac_access_logs';

  /// Уникальный ID записи лога
  final String id;

  /// ID пользователя, который пытался получить доступ
  final String userId;

  /// Email пользователя (для удобства отображения в UI)
  final String userEmail;

  /// ID тенанта, в контексте которого происходила попытка доступа
  final String tenantId;

  /// Ресурс, к которому запрашивался доступ
  /// Формат: "resourceType:resourceId" (например, "project:abc123", "graph:xyz789")
  final String resource;

  /// Действие, которое пытались выполнить
  /// Примеры: "read", "write", "delete", "execute", "admin"
  final String action;

  /// Был ли доступ разрешён
  /// true = доступ разрешён, false = доступ запрещён
  final bool allowed;

  /// Причина решения (особенно важна для denied)
  /// Примеры:
  /// - "Insufficient permissions"
  /// - "Policy denied: IP not in whitelist"
  /// - "Role 'admin' required"
  /// - "Resource not found"
  final String? reason;

  /// Unix timestamp (секунды) когда произошла попытка доступа
  final int timestamp;

  /// IP адрес, с которого была попытка доступа
  final String? ipAddress;

  /// User-Agent браузера/клиента
  final String? userAgent;

  /// Дополнительные метаданные (контекст запроса, примененные политики и т.д.)
  /// Примеры полей:
  /// - "appliedPolicies": ["policy-id-1", "policy-id-2"]
  /// - "requestId": "req-123"
  /// - "sessionId": "sess-456"
  /// - "evaluationTimeMs": 15
  final Map<String, dynamic>? metadata;

  factory AqAccessLog.fromJson(Map<String, dynamic> json) => AqAccessLog(
        id: json['id'] as String,
        userId: json['userId'] as String,
        userEmail: json['userEmail'] as String,
        tenantId: json['tenantId'] as String,
        resource: json['resource'] as String,
        action: json['action'] as String,
        allowed: json['allowed'] as bool,
        timestamp: json['timestamp'] as int,
        reason: json['reason'] as String?,
        ipAddress: json['ipAddress'] as String?,
        userAgent: json['userAgent'] as String?,
        metadata: json['metadata'] as Map<String, dynamic>?,
      );

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'id': id,
      'userId': userId,
      'userEmail': userEmail,
      'tenantId': tenantId,
      'resource': resource,
      'action': action,
      'allowed': allowed,
      'timestamp': timestamp,
    };
    if (reason != null) m['reason'] = reason;
    if (ipAddress != null) m['ipAddress'] = ipAddress;
    if (userAgent != null) m['userAgent'] = userAgent;
    if (metadata != null) m['metadata'] = metadata;
    return m;
  }

  DateTime get timestampAsDateTime =>
      DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
}

/// Фильтр для запроса логов доступа
///
/// Backend должен поддерживать фильтрацию по всем этим полям.
/// Все поля опциональны - если не указаны, фильтр не применяется.
class AccessLogFilter {
  const AccessLogFilter({
    this.userId,
    this.tenantId,
    this.resource,
    this.action,
    this.allowed,
    this.startTime,
    this.endTime,
    this.ipAddress,
    this.limit = 100,
    this.offset = 0,
  });

  /// Фильтр по пользователю
  final String? userId;

  /// Фильтр по тенанту
  final String? tenantId;

  /// Фильтр по ресурсу (поддерживает wildcard: "project:*")
  final String? resource;

  /// Фильтр по действию
  final String? action;

  /// Фильтр по результату (null = все, true = только разрешённые, false = только запрещённые)
  final bool? allowed;

  /// Начало временного диапазона (Unix timestamp в секундах)
  final int? startTime;

  /// Конец временного диапазона (Unix timestamp в секундах)
  final int? endTime;

  /// Фильтр по IP адресу
  final String? ipAddress;

  /// Максимальное количество записей (pagination)
  final int limit;

  /// Смещение для pagination
  final int offset;

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'limit': limit,
      'offset': offset,
    };
    if (userId != null) m['userId'] = userId;
    if (tenantId != null) m['tenantId'] = tenantId;
    if (resource != null) m['resource'] = resource;
    if (action != null) m['action'] = action;
    if (allowed != null) m['allowed'] = allowed;
    if (startTime != null) m['startTime'] = startTime;
    if (endTime != null) m['endTime'] = endTime;
    if (ipAddress != null) m['ipAddress'] = ipAddress;
    return m;
  }
}
