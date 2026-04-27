// aq_schema/lib/data_layer/api_contract/vault_api_route_builder.dart
//
// Type-safe route builder for Vault API.

import '../../core/interfaces/i_aq_api_contract.dart';
import 'vault_api_contract.dart';

/// Type-safe route builder for Vault Data Service API.
///
/// Provides convenient methods for building URLs with compile-time safety.
///
/// ## Usage
///
/// ```dart
/// final contract = VaultApiContract();
/// final builder = contract.createRouteBuilder('http://localhost:8765');
///
/// // Type-safe URL building
/// final handshakeUrl = builder.handshake();
/// // → http://localhost:8765/v1/vault/handshake
///
/// final rpcUrl = builder.rpc();
/// // → http://localhost:8765/v1/vault/rpc
///
/// final watchUrl = builder.watch(collection: 'projects', tenantId: 'system');
/// // → http://localhost:8765/v1/vault/watch?collection=projects&tenantId=system
/// ```
class VaultApiRouteBuilder extends AqApiRouteBuilder {
  VaultApiRouteBuilder(VaultApiContract contract, String baseUrl)
      : super(contract, baseUrl);

  VaultApiContract get _vaultContract => contract as VaultApiContract;

  /// Build URL for handshake endpoint.
  ///
  /// Route: `POST /v1/vault/handshake`
  ///
  /// Used to establish connection and verify client-server compatibility.
  String handshake() {
    return _vaultContract.buildUrl(baseUrl, VaultApiContract.routeHandshake);
  }

  /// Build URL for RPC endpoint.
  ///
  /// Route: `POST /v1/vault/rpc`
  ///
  /// Used for all repository operations (CRUD, versioning, logs).
  String rpc() {
    return _vaultContract.buildUrl(baseUrl, VaultApiContract.routeRpc);
  }

  /// Build URL for watch endpoint with query parameters.
  ///
  /// Route: `GET /v1/vault/watch?collection={collection}&tenantId={tenantId}`
  ///
  /// Used to subscribe to collection changes via Server-Sent Events (SSE).
  String watch({
    required String collection,
    required String tenantId,
  }) {
    return _vaultContract.buildUrl(
      baseUrl,
      VaultApiContract.routeWatch,
      {
        'collection': collection,
        'tenantId': tenantId,
      },
    );
  }

  /// Build URL for health check endpoint.
  ///
  /// Route: `GET /v1/vault/health`
  ///
  /// Used to verify server is running and responsive.
  String health() {
    return _vaultContract.buildUrl(baseUrl, VaultApiContract.routeHealth);
  }
}
