// pkgs/aq_schema/lib/security/models/access_context.dart
//
// Контекст для проверки доступа в RBAC системе.
// Содержит всю информацию, необходимую для принятия решения о доступе.

/// Контекст для проверки доступа
///
/// Содержит информацию о пользователе, ресурсе, действии и дополнительном контексте.
/// Используется AccessControlEngine для оценки прав доступа.
final class AccessContext {
  const AccessContext({
    required this.userId,
    required this.tenantId,
    required this.resource,
    required this.action,
    this.userRoles = const [],
    this.userPermissions = const [],
    this.userScopes = const [],
    this.ipAddress,
    this.timestamp,
    this.userAttributes = const {},
    this.resourceAttributes = const {},
    this.sessionId,
    this.requestId,
  });

  /// ID пользователя, для которого проверяется доступ
  final String userId;

  /// ID тенанта, в контексте которого проверяется доступ
  final String tenantId;

  /// Ресурс, к которому запрашивается доступ
  /// Формат: "resourceType:resourceId" или "resourceType"
  /// Примеры: "project:abc123", "graph:xyz789", "projects"
  final String resource;

  /// Действие, которое пытаются выполнить
  /// Примеры: "read", "write", "delete", "execute", "admin"
  final String action;

  /// Список ролей пользователя (имена ролей)
  final List<String> userRoles;

  /// Список разрешений пользователя (permission keys)
  final List<String> userPermissions;

  /// Список scopes пользователя (для fine-grained access control)
  final List<String> userScopes;

  /// IP адрес, с которого выполняется запрос
  final String? ipAddress;

  /// Unix timestamp (секунды) когда выполняется запрос
  /// Если null, используется текущее время
  final int? timestamp;

  /// Атрибуты пользователя для policy evaluation
  ///
  /// Примеры:
  /// - "email": "user@example.com"
  /// - "userType": "end_user" | "service_account"
  /// - "department": "engineering"
  /// - "level": "senior"
  final Map<String, dynamic> userAttributes;

  /// Атрибуты ресурса для policy evaluation
  ///
  /// Примеры:
  /// - "ownerId": "user-123"
  /// - "visibility": "private" | "public"
  /// - "status": "active" | "archived"
  /// - "projectId": "project-456"
  final Map<String, dynamic> resourceAttributes;

  /// ID сессии (для логирования и аудита)
  final String? sessionId;

  /// ID запроса (для трейсинга)
  final String? requestId;

  /// Получить тип ресурса из resource string
  ///
  /// Примеры:
  /// - "project:abc123" → "project"
  /// - "graph:xyz789" → "graph"
  /// - "projects" → "projects"
  String get resourceType {
    final parts = resource.split(':');
    return parts.first;
  }

  /// Получить ID ресурса из resource string (если есть)
  ///
  /// Примеры:
  /// - "project:abc123" → "abc123"
  /// - "graph:xyz789" → "xyz789"
  /// - "projects" → null
  String? get resourceId {
    final parts = resource.split(':');
    return parts.length > 1 ? parts[1] : null;
  }

  /// Получить permission key для данного контекста
  ///
  /// Формат: "resourceType:action"
  /// Примеры: "project:read", "graph:write", "admin:*"
  String get permissionKey => '$resourceType:$action';

  /// Получить текущий timestamp (или использовать переданный)
  int get effectiveTimestamp =>
      timestamp ?? (DateTime.now().millisecondsSinceEpoch ~/ 1000);

  factory AccessContext.fromJson(Map<String, dynamic> json) => AccessContext(
        userId: json['userId'] as String,
        tenantId: json['tenantId'] as String,
        resource: json['resource'] as String,
        action: json['action'] as String,
        userRoles: (json['userRoles'] as List<dynamic>?)?.cast<String>() ?? [],
        userPermissions: (json['userPermissions'] as List<dynamic>?)?.cast<String>() ?? [],
        userScopes: (json['userScopes'] as List<dynamic>?)?.cast<String>() ?? [],
        ipAddress: json['ipAddress'] as String?,
        timestamp: json['timestamp'] as int?,
        userAttributes: json['userAttributes'] as Map<String, dynamic>? ?? {},
        resourceAttributes: json['resourceAttributes'] as Map<String, dynamic>? ?? {},
        sessionId: json['sessionId'] as String?,
        requestId: json['requestId'] as String?,
      );

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'userId': userId,
      'tenantId': tenantId,
      'resource': resource,
      'action': action,
    };
    if (userRoles.isNotEmpty) m['userRoles'] = userRoles;
    if (userPermissions.isNotEmpty) m['userPermissions'] = userPermissions;
    if (userScopes.isNotEmpty) m['userScopes'] = userScopes;
    if (ipAddress != null) m['ipAddress'] = ipAddress;
    if (timestamp != null) m['timestamp'] = timestamp;
    if (userAttributes.isNotEmpty) m['userAttributes'] = userAttributes;
    if (resourceAttributes.isNotEmpty) m['resourceAttributes'] = resourceAttributes;
    if (sessionId != null) m['sessionId'] = sessionId;
    if (requestId != null) m['requestId'] = requestId;
    return m;
  }

  @override
  String toString() =>
      'AccessContext(user: $userId, resource: $resource, action: $action)';
}
