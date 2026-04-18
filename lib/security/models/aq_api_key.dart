import 'aq_user.dart';
import 'aq_session.dart';
import 'aq_tenant.dart';
import 'aq_token_claims.dart';
import 'credentials.dart';

// pkgs/aq_schema/lib/security/models/aq_api_key.dart
//
// Long-lived API key for service accounts (workers, data service, external).
// Raw key shown ONCE on creation. Only hash stored.

final class AqApiKey {
  const AqApiKey({
    required this.id,
    required this.userId,
    required this.tenantId,
    required this.name,
    required this.keyPrefix,
    required this.keyHash,
    required this.permissions,
    required this.isActive,
    required this.createdAt,
    this.lastUsedAt,
    this.lastRotatedAt,
    this.expiresAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String tenantId;

  /// Human-readable label: 'Graph Worker Production'
  final String name;

  /// First 8 chars — for display only, not auth.
  final String keyPrefix;

  /// SHA-256 hash of the full key — stored, never the raw key.
  final String keyHash;

  final List<String> permissions;
  final bool isActive;
  final int? lastUsedAt;
  final int? lastRotatedAt;
  final int? expiresAt;
  final int createdAt;
  final int? updatedAt;

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().millisecondsSinceEpoch ~/ 1000 >= expiresAt!;
  }

  factory AqApiKey.fromJson(Map<String, dynamic> json) => AqApiKey(
        id: json['id'] as String,
        userId: json['userId'] as String,
        tenantId: json['tenantId'] as String,
        name: json['name'] as String,
        keyPrefix: json['keyPrefix'] as String,
        keyHash: json['keyHash'] as String,
        permissions:
            (json['permissions'] as List<dynamic>?)?.cast<String>() ?? [],
        isActive: json['isActive'] as bool? ?? true,
        lastUsedAt: json['lastUsedAt'] as int?,
        lastRotatedAt: json['lastRotatedAt'] as int?,
        expiresAt: json['expiresAt'] as int?,
        createdAt: json['createdAt'] as int,
        updatedAt: json['updatedAt'] as int?,
      );

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'id': id,
      'userId': userId,
      'tenantId': tenantId,
      'name': name,
      'keyPrefix': keyPrefix,
      'keyHash': keyHash,
      'permissions': permissions,
      'isActive': isActive,
      'createdAt': createdAt,
    };
    if (lastUsedAt != null) m['lastUsedAt'] = lastUsedAt;
    if (lastRotatedAt != null) m['lastRotatedAt'] = lastRotatedAt;
    if (expiresAt != null) m['expiresAt'] = expiresAt;
    if (updatedAt != null) m['updatedAt'] = updatedAt;
    return m;
  }

  AqApiKey copyWith({
    String? name,
    List<String>? permissions,
    bool? isActive,
    int? lastUsedAt,
    int? lastRotatedAt,
    int? expiresAt,
    int? updatedAt,
  }) =>
      AqApiKey(
        id: id,
        userId: userId,
        tenantId: tenantId,
        name: name ?? this.name,
        keyPrefix: keyPrefix,
        keyHash: keyHash,
        permissions: permissions ?? this.permissions,
        isActive: isActive ?? this.isActive,
        lastUsedAt: lastUsedAt ?? this.lastUsedAt,
        lastRotatedAt: lastRotatedAt ?? this.lastRotatedAt,
        expiresAt: expiresAt ?? this.expiresAt,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Auth request / response DTOs
// ─────────────────────────────────────────────────────────────────────────────

/// Incoming auth request with credentials.
final class AuthRequest {
  const AuthRequest({required this.credentials});

  final Credentials credentials;

  factory AuthRequest.fromJson(Map<String, dynamic> json) => AuthRequest(
        credentials: Credentials.fromJson(
          json['credentials'] as Map<String, dynamic>,
        ),
      );

  Map<String, dynamic> toJson() => {
        'credentials': credentials.toJson(),
      };
}

/// Successful auth response (для API транспорта).
/// Используется в HTTP API между сервисами.
final class ApiAuthResponse {
  const ApiAuthResponse({
    required this.user,
    required this.tenant,
    required this.tokens,
    required this.session,
  });

  final AqUser user;
  final AqTenant tenant;
  final TokenPair tokens;
  final AqSession session;

  factory ApiAuthResponse.fromJson(Map<String, dynamic> json) => ApiAuthResponse(
        user: AqUser.fromJson(json['user'] as Map<String, dynamic>),
        tenant: AqTenant.fromJson(json['tenant'] as Map<String, dynamic>),
        tokens: TokenPair.fromJson(json['tokens'] as Map<String, dynamic>),
        session: AqSession.fromJson(json['session'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'user': user.toJson(),
        'tenant': tenant.toJson(),
        'tokens': tokens.toJson(),
        'session': session.toJson(),
      };
}

/// Token validation request (used by workers, data service).
final class ValidateTokenRequest {
  const ValidateTokenRequest({
    required this.token,
    this.requiredPerms = const [],
  });

  final String token;
  final List<String> requiredPerms;

  Map<String, dynamic> toJson() => {
        'token': token,
        if (requiredPerms.isNotEmpty) 'requiredPerms': requiredPerms,
      };

  factory ValidateTokenRequest.fromJson(Map<String, dynamic> json) =>
      ValidateTokenRequest(
        token: json['token'] as String,
        requiredPerms:
            (json['requiredPerms'] as List<dynamic>?)?.cast<String>() ?? [],
      );
}

/// Token validation response.
final class ValidateTokenResponse {
  const ValidateTokenResponse({
    required this.valid,
    this.claims,
    this.permitted,
    this.reason,
  });

  final bool valid;
  final AqTokenClaims? claims;
  final bool? permitted;
  final String? reason;

  factory ValidateTokenResponse.ok(AqTokenClaims claims,
          {bool permitted = true}) =>
      ValidateTokenResponse(valid: true, claims: claims, permitted: permitted);

  factory ValidateTokenResponse.fail(String reason) =>
      ValidateTokenResponse(valid: false, reason: reason);

  factory ValidateTokenResponse.fromJson(Map<String, dynamic> json) =>
      ValidateTokenResponse(
        valid: json['valid'] as bool,
        claims: json['claims'] != null
            ? AqTokenClaims.fromJson(json['claims'] as Map<String, dynamic>)
            : null,
        permitted: json['permitted'] as bool?,
        reason: json['reason'] as String?,
      );

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{'valid': valid};
    if (claims != null) m['claims'] = claims!.toJson();
    if (permitted != null) m['permitted'] = permitted;
    if (reason != null) m['reason'] = reason;
    return m;
  }
}

/// Standard error envelope.
final class SecurityError {
  const SecurityError(
      {required this.code, required this.message, this.details});

  final String code;
  final String message;
  final Map<String, dynamic>? details;

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{'code': code, 'message': message};
    if (details != null) m['details'] = details;
    return m;
  }

  factory SecurityError.fromJson(Map<String, dynamic> json) => SecurityError(
        code: json['code'] as String,
        message: json['message'] as String,
        details: json['details'] as Map<String, dynamic>?,
      );
}
