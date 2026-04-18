// pkgs/aq_schema/lib/security/mock/mock_security_service.dart
//
// Mock реализация ISecurityService для unit и widget тестов.
// ВСЕ классы имеют суффикс Mock для предотвращения попадания в продакшн.

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
import 'mock_role_management_service.dart';
import 'mock_policy_service.dart';
import 'mock_audit_service.dart';

/// Mock реализация ISecurityService для тестов
///
/// Использование в тестах:
/// ```dart
/// void main() {
///   late MockSecurityService mockService;
///
///   setUp(() {
///     mockService = MockSecurityService();
///     setSecurityServiceInstance(mockService);
///   });
///
///   tearDown(() {
///     mockService.dispose();
///   });
///
///   test('should login successfully', () async {
///     final response = await mockService.loginWithEmail(
///       email: 'test@example.com',
///       password: 'password',
///     );
///     expect(response.user.email, 'test@example.com');
///   });
/// }
/// ```
class MockSecurityService implements ISecurityService {
  MockSecurityService({
    SecurityState? initialState,
    this.mockUser,
    this.mockTenant,
    this.mockSession,
  })  : _stateController = StreamController<SecurityState>.broadcast(),
        _currentState = initialState ?? const SecurityStateUnauthenticated() {
    _stateController.add(_currentState);
  }

  final StreamController<SecurityState> _stateController;
  late SecurityState _currentState;

  // Mock данные
  final AqUser? mockUser;
  final AqTenant? mockTenant;
  final AqSession? mockSession;

  // Подсервисы
  late final MockRoleManagementService _roleManagement =
      MockRoleManagementService();
  late final MockPolicyService _policies = MockPolicyService();
  late final MockAuditService _audit = MockAuditService();

  @override
  Stream<SecurityState> get stream => _stateController.stream;

  @override
  SecurityState get state => _currentState;

  @override
  AqUser? get currentUser => _currentState is SecurityStateAuthenticated
      ? (_currentState as SecurityStateAuthenticated).user
      : null;

  @override
  AqTenant? get currentTenant => _currentState is SecurityStateAuthenticated
      ? (_currentState as SecurityStateAuthenticated).tenant
      : null;

  @override
  AqTokenClaims? get currentClaims =>
      _currentState is SecurityStateAuthenticated
          ? (_currentState as SecurityStateAuthenticated).claims
          : null;

  @override
  bool get isAuthenticated => _currentState is SecurityStateAuthenticated;

  @override
  Future<String?> get accessToken async =>
      isAuthenticated ? 'mock_access_token' : null;

  @override
  IRoleManagementService get roleManagement => _roleManagement;

  @override
  IPolicyService get policies => _policies;

  @override
  IAuditService get audit => _audit;

  // ── Методы авторизации ────────────────────────────────────────────────────

  @override
  Future<AuthResponse> loginWithGoogle({
    required String code,
    required String redirectUri,
  }) async {
    return _mockLogin();
  }

  @override
  Future<AuthResponse> loginWithEmail({
    required String email,
    required String password,
  }) async {
    return _mockLogin();
  }

  @override
  Future<AuthResponse> loginWithApiKey(String apiKey) async {
    return _mockLogin();
  }

  @override
  Future<AuthResponse> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    return _mockLogin();
  }

  @override
  Future<void> logout() async {
    _currentState = const SecurityStateUnauthenticated();
    _stateController.add(_currentState);
  }

  @override
  Future<AqTokenPair> refreshTokens() async {
    return const TokenPair(
      accessToken: 'mock_access_token',
      refreshToken: 'mock_refresh_token',
      accessExpiresAt: 10000,
      refreshExpiresAt: 10000,
    );
  }

  @override
  Future<void> restoreSession() async {
    // Mock: ничего не делаем
  }

  // ── Проверка прав ─────────────────────────────────────────────────────────

  @override
  Future<bool> hasPermission(String permission) async => true;

  @override
  Future<bool> hasRole(String role) async => true;

  @override
  Future<bool> hasPermissions(List<String> permissions,
          {bool requireAll = true}) async =>
      true;

  @override
  Future<bool> hasRoles(List<String> roles, {bool requireAll = true}) async =>
      true;

  @override
  Future<List<String>> getResourcePermissions(
    String resourceId, {
    List<String>? actions,
  }) async {
    // Mock: возвращаем все запрошенные действия как разрешённые
    final checkActions = actions ?? ['read', 'write', 'delete', 'admin'];
    final resourceType = resourceId.split('/').first;
    return checkActions.map((action) => '$resourceType:$action').toList();
  }

  // ── Управление сессиями ───────────────────────────────────────────────────

  @override
  Future<List<AqSession>> getActiveSessions() async {
    return [
      if (mockSession != null) mockSession!,
    ];
  }

  @override
  Future<void> revokeSession(String sessionId) async {}

  @override
  Future<void> revokeAllOtherSessions() async {}

  // ── Управление API ключами ────────────────────────────────────────────────

  @override
  Future<List<AqApiKey>> getApiKeys() async => [];

  @override
  Future<AqApiKey> createApiKey({
    required String name,
    required List<String> permissions,
    bool isTest = false,
  }) async {
    return AqApiKey(
      id: 'mock_key_id',
      userId: currentUser?.id ?? 'mock_user',
      tenantId: currentTenant?.id ?? 'mock_tenant',
      name: name,
      keyPrefix: 'mock_key',
      keyHash: 'mock_hash',
      permissions: permissions,
      isActive: true,
      createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    );
  }

  @override
  Future<AqApiKey> rotateApiKey(String keyId) async {
    return AqApiKey(
      id: keyId,
      userId: currentUser?.id ?? 'mock_user',
      tenantId: currentTenant?.id ?? 'mock_tenant',
      name: 'Rotated Key',
      keyPrefix: 'mock_key',
      keyHash: 'mock_hash_new',
      permissions: [],
      isActive: true,
      createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      lastRotatedAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    );
  }

  @override
  Future<void> revokeApiKey(String keyId) async {}

  // ── Управление профилем ───────────────────────────────────────────────────

  @override
  Future<AqUser> updateProfile({String? displayName, String? avatarUrl}) async {
    return currentUser ?? _createMockUser();
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {}

  @override
  Future<void> requestPasswordReset(String email) async {}

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {}

  // ── Верификация email ─────────────────────────────────────────────────────

  @override
  Future<void> sendVerificationCode() async {}

  @override
  Future<void> verifyEmail(String code) async {}

  // ── Управление тенантами ──────────────────────────────────────────────────

  @override
  Future<List<AqTenant>> getAvailableTenants() async {
    return [
      if (mockTenant != null) mockTenant!,
    ];
  }

  @override
  Future<void> switchTenant(String tenantId) async {}

  // ── Утилиты ───────────────────────────────────────────────────────────────

  @override
  Future<bool> validateToken(String token) async => true;

  @override
  Future<void> dispose() async {
    await _stateController.close();
  }

  // ── Вспомогательные методы ────────────────────────────────────────────────

  AuthResponse _mockLogin() {
    final user = mockUser ?? _createMockUser();
    final tenant = mockTenant ?? _createMockTenant();
    final session = mockSession ?? _createMockSession(user.id, tenant.id);
    final tokens = const TokenPair(
      accessToken: 'mock_access_token',
      refreshToken: 'mock_refresh_token',
      accessExpiresAt: 10000,
      refreshExpiresAt: 10000,
    );

    _currentState = SecurityStateAuthenticated(
      user: user,
      tenant: tenant,
      session: session,
      claims: _createMockClaims(user.id, tenant.id),
    );
    _stateController.add(_currentState);

    return AuthResponse(
      user: user,
      tenant: tenant,
      session: session,
      tokens: tokens,
    );
  }

  AqUser _createMockUser() {
    return AqUser(
      id: 'mock_user_id',
      email: 'mock@example.com',
      displayName: 'Mock User',
      userType: UserType.developer,
      tenantId: 'mock_tenant_id',
      authProvider: IdentityProvider.mock,
      isActive: true,
      createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    );
  }

  AqTenant _createMockTenant() {
    return AqTenant(
      id: 'mock_tenant_id',
      name: 'Mock Tenant',
      slug: 'mock-tenant',
      plan: TenantPlan.free,
      isActive: true,
      createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    );
  }

  AqSession _createMockSession(String userId, String tenantId) {
    return AqSession(
      id: 'mock_session_id',
      userId: userId,
      tenantId: tenantId,
      status: SessionStatus.active,
      authProvider: IdentityProvider.mock,
      createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      expiresAt: DateTime.now()
              .add(const Duration(hours: 24))
              .millisecondsSinceEpoch ~/
          1000,
      lastSeenAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    );
  }

  AqTokenClaims _createMockClaims(String userId, String tenantId) {
    return AqTokenClaims(
      sub: userId,
      tid: tenantId,
      email: 'mock@example.com',
      type: TokenType.access,
      jti: 'mock_jti',
      sid: 'mock_session_id',
      iat: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      exp:
          DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/
              1000,
      scopes: ['read', 'write'],
      roles: ['user'],
    );
  }
}
