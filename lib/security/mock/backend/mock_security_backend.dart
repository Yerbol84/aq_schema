// aq_schema/lib/security/mock/backend/mock_security_backend.dart
//
// Единое in-memory состояние для всех моков security слоя.
// Все MockXxx классы используют один backend — изменения видны везде.

import '../../models/aq_user.dart';
import '../../models/aq_tenant.dart';
import '../../models/aq_session.dart';
import '../../models/aq_role.dart';
import '../../models/aq_token_claims.dart';
import '../../models/aq_api_key.dart';
import '../../models/aq_policy.dart';
import '../../models/aq_access_log.dart';
import '../../models/aq_audit_trail.dart';
import '../../models/aq_revoked_token.dart';
import 'mock_security_seed.dart';

/// Единое in-memory состояние security слоя для тестов.
///
/// Все моки портов (MockSecurityService, MockVaultSecurityProtocol,
/// MockAuthContext, MockRoleManagementService, MockPolicyService, MockAuditService)
/// используют один экземпляр этого класса.
///
/// ## Сценарии
///
/// ```dart
/// // Пустое состояние — для тестов регистрации
/// final b = MockSecurityBackend.empty();
///
/// // Admin + tenant — для большинства тестов
/// final b = MockSecurityBackend.withAdmin();
///
/// // Все роли + политики — для тестов RBAC + Policy Engine
/// final b = MockSecurityBackend.withPolicies();
///
/// // Два tenant'а — для тестов изоляции
/// final b = MockSecurityBackend.multiTenant();
///
/// // Истёкшие сущности — для тестов expiry
/// final b = MockSecurityBackend.withExpired();
/// ```
final class MockSecurityBackend {
  MockSecurityBackend._();

  // ── Состояние ──────────────────────────────────────────────────────────────

  final Map<String, AqUser> users = {};
  final Map<String, AqTenant> tenants = {};
  final Map<String, AqSession> sessions = {};
  final Map<String, AqRole> roles = {};
  final Map<String, List<AqUserRole>> userRoles = {}; // userId → assignments
  final Map<String, AqApiKey> apiKeys = {};
  final List<AqAccessPolicy> policies = [];
  final List<AqAccessLog> accessLogs = [];
  final List<AqAuditTrail> auditTrail = [];
  final Set<String> revokedTokenJtis = {};

  // Текущий аутентифицированный пользователь (для MockAuthContext)
  AqTokenClaims? currentClaims;

  // ── Сценарии ───────────────────────────────────────────────────────────────

  /// Пустое состояние. Для тестов регистрации и первого логина.
  factory MockSecurityBackend.empty() => MockSecurityBackend._();

  /// Admin пользователь + tenant A. Для большинства тестов.
  factory MockSecurityBackend.withAdmin() {
    final b = MockSecurityBackend._();
    b.tenants[MockSecuritySeed.tenantAId] = MockSecuritySeed.tenantA;
    b.users[MockSecuritySeed.adminId] = MockSecuritySeed.adminUser;
    b.roles[MockSecuritySeed.adminRoleId] = MockSecuritySeed.adminRole;
    b.userRoles[MockSecuritySeed.adminId] = [MockSecuritySeed.adminUserRole];
    b.sessions[MockSecuritySeed.adminSessionId] = MockSecuritySeed.adminSession;
    b.currentClaims = MockSecuritySeed.adminClaims;
    return b;
  }

  /// Admin + Editor + Viewer + все роли. Для тестов RBAC.
  factory MockSecurityBackend.withRoles() {
    final b = MockSecurityBackend.withAdmin();
    b.users[MockSecuritySeed.editorId] = MockSecuritySeed.editorUser;
    b.users[MockSecuritySeed.viewerId] = MockSecuritySeed.viewerUser;
    b.roles[MockSecuritySeed.editorRoleId] = MockSecuritySeed.editorRole;
    b.roles[MockSecuritySeed.viewerRoleId] = MockSecuritySeed.viewerRole;
    b.userRoles[MockSecuritySeed.editorId] = [MockSecuritySeed.editorUserRole];
    b.userRoles[MockSecuritySeed.viewerId] = [MockSecuritySeed.viewerUserRole];
    b.sessions[MockSecuritySeed.editorSessionId] = MockSecuritySeed.editorSession;
    return b;
  }

  /// Все роли + политики. Для тестов Policy Engine.
  factory MockSecurityBackend.withPolicies() {
    final b = MockSecurityBackend.withRoles();
    b.policies.add(MockSecuritySeed.ipBlockPolicy);
    return b;
  }

  /// Два tenant'а с изолированными пользователями. Для тестов мультитенантности.
  factory MockSecurityBackend.multiTenant() {
    final b = MockSecurityBackend.withRoles();
    b.tenants[MockSecuritySeed.tenantBId] = MockSecuritySeed.tenantB;
    b.users[MockSecuritySeed.tenantBUserId] = MockSecuritySeed.tenantBUser;
    b.roles[MockSecuritySeed.viewerRoleId] ??= MockSecuritySeed.viewerRole;
    b.userRoles[MockSecuritySeed.tenantBUserId] = [MockSecuritySeed.tenantBUserRole];
    return b;
  }

  /// Истёкшие сессии и токены. Для тестов expiry и refresh rotation.
  factory MockSecurityBackend.withExpired() {
    final b = MockSecurityBackend.withRoles();
    b.sessions[MockSecuritySeed.expiredSessionId] = MockSecuritySeed.expiredSession;
    b.revokedTokenJtis.add(MockSecuritySeed.expiredClaims.jti);
    return b;
  }

  /// Заблокированный пользователь. Для тестов отказа в доступе.
  factory MockSecurityBackend.withBlockedUser() {
    final b = MockSecurityBackend.withRoles();
    b.users[MockSecuritySeed.blockedUserId] = MockSecuritySeed.blockedUser;
    return b;
  }

  // ── Вспомогательные методы ─────────────────────────────────────────────────

  /// Получить claims по токену из заголовка Authorization.
  AqTokenClaims? claimsFromToken(String? token) {
    if (token == null) return null;
    if (revokedTokenJtis.contains(
      MockSecuritySeed.tokenMap[token]?.jti,
    )) return null;
    return MockSecuritySeed.tokenMap[token];
  }

  /// Получить claims из HTTP headers.
  AqTokenClaims? claimsFromHeaders(Map<String, String> headers) {
    final auth = headers['Authorization'] ?? headers['authorization'];
    if (auth == null) return null;
    final token = auth.startsWith('Bearer ') ? auth.substring(7) : auth;
    return claimsFromToken(token);
  }

  /// Получить роли пользователя (не истёкшие).
  List<AqRole> getRolesForUser(String userId) {
    final assignments = userRoles[userId] ?? [];
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return assignments
        .where((ur) => ur.expiresAt == null || ur.expiresAt! > now)
        .map((ur) => roles[ur.roleId])
        .whereType<AqRole>()
        .toList();
  }

  /// Проверить право пользователя (RBAC, без политик).
  bool hasPermission(String userId, String resource, String action) {
    final userRoleList = getRolesForUser(userId);
    for (final role in userRoleList) {
      for (final perm in role.permissions) {
        if (perm == '*:*' || perm == '$resource:$action' ||
            perm == '$resource:*' || perm == '*:$action') {
          return true;
        }
      }
    }
    return false;
  }

  /// Проверить активна ли сессия.
  bool isSessionActive(String sessionId) {
    final session = sessions[sessionId];
    if (session == null) return false;
    if (session.status != SessionStatus.active) return false;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return session.expiresAt > now;
  }

  /// Отозвать токен.
  void revokeToken(String jti) => revokedTokenJtis.add(jti);

  /// Проверить отозван ли токен.
  bool isRevoked(String jti) => revokedTokenJtis.contains(jti);
}
