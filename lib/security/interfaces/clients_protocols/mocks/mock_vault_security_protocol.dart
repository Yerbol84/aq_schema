// pkgs/aq_schema/lib/security/interfaces/clients_protocols/mocks/mock_vault_security_protocol.dart
//
// Mock реализация IVaultSecurityProtocol для тестирования.
//
// Поддерживает захардкоженные токены и API ключи.

import 'package:aq_schema/aq_schema.dart';

/// Mock реализация IVaultSecurityProtocol для тестирования.
///
/// **Захардкоженные токены:**
/// - `test-admin-token` — админ (все права)
/// - `test-user-token` — обычный пользователь (read/write)
/// - `test-readonly-token` — только чтение
/// - `test-blocked-token` — заблокирован (всё запрещено)
///
/// **Использование в тестах:**
/// ```dart
/// void main() {
///   setUp(() {
///     IVaultSecurityProtocol.initialize(MockVaultSecurityProtocol());
///   });
///
///   tearDown(() {
///     IVaultSecurityProtocol.reset();
///   });
///
///   test('admin can delete', () async {
///     final storage = PostgresVaultStorage(
///       headers: {'Authorization': 'Bearer test-admin-token'},
///     );
///     await storage.delete('projects', 'project-1'); // OK
///   });
/// }
/// ```
final class MockVaultSecurityProtocol implements IVaultSecurityProtocol {
  MockVaultSecurityProtocol({
    this.defaultBehavior = MockBehavior.allowAll,
  });

  final MockBehavior defaultBehavior;

  // Захардкоженные токены для тестирования
  static const Map<String, AqTokenClaims> _testTokens = {
    'test-admin-token': AqTokenClaims(
      sub: 'admin-user-id',
      email: 'admin@test.com',
      tid: 'test-tenant',
      roles: ['admin', 'user'],
      scopes: ['*'],
      iat: 1700000000,
      exp: 2000000000,
      type: TokenType.access,
      jti: '',
      sid: '',
    ),
    'test-user-token': AqTokenClaims(
      sub: 'user-id',
      email: 'user@test.com',
      tid: 'test-tenant',
      roles: ['user'],
      scopes: [
        'projects:read',
        'projects:write',
        'graphs:read',
        'graphs:write'
      ],
      iat: 1700000000,
      exp: 2000000000,
      type: TokenType.access,
      jti: '',
      sid: '',
    ),
    'test-readonly-token': AqTokenClaims(
      sub: 'readonly-user-id',
      email: 'readonly@test.com',
      tid: 'test-tenant',
      roles: ['viewer'],
      scopes: ['projects:read', 'graphs:read'],
      iat: 1700000000,
      exp: 2000000000,
      type: TokenType.access,
      jti: '',
      sid: '',
    ),
    'test-blocked-token': AqTokenClaims(
      sub: 'blocked-user-id',
      email: 'blocked@test.com',
      tid: 'test-tenant',
      type: TokenType.access,
      jti: '',
      sid: '',
      roles: [],
      scopes: [],
      iat: 1700000000,
      exp: 2000000000,
    ),
  };

  @override
  Future<AqTokenClaims?> extractClaims(Map<String, String> headers) async {
    final authHeader = headers['Authorization'] ?? headers['authorization'];
    if (authHeader == null) return null;

    // Извлечь токен
    final token =
        authHeader.startsWith('Bearer ') ? authHeader.substring(7) : authHeader;

    // Вернуть захардкоженный claims
    return _testTokens[token];
  }

  @override
  Future<AccessDecision> canRead({
    required AqTokenClaims? claims,
    required String collection,
    String? entityId,
  }) async {
    if (claims == null) {
      return defaultBehavior == MockBehavior.allowAll
          ? AccessDecision.allow(reason: 'Mock: allow all')
          : AccessDecision.deny(reason: 'Anonymous access denied');
    }

    // Админ может всё
    if (claims.roles.contains('admin')) {
      return AccessDecision.allow(reason: 'Admin access');
    }

    // Заблокированный пользователь
    if (claims.scopes.isEmpty) {
      return AccessDecision.deny(reason: 'User blocked');
    }

    // Проверить scope
    if (claims.scopes.contains('*') ||
        claims.scopes.contains('$collection:read') ||
        claims.scopes.contains('$collection:*')) {
      return AccessDecision.allow(reason: 'Scope granted');
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
    if (claims == null) {
      return AccessDecision.deny(reason: 'Authentication required');
    }

    // Админ может всё
    if (claims.roles.contains('admin')) {
      return AccessDecision.allow(reason: 'Admin access');
    }

    // Заблокированный пользователь
    if (claims.scopes.isEmpty) {
      return AccessDecision.deny(reason: 'User blocked');
    }

    // Проверить scope
    if (claims.scopes.contains('*') ||
        claims.scopes.contains('$collection:write') ||
        claims.scopes.contains('$collection:*')) {
      return AccessDecision.allow(reason: 'Scope granted');
    }

    return AccessDecision.deny(reason: 'No write permission for $collection');
  }

  @override
  Future<AccessDecision> canDelete({
    required AqTokenClaims? claims,
    required String collection,
    required String entityId,
  }) async {
    if (claims == null) {
      return AccessDecision.deny(reason: 'Authentication required');
    }

    // Только админ может удалять
    if (claims.roles.contains('admin')) {
      return AccessDecision.allow(reason: 'Admin access');
    }

    return AccessDecision.deny(reason: 'Only admin can delete');
  }

  @override
  Future<AccessDecision> canPublish({
    required AqTokenClaims? claims,
    required String collection,
    required String entityId,
  }) async {
    if (claims == null) {
      return AccessDecision.deny(reason: 'Authentication required');
    }

    // Админ или пользователь с write правами
    if (claims.roles.contains('admin') ||
        claims.scopes.contains('$collection:write')) {
      return AccessDecision.allow(reason: 'Publish permission granted');
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
    if (claims == null) {
      return AccessDecision.deny(reason: 'Authentication required');
    }

    // Только админ может выдавать права
    if (claims.roles.contains('admin')) {
      return AccessDecision.allow(reason: 'Admin access');
    }

    return AccessDecision.deny(reason: 'Only admin can grant access');
  }

  @override
  Future<bool> checkRateLimit({
    required AqTokenClaims? claims,
    required String operation,
    String? ip,
  }) async {
    // В тестах лимитов нет
    return true;
  }

  @override
  Future<List<ValidationFieldError>> validateData({
    required String collection,
    required Map<String, dynamic> data,
  }) async {
    // Простая валидация для тестов
    final errors = <ValidationFieldError>[];

    // Проверить наличие обязательных полей
    if (!data.containsKey('id')) {
      errors.add(ValidationFieldError(
        field: 'id',
        message: 'Field "id" is required',
        code: 'REQUIRED',
      ));
    }

    // Проверить на SQL injection (простая проверка)
    for (final entry in data.entries) {
      if (entry.value is String) {
        final value = entry.value as String;
        if (value.contains('DROP TABLE') ||
            value.contains('DELETE FROM') ||
            value.contains('--')) {
          errors.add(ValidationFieldError(
            field: entry.key,
            message: 'Potential SQL injection detected',
            code: 'SQL_INJECTION',
          ));
        }
      }
    }

    return errors;
  }

  @override
  Future<Map<String, dynamic>> encryptSensitiveFields({
    required AqTokenClaims? claims,
    required String collection,
    required Map<String, dynamic> data,
  }) async {
    // В тестах не шифруем
    return data;
  }

  @override
  Future<Map<String, dynamic>> decryptSensitiveFields({
    required AqTokenClaims? claims,
    required String collection,
    required Map<String, dynamic> data,
  }) async {
    // В тестах не расшифровываем
    return data;
  }

  @override
  Future<void> logOperation({
    required AqTokenClaims? claims,
    required String operation,
    required String collection,
    String? entityId,
    required bool success,
    String? errorMessage,
  }) async {
    // В тестах можно логировать в память для проверки
    print(
        '[AUDIT] $operation on $collection/$entityId by ${claims?.sub ?? "anonymous"}: ${success ? "SUCCESS" : "FAILED"}');
  }

  @override
  // TODO: implement resourcePermissions
  IResourcePermissionService get resourcePermissions =>
      throw UnimplementedError();
}

/// Поведение mock по умолчанию
enum MockBehavior {
  /// Всё разрешено (как NoOp)
  allowAll,

  /// Требуется аутентификация
  requireAuth,

  /// Всё запрещено
  denyAll,
}
