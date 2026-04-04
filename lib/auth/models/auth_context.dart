/// Auth domain models and abstract interfaces.
///
/// v1 uses MockAuthProvider (always success).
/// v2 will plug in JwtAuthProvider / OAuth2AuthProvider without
/// changing any other packages in the ecosystem.
library;

// ══════════════════════════════════════════════════════════
//  Enums
// ══════════════════════════════════════════════════════════

/// Authorization mechanism type.
enum AuthType {
  bearer('bearer'),
  apikey('apikey'),
  oauth2('oauth2'),
  oauth2Token('oauth2_token'),
  none('none'),
  mock('mock');

  const AuthType(this.value);
  final String value;

  static AuthType fromString(String s) => switch (s) {
        'bearer' => AuthType.bearer,
        'apikey' => AuthType.apikey,
        'oauth2' => AuthType.oauth2,
        'oauth2_token' => AuthType.oauth2Token,
        'mock' => AuthType.mock,
        _ => AuthType.none,
      };
}

/// Reason why auth validation failed.
enum AuthFailureReason {
  tokenMissing('token_missing'),
  tokenExpired('token_expired'),
  tokenInvalid('token_invalid'),
  tokenRevoked('token_revoked'),
  scopeInsufficient('scope_insufficient'),
  serviceUnavailable('service_unavailable');

  const AuthFailureReason(this.value);
  final String value;

  static AuthFailureReason fromString(String s) => AuthFailureReason.values
      .firstWhere((e) => e.value == s, orElse: () => AuthFailureReason.tokenInvalid);
}

// ══════════════════════════════════════════════════════════
//  AuthTokenPayload — raw incoming token from MCP client
// ══════════════════════════════════════════════════════════

/// Raw token payload passed in `params._aq_auth` by MCP client.
/// This is the input — not yet validated.
final class AuthTokenPayload {
  const AuthTokenPayload({
    required this.type,
    this.token,
    this.oauth2,
  });

  factory AuthTokenPayload.fromJson(Map<String, dynamic> json) {
    final oauth2Raw = json['oauth2'] as Map<String, dynamic>?;
    return AuthTokenPayload(
      type: AuthType.fromString((json['type'] as String?) ?? 'none'),
      token: json['token'] as String?,
      oauth2: oauth2Raw != null ? OAuth2TokenPayload.fromJson(oauth2Raw) : null,
    );
  }

  final AuthType type;
  final String? token;
  final OAuth2TokenPayload? oauth2;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'type': type.value};
    if (token != null) map['token'] = token;
    if (oauth2 != null) map['oauth2'] = oauth2!.toJson();
    return map;
  }

  static const empty = AuthTokenPayload(type: AuthType.none);
}

/// OAuth2 token data inside [AuthTokenPayload].
final class OAuth2TokenPayload {
  const OAuth2TokenPayload({
    required this.accessToken,
    required this.tokenType,
    this.refreshToken,
    this.expiresIn,
    this.scope,
  });

  factory OAuth2TokenPayload.fromJson(Map<String, dynamic> json) =>
      OAuth2TokenPayload(
        accessToken: json['access_token'] as String,
        tokenType: json['token_type'] as String,
        refreshToken: json['refresh_token'] as String?,
        expiresIn: json['expires_in'] as int?,
        scope: json['scope'] as String?,
      );

  final String accessToken;
  final String tokenType;
  final String? refreshToken;
  final int? expiresIn;
  final String? scope;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'access_token': accessToken,
      'token_type': tokenType,
    };
    if (refreshToken != null) map['refresh_token'] = refreshToken;
    if (expiresIn != null) map['expires_in'] = expiresIn;
    if (scope != null) map['scope'] = scope;
    return map;
  }
}

// ══════════════════════════════════════════════════════════
//  AuthContext — internal validated state
// ══════════════════════════════════════════════════════════

/// Validated auth state. Created by [AuthProvider] after successful validation.
/// Passed into the Redis queue alongside the job — never contains raw tokens.
final class AuthContext {
  const AuthContext({
    required this.type,
    required this.validated,
    required this.timestamp,
    this.subject,
    this.scopes = const [],
    this.claims,
    this.expiresAt,
    this.isMock = false,
  });

  factory AuthContext.fromJson(Map<String, dynamic> json) => AuthContext(
        type: AuthType.fromString(json['type'] as String),
        validated: json['validated'] as bool,
        timestamp: json['timestamp'] as int,
        subject: json['subject'] as String?,
        scopes: (json['scopes'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        claims: json['claims'] as Map<String, dynamic>?,
        expiresAt: json['expires_at'] as int?,
        isMock: (json['_mock'] as bool?) ?? false,
      );

  final AuthType type;
  final bool validated;
  final int timestamp;
  final String? subject;
  final List<String> scopes;
  final Map<String, dynamic>? claims;
  final int? expiresAt;

  /// AQ EXTENSION: true when MockAuthProvider was used.
  final bool isMock;

  bool get isExpired {
    if (expiresAt == null) return false;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return now >= expiresAt!;
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'type': type.value,
      'validated': validated,
      'timestamp': timestamp,
    };
    if (subject != null) map['subject'] = subject;
    if (scopes.isNotEmpty) map['scopes'] = scopes;
    if (claims != null) map['claims'] = claims;
    if (expiresAt != null) map['expires_at'] = expiresAt;
    if (isMock) map['_mock'] = true;
    return map;
  }

  /// Pre-built mock context used by [MockAuthProvider].
  static AuthContext mockContext() => AuthContext(
        type: AuthType.mock,
        validated: true,
        subject: 'mock-user',
        scopes: const ['*'],
        isMock: true,
        timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      );

  /// Pre-built unauthenticated context for tools that don't require auth.
  static AuthContext anonymous() => AuthContext(
        type: AuthType.none,
        validated: true,
        timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      );

  @override
  String toString() =>
      'AuthContext(type: ${type.value}, subject: $subject, mock: $isMock)';
}

// ══════════════════════════════════════════════════════════
//  AuthResult — validation output
// ══════════════════════════════════════════════════════════

/// Result returned by [AuthProvider.validate].
final class AuthResult {
  const AuthResult({
    required this.success,
    required this.timestamp,
    this.context,
    this.failureReason,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    final ctxRaw = json['context'] as Map<String, dynamic>?;
    final errorStr = json['error'] as String?;
    return AuthResult(
      success: json['success'] as bool,
      timestamp: json['timestamp'] as int,
      context: ctxRaw != null ? AuthContext.fromJson(ctxRaw) : null,
      failureReason: errorStr != null
          ? AuthFailureReason.fromString(errorStr)
          : null,
    );
  }

  /// True when token was accepted.
  final bool success;

  /// Populated when [success] is true.
  final AuthContext? context;

  /// Populated when [success] is false.
  final AuthFailureReason? failureReason;

  final int timestamp;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'success': success,
      'timestamp': timestamp,
    };
    if (context != null) map['context'] = context!.toJson();
    if (failureReason != null) map['error'] = failureReason!.value;
    return map;
  }

  /// Pre-built mock success result.
  static AuthResult mock() => AuthResult(
        success: true,
        context: AuthContext.mockContext(),
        timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      );

  /// Pre-built failure result.
  static AuthResult failure(AuthFailureReason reason) => AuthResult(
        success: false,
        failureReason: reason,
        timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      );

  @override
  String toString() =>
      'AuthResult(success: $success, reason: ${failureReason?.value})';
}

// ══════════════════════════════════════════════════════════
//  AuthProvider — abstract interface
// ══════════════════════════════════════════════════════════

/// Abstract interface for authentication providers.
///
/// v1: [MockAuthProvider] — always returns success, logs calls.
/// v2: JwtAuthProvider, OAuth2AuthProvider — real validation.
///
/// Upper packages (aq_auth, aq_mcp_adapter) depend only on this interface.
/// Swap implementation without changing any other packages.
abstract interface class AuthProvider {
  /// Whether this provider is the mock stub (v1).
  bool get isMock;

  /// Validates a raw token payload from the MCP client.
  Future<AuthResult> validate(AuthTokenPayload tokenPayload);

  /// Refreshes an expired [AuthContext] (OAuth2 only).
  /// Default impl returns the same context unchanged.
  Future<AuthContext> refresh(AuthContext expiredContext);

  /// Checks whether the given context has all [requiredScopes].
  bool hasScope(AuthContext ctx, List<String> requiredScopes);
}

// ══════════════════════════════════════════════════════════
//  AuthMiddleware — abstract interface
// ══════════════════════════════════════════════════════════

/// Middleware interface used by the adapter to gate requests.
///
/// Separates "can this request proceed?" (authenticate)
/// from "can this principal use this tool?" (authorize).
abstract interface class AuthMiddleware {
  /// Authenticates the raw token payload.
  /// Returns a validated [AuthResult].
  Future<AuthResult> authenticate(AuthTokenPayload? payload);

  /// Checks if the authenticated [AuthContext] is allowed to use [toolName].
  Future<bool> authorize(AuthContext ctx, String toolName);
}
