// pkgs/aq_schema/lib/security/mock/mock_role_management_service.dart
//
// Mock реализация IRoleManagementService для тестов.

import '../interfaces/i_role_management_service.dart';
import '../models/aq_role.dart';
import '../models/aq_user.dart';

/// Mock реализация IRoleManagementService
class MockRoleManagementService implements IRoleManagementService {
  final List<AqRole> _roles = [
    AqRole(
      id: 'role_admin',
      name: 'Admin',
      description: 'Administrator role',
      permissions: ['*'],
      isSystem: true,
      createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    ),
    AqRole(
      id: 'role_user',
      name: 'User',
      description: 'Regular user role',
      permissions: ['projects:read', 'graphs:read'],
      isSystem: true,
      createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    ),
  ];

  final Map<String, List<String>> _userRoles = {}; // userId -> [roleId]

  @override
  Future<List<AqRole>> getRoles() async => List.from(_roles);

  @override
  Future<AqRole?> getRole(String roleId) async {
    try {
      return _roles.firstWhere((r) => r.id == roleId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AqRole> createRole({
    required String name,
    String? description,
    required List<String> permissions,
  }) async {
    final role = AqRole(
      id: 'role_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: description,
      permissions: permissions,
      isSystem: false,
      createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    );
    _roles.add(role);
    return role;
  }

  @override
  Future<AqRole> updateRole({
    required String roleId,
    String? name,
    String? description,
    List<String>? permissions,
  }) async {
    final index = _roles.indexWhere((r) => r.id == roleId);
    if (index == -1) throw Exception('Role not found');

    final oldRole = _roles[index];
    final updatedRole = AqRole(
      id: oldRole.id,
      name: name ?? oldRole.name,
      description: description ?? oldRole.description,
      permissions: permissions ?? oldRole.permissions,
      tenantId: oldRole.tenantId,
      isSystem: oldRole.isSystem,
      createdAt: oldRole.createdAt,
    );

    _roles[index] = updatedRole;
    return updatedRole;
  }

  @override
  Future<void> deleteRole(String roleId) async {
    _roles.removeWhere((r) => r.id == roleId);
    // Удалить все назначения этой роли
    _userRoles.forEach((userId, roleIds) {
      roleIds.remove(roleId);
    });
  }

  @override
  Future<void> assignRole({
    required String userId,
    required String roleId,
    int? expiresAt,
  }) async {
    if (!_userRoles.containsKey(userId)) {
      _userRoles[userId] = [];
    }
    if (!_userRoles[userId]!.contains(roleId)) {
      _userRoles[userId]!.add(roleId);
    }
  }

  @override
  Future<void> revokeRole({
    required String userId,
    required String roleId,
  }) async {
    _userRoles[userId]?.remove(roleId);
  }

  @override
  Future<List<AqRole>> getUserRoles(String userId) async {
    final roleIds = _userRoles[userId] ?? [];
    return _roles.where((r) => roleIds.contains(r.id)).toList();
  }

  @override
  Future<List<AqUser>> getUsersByRole(String roleId) async {
    final userIds = _userRoles.entries
        .where((entry) => entry.value.contains(roleId))
        .map((entry) => entry.key)
        .toList();

    return userIds
        .map((id) => AqUser(
              id: id,
              email: 'user_$id@example.com',
              displayName: 'User $id',
              createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
              userType: UserType.endUser,
              tenantId: '',
              authProvider: IdentityProvider.mock,
              isActive: true,
            ))
        .toList();
  }

  @override
  Future<List<String>> getAllPermissions() async {
    return [
      'projects:read',
      'projects:write',
      'projects:delete',
      'projects:admin',
      'graphs:read',
      'graphs:write',
      'graphs:execute',
      'graphs:delete',
      'instructions:read',
      'instructions:write',
      'admin:*',
    ];
  }
}
