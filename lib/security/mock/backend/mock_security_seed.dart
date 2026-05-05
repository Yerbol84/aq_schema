// aq_schema/lib/security/mock/backend/mock_security_seed.dart
//
// Seed данные для MockSecurityBackend.
// ID и имена — константы. Timestamps — динамические (от DateTime.now()).

import '../../models/aq_user.dart';
import '../../models/aq_tenant.dart';
import '../../models/aq_session.dart';
import '../../models/aq_role.dart';
import '../../models/aq_token_claims.dart';
import '../../models/aq_api_key.dart';
import '../../models/aq_policy.dart';
import '../../models/access_context.dart';

abstract final class MockSecuritySeed {
  // ── Timestamps (динамические) ──────────────────────────────────────────────
  static int get now => DateTime.now().millisecondsSinceEpoch ~/ 1000;
  static int get future => now + 86400 * 365; // +1 год
  static int get past => now - 86400;          // -1 день (истёкший)

  // ── IDs (константы) ───────────────────────────────────────────────────────
  static const String tenantAId = 'tenant-a';
  static const String tenantBId = 'tenant-b';

  static const String adminRoleId = 'role-admin';
  static const String editorRoleId = 'role-editor';
  static const String viewerRoleId = 'role-viewer';

  static const String adminId = 'user-admin';
  static const String editorId = 'user-editor';
  static const String viewerId = 'user-viewer';
  static const String tenantBUserId = 'user-tenant-b';
  static const String blockedUserId = 'user-blocked';

  static const String adminSessionId = 'session-admin';
  static const String editorSessionId = 'session-editor';
  static const String expiredSessionId = 'session-expired';

  static const String adminToken = 'mock-token-admin';
  static const String editorToken = 'mock-token-editor';
  static const String viewerToken = 'mock-token-viewer';
  static const String expiredToken = 'mock-token-expired';
  static const String revokedToken = 'mock-token-revoked';
  static const String tenantBToken = 'mock-token-tenant-b';

  static const String apiKeyId = 'apikey-1';
  static const String apiKeyRaw = 'aq_test_api_key_12345';

  // ── Tenants ────────────────────────────────────────────────────────────────
  static AqTenant get tenantA => AqTenant(
        id: tenantAId, name: 'Tenant A', slug: 'tenant-a',
        plan: TenantPlan.pro, isActive: true, createdAt: now,
      );

  static AqTenant get tenantB => AqTenant(
        id: tenantBId, name: 'Tenant B', slug: 'tenant-b',
        plan: TenantPlan.free, isActive: true, createdAt: now,
      );

  // ── Roles ──────────────────────────────────────────────────────────────────
  static AqRole get adminRole => AqRole(
        id: adminRoleId, name: 'admin', permissions: ['*:*'],
        isSystem: true, createdAt: now,
      );

  static AqRole get editorRole => AqRole(
        id: editorRoleId, name: 'editor',
        permissions: ['projects:read', 'projects:write', 'graphs:read', 'graphs:write'],
        inheritsFrom: [viewerRoleId], isSystem: true, createdAt: now,
      );

  static AqRole get viewerRole => AqRole(
        id: viewerRoleId, name: 'viewer',
        permissions: ['projects:read', 'graphs:read'],
        isSystem: true, createdAt: now,
      );

  // ── Users ──────────────────────────────────────────────────────────────────
  static AqUser get adminUser => AqUser(
        id: adminId, email: 'admin@test.com', displayName: 'Admin User',
        tenantId: tenantAId, authProvider: IdentityProvider.emailPassword,
        userType: UserType.platformAdmin, isActive: true, createdAt: now,
      );

  static AqUser get editorUser => AqUser(
        id: editorId, email: 'editor@test.com', displayName: 'Editor User',
        tenantId: tenantAId, authProvider: IdentityProvider.emailPassword,
        userType: UserType.developer, isActive: true, createdAt: now,
      );

  static AqUser get viewerUser => AqUser(
        id: viewerId, email: 'viewer@test.com', displayName: 'Viewer User',
        tenantId: tenantAId, authProvider: IdentityProvider.emailPassword,
        userType: UserType.developer, isActive: true, createdAt: now,
      );

  static AqUser get tenantBUser => AqUser(
        id: tenantBUserId, email: 'user@tenant-b.com', displayName: 'Tenant B User',
        tenantId: tenantBId, authProvider: IdentityProvider.emailPassword,
        userType: UserType.developer, isActive: true, createdAt: now,
      );

  static AqUser get blockedUser => AqUser(
        id: blockedUserId, email: 'blocked@test.com', displayName: 'Blocked User',
        tenantId: tenantAId, authProvider: IdentityProvider.emailPassword,
        userType: UserType.developer, isActive: false, createdAt: now,
      );

  // ── Sessions ───────────────────────────────────────────────────────────────
  static AqSession get adminSession => AqSession(
        id: adminSessionId, userId: adminId, tenantId: tenantAId,
        status: SessionStatus.active, authProvider: IdentityProvider.emailPassword,
        kind: SessionKind.human, createdAt: now, expiresAt: future, lastSeenAt: now,
      );

  static AqSession get editorSession => AqSession(
        id: editorSessionId, userId: editorId, tenantId: tenantAId,
        status: SessionStatus.active, authProvider: IdentityProvider.emailPassword,
        kind: SessionKind.human, createdAt: now, expiresAt: future, lastSeenAt: now,
      );

  static AqSession get expiredSession => AqSession(
        id: expiredSessionId, userId: viewerId, tenantId: tenantAId,
        status: SessionStatus.expired, authProvider: IdentityProvider.emailPassword,
        kind: SessionKind.human, createdAt: past, expiresAt: past, lastSeenAt: past,
      );

  // ── Token Claims ───────────────────────────────────────────────────────────
  static AqTokenClaims get adminClaims => AqTokenClaims(
        sub: adminId, tid: tenantAId, email: 'admin@test.com',
        type: TokenType.access, roles: ['admin'], scopes: ['*:*'],
        iat: now, exp: future, jti: 'jti-admin', sid: adminSessionId,
      );

  static AqTokenClaims get editorClaims => AqTokenClaims(
        sub: editorId, tid: tenantAId, email: 'editor@test.com',
        type: TokenType.access, roles: ['editor'],
        scopes: ['projects:read', 'projects:write', 'graphs:read', 'graphs:write'],
        iat: now, exp: future, jti: 'jti-editor', sid: editorSessionId,
      );

  static AqTokenClaims get viewerClaims => AqTokenClaims(
        sub: viewerId, tid: tenantAId, email: 'viewer@test.com',
        type: TokenType.access, roles: ['viewer'],
        scopes: ['projects:read', 'graphs:read'],
        iat: now, exp: future, jti: 'jti-viewer', sid: 'session-viewer',
      );

  static AqTokenClaims get expiredClaims => AqTokenClaims(
        sub: viewerId, tid: tenantAId, email: 'viewer@test.com',
        type: TokenType.access, roles: ['viewer'], scopes: ['projects:read'],
        iat: past, exp: past, // истёк
        jti: 'jti-expired', sid: expiredSessionId,
      );

  static AqTokenClaims get tenantBClaims => AqTokenClaims(
        sub: tenantBUserId, tid: tenantBId, email: 'user@tenant-b.com',
        type: TokenType.access, roles: ['viewer'], scopes: ['projects:read'],
        iat: now, exp: future, jti: 'jti-tenant-b', sid: 'session-tenant-b',
      );

  // tokenMap — геттер, пересоздаётся с актуальными timestamps
  static Map<String, AqTokenClaims> get tokenMap => {
        adminToken: adminClaims,
        editorToken: editorClaims,
        viewerToken: viewerClaims,
        expiredToken: expiredClaims,
        tenantBToken: tenantBClaims,
      };

  // ── API Key ────────────────────────────────────────────────────────────────
  static AqApiKey get apiKey => AqApiKey(
        id: apiKeyId, userId: editorId, tenantId: tenantAId,
        name: 'Test API Key', keyPrefix: 'aq_test',
        keyHash: 'hash_of_aq_test_api_key_12345',
        permissions: ['projects:read', 'projects:write'],
        isActive: true, createdAt: now,
      );

  // ── Policy ─────────────────────────────────────────────────────────────────
  static AqAccessPolicy get ipBlockPolicy => AqAccessPolicy(
        id: 'policy-ip-block', name: 'Block suspicious IPs',
        tenantId: tenantAId, priority: 100, isActive: true,
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
        createdAt: now, createdBy: adminId,
      );

  // ── User Role assignments ──────────────────────────────────────────────────
  static AqUserRole get adminUserRole => AqUserRole(
        userId: adminId, roleId: adminRoleId,
        tenantId: tenantAId, grantedAt: now,
      );

  static AqUserRole get editorUserRole => AqUserRole(
        userId: editorId, roleId: editorRoleId,
        tenantId: tenantAId, grantedAt: now,
      );

  static AqUserRole get viewerUserRole => AqUserRole(
        userId: viewerId, roleId: viewerRoleId,
        tenantId: tenantAId, grantedAt: now,
      );

  static AqUserRole get tenantBUserRole => AqUserRole(
        userId: tenantBUserId, roleId: viewerRoleId,
        tenantId: tenantBId, grantedAt: now,
      );

  static AqUserRole get temporaryRole => AqUserRole(
        userId: viewerId, roleId: adminRoleId,
        tenantId: tenantAId, grantedAt: now,
        expiresAt: now + 1, // истекает через 1 секунду
      );
}
