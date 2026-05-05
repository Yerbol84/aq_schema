// aq_schema/lib/security/mock/mock_role_management_service.dart
//
// Mock IRoleManagementService — использует MockSecurityBackend.
//
// Гарантии реализации (aq_security обязан соблюдать):
//   getRoles()                          → все роли
//   getRole(существующий id)            → AqRole
//   getRole(несуществующий id)          → null
//   createRole(новая роль)              → сохранена в backend
//   createRole(дублирующее имя)         → throws Exception('role_already_exists')
//   deleteRole(системная роль)          → throws Exception('cannot_delete_system_role')
//   assignRole(userId, roleId)          → роль назначена, видна в getUserRoles
//   revokeRole(userId, roleId)          → роль отозвана

import '../interfaces/i_role_management_service.dart';
import '../models/aq_role.dart';
import '../models/aq_user.dart';
import 'backend/mock_security_backend.dart';

final class MockRoleManagementService implements IRoleManagementService {
  MockRoleManagementService(this._backend);

  final MockSecurityBackend _backend;

  @override
  Future<List<AqRole>> getRoles() async =>
      _backend.roles.values.toList();

  @override
  Future<AqRole?> getRole(String roleId) async =>
      _backend.roles[roleId];

  @override
  Future<AqRole> createRole({
    required String name,
    String? description,
    required List<String> permissions,
  }) async {
    if (_backend.roles.values.any((r) => r.name == name)) {
      throw Exception('role_already_exists');
    }
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final role = AqRole(
      id: 'role-${_backend.roles.length + 1}',
      name: name,
      description: description,
      permissions: permissions,
      isSystem: false,
      createdAt: now,
    );
    _backend.roles[role.id] = role;
    return role;
  }

  @override
  Future<AqRole> updateRole({
    required String roleId,
    String? name,
    String? description,
    List<String>? permissions,
  }) async {
    final role = _backend.roles[roleId];
    if (role == null) throw Exception('role_not_found');
    if (role.isSystem && name != null && name != role.name) {
      throw Exception('cannot_rename_system_role');
    }
    final updated = AqRole(
      id: role.id,
      name: name ?? role.name,
      description: description ?? role.description,
      permissions: permissions ?? role.permissions,
      inheritsFrom: role.inheritsFrom,
      tenantId: role.tenantId,
      isSystem: role.isSystem,
      createdAt: role.createdAt,
      updatedAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    );
    _backend.roles[roleId] = updated;
    return updated;
  }

  @override
  Future<void> deleteRole(String roleId) async {
    final role = _backend.roles[roleId];
    if (role == null) throw Exception('role_not_found');
    if (role.isSystem) throw Exception('cannot_delete_system_role');
    _backend.roles.remove(roleId);
    for (final assignments in _backend.userRoles.values) {
      assignments.removeWhere((ur) => ur.roleId == roleId);
    }
  }

  @override
  Future<void> assignRole({
    required String userId,
    required String roleId,
    int? expiresAt,
  }) async {
    if (!_backend.roles.containsKey(roleId)) throw Exception('role_not_found');
    if (!_backend.users.containsKey(userId)) throw Exception('user_not_found');
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final tenantId = _backend.users[userId]!.tenantId;
    final assignment = AqUserRole(
      userId: userId,
      roleId: roleId,
      tenantId: tenantId,
      grantedAt: now,
      expiresAt: expiresAt,
    );
    _backend.userRoles.putIfAbsent(userId, () => []);
    _backend.userRoles[userId]!.removeWhere((ur) => ur.roleId == roleId);
    _backend.userRoles[userId]!.add(assignment);
  }

  @override
  Future<void> revokeRole({
    required String userId,
    required String roleId,
  }) async {
    _backend.userRoles[userId]?.removeWhere((ur) => ur.roleId == roleId);
  }

  @override
  Future<List<AqRole>> getUserRoles(String userId) async =>
      _backend.getRolesForUser(userId);

  @override
  Future<List<AqUser>> getUsersByRole(String roleId) async {
    final userIds = _backend.userRoles.entries
        .where((e) => e.value.any((ur) => ur.roleId == roleId))
        .map((e) => e.key)
        .toList();
    return userIds
        .map((id) => _backend.users[id])
        .whereType<AqUser>()
        .toList();
  }

  @override
  Future<List<String>> getAllPermissions() async => [
        'projects:read', 'projects:write', 'projects:delete',
        'graphs:read', 'graphs:write', 'graphs:execute', 'graphs:delete',
        'users:read', 'users:write', 'users:delete',
        'roles:read', 'roles:write', 'roles:delete', 'roles:assign', 'roles:revoke',
        'policies:read', 'policies:write', 'policies:delete',
        'audit:read', 'audit:delete',
        'admin:*', '*:*',
      ];
}
