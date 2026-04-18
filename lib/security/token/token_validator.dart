// pkgs/aq_schema/lib/security/token/token_validator.dart
//
// Shared token validation logic. Pure Dart.
// Used identically on client (verify incoming tokens),
// server (validate before processing),
// and worker (check auth before executing jobs).
//
// The validator does NOT check revocation — that requires DB access
// and lives in the server layer (SecurityServer.validateToken).
// Clients and workers call POST /auth/validate for full validation.

import '../models/aq_token_claims.dart';
import 'token_codec.dart';

enum ValidationFailure {
  malformed,
  invalidSignature,
  expired,
  wrongType,
}

final class TokenValidationResult {
  const TokenValidationResult._({
    required this.valid,
    this.claims,
    this.failure,
    this.message,
  });

  factory TokenValidationResult.ok(AqTokenClaims claims) =>
      TokenValidationResult._(valid: true, claims: claims);

  factory TokenValidationResult.fail(ValidationFailure failure, String message) =>
      TokenValidationResult._(valid: false, failure: failure, message: message);

  final bool valid;
  final AqTokenClaims? claims;
  final ValidationFailure? failure;
  final String? message;

  /// Throws [TokenException] if not valid.
  AqTokenClaims get claimsOrThrow {
    if (!valid || claims == null) {
      throw TokenFormatException(message ?? 'Token validation failed');
    }
    return claims!;
  }
}

/// Stateless token validator. Shared across all nodes.
final class TokenValidator {
  const TokenValidator({required this.codec});

  final TokenCodec codec;

  /// Validate access token signature and expiry.
  TokenValidationResult validateAccess(String token) =>
      _validate(token, expectedType: TokenType.access);

  /// Validate refresh token signature and expiry.
  TokenValidationResult validateRefresh(String token) =>
      _validate(token, expectedType: TokenType.refresh);

  /// Validate any token type.
  TokenValidationResult validate(String token) => _validate(token);

  TokenValidationResult _validate(String token, {TokenType? expectedType}) {
    AqTokenClaims claims;
    try {
      claims = codec.decode(token);
    } on TokenSignatureException catch (e) {
      return TokenValidationResult.fail(ValidationFailure.invalidSignature, e.message);
    } on TokenFormatException catch (e) {
      return TokenValidationResult.fail(ValidationFailure.malformed, e.message);
    } catch (e) {
      return TokenValidationResult.fail(ValidationFailure.malformed, e.toString());
    }

    if (claims.isExpired) {
      return TokenValidationResult.fail(
        ValidationFailure.expired,
        'Token expired at ${DateTime.fromMillisecondsSinceEpoch(claims.exp * 1000)}',
      );
    }

    if (expectedType != null && claims.type != expectedType) {
      return TokenValidationResult.fail(
        ValidationFailure.wrongType,
        'Expected ${expectedType.value} token, got ${claims.type.value}',
      );
    }

    return TokenValidationResult.ok(claims);
  }
}
