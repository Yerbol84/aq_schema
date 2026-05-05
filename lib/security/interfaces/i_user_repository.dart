// pkgs/aq_schema/lib/security/interfaces/i_user_repository.dart

import '../models/aq_user.dart';
import '../models/aq_profile.dart';
import '../models/aq_role.dart';

abstract interface class IUserRepository {
  Future<AqUser?> findById(String id);
  Future<AqUser?> findByEmail(String email);
  Future<AqUser?> findByProvider(String provider, String providerUserId);
  Future<AqUser> create(AqUser user);
  Future<AqUser> update(AqUser user);
  Future<void> updateLastLogin(String userId, int timestamp);
  Future<List<AqUser>> listByTenant(String tenantId);
}

abstract interface class IProfileRepository {
  Future<AqProfile?> findByUserId(String userId);
  Future<AqProfile> upsert(AqProfile profile);
}

abstract interface class IRoleRepository {
  Future<List<AqRole>> findByUser(String userId, String tenantId);
  Future<List<AqRole>> listSystemRoles();
  Future<AqRole?> findById(String id);
  Future<AqRole?> findByName(String name, {String? tenantId});
  Future<List<AqRole>> getAllRoles();
  Future<AqRole> create(AqRole role);
  Future<void> saveRole(AqRole role);
  Future<void> deleteRole(String roleId);
  Future<void> assignRole(String userId, String roleId, String tenantId,
      {String? grantedBy});
  Future<void> revokeRole(String userId, String roleId, String tenantId);
}

abstract interface class IUserRoleRepository {
  Future<List<AqUserRole>> getUserRoles(String userId);
  Future<void> assignRole(AqUserRole userRole);
  Future<void> revokeRole(String userId, String roleId);
}
