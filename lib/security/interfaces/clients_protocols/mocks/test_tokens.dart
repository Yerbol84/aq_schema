// pkgs/aq_schema/lib/security/interfaces/clients_protocols/mocks/test_tokens.dart
//
// Захардкоженные токены для тестирования.

/// Тестовые токены для использования в тестах.
///
/// **Использование:**
/// ```dart
/// test('admin can delete', () async {
///   final storage = PostgresVaultStorage(
///     headers: {'Authorization': 'Bearer ${TestTokens.admin}'},
///   );
///   await storage.delete('projects', 'project-1');
/// });
/// ```
abstract final class TestTokens {
  /// Админ токен (все права)
  static const String admin = 'test-admin-token';

  /// Обычный пользователь (read/write)
  static const String user = 'test-user-token';

  /// Только чтение
  static const String readonly = 'test-readonly-token';

  /// Заблокированный пользователь
  static const String blocked = 'test-blocked-token';

  /// Анонимный (без токена)
  static const String? anonymous = null;
}

/// Тестовые API ключи.
abstract final class TestApiKeys {
  /// Админ API ключ
  static const String admin = 'test-api-key-admin-12345';

  /// Обычный API ключ
  static const String user = 'test-api-key-user-67890';

  /// Read-only API ключ
  static const String readonly = 'test-api-key-readonly-11111';
}

/// Тестовые user ID.
abstract final class TestUsers {
  static const String admin = 'admin-user-id';
  static const String user = 'user-id';
  static const String readonly = 'readonly-user-id';
  static const String blocked = 'blocked-user-id';
}

/// Тестовые tenant ID.
abstract final class TestTenants {
  static const String main = 'test-tenant';
  static const String secondary = 'test-tenant-2';
  static const String system = 'system';
}
