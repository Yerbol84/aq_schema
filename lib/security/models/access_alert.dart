// pkgs/aq_schema/lib/security/models/access_alert.dart
//
// Модель алерта о подозрительной активности в системе безопасности.

/// Тип алерта
enum AlertType {
  suspiciousActivity('suspicious_activity'),
  rateLimit('rate_limit'),
  policyViolation('policy_violation'),
  roleExpiring('role_expiring'),
  privilegeEscalation('privilege_escalation'),
  unusualAccess('unusual_access'),
  failedAuthentication('failed_authentication'),
  dataExfiltration('data_exfiltration');

  const AlertType(this.value);
  final String value;

  static AlertType fromString(String s) =>
      AlertType.values.firstWhere((e) => e.value == s);
}

/// Уровень серьёзности алерта
enum AlertSeverity {
  low('low'),
  medium('medium'),
  high('high'),
  critical('critical');

  const AlertSeverity(this.value);
  final String value;

  static AlertSeverity fromString(String s) =>
      AlertSeverity.values.firstWhere((e) => e.value == s);
}

/// Алерт о подозрительной активности
///
/// Генерируется системой безопасности при обнаружении подозрительных действий.
/// Используется для мониторинга и реагирования на угрозы безопасности.
final class AccessAlert {
  const AccessAlert({
    required this.id,
    required this.type,
    required this.severity,
    required this.title,
    required this.description,
    required this.userId,
    required this.userEmail,
    required this.tenantId,
    required this.timestamp,
    this.resource,
    this.action,
    this.ipAddress,
    this.metadata,
    this.resolved = false,
    this.resolvedAt,
    this.resolvedBy,
    this.resolution,
  });

  static const String kCollection = 'rbac_alerts';

  /// Уникальный ID алерта
  final String id;

  /// Тип алерта
  final AlertType type;

  /// Уровень серьёзности
  final AlertSeverity severity;

  /// Заголовок алерта (краткое описание)
  /// Примеры:
  /// - "Suspicious login from new location"
  /// - "Rate limit exceeded"
  /// - "Privilege escalation attempt"
  final String title;

  /// Детальное описание алерта
  /// Примеры:
  /// - "User attempted to access admin panel from IP 192.168.1.100, which is outside the allowed range"
  /// - "User made 100 requests in 1 minute, exceeding the limit of 60 requests/minute"
  final String description;

  /// ID пользователя, связанного с алертом
  final String userId;

  /// Email пользователя (для удобства отображения)
  final String userEmail;

  /// ID тенанта
  final String tenantId;

  /// Unix timestamp (секунды) когда был создан алерт
  final int timestamp;

  /// Ресурс, связанный с алертом (опционально)
  final String? resource;

  /// Действие, связанное с алертом (опционально)
  final String? action;

  /// IP адрес, с которого произошло событие
  final String? ipAddress;

  /// Дополнительные метаданные
  /// Примеры полей:
  /// - "attemptCount": 5
  /// - "timeWindow": "1 minute"
  /// - "previousIPs": ["192.168.1.1", "192.168.1.2"]
  /// - "requestIds": ["req-1", "req-2"]
  final Map<String, dynamic>? metadata;

  /// Был ли алерт разрешён (обработан)
  final bool resolved;

  /// Unix timestamp (секунды) когда алерт был разрешён
  final int? resolvedAt;

  /// ID пользователя, который разрешил алерт
  final String? resolvedBy;

  /// Описание разрешения (что было сделано)
  /// Примеры:
  /// - "False positive - user was traveling"
  /// - "User account suspended"
  /// - "IP added to whitelist"
  final String? resolution;

  DateTime get timestampAsDateTime =>
      DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

  DateTime? get resolvedAtAsDateTime => resolvedAt != null
      ? DateTime.fromMillisecondsSinceEpoch(resolvedAt! * 1000)
      : null;

  AccessAlert copyWith({
    String? id,
    AlertType? type,
    AlertSeverity? severity,
    String? title,
    String? description,
    String? userId,
    String? userEmail,
    String? tenantId,
    int? timestamp,
    String? resource,
    String? action,
    String? ipAddress,
    Map<String, dynamic>? metadata,
    bool? resolved,
    int? resolvedAt,
    String? resolvedBy,
    String? resolution,
  }) {
    return AccessAlert(
      id: id ?? this.id,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      title: title ?? this.title,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      tenantId: tenantId ?? this.tenantId,
      timestamp: timestamp ?? this.timestamp,
      resource: resource ?? this.resource,
      action: action ?? this.action,
      ipAddress: ipAddress ?? this.ipAddress,
      metadata: metadata ?? this.metadata,
      resolved: resolved ?? this.resolved,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      resolution: resolution ?? this.resolution,
    );
  }

  factory AccessAlert.fromJson(Map<String, dynamic> json) => AccessAlert(
        id: json['id'] as String,
        type: AlertType.fromString(json['type'] as String),
        severity: AlertSeverity.fromString(json['severity'] as String),
        title: json['title'] as String,
        description: json['description'] as String,
        userId: json['userId'] as String,
        userEmail: json['userEmail'] as String,
        tenantId: json['tenantId'] as String,
        timestamp: json['timestamp'] as int,
        resource: json['resource'] as String?,
        action: json['action'] as String?,
        ipAddress: json['ipAddress'] as String?,
        metadata: json['metadata'] as Map<String, dynamic>?,
        resolved: json['resolved'] as bool? ?? false,
        resolvedAt: json['resolvedAt'] as int?,
        resolvedBy: json['resolvedBy'] as String?,
        resolution: json['resolution'] as String?,
      );

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'id': id,
      'type': type.value,
      'severity': severity.value,
      'title': title,
      'description': description,
      'userId': userId,
      'userEmail': userEmail,
      'tenantId': tenantId,
      'timestamp': timestamp,
      'resolved': resolved,
    };
    if (resource != null) m['resource'] = resource;
    if (action != null) m['action'] = action;
    if (ipAddress != null) m['ipAddress'] = ipAddress;
    if (metadata != null) m['metadata'] = metadata;
    if (resolvedAt != null) m['resolvedAt'] = resolvedAt;
    if (resolvedBy != null) m['resolvedBy'] = resolvedBy;
    if (resolution != null) m['resolution'] = resolution;
    return m;
  }

  @override
  String toString() =>
      'AccessAlert(type: ${type.value}, severity: ${severity.value}, user: $userEmail)';
}

/// Фильтр для запроса алертов
class AccessAlertFilter {
  const AccessAlertFilter({
    this.userId,
    this.tenantId,
    this.type,
    this.severity,
    this.resolved,
    this.startTime,
    this.endTime,
    this.limit = 100,
    this.offset = 0,
  });

  /// Фильтр по пользователю
  final String? userId;

  /// Фильтр по тенанту
  final String? tenantId;

  /// Фильтр по типу алерта
  final AlertType? type;

  /// Фильтр по уровню серьёзности
  final AlertSeverity? severity;

  /// Фильтр по статусу (null = все, true = только разрешённые, false = только неразрешённые)
  final bool? resolved;

  /// Начало временного диапазона (Unix timestamp в секундах)
  final int? startTime;

  /// Конец временного диапазона (Unix timestamp в секундах)
  final int? endTime;

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
    if (type != null) m['type'] = type!.value;
    if (severity != null) m['severity'] = severity!.value;
    if (resolved != null) m['resolved'] = resolved;
    if (startTime != null) m['startTime'] = startTime;
    if (endTime != null) m['endTime'] = endTime;
    return m;
  }
}
