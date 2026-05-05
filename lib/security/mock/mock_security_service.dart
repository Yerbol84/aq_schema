// aq_schema/lib/security/mock/mock_security_service.dart
//
// Mock ISecurityService — использует MockSecurityBackend.
//
// Гарантии реализации (aq_security обязан соблюдать):
//   loginWithEmail(верные credentials)   → AuthResponse
//   loginWithEmail(неверный пароль)      → throws Exception('invalid_credentials')
//   loginWithEmail(несуществующий email) → throws Exception('user_not_found')
//   loginWithEmail(заблокированный user) → throws Exception('user_disabled')
//   logout()                             → сессия отзывается, state = Unauthenticated
//   hasPermission(право из токена)       → true (локально, из claims)
//   hasPermission(отсутствующее право)   → false

import 'dart:async';
import '../interfaces/i_security_service.dart';
import '../interfaces/i_role_management_service.dart';
import '../interfaces/i_policy_service.dart';
import '../interfaces/i_audit_service.dart';
import '../models/aq_user.dart';
import '../models/aq_tenant.dart';
import '../models/aq_session.dart';
import '../models/aq_token_claims.dart';
import '../models/aq_api_key.dart';
import 'backend/mock_security_backend.dart';
import 'backend/mock_security_seed.dart';
import 'mock_role_management_service.dart';
import 'mock_policy_service.dart';
import 'mock_audit_service.dart';

final class MockSecurityService implements ISecurityService {
  MockSecurityService(this._backend)
      : _stateController = StreamController<SecurityState>.broadcast() {
    // Если backend уже имеет currentClaims — восстановить состояние
    final claims = _backend.currentClaims;
    if (claims != null) {
      final user = _backend.users[claims.sub];
      final tenant = _backend.tenants[claims.tid];
      final session = _backend.sessions[claims.sid];
      if (user != null && tenant != null && session != null) {
        _state = SecurityStateAuthenticated(
          user: user, tenant: tenant, session: session, claims: claims,
        );
      }
    }
    _stateController.add(_state);
  }

  final MockSecurityBackend _backend;
  final StreamController<SecurityState> _stateController;
  SecurityState _state = const SecurityStateUnauthenticated();

  late final MockRoleManagementService _roleManagement =
      MockRoleManagementService(_backend);
  late final MockPolicyService _policies = MockPolicyService(_backend);
  late final MockAuditService _audit = MockAuditService(_backend);

  // ── State ──────────────────────────────────────────────────────────────────

  @override Stream<SecurityState> get stream => _stateController.stream;
  @override SecurityState get state => _state;
  @override bool get isAuthenticated => _state is SecurityStateAuthenticated;

  @override
  AqUser? get currentUser =>
      _state is SecurityStateAuthenticated
          ? (_state as SecurityStateAuthenticated).user : null;

  @override
  AqTenant? get currentTenant =>
      _state is SecurityStateAuthenticated
          ? (_state as SecurityStateAuthenticated).tenant : null;

  @override
  AqTokenClaims? get currentClaims =>
      _state is SecurityStateAuthenticated
          ? (_state as SecurityStateAuthenticated).claims : null;

  @override
  Future<String?> get accessToken async =>
      isAuthenticated ? MockSecuritySeed.adminToken : null;

  @override IRoleManagementService get roleManagement => _roleManagement;
  @override IPolicyService get policies => _policies;
  @override IAuditService get audit => _audit;

  // ── Auth ───────────────────────────────────────────────────────────────────

  @override
  Future<AuthResponse> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final user = _backend.users.values
        .where((u) => u.email == email)
        .firstOrNull;

    if (user == null) throw Exception('user_not_found');
    if (!user.isActive) throw Exception('user_disabled');
    // Mock: пароль 'wrong' всегда неверный, остальные — верные
    if (password == 'wrong') throw Exception('invalid_credentials');

    return _loginAs(user);
  }

  @override
  Future<AuthResponse> loginWithApiKey(String apiKey) async {
    final key = _backend.apiKeys.values
        .where((k) => k.isActive && !k.isExpired)
        .firstOrNull;
    if (key == null) throw Exception('invalid_api_key');

    final user = _backend.users[key.userId];
    if (user == null || !user.isActive) throw Exception('user_not_found');
    return _loginAs(user);
  }

  @override
  Future<AuthResponse> loginWithGoogle({
    required String code,
    required String redirectUri,
  }) async {
    // Mock: code 'invalid' → ошибка
    if (code == 'invalid') throw Exception('invalid_oauth_code');
    final user = _backend.users.values.firstOrNull;
    if (user == null) throw Exception('user_not_found');
    return _loginAs(user);
  }

  @override
  Future<AuthResponse> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    if (_backend.users.values.any((u) => u.email == email)) {
      throw Exception('email_already_exists');
    }
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final user = AqUser(
      id: 'user-${_backend.users.length + 1}',
      email: email,
      displayName: displayName ?? email.split('@').first,
      tenantId: _backend.tenants.keys.firstOrNull ?? 'default',
      authProvider: IdentityProvider.emailPassword,
      userType: UserType.developer,
      isActive: true,
      createdAt: now,
    );
    _backend.users[user.id] = user;
    return _loginAs(user);
  }

  @override
  Future<void> logout() async {
    final claims = currentClaims;
    if (claims != null) {
      final session = _backend.sessions[claims.sid];
      if (session != null) {
        _backend.sessions[claims.sid] = AqSession(
          id: session.id, userId: session.userId, tenantId: session.tenantId,
          status: SessionStatus.revoked, authProvider: session.authProvider,
          kind: session.kind, createdAt: session.createdAt,
          expiresAt: session.expiresAt, lastSeenAt: session.lastSeenAt,
        );
      }
      _backend.revokeToken(claims.jti);
      _backend.currentClaims = null;
    }
    _state = const SecurityStateUnauthenticated();
    _stateController.add(_state);
  }

  @override
  Future<AqTokenPair> refreshTokens() async {
    if (!isAuthenticated) throw Exception('not_authenticated');
    return const TokenPair(
      accessToken: MockSecuritySeed.adminToken,
      refreshToken: 'mock-refresh-token',
      accessExpiresAt: MockSecuritySeed.adminClaims.exp,
      refreshExpiresAt: MockSecuritySeed.adminClaims.exp,
    );
  }

  @override
  Future<void> restoreSession() async {
    // Mock: ничего не делаем — состояние уже в backend
  }

  // ── Permissions (локально из токена) ──────────────────────────────────────

  @override
  Future<bool> hasPermission(String permission) async {
    final claims = currentClaims;
    if (claims == null) return false;
    return claims.scopes.contains('*:*') ||
        claims.scopes.contains(permission) ||
        claims.scopes.contains('${permission.split(':').first}:*');
  }

  @override
  Future<bool> hasRole(String role) async =>
      currentClaims?.roles.contains(role) ?? false;

  @override
  Future<bool> hasPermissions(List<String> permissions,
      {bool requireAll = true}) async {
    if (requireAll) {
      for (final p in permissions) {
        if (!await hasPermission(p)) return false;
      }
      return true;
    }
    for (final p in permissions) {
      if (await hasPermission(p)) return true;
    }
    return false;
  }

  @override
  Future<bool> hasRoles(List<String> roles, {bool requireAll = true}) async {
    if (requireAll) {
      for (final r in roles) {
        if (!await hasRole(r)) return false;
      }
      return true;
    }
    for (final r in roles) {
      if (await hasRole(r)) return true;
    }
    return false;
  }

  @override
  Future<List<String>> getResourcePermissions(
    String resourceId, {
    List<String>? actions,
  }) async {
    final claims = currentClaims;
    if (claims == null) return [];
    final resourceType = resourceId.split('/').first;
    final checkActions = actions ?? ['read', 'write', 'delete', 'admin'];
    return checkActions
        .where((a) =>
            claims.scopes.contains('*:*') ||
            claims.scopes.contains('$resourceType:$a') ||
            claims.scopes.contains('$resourceType:*'))
        .map((a) => '$resourceType:$a')
        .toList();
  }

  // ── Sessions ───────────────────────────────────────────────────────────────

  @override
  Future<List<AqSession>> getActiveSessions() async {
    final userId = currentClaims?.sub;
    if (userId == null) return [];
    return _backend.sessions.values
        .where((s) => s.userId == userId && s.status == SessionStatus.active)
        .toList();
  }

  @override
  Future<void> revokeSession(String sessionId) async {
    final s = _backend.sessions[sessionId];
    if (s == null) return;
    _backend.sessions[sessionId] = AqSession(
      id: s.id, userId: s.userId, tenantId: s.tenantId,
      status: SessionStatus.revoked, authProvider: s.authProvider,
      kind: s.kind, createdAt: s.createdAt,
      expiresAt: s.expiresAt, lastSeenAt: s.lastSeenAt,
    );
  }

  @override
  Future<void> revokeAllOtherSessions() async {
    final currentSid = currentClaims?.sid;
    final userId = currentClaims?.sub;
    if (userId == null) return;
    for (final s in _backend.sessions.values.toList()) {
      if (s.userId == userId && s.id != currentSid) {
        await revokeSession(s.id);
      }
    }
  }

  // ── API Keys ───────────────────────────────────────────────────────────────

  @override
  Future<List<AqApiKey>> getApiKeys() async {
    final userId = currentClaims?.sub;
    if (userId == null) return [];
    return _backend.apiKeys.values.where((k) => k.userId == userId).toList();
  }

  @override
  Future<AqApiKey> createApiKey({
    required String name,
    required List<String> permissions,
    bool isTest = false,
  }) async {
    final claims = currentClaims;
    if (claims == null) throw Exception('not_authenticated');
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final key = AqApiKey(
      id: 'apikey-${_backend.apiKeys.length + 1}',
      userId: claims.sub,
      tenantId: claims.tid,
      name: name,
      keyPrefix: 'aq_mock',
      keyHash: 'mock_hash_$name',
      permissions: permissions,
      isActive: true,
      createdAt: now,
    );
    _backend.apiKeys[key.id] = key;
    return key;
  }

  @override
  Future<AqApiKey> rotateApiKey(String keyId) async {
    final old = _backend.apiKeys[keyId];
    if (old == null) throw Exception('api_key_not_found');
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final newKey = AqApiKey(
      id: 'apikey-rotated-$keyId',
      userId: old.userId, tenantId: old.tenantId, name: old.name,
      keyPrefix: 'aq_mock', keyHash: 'mock_hash_rotated',
      permissions: old.permissions, isActive: true,
      createdAt: now, lastRotatedAt: now,
    );
    _backend.apiKeys[old.id] = AqApiKey(
      id: old.id, userId: old.userId, tenantId: old.tenantId, name: old.name,
      keyPrefix: old.keyPrefix, keyHash: old.keyHash,
      permissions: old.permissions, isActive: false,
      createdAt: old.createdAt, lastRotatedAt: now,
    );
    _backend.apiKeys[newKey.id] = newKey;
    return newKey;
  }

  @override
  Future<void> revokeApiKey(String keyId) async {
    final k = _backend.apiKeys[keyId];
    if (k == null) return;
    _backend.apiKeys[keyId] = AqApiKey(
      id: k.id, userId: k.userId, tenantId: k.tenantId, name: k.name,
      keyPrefix: k.keyPrefix, keyHash: k.keyHash,
      permissions: k.permissions, isActive: false, createdAt: k.createdAt,
    );
  }

  // ── Profile ────────────────────────────────────────────────────────────────

  @override
  Future<AqUser> updateProfile({String? displayName, String? avatarUrl}) async {
    final user = currentUser;
    if (user == null) throw Exception('not_authenticated');
    final updated = AqUser(
      id: user.id, email: user.email, tenantId: user.tenantId,
      authProvider: user.authProvider, userType: user.userType,
      isActive: user.isActive, createdAt: user.createdAt,
      displayName: displayName ?? user.displayName,
      avatarUrl: avatarUrl ?? user.avatarUrl,
    );
    _backend.users[user.id] = updated;
    return updated;
  }

  @override Future<void> changePassword({required String oldPassword, required String newPassword}) async {
    if (oldPassword == 'wrong') throw Exception('invalid_password');
  }
  @override Future<void> requestPasswordReset(String email) async {}
  @override Future<void> resetPassword({required String email, required String code, required String newPassword}) async {
    if (code == 'invalid') throw Exception('invalid_reset_code');
  }
  @override Future<void> sendVerificationCode() async {}
  @override Future<void> verifyEmail(String code) async {
    if (code == 'invalid') throw Exception('invalid_verification_code');
  }

  // ── Tenants ────────────────────────────────────────────────────────────────

  @override
  Future<List<AqTenant>> getAvailableTenants() async =>
      _backend.tenants.values.toList();

  @override
  Future<void> switchTenant(String tenantId) async {
    if (!_backend.tenants.containsKey(tenantId)) {
      throw Exception('tenant_not_found');
    }
  }

  @override
  Future<bool> validateToken(String token) async =>
      MockSecuritySeed.tokenMap.containsKey(token) &&
      !_backend.isRevoked(MockSecuritySeed.tokenMap[token]!.jti);

  @override
  Future<void> dispose() async => _stateController.close();

  // ── Internal ───────────────────────────────────────────────────────────────

  AuthResponse _loginAs(AqUser user) {
    final tenant = _backend.tenants[user.tenantId] ??
        AqTenant(
          id: user.tenantId, name: user.tenantId, slug: user.tenantId,
          plan: TenantPlan.free, isActive: true,
          createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        );
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final session = AqSession(
      id: 'session-${user.id}', userId: user.id, tenantId: user.tenantId,
      status: SessionStatus.active, authProvider: user.authProvider,
      kind: SessionKind.human, createdAt: now,
      expiresAt: now + 86400, lastSeenAt: now,
    );
    _backend.sessions[session.id] = session;

    final roles = _backend.getRolesForUser(user.id);
    final scopes = roles.expand((r) => r.permissions).toSet().toList();
    final roleNames = roles.map((r) => r.name).toList();

    final claims = AqTokenClaims(
      sub: user.id, tid: user.tenantId, email: user.email,
      type: TokenType.access, roles: roleNames, scopes: scopes,
      iat: now, exp: now + 3600,
      jti: 'jti-${user.id}-$now', sid: session.id,
    );
    _backend.currentClaims = claims;

    _state = SecurityStateAuthenticated(
      user: user, tenant: tenant, session: session, claims: claims,
    );
    _stateController.add(_state);

    return AuthResponse(
      user: user, tenant: tenant, session: session,
      tokens: TokenPair(
        accessToken: 'mock-token-${user.id}',
        refreshToken: 'mock-refresh-${user.id}',
        accessExpiresAt: claims.exp,
        refreshExpiresAt: now + 86400 * 30,
      ),
    );
  }
}
