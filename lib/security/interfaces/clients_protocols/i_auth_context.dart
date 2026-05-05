// aq_schema/lib/security/interfaces/clients_protocols/i_auth_context.dart
//
// Порт контекста аутентификации для data layer.
// Реализация: aq_security/lib/src/client/aq_auth_context.dart

/// # IAuthContext — текущий пользователь для data layer
///
/// Data layer не знает об `ISecurityService`. Он читает токен и tenant
/// из этого синглтона — без зависимости на aq_security.
///
/// ---
///
/// ## 📦 Data Layer (dart_vault) — как использовать
///
/// ```dart
/// // В RemoteVaultStorage или любом клиенте data layer:
/// final token = await IAuthContext.instance?.currentToken;
/// final tenantId = await IAuthContext.instance?.currentTenantId ?? 'system';
///
/// // Передать в HTTP запрос
/// final response = await http.get(
///   Uri.parse('$endpoint/vault/$collection/$id'),
///   headers: {
///     if (token != null) 'Authorization': 'Bearer $token',
///     'X-Tenant-Id': tenantId,
///   },
/// );
/// ```
///
/// ---
///
/// ## 🚀 Production (main.dart)
///
/// ```dart
/// import 'package:aq_security/aq_security.dart';
///
/// // После AQSecurityClient.init() — aq_security регистрирует IAuthContext автоматически
/// final service = await AQSecurityClient.init('https://auth.example.com');
/// // IAuthContext.instance уже установлен
///
/// await IDataLayer.initialize(endpoint: 'https://vault.example.com');
/// ```
///
/// ---
///
/// ## 🧪 Тесты
///
/// ```dart
/// import 'package:aq_schema/security_testing.dart';
///
/// setUp(() => IAuthContext.initialize(MockAuthContext.forUser('user-1', 'tenant-1')));
/// tearDown(() => IAuthContext.reset());
/// ```
abstract interface class IAuthContext {
  // ══════════════════════════════════════════════════════════════════════════
  // Singleton
  // ══════════════════════════════════════════════════════════════════════════

  static IAuthContext? _instance;

  /// Global singleton instance.
  ///
  /// Returns null if not initialized.
  /// Data layer should handle null gracefully (development mode).
  static IAuthContext? get instance => _instance;

  /// Initialize auth context with implementation.
  ///
  /// **Call once in main.dart before IDataLayer.initialize().**
  ///
  /// ```dart
  /// IAuthContext.initialize(AqAuthContext(securityService));
  /// ```
  static void initialize(IAuthContext impl) {
    _instance = impl;
  }

  /// Reset singleton (for testing).
  static void reset() {
    _instance = null;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Auth State
  // ══════════════════════════════════════════════════════════════════════════

  /// Current JWT access token.
  ///
  /// Returns null if user is not authenticated.
  /// Data layer uses this for `Authorization: Bearer {token}` header.
  Future<String?> get currentToken;

  /// Current tenant ID for multi-tenancy.
  ///
  /// Returns 'system' if no tenant context.
  /// Data layer uses this for tenant isolation.
  Future<String> get currentTenantId;

  /// Current user ID.
  ///
  /// Returns null if user is not authenticated.
  /// Data layer uses this for audit trails (createdBy, updatedBy).
  Future<String?> get currentUserId;
}
