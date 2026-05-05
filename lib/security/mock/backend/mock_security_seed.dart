// aq_schema/lib/security/mock/backend/mock_security_seed.dart
//
// Константы для MockSecurityBackend.
// Стабильные ID и данные — одинаковы во всех тестах.

import '../../models/aq_user.dart';
import '../../models/aq_tenant.dart';
import '../../models/aq_session.dart';
import '../../models/aq_role.dart';
import '../../models/aq_token_claims.dart';
import '../../models/aq_api_key.dart';
import '../../models/aq_policy.dart';
import '../../models/access_context.dart';

abstract final class MockSecuritySeed {
  // ── Timestamps ─────────────────────────────────────────────────────────────
  static const int _now = 1746000000; // фиксированный timestamp
  static const int _future = 1746000000 + 86400 * 30; // +30 дней
  static const int _past = 1746000000 - 86400; // -1 день (истёкший)

  // ── Tenant A ───────────────────────────────────────────────────────────────
  static const String tenantAId = 'tenant-a';
  static const String tenantBId = 'tenant-b';

  static const AqTenant tenantA = AqTenant(
    id: tenantAId,
    name: 'Tenant A',
    slug: 'tenant-a',
    plan: TenantPlan.pro,
    isActive: true,
    createdAt: _now,
  );

  static const AqTenant tenantB = AqTenant(
    id: tenantBId,
    name: 'Tenant B',
    slug: 'tenant-b',
    plan: TenantPlan.free,
    isActive: true,
    createdAt: _now,
  );

  // ── Roles ──────────────────────────────────────────────────────────────────
  static const String adminRoleId = 'role-admin';
  static const String editorRoleId = 'role-editor';
  static const String viewerRoleId = 'role-viewer';

  static const AqRole adminRole = AqRole(
    id: adminRoleId,
    name: 'admin',
    permissions: ['*:*'],
    isSystem: true,
    createdAt: _now,
  );

  static const AqRole editorRole = AqRole(
    id: editorRoleId,
    name: 'editor',
    permissions: [
      'projects:read', 'projects:write',
      'graphs:read', 'graphs:write',
    ],
    inheritsFrom: [viewerRoleId],
    isSystem: true,
    createdAt: _now,
  );

  static const AqRole viewerRole = AqRole(
    id: viewerRoleId,
    name: 'viewer',
    permissions: ['projects:read', 'graphs:read'],
    isSystem: true,
    createdAt: _now,
  );

  // ── Users ──────────────────────────────────────────────────────────────────
  static const String adminId = 'user-admin';
  static const String editorId = 'user-editor';
  static const String viewerId = 'user-viewer';
  static const String tenantBUserId = 'user-tenant-b';
  static const String blockedUserId = 'user-blocked';

  static const AqUser adminUser = AqUser(
    id: adminId,
    email: 'admin@test.com',
    displayName: 'Admin User',
    tenantId: tenantAId,
    authProvider: IdentityProvider.emailPassword,
    userType: UserType.platformAdmin,
    isActive: true,
    createdAt: _now,
  );

  static const AqUser editorUser = AqUser(
    id: editorId,
    email: 'editor@test.com',
    displayName: 'Editor User',
    tenantId: tenantAId,
    authProvider: IdentityProvider.emailPassword,
    userType: UserType.developer,
    isActive: true,
    createdAt: _now,
  );

  static const AqUser viewerUser = AqUser(
    id: viewerId,
    email: 'viewer@test.com',
    displayName: 'Viewer User',
    tenantId: tenantAId,
    authProvider: IdentityProvider.emailPassword,
    userType: UserType.developer,
    isActive: true,
    createdAt: _now,
  );

  static const AqUser tenantBUser = AqUser(
    id: tenantBUserId,
    email: 'user@tenant-b.com',
    displayName: 'Tenant B User',
    tenantId: tenantBId,
    authProvider: IdentityProvider.emailPassword,
    userType: UserType.developer,
    isActive: true,
    createdAt: _now,
  );

  static const AqUser blockedUser = AqUser(
    id: blockedUserId,
    email: 'blocked@test.com',
    displayName: 'Blocked User',
    tenantId: tenantAId,
    authProvider: IdentityProvider.emailPassword,
    userType: UserType.developer,
    isActive: false, // заблокирован
    createdAt: _now,
  );

  // ── Sessions ───────────────────────────────────────────────────────────────
  static const String adminSessionId = 'session-admin';
  static const String editorSessionId = 'session-editor';
  static const String expiredSessionId = 'session-expired';

  static const AqSession adminSession = AqSession(
    id: adminSessionId,
    userId: adminId,
    tenantId: tenantAId,
    status: SessionStatus.active,
    authProvider: IdentityProvider.emailPassword,
    kind: SessionKind.human,
    createdAt: _now,
    expiresAt: _future,
    lastSeenAt: _now,
  );

  static const AqSession editorSession = AqSession(
    id: editorSessionId,
    userId: editorId,
    tenantId: tenantAId,
    status: SessionStatus.active,
    authProvider: IdentityProvider.emailPassword,
    kind: SessionKind.human,
    createdAt: _now,
    expiresAt: _future,
    lastSeenAt: _now,
  );

  static const AqSession expiredSession = AqSession(
    id: expiredSessionId,
    userId: viewerId,
    tenantId: tenantAId,
    status: SessionStatus.expired,
    authProvider: IdentityProvider.emailPassword,
    kind: SessionKind.human,
    createdAt: _past,
    expiresAt: _past, // уже истёк
    lastSeenAt: _past,
  );

  // ── Token Claims ───────────────────────────────────────────────────────────
  static const AqTokenClaims adminClaims = AqTokenClaims(
    sub: adminId,
    tid: tenantAId,
    email: 'admin@test.com',
    type: TokenType.access,
    roles: ['admin'],
    scopes: ['*:*'],
    iat: _now,
    exp: _future,
    jti: 'jti-admin',
    sid: adminSessionId,
  );

  static const AqTokenClaims editorClaims = AqTokenClaims(
    sub: editorId,
    tid: tenantAId,
    email: 'editor@test.com',
    type: TokenType.access,
    roles: ['editor'],
    scopes: ['projects:read', 'projects:write', 'graphs:read', 'graphs:write'],
    iat: _now,
    exp: _future,
    jti: 'jti-editor',
    sid: editorSessionId,
  );

  static const AqTokenClaims viewerClaims = AqTokenClaims(
    sub: viewerId,
    tid: tenantAId,
    email: 'viewer@test.com',
    type: TokenType.access,
    roles: ['viewer'],
    scopes: ['projects:read', 'graphs:read'],
    iat: _now,
    exp: _future,
    jti: 'jti-viewer',
    sid: 'session-viewer',
  );

  static const AqTokenClaims expiredClaims = AqTokenClaims(
    sub: viewerId,
    tid: tenantAId,
    email: 'viewer@test.com',
    type: TokenType.access,
    roles: ['viewer'],
    scopes: ['projects:read'],
    iat: _past,
    exp: _past, // истёк
    jti: 'jti-expired',
    sid: expiredSessionId,
  );

  static const AqTokenClaims tenantBClaims = AqTokenClaims(
    sub: tenantBUserId,
    tid: tenantBId,
    email: 'user@tenant-b.com',
    type: TokenType.access,
    roles: ['viewer'],
    scopes: ['projects:read'],
    iat: _now,
    exp: _future,
    jti: 'jti-tenant-b',
    sid: 'session-tenant-b',
  );

  // ── Token strings (для HTTP headers) ──────────────────────────────────────
  static const String adminToken = 'mock-token-admin';
  static const String editorToken = 'mock-token-editor';
  static const String viewerToken = 'mock-token-viewer';
  static const String expiredToken = 'mock-token-expired';
  static const String revokedToken = 'mock-token-revoked';
  static const String tenantBToken = 'mock-token-tenant-b';

  static const Map<String, AqTokenClaims> tokenMap = {
    adminToken: adminClaims,
    editorToken: editorClaims,
    viewerToken: viewerClaims,
    expiredToken: expiredClaims,
    tenantBToken: tenantBClaims,
  };

  // ── API Keys ───────────────────────────────────────────────────────────────
  static const String apiKeyId = 'apikey-1';
  static const String apiKeyRaw = 'aq_test_api_key_12345';

  static const AqApiKey apiKey = AqApiKey(
    id: apiKeyId,
    userId: editorId,
    tenantId: tenantAId,
    name: 'Test API Key',
    keyPrefix: 'aq_test',
    keyHash: 'hash_of_aq_test_api_key_12345',
    permissions: ['projects:read', 'projects:write'],
    isActive: true,
    createdAt: _now,
  );

  // ── Policies ───────────────────────────────────────────────────────────────
  static final AqAccessPolicy ipBlockPolicy = AqAccessPolicy(
    id: 'policy-ip-block',
    name: 'Block suspicious IPs',
    tenantId: tenantAId,
    priority: 100,
    isActive: true,
    statements: [
      PolicyStatement(
        effect: PolicyEffect.deny,
        conditions: [
          PolicyCondition(
            type: PolicyConditionType.ipAddress,
            operator: PolicyOperator.inList,
            value: ['1.2.3.4', '10.0.0.99'],
          ),
        ],
      ),
    ],
    createdAt: _now,
    createdBy: adminId,
  );

  // ── User Role assignments ──────────────────────────────────────────────────
  static const AqUserRole adminUserRole = AqUserRole(
    userId: adminId,
    roleId: adminRoleId,
    tenantId: tenantAId,
    grantedAt: _now,
  );

  static const AqUserRole editorUserRole = AqUserRole(
    userId: editorId,
    roleId: editorRoleId,
    tenantId: tenantAId,
    grantedAt: _now,
  );

  static const AqUserRole viewerUserRole = AqUserRole(
    userId: viewerId,
    roleId: viewerRoleId,
    tenantId: tenantAId,
    grantedAt: _now,
  );

  static const AqUserRole tenantBUserRole = AqUserRole(
    userId: tenantBUserId,
    roleId: viewerRoleId,
    tenantId: tenantBId,
    grantedAt: _now,
  );

  // Временная роль (истекает через 1 секунду от _now)
  static const AqUserRole temporaryRole = AqUserRole(
    userId: viewerId,
    roleId: adminRoleId,
    tenantId: tenantAId,
    grantedAt: _now,
    expiresAt: _now + 1,
  );
}
