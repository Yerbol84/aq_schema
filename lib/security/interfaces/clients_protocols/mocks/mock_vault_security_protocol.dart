// aq_schema/lib/security/interfaces/clients_protocols/mocks/mock_vault_security_protocol.dart
//
// Mock IVaultSecurityProtocol — использует MockSecurityBackend.
//
// Гарантии реализации (aq_security обязан соблюдать):
//   extractClaims(admin token)          → adminClaims
//   extractClaims(revoked token)        → null
//   extractClaims(no header)            → null
//   canRead(admin)                      → AccessDecision.allow
//   canRead(viewer, 'projects')         → AccessDecision.allow (есть scope)
//   canRead(viewer, 'users')            → AccessDecision.deny (нет scope)
//   canWrite(viewer)                    → AccessDecision.deny
//   canDelete(non-admin)                → AccessDecision.deny
//   canRead(null claims)                → AccessDecision.deny
//   validateData(без id)                → [ValidationFieldError('id')]
//   encryptSensitiveFields              → данные без изменений (mock не шифрует)

import 'package:aq_schema/aq_schema.dart';
import '../../../mock/backend/mock_security_backend.dart';
import '../../../mock/backend/mock_security_seed.dart';
import '../i_vault_security_protocol.dart';
import '../../../interfaces/i_resource_permission_service.dart';

final class MockVaultSecurityProtocol implements IVaultSecurityProtocol {
  MockVaultSecurityProtocol(this._backend);

  final MockSecurityBackend _backend;

  @override
  Future<AqTokenClaims?> extractClaims(Map<String, String> headers) async {
    final claims = _backend.claimsFromHeaders(headers);
    if (claims == null) return null;
    // Проверить не истёк ли токен
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if (claims.exp < now) return null;
    return claims;
  }

  @override
  Future<AccessDecision> canRead({
    required AqTokenClaims? claims,
    required String collection,
    String? entityId,
  }) async {
    if (claims == null) return AccessDecision.deny(reason: 'Authentication required');
    if (!_isUserActive(claims.sub)) return AccessDecision.deny(reason: 'User disabled');
    if (_backend.hasPermission(claims.sub, collection, 'read') ||
        claims.scopes.contains('*:*') ||
        claims.scopes.contains('$collection:read') ||
        claims.scopes.contains('$collection:*')) {
      return AccessDecision.allow(reason: 'Access granted');
    }
    return AccessDecision.deny(reason: 'No read permission for $collection');
  }

  @override
  Future<AccessDecision> canWrite({
    required AqTokenClaims? claims,
    required String collection,
    String? entityId,
    required Map<String, dynamic> data,
  }) async {
    if (claims == null) return AccessDecision.deny(reason: 'Authentication required');
    if (!_isUserActive(claims.sub)) return AccessDecision.deny(reason: 'User disabled');
    if (_backend.hasPermission(claims.sub, collection, 'write') ||
        claims.scopes.contains('*:*') ||
        claims.scopes.contains('$collection:write') ||
        claims.scopes.contains('$collection:*')) {
      return AccessDecision.allow(reason: 'Access granted');
    }
    return AccessDecision.deny(reason: 'No write permission for $collection');
  }

  @override
  Future<AccessDecision> canDelete({
    required AqTokenClaims? claims,
    required String collection,
    required String entityId,
  }) async {
    if (claims == null) return AccessDecision.deny(reason: 'Authentication required');
    if (!_isUserActive(claims.sub)) return AccessDecision.deny(reason: 'User disabled');
    if (claims.roles.contains('admin') || claims.scopes.contains('*:*')) {
      return AccessDecision.allow(reason: 'Access granted');
    }
    return AccessDecision.deny(reason: 'Only admin can delete');
  }

  @override
  Future<AccessDecision> canPublish({
    required AqTokenClaims? claims,
    required String collection,
    required String entityId,
  }) async {
    if (claims == null) return AccessDecision.deny(reason: 'Authentication required');
    if (claims.roles.contains('admin') ||
        claims.scopes.contains('$collection:write') ||
        claims.scopes.contains('*:*')) {
      return AccessDecision.allow(reason: 'Access granted');
    }
    return AccessDecision.deny(reason: 'No publish permission');
  }

  @override
  Future<AccessDecision> canGrant({
    required AqTokenClaims? claims,
    required String collection,
    required String entityId,
    required String targetUserId,
    required AccessLevel level,
  }) async {
    if (claims == null) return AccessDecision.deny(reason: 'Authentication required');
    if (claims.roles.contains('admin') || claims.scopes.contains('*:*')) {
      return AccessDecision.allow(reason: 'Access granted');
    }
    return AccessDecision.deny(reason: 'Only admin can grant access');
  }

  @override
  Future<bool> checkRateLimit({
    required AqTokenClaims? claims,
    required String operation,
    String? ip,
  }) async => true; // Mock: лимитов нет

  @override
  Future<List<ValidationFieldError>> validateData({
    required String collection,
    required Map<String, dynamic> data,
  }) async {
    final errors = <ValidationFieldError>[];
    if (!data.containsKey('id')) {
      errors.add(const ValidationFieldError(
        field: 'id', message: 'Field "id" is required', code: 'REQUIRED',
      ));
    }
    return errors;
  }

  @override
  Future<Map<String, dynamic>> encryptSensitiveFields({
    required AqTokenClaims? claims,
    required String collection,
    required Map<String, dynamic> data,
  }) async => data; // Mock: не шифруем

  @override
  Future<Map<String, dynamic>> decryptSensitiveFields({
    required AqTokenClaims? claims,
    required String collection,
    required Map<String, dynamic> data,
  }) async => data; // Mock: не расшифровываем

  @override
  Future<void> logOperation({
    required AqTokenClaims? claims,
    required String operation,
    required String collection,
    String? entityId,
    required bool success,
    String? errorMessage,
  }) async {
    // Mock: записываем в backend для проверки в тестах
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    _backend.accessLogs.add(AqAccessLog(
      id: 'log-${_backend.accessLogs.length}',
      userId: claims?.sub ?? 'anonymous',
      userEmail: claims?.email ?? 'anonymous',
      tenantId: claims?.tid ?? 'unknown',
      resource: collection,
      action: operation,
      allowed: success,
      reason: errorMessage,
      timestamp: now,
    ));
  }

  @override
  IResourcePermissionService get resourcePermissions =>
      throw UnimplementedError('MockResourcePermissionService not yet implemented');

  bool _isUserActive(String userId) {
    final user = _backend.users[userId];
    return user == null || user.isActive; // если нет в backend — разрешаем
  }
}

/// Поведение mock по умолчанию (для обратной совместимости)
enum MockBehavior { allowAll, requireAuth, denyAll }
