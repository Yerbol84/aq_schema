// aq_schema/lib/security/mock/mock_role_management_service.dart
//
// Mock IRoleManagementService — использует MockSecurityBackend.
//
// Гарантии реализации (aq_security обязан соблюдать):
//   getRoles()                          → все роли tenant'а
//   getRoleById(существующий id)        → AqRole
//   getRoleById(несуществующий id)      → null
//   createRole(новая роль)              → AqRole сохранена в backend
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
  Future<AqRole?> getRoleById(String roleId) async =>
      _backend.roles[roleId];

  @override
  Future<AqRole?> getRoleByName(String name) async =>
      _backend.roles.values.where((r) => r.name == name).firstOrNull;

  @override
  Future<AqRole> createRole({
    required String name,
    String? description,
    required List<String> permissions,
    List<String> inheritsFrom = const [],
    String? tenantId,
    Map<String, dynamic> metadata = const {},
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
      inheritsFrom: inheritsFrom,
      tenantId: tenantId,
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
    List<String>? inheritsFrom,
    Map<String, dynamic>? metadata,
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
      inheritsFrom: inheritsFrom ?? role.inheritsFrom,
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
    // Отозвать у всех пользователей
    for (final assignments in _backend.userRoles.values) {
      assignments.removeWhere((ur) => ur.roleId == roleId);
    }
  }

  @override
  Future<List<AqUserRole>> getUserRoles(String userId) async =>
      _backend.userRoles[userId] ?? [];

  @override
  Future<void> assignRole(
    String userId,
    String roleId, {
    String? tenantId,
    DateTime? expiresAt,
    String? reason,
  }) async {
    if (!_backend.roles.containsKey(roleId)) throw Exception('role_not_found');
    if (!_backend.users.containsKey(userId)) throw Exception('user_not_found');
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final tid = tenantId ?? _backend.users[userId]!.tenantId;
    final assignment = AqUserRole(
      userId: userId,
      roleId: roleId,
      tenantId: tid,
      grantedAt: now,
      expiresAt: expiresAt != null
          ? expiresAt.millisecondsSinceEpoch ~/ 1000
          : null,
    );
    _backend.userRoles.putIfAbsent(userId, () => []);
    _backend.userRoles[userId]!.removeWhere((ur) => ur.roleId == roleId);
    _backend.userRoles[userId]!.add(assignment);
  }

  @override
  Future<void> revokeRole(String userId, String roleId) async {
    _backend.userRoles[userId]?.removeWhere((ur) => ur.roleId == roleId);
  }

  @override
  Future<List<AqRole>> getEffectiveRoles(String userId) async =>
      _backend.getRolesForUser(userId);

  @override
  Future<List<AqUser>> getUsersWithRole(String roleId) async {
    final userIds = _backend.userRoles.entries
        .where((e) => e.value.any((ur) => ur.roleId == roleId))
        .map((e) => e.key)
        .toList();
    return userIds
        .map((id) => _backend.users[id])
        .whereType<AqUser>()
        .toList();
  }
}
