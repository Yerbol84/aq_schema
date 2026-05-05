// aq_schema/lib/security/interfaces/clients_protocols/mocks/mock_auth_context.dart
//
// Mock IAuthContext — использует MockSecurityBackend.
//
// Гарантии реализации (aq_security обязан соблюдать):
//   currentToken (аутентифицирован)     → строка токена
//   currentToken (не аутентифицирован)  → null
//   currentTenantId (аутентифицирован)  → tenantId из claims
//   currentTenantId (не аутентифицирован) → 'system'
//   currentUserId (аутентифицирован)    → userId из claims
//   currentUserId (не аутентифицирован) → null

import '../i_auth_context.dart';
import '../../../mock/backend/mock_security_backend.dart';
import '../../../mock/backend/mock_security_seed.dart';

final class MockAuthContext implements IAuthContext {
  MockAuthContext(this._backend);

  final MockSecurityBackend _backend;

  @override
  Future<String?> get currentToken async {
    final claims = _backend.currentClaims;
    if (claims == null) return null;
    // Найти токен по claims
    for (final entry in MockSecuritySeed.tokenMap.entries) {
      if (entry.value.sub == claims.sub && entry.value.tid == claims.tid) {
        return entry.key;
      }
    }
    return 'mock-token-${claims.sub}';
  }

  @override
  Future<String> get currentTenantId async =>
      _backend.currentClaims?.tid ?? 'system';

  @override
  Future<String?> get currentUserId async =>
      _backend.currentClaims?.sub;
}
