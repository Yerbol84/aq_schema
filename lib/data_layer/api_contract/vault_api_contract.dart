// aq_schema/lib/data_layer/api_contract/vault_api_contract.dart
//
// Vault Data Service API Contract - Single Source of Truth for routes.

import '../../core/interfaces/i_aq_api_contract.dart';
import '../../core/models/route_spec.dart';
import 'vault_api_route_builder.dart';

/// Vault Data Service API Contract.
///
/// Defines all HTTP routes for dart_vault client-server communication.
/// Both client (RemoteVaultStorage) and server (main.dart) MUST use
/// these route definitions.
///
/// ## Route Pattern
///
/// All routes follow: `/{apiVersion}{basePath}{route}`
///
/// Examples:
/// - `/v1/vault/handshake`
/// - `/v1/vault/rpc`
/// - `/v1/vault/watch`
///
/// ## Usage in Client
///
/// ```dart
/// import 'package:aq_schema/aq_schema.dart';
///
/// final contract = VaultApiContract();
/// final url = contract.buildUrl('http://localhost:8765', 'handshake');
/// // Result: http://localhost:8765/v1/vault/handshake
///
/// await http.post(Uri.parse(url), body: jsonEncode(request));
/// ```
///
/// ## Usage in Server
///
/// ```dart
/// import 'package:aq_schema/aq_schema.dart';
///
/// final contract = VaultApiContract();
/// final router = Router()
///   ..post(contract.getFullRoute('handshake'), _handleHandshake)
///   ..post(contract.getFullRoute('rpc'), _handleRpc)
///   ..get(contract.getFullRoute('health'), _handleHealth);
/// ```
class VaultApiContract with AqApiContract {
  const VaultApiContract();

  @override
  String get apiVersion => 'v1';

  @override
  String get basePath => '/vault';

  @override
  Map<String, RouteSpec> get routes => {
        'handshake': const RouteSpec(
          path: '/handshake',
          method: 'POST',
          requestType: Map, // HandshakeRequest
          responseType: Map, // HandshakeResponse
          description: 'Establish connection and verify compatibility',
          requiresAuth: false,
        ),
        'rpc': const RouteSpec(
          path: '/rpc',
          method: 'POST',
          requestType: Map, // VaultRpcRequest
          responseType: Map, // VaultRpcResponse
          description: 'Execute repository operations (CRUD, versioning, logs)',
          requiresAuth: true,
        ),
        'watch': const RouteSpec(
          path: '/watch',
          method: 'GET',
          description: 'Subscribe to collection changes via SSE (Server-Sent Events)',
          requiresAuth: true,
          queryParams: {
            'collection': 'Collection name to watch',
            'tenantId': 'Tenant ID for filtering',
          },
        ),
        'health': const RouteSpec(
          path: '/health',
          method: 'GET',
          responseType: Map, // {status: "healthy", timestamp: "..."}
          description: 'Health check endpoint (no auth required)',
          requiresAuth: false,
        ),
      };

  @override
  AqApiRouteBuilder createRouteBuilder(String baseUrl) {
    return VaultApiRouteBuilder(this, baseUrl);
  }

  // ── Convenience Constants ──────────────────────────────────────────────────

  /// HTTP Methods
  static const String methodPost = 'POST';
  static const String methodGet = 'GET';
  static const String methodPut = 'PUT';
  static const String methodDelete = 'DELETE';

  // ── Route Names (for type-safe access) ────────────────────────────────────

  static const String routeHandshake = 'handshake';
  static const String routeRpc = 'rpc';
  static const String routeWatch = 'watch';
  static const String routeHealth = 'health';
}
