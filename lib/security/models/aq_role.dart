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
