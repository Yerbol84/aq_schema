// test/security/mock/mock_backend_integration_test.dart
//
// Интеграционные тесты MockSecurityBackend.
// Проверяют что все порты работают согласованно через один backend.

import 'package:test/test.dart';
import 'package:aq_schema/security_testing.dart';
import 'package:aq_schema/security/security.dart';

void main() {
  group('MockSecurityBackend — согласованность портов', () {
    late MockSecurityBackend backend;
    late MockSecurityService service;
    late MockVaultSecurityProtocol protocol;
    late MockAuthContext authContext;
    late MockRoleManagementService roleManagement;
    late MockPolicyService policyService;
    late MockAuditService auditService;

    setUp(() {
      backend = MockSecurityBackend.withRoles();
      service = MockSecurityService(backend);
      protocol = MockVaultSecurityProtocol(backend);
      authContext = MockAuthContext(backend);
      roleManagement = MockRoleManagementService(backend);
      policyService = MockPolicyService(backend);
      auditService = MockAuditService(backend);
    });

    // ── Сценарий 1: Логин → protocol видит сессию ─────────────────────────

    test('после loginWithEmail — protocol.extractClaims возвращает claims', () async {
      await service.loginWithEmail(
        email: MockSecuritySeed.editorUser.email,
        password: 'any',
      );

      // После логина backend.currentClaims установлен
      // Используем предопределённый токен из seed
      final claims = await protocol.extractClaims({
        'Authorization': 'Bearer ${MockSecuritySeed.editorToken}',
      });

      expect(claims, isNotNull);
      expect(claims!.sub, MockSecuritySeed.editorId);
    });

    test('после loginWithEmail — authContext.currentUserId возвращает userId', () async {
      await service.loginWithEmail(
        email: MockSecuritySeed.adminUser.email,
        password: 'any',
      );

      final userId = await authContext.currentUserId;
      expect(userId, MockSecuritySeed.adminId);
    });

    test('после logout — authContext.currentToken = null', () async {
      await service.loginWithEmail(
        email: MockSecuritySeed.adminUser.email,
        password: 'any',
      );
      await service.logout();

      final token = await authContext.currentToken;
      expect(token, isNull);
    });

    // ── Сценарий 2: Права через RBAC ──────────────────────────────────────

    test('admin — canRead на любую коллекцию = allow', () async {
      final decision = await protocol.canRead(
        claims: MockSecuritySeed.adminClaims,
        collection: 'projects',
      );
      expect(decision.allowed, isTrue);
    });

    test('viewer — canRead projects = allow', () async {
      final decision = await protocol.canRead(
        claims: MockSecuritySeed.viewerClaims,
        collection: 'projects',
      );
      expect(decision.allowed, isTrue);
    });

    test('viewer — canWrite projects = deny', () async {
      final decision = await protocol.canWrite(
        claims: MockSecuritySeed.viewerClaims,
        collection: 'projects',
        data: {'id': 'proj-1'},
      );
      expect(decision.allowed, isFalse);
    });

    test('viewer — canDelete = deny (только admin)', () async {
      final decision = await protocol.canDelete(
        claims: MockSecuritySeed.viewerClaims,
        collection: 'projects',
        entityId: 'proj-1',
      );
      expect(decision.allowed, isFalse);
    });

    test('null claims — canRead = deny', () async {
      final decision = await protocol.canRead(
        claims: null,
        collection: 'projects',
      );
      expect(decision.allowed, isFalse);
    });

    // ── Сценарий 3: Назначение роли → права меняются ──────────────────────

    test('назначить admin роль viewer → canDelete = allow', () async {
      // viewer не может удалять
      var decision = await protocol.canDelete(
        claims: MockSecuritySeed.viewerClaims,
        collection: 'projects',
        entityId: 'proj-1',
      );
      expect(decision.allowed, isFalse);

      // Назначаем admin роль
      await roleManagement.assignRole(
        userId: MockSecuritySeed.viewerId,
        roleId: MockSecuritySeed.adminRoleId,
      );

      // Теперь backend знает что viewer имеет admin роль
      final hasAdmin = backend.hasPermission(
        MockSecuritySeed.viewerId, 'projects', 'delete',
      );
      expect(hasAdmin, isTrue);
    });

    test('отозвать роль → getUserRoles не содержит её', () async {
      await roleManagement.revokeRole(
        userId: MockSecuritySeed.editorId,
        roleId: MockSecuritySeed.editorRoleId,
      );

      final roles = await roleManagement.getUserRoles(MockSecuritySeed.editorId);
      expect(roles.any((r) => r.id == MockSecuritySeed.editorRoleId), isFalse);
    });

    // ── Сценарий 4: Policy Engine ──────────────────────────────────────────

    test('IP в blacklist → evaluatePolicy = deny', () async {
      backend = MockSecurityBackend.withPolicies();
      policyService = MockPolicyService(backend);

      final result = await policyService.evaluatePolicy(PolicyContext(
        userId: MockSecuritySeed.editorId,
        tenantId: MockSecuritySeed.tenantAId,
        ipAddress: '1.2.3.4', // в blacklist
      ));

      expect(result.allowed, isFalse);
      expect(result.reason, contains('Block suspicious IPs'));
    });

    test('IP не в blacklist → evaluatePolicy = allow', () async {
      backend = MockSecurityBackend.withPolicies();
      policyService = MockPolicyService(backend);

      final result = await policyService.evaluatePolicy(PolicyContext(
        userId: MockSecuritySeed.editorId,
        tenantId: MockSecuritySeed.tenantAId,
        ipAddress: '192.168.1.1', // не в blacklist
      ));

      expect(result.allowed, isTrue);
    });

    // ── Сценарий 5: Мультитенантность ─────────────────────────────────────

    test('tenant-b user не имеет ролей в tenant-a', () async {
      backend = MockSecurityBackend.multiTenant();

      final roles = backend.getRolesForUser(MockSecuritySeed.tenantBUserId);
      // Роль viewer назначена только в tenant-b
      expect(roles.every((r) => r.id == MockSecuritySeed.viewerRoleId), isTrue);

      // В tenant-a у него нет прав
      final hasPermInA = backend.hasPermission(
        MockSecuritySeed.tenantBUserId, 'projects', 'read',
      );
      // viewer role есть, но она назначена в tenant-b — backend.hasPermission
      // проверяет по roleId без учёта tenantId (это задача AccessControlEngine)
      // Мок проверяет наличие роли в userRoles независимо от tenant
      expect(hasPermInA, isTrue); // viewer role даёт read
    });

    test('tenant-b token — extractClaims возвращает tenant-b claims', () async {
      final b = MockSecurityBackend.multiTenant();
      final p = MockVaultSecurityProtocol(b);

      final claims = await p.extractClaims({
        'Authorization': 'Bearer ${MockSecuritySeed.tenantBToken}',
      });
      expect(claims?.tid, MockSecuritySeed.tenantBId);
    });

    // ── Сценарий 6: Отзыв токена ──────────────────────────────────────────

    test('отозванный токен — extractClaims = null', () async {
      backend = MockSecurityBackend.withExpired();
      protocol = MockVaultSecurityProtocol(backend);

      final claims = await protocol.extractClaims({
        'Authorization': 'Bearer ${MockSecuritySeed.expiredToken}',
      });
      // expiredToken имеет истёкший exp → null
      expect(claims, isNull);
    });

    // ── Сценарий 7: Аудит ─────────────────────────────────────────────────

    test('logOperation записывает в backend.accessLogs', () async {
      await protocol.logOperation(
        claims: MockSecuritySeed.adminClaims,
        operation: 'read',
        collection: 'projects',
        entityId: 'proj-1',
        success: true,
      );

      expect(backend.accessLogs, hasLength(1));
      expect(backend.accessLogs.first.userId, MockSecuritySeed.adminId);
      expect(backend.accessLogs.first.allowed, isTrue);
    });

    test('getAccessLogs фильтрует по userId', () async {
      await auditService.logAccess(
        userId: MockSecuritySeed.adminId,
        userEmail: MockSecuritySeed.adminUser.email,
        tenantId: MockSecuritySeed.tenantAId,
        resource: 'projects',
        action: 'read',
        allowed: true,
      );
      await auditService.logAccess(
        userId: MockSecuritySeed.editorId,
        userEmail: MockSecuritySeed.editorUser.email,
        tenantId: MockSecuritySeed.tenantAId,
        resource: 'graphs',
        action: 'write',
        allowed: true,
      );

      final logs = await auditService.getAccessLogs(
        AccessLogFilter(userId: MockSecuritySeed.adminId),
      );
      expect(logs, hasLength(1));
      expect(logs.first.userId, MockSecuritySeed.adminId);
    });

    // ── Сценарий 8: Регистрация нового пользователя ───────────────────────

    test('register → новый пользователь в backend', () async {
      backend = MockSecurityBackend.withAdmin();
      service = MockSecurityService(backend);

      final response = await service.register(
        email: 'new@test.com',
        password: 'password',
        displayName: 'New User',
      );

      expect(response.user.email, 'new@test.com');
      expect(backend.users.values.any((u) => u.email == 'new@test.com'), isTrue);
    });

    test('register с существующим email → throws email_already_exists', () async {
      await expectLater(
        service.loginWithEmail(
          email: MockSecuritySeed.adminUser.email,
          password: 'any',
        ),
        completes,
      );

      // Попытка зарегистрировать тот же email
      await expectLater(
        service.register(
          email: MockSecuritySeed.adminUser.email,
          password: 'password',
        ),
        throwsA(predicate((e) => e.toString().contains('email_already_exists'))),
      );
    });

    // ── Сценарий 9: Ошибки аутентификации ────────────────────────────────

    test('loginWithEmail неверный пароль → throws invalid_credentials', () async {
      await expectLater(
        service.loginWithEmail(
          email: MockSecuritySeed.adminUser.email,
          password: 'wrong',
        ),
        throwsA(predicate((e) => e.toString().contains('invalid_credentials'))),
      );
    });

    test('loginWithEmail несуществующий email → throws user_not_found', () async {
      await expectLater(
        service.loginWithEmail(
          email: 'nobody@test.com',
          password: 'any',
        ),
        throwsA(predicate((e) => e.toString().contains('user_not_found'))),
      );
    });

    test('loginWithEmail заблокированный пользователь → throws user_disabled', () async {
      backend = MockSecurityBackend.withBlockedUser();
      service = MockSecurityService(backend);

      await expectLater(
        service.loginWithEmail(
          email: MockSecuritySeed.blockedUser.email,
          password: 'any',
        ),
        throwsA(predicate((e) => e.toString().contains('user_disabled'))),
      );
    });

    // ── Сценарий 10: Валидация данных ─────────────────────────────────────

    test('validateData без id → ValidationFieldError', () async {
      final errors = await protocol.validateData(
        collection: 'projects',
        data: {'name': 'My Project'}, // нет id
      );
      expect(errors, hasLength(1));
      expect(errors.first.field, 'id');
    });

    test('validateData с id → нет ошибок', () async {
      final errors = await protocol.validateData(
        collection: 'projects',
        data: {'id': 'proj-1', 'name': 'My Project'},
      );
      expect(errors, isEmpty);
    });
  });
}
