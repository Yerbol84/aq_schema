// aq_schema/lib/core/models/route_spec.dart
//
// Route specification model for API contracts.

/// Metadata describing an API route.
///
/// Used by [IAqApiContract] implementations to define route specifications
/// with type information, HTTP methods, and documentation.
class RouteSpec {
  /// The route path (e.g., "/vault/handshake")
  final String path;

  /// HTTP method (e.g., "POST", "GET", "PUT", "DELETE")
  final String method;

  /// Request payload type (for documentation/validation)
  final Type? requestType;

  /// Response payload type (for documentation/validation)
  final Type? responseType;

  /// Human-readable description of what this route does
  final String description;

  /// Whether this route requires authentication
  final bool requiresAuth;

  /// Optional query parameters specification
  final Map<String, String>? queryParams;

  const RouteSpec({
    required this.path,
    required this.method,
    this.requestType,
    this.responseType,
    required this.description,
    this.requiresAuth = false,
    this.queryParams,
  });

  /// Create a copy with modified fields
  RouteSpec copyWith({
    String? path,
    String? method,
    Type? requestType,
    Type? responseType,
    String? description,
    bool? requiresAuth,
    Map<String, String>? queryParams,
  }) {
    return RouteSpec(
      path: path ?? this.path,
      method: method ?? this.method,
      requestType: requestType ?? this.requestType,
      responseType: responseType ?? this.responseType,
      description: description ?? this.description,
      requiresAuth: requiresAuth ?? this.requiresAuth,
      queryParams: queryParams ?? this.queryParams,
    );
  }

  @override
  String toString() {
    return 'RouteSpec($method $path - $description)';
  }
}
