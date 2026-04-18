// pkgs/aq_schema/lib/security/models/aq_audit_trail.dart
//
// Модель для аудита изменений в системе безопасности.
// Отслеживает все изменения ролей, прав, политик и назначений.

/// Тип действия в аудите
enum AuditActionType {
  create('create'),
  update('update'),
  delete('delete'),
  assign('assign'),
  revoke('revoke');

  const AuditActionType(this.value);
  final String value;

  static AuditActionType fromString(String s) =>
      AuditActionType.values.firstWhere((e) => e.value == s);
}

/// Тип сущности в аудите
enum AuditEntityType {
  role('role'),
  permission('permission'),
  policy('policy'),
  user('user'),
  apiKey('api_key'),
  session('session');

  const AuditEntityType(this.value);
  final String value;

  static AuditEntityType fromString(String s) =>
      AuditEntityType.values.firstWhere((e) => e.value == s);
}

/// Запись в аудит-трейле
///
/// Каждое изменение в системе безопасности (роли, права, политики) должно
/// создавать запись в аудит-трейле для отслеживания "кто, что, когда изменил".
final class AqAuditTrail {
  const AqAuditTrail({
    required this.id,
    required this.action,
    required this.entityType,
    required this.entityId,
    required this.entityName,
    required this.userId,
    required this.userEmail,
    required this.tenantId,
    required this.timestamp,
    this.changes,
    this.reason,
    this.ipAddress,
    this.metadata,
  });

  static const String kCollection = 'rbac_audit_trail';

  /// Уникальный ID записи аудита
  final String id;

  /// Тип действия (create, update, delete, assign, revoke)
  final AuditActionType action;

  /// Тип сущности, которая была изменена
  final AuditEntityType entityType;

  /// ID изменённой сущности
  final String entityId;

  /// Название сущности (для удобства отображения в UI)
  /// Примеры: "Admin Role", "projects:write", "IP Whitelist Policy"
  final String entityName;

  /// ID пользователя, который сделал изменение
  final String userId;

  /// Email пользователя (для удобства отображения в UI)
  final String userEmail;

  /// ID тенанта, в контексте которого произошло изменение
  final String tenantId;

  /// Unix timestamp (секунды) когда произошло изменение
  final int timestamp;

  /// Детали изменений (diff старого и нового состояния)
  ///
  /// Формат для разных действий:
  ///
  /// CREATE:
  /// {
  ///   "created": { "name": "Editor", "permissions": ["projects:read", "projects:write"] }
  /// }
  ///
  /// UPDATE:
  /// {
  ///   "before": { "name": "Editor", "permissions": ["projects:read"] },
  ///   "after": { "name": "Editor", "permissions": ["projects:read", "projects:write"] },
  ///   "diff": { "permissions": { "added": ["projects:write"], "removed": [] } }
  /// }
  ///
  /// DELETE:
  /// {
  ///   "deleted": { "name": "Editor", "permissions": ["projects:read", "projects:write"] }
  /// }
  ///
  /// ASSIGN:
  /// {
  ///   "assigned": { "roleId": "role-123", "roleName": "Admin", "toUserId": "user-456" }
  /// }
  ///
  /// REVOKE:
  /// {
  ///   "revoked": { "roleId": "role-123", "roleName": "Admin", "fromUserId": "user-456" }
  /// }
  final Map<String, dynamic>? changes;

  /// Причина изменения (опционально, может быть указана пользователем)
  /// Примеры:
  /// - "User requested admin access for project deployment"
  /// - "Security audit: removing unused permissions"
  /// - "Compliance requirement: enforcing IP whitelist"
  final String? reason;

  /// IP адрес, с которого было сделано изменение
  final String? ipAddress;

  /// Дополнительные метаданные
  /// Примеры полей:
  /// - "requestId": "req-123"
  /// - "sessionId": "sess-456"
  /// - "apiVersion": "v1"
  /// - "clientType": "web" | "api" | "cli"
  final Map<String, dynamic>? metadata;

  factory AqAuditTrail.fromJson(Map<String, dynamic> json) => AqAuditTrail(
        id: json['id'] as String,
        action: AuditActionType.fromString(json['action'] as String),
        entityType: AuditEntityType.fromString(json['entityType'] as String),
        entityId: json['entityId'] as String,
        entityName: json['entityName'] as String,
        userId: json['userId'] as String,
        userEmail: json['userEmail'] as String,
        tenantId: json['tenantId'] as String,
        timestamp: json['timestamp'] as int,
        changes: json['changes'] as Map<String, dynamic>?,
        reason: json['reason'] as String?,
        ipAddress: json['ipAddress'] as String?,
        metadata: json['metadata'] as Map<String, dynamic>?,
      );

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'id': id,
      'action': action.value,
      'entityType': entityType.value,
      'entityId': entityId,
      'entityName': entityName,
      'userId': userId,
      'userEmail': userEmail,
      'tenantId': tenantId,
      'timestamp': timestamp,
    };
    if (changes != null) m['changes'] = changes;
    if (reason != null) m['reason'] = reason;
    if (ipAddress != null) m['ipAddress'] = ipAddress;
    if (metadata != null) m['metadata'] = metadata;
    return m;
  }

  DateTime get timestampAsDateTime =>
      DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
}

/// Фильтр для запроса аудит-трейла
///
/// Backend должен поддерживать фильтрацию по всем этим полям.
/// Все поля опциональны - если не указаны, фильтр не применяется.
class AuditTrailFilter {
  const AuditTrailFilter({
    this.userId,
    this.tenantId,
    this.action,
    this.entityType,
    this.entityId,
    this.startTime,
    this.endTime,
    this.searchQuery,
    this.limit = 100,
    this.offset = 0,
  });

  /// Фильтр по пользователю, который сделал изменение
  final String? userId;

  /// Фильтр по тенанту
  final String? tenantId;

  /// Фильтр по типу действия
  final AuditActionType? action;

  /// Фильтр по типу сущности
  final AuditEntityType? entityType;

  /// Фильтр по конкретной сущности
  final String? entityId;

  /// Начало временного диапазона (Unix timestamp в секундах)
  final int? startTime;

  /// Конец временного диапазона (Unix timestamp в секундах)
  final int? endTime;

  /// Поиск по entityName, userEmail, reason (полнотекстовый поиск)
  final String? searchQuery;

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
    if (action != null) m['action'] = action!.value;
    if (entityType != null) m['entityType'] = entityType!.value;
    if (entityId != null) m['entityId'] = entityId;
    if (startTime != null) m['startTime'] = startTime;
    if (endTime != null) m['endTime'] = endTime;
    if (searchQuery != null) m['searchQuery'] = searchQuery;
    return m;
  }
}
