// aq_schema/lib/security/interfaces/clients_protocols/i_auth_context.dart
//
// Auth context provider for data layer.
//
// Data layer reads auth from this singleton instead of constructor params.
// This decouples data layer from auth implementation.
//
// ## Usage
//
// ### In aq_security package (implementation):
//
// ```dart
// class AqAuthContext implements IAuthContext {
//   final ISecurityService _securityService;
//
//   AqAuthContext(this._securityService);
//
//   @override
//   Future<String?> get currentToken async {
//     final session = await _securityService.getCurrentSession();
//     return session?.accessToken;
//   }
//
//   @override
//   Future<String> get currentTenantId async {
//     final session = await _securityService.getCurrentSession();
//     return session?.tenantId ?? 'system';
//   }
//
//   @override
//   Future<String?> get currentUserId async {
//     final session = await _securityService.getCurrentSession();
//     return session?.userId;
//   }
// }
// ```
//
// ### In main.dart (initialization):
//
// ```dart
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // 1. Initialize security service
//   final securityService = ISecurityService.instance;
//
//   // 2. Initialize auth context
//   IAuthContext.initialize(AqAuthContext(securityService));
//
//   // 3. Initialize data layer (reads auth from IAuthContext)
//   await IDataLayer.initialize(endpoint: 'http://localhost:8765');
//
//   runApp(MyApp());
// }
// ```
//
// ### In data layer (consumption):
//
// ```dart
// // dart_vault reads auth from IAuthContext
// final authToken = await IAuthContext.instance?.currentToken;
// final tenantId = await IAuthContext.instance?.currentTenantId ?? 'system';
//
// final storage = RemoteVaultStorage(
//   endpoint: endpoint,
//   tenantId: tenantId,
//   authToken: authToken,
// );
// ```

/// Auth context provider for data layer.
///
/// Provides current authentication state (token, tenant, user) to data layer
/// without coupling data layer to auth implementation.
///
/// ## Lifecycle
///
/// 1. aq_security package implements this interface
/// 2. App calls [initialize] in main.dart
/// 3. Data layer reads auth via [instance]
///
/// ## Implementation
///
/// TODO(aq_security): Implement in aq_security package.
/// For now, data layer can work without auth (development mode).
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
