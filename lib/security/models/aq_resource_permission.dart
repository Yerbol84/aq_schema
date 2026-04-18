// pkgs/aq_schema/lib/security/models/aq_resource_permission.dart
//
// Resource-based permissions для fine-grained access control.
// Позволяет управлять доступом к конкретным ресурсам (projects, graphs, etc).

/// Тип ресурса в системе
enum ResourceType {
  project('project'),
  graph('graph'),
  instruction('instruction'),
  prompt('prompt'),
  dataset('dataset'),
  model('model'),
  apiKey('api_key'),
  session('session');

  const ResourceType(this.value);
  final String value;

  static ResourceType fromString(String s) =>
      ResourceType.values.firstWhere((e) => e.value == s);
}

/// Уровень доступа к ресурсу
enum AccessLevel {
  none('none'),           // Нет доступа
  read('read'),           // Чтение
  write('write'),         // Чтение + запись
  admin('admin'),         // Полный контроль
  owner('owner');         // Владелец (может удалить, передать ownership)

  const AccessLevel(this.value);
  final String value;

  static AccessLevel fromString(String s) =>
      AccessLevel.values.firstWhere((e) => e.value == s);

  /// Проверяет, включает ли этот уровень другой уровень
  bool includes(AccessLevel other) {
    const hierarchy = {
      AccessLevel.none: 0,
      AccessLevel.read: 1,
      AccessLevel.write: 2,
      AccessLevel.admin: 3,
      AccessLevel.owner: 4,
    };

    return hierarchy[this]! >= hierarchy[other]!;
  }
}

/// Resource permission — связь между пользователем и ресурсом
final class AqResourcePermission {
  const AqResourcePermission({
    required this.id,
    required this.resourceType,
    required this.resourceId,
    required this.userId,
    required this.tenantId,
    required this.accessLevel,
    required this.grantedAt,
    required this.grantedBy,
    this.expiresAt,
    this.inheritedFrom,
  });

  final String id;
  final ResourceType resourceType;
  final String resourceId;
  final String userId;
  final String tenantId;
  final AccessLevel accessLevel;
  final int grantedAt;
  final String grantedBy;        // User ID кто выдал permission
  final int? expiresAt;          // Опциональное истечение
  final String? inheritedFrom;   // ID родительского ресурса (для inheritance)

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().millisecondsSinceEpoch ~/ 1000 >= expiresAt!;
  }

  bool get isInherited => inheritedFrom != null;

  factory AqResourcePermission.fromJson(Map<String, dynamic> json) =>
      AqResourcePermission(
        id: json['id'] as String,
        resourceType: ResourceType.fromString(json['resourceType'] as String),
        resourceId: json['resourceId'] as String,
        userId: json['userId'] as String,
        tenantId: json['tenantId'] as String,
        accessLevel: AccessLevel.fromString(json['accessLevel'] as String),
        grantedAt: json['grantedAt'] as int,
        grantedBy: json['grantedBy'] as String,
        expiresAt: json['expiresAt'] as int?,
        inheritedFrom: json['inheritedFrom'] as String?,
      );

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'id': id,
      'resourceType': resourceType.value,
      'resourceId': resourceId,
      'userId': userId,
      'tenantId': tenantId,
      'accessLevel': accessLevel.value,
      'grantedAt': grantedAt,
      'grantedBy': grantedBy,
    };
    if (expiresAt != null) m['expiresAt'] = expiresAt;
    if (inheritedFrom != null) m['inheritedFrom'] = inheritedFrom;
    return m;
  }

  AqResourcePermission copyWith({
    AccessLevel? accessLevel,
    int? expiresAt,
  }) =>
      AqResourcePermission(
        id: id,
        resourceType: resourceType,
        resourceId: resourceId,
        userId: userId,
        tenantId: tenantId,
        accessLevel: accessLevel ?? this.accessLevel,
        grantedAt: grantedAt,
        grantedBy: grantedBy,
        expiresAt: expiresAt ?? this.expiresAt,
        inheritedFrom: inheritedFrom,
      );
}

/// Repository interface для resource permissions
abstract interface class IResourcePermissionRepository {
  /// Выдать permission пользователю на ресурс
  Future<AqResourcePermission> grant(AqResourcePermission permission);

  /// Отозвать permission
  Future<void> revoke(String permissionId);

  /// Получить permission по ID
  Future<AqResourcePermission?> findById(String id);

  /// Получить все permissions пользователя для ресурса
  Future<List<AqResourcePermission>> findByUserAndResource({
    required String userId,
    required ResourceType resourceType,
    required String resourceId,
  });

  /// Получить все permissions для ресурса
  Future<List<AqResourcePermission>> findByResource({
    required ResourceType resourceType,
    required String resourceId,
  });

  /// Получить все permissions пользователя
  Future<List<AqResourcePermission>> findByUser(String userId);

  /// Проверить, есть ли у пользователя доступ к ресурсу
  Future<AccessLevel?> checkAccess({
    required String userId,
    required ResourceType resourceType,
    required String resourceId,
  });

  /// Удалить все permissions для ресурса (при удалении ресурса)
  Future<int> deleteByResource({
    required ResourceType resourceType,
    required String resourceId,
  });

  /// Удалить истёкшие permissions
  Future<int> cleanupExpired();
}
