// aq_schema/lib/core/interfaces/i_aq_api_contract.dart
//
// Generic interface for API contracts across all AQ services.

import '../models/route_spec.dart';

/// Generic mixin for defining API contracts in AQ ecosystem.
///
/// ## Purpose
///
/// Provides a single source of truth for HTTP API routes, ensuring client
/// and server implementations stay in sync. Each service (vault, auth, mcp)
/// uses this mixin to define its API contract.
///
/// ## Benefits
///
/// - **Type Safety**: Routes are constants, not magic strings
/// - **Single Source of Truth**: Both client and server use same contract
/// - **Versioning**: Built-in API version management
/// - **Documentation**: Contract IS the documentation
/// - **Testing**: Easy to validate both sides against contract
///
/// ## Usage
///
/// ### 1. Define Contract (in aq_schema)
///
/// ```dart
/// class VaultApiContract with AqApiContract {
///   @override
///   String get apiVersion => 'v1';
///
///   @override
///   String get basePath => '/vault';
///
///   @override
///   Map<String, RouteSpec> get routes => {
///     'handshake': RouteSpec(
///       path: '/handshake',
///       method: 'POST',
///       description: 'Establish connection',
///     ),
///   };
/// }
/// ```
///
/// ### 2. Use in Client
///
/// ```dart
/// final contract = VaultApiContract();
/// final url = contract.buildUrl(
///   'http://localhost:8765',
///   'handshake',
/// );
/// // Result: http://localhost:8765/v1/vault/handshake
/// ```
///
/// ### 3. Use in Server
///
/// ```dart
/// final contract = VaultApiContract();
/// final router = Router()
///   ..post(contract.getFullRoute('handshake'), handleHandshake);
/// // Route: /v1/vault/handshake
/// ```
mixin AqApiContract {
  /// API version (e.g., "v1", "v2").
  ///
  /// Used in URL path: `/v1/service/route`
  String get apiVersion;

  /// Base path for this service (e.g., "/vault", "/auth", "/mcp").
  ///
  /// Combined with version: `/v1/vault`
  String get basePath;

  /// All routes with metadata.
  ///
  /// Key: route name (e.g., "handshake", "rpc")
  /// Value: [RouteSpec] with path, method, types, description
  Map<String, RouteSpec> get routes;

  /// Get route path by name (without version/base).
  ///
  /// Example: `getRoute('handshake')` → `'/handshake'`
  ///
  /// Throws [ArgumentError] if route name not found.
  String getRoute(String routeName) {
    final spec = routes[routeName];
    if (spec == null) {
      throw ArgumentError(
        'Route "$routeName" not found in ${runtimeType}. '
        'Available routes: ${routes.keys.join(", ")}',
      );
    }
    return spec.path;
  }

  /// Get full route path with version and base (for server routing).
  ///
  /// Example: `getFullRoute('handshake')` → `'/v1/vault/handshake'`
  ///
  /// Pattern: `/{apiVersion}{basePath}{routePath}`
  String getFullRoute(String routeName) {
    final routePath = getRoute(routeName);
    return '/$apiVersion$basePath$routePath';
  }

  /// Build complete URL with base URL (for client requests).
  ///
  /// Example:
  /// ```dart
  /// buildUrl('http://localhost:8765', 'handshake')
  /// // → 'http://localhost:8765/v1/vault/handshake'
  ///
  /// buildUrl('http://localhost:8765', 'watch', {'collection': 'projects'})
  /// // → 'http://localhost:8765/v1/vault/watch?collection=projects'
  /// ```
  String buildUrl(
    String baseUrl,
    String routeName, [
    Map<String, String>? queryParams,
  ]) {
    final fullRoute = getFullRoute(routeName);
    final url = '$baseUrl$fullRoute';

    if (queryParams == null || queryParams.isEmpty) {
      return url;
    }

    final query = queryParams.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return '$url?$query';
  }

  /// Create a typed route builder for this contract.
  ///
  /// Route builders provide type-safe methods for building URLs.
  ///
  /// Example:
  /// ```dart
  /// final builder = contract.createRouteBuilder('http://localhost:8765');
  /// final url = builder.handshake();  // Type-safe!
  /// ```
  AqApiRouteBuilder createRouteBuilder(String baseUrl);
}

/// Base class for typed route builders.
///
/// Each API contract should provide a concrete implementation with
/// type-safe methods for building URLs.
///
/// Example:
/// ```dart
/// class VaultApiRouteBuilder extends AqApiRouteBuilder {
///   VaultApiRouteBuilder(super.contract, super.baseUrl);
///
///   String handshake() => contract.buildUrl(baseUrl, 'handshake');
///   String rpc() => contract.buildUrl(baseUrl, 'rpc');
/// }
/// ```
abstract class AqApiRouteBuilder {
  /// The contract this builder uses
  final AqApiContract contract;

  /// Base URL for building complete URLs
  final String baseUrl;

  const AqApiRouteBuilder(this.contract, this.baseUrl);
}
