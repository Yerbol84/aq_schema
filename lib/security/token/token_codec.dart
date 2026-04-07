// pkgs/aq_schema/lib/security/token/token_codec.dart
//
// Pure Dart JWT implementation (HS256).
// Used on BOTH client (decode/verify) and server (sign/verify).
// No external JWT library — only dart:convert and dart:typed_data.
// HMAC-SHA256 requires the 'crypto' package (pure Dart, no native code).
//
// Dependencies: crypto (^3.0.0)

import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

import '../models/aq_token_claims.dart';

/// Low-level JWT codec. Use [TokenValidator] for full validation.
final class TokenCodec {
  const TokenCodec({required this.secret});

  final String secret;

  // ── Encode ────────────────────────────────────────────────────────────────

  /// Sign claims and return compact JWT string.
  String encode(AqTokenClaims claims) {
    final header = _b64({'alg': 'HS256', 'typ': 'JWT'});
    final payload = _b64(claims.toJson());
    final message = '$header.$payload';
    final sig = _sign(message);
    return '$message.$sig';
  }

  // ── Decode ────────────────────────────────────────────────────────────────

  /// Decode without verifying signature. Use [decode] for trusted decode.
  static AqTokenClaims decodeUnverified(String token) {
    final parts = token.split('.');
    if (parts.length != 3) throw const TokenFormatException('Invalid JWT structure');
    final payload = _fromB64(parts[1]);
    return AqTokenClaims.fromJson(payload);
  }

  /// Decode and verify signature. Throws [TokenException] on failure.
  AqTokenClaims decode(String token) {
    final parts = token.split('.');
    if (parts.length != 3) throw const TokenFormatException('Invalid JWT structure');

    // Verify signature
    final message = '${parts[0]}.${parts[1]}';
    final expectedSig = _sign(message);
    if (!_constantTimeEquals(expectedSig, parts[2])) {
      throw const TokenSignatureException('Invalid token signature');
    }

    final payload = _fromB64(parts[1]);
    return AqTokenClaims.fromJson(payload);
  }

  // ── Private ───────────────────────────────────────────────────────────────

  String _sign(String message) {
    final key = utf8.encode(secret);
    final bytes = utf8.encode(message);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(bytes);
    return _base64UrlEncode(Uint8List.fromList(digest.bytes));
  }

  static String _b64(Map<String, dynamic> data) {
    final json = jsonEncode(data);
    return _base64UrlEncode(utf8.encode(json) as Uint8List);
  }

  static Map<String, dynamic> _fromB64(String b64) {
    final normalized = b64.padRight(
      b64.length + (4 - b64.length % 4) % 4,
      '=',
    );
    final decoded = base64Url.decode(normalized);
    return jsonDecode(utf8.decode(decoded)) as Map<String, dynamic>;
  }

  static String _base64UrlEncode(Uint8List bytes) =>
      base64Url.encode(bytes).replaceAll('=', '');

  /// Constant-time string comparison — prevents timing attacks.
  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }
}

// ── Exceptions ────────────────────────────────────────────────────────────────

sealed class TokenException implements Exception {
  const TokenException(this.message);
  final String message;
  @override
  String toString() => '$runtimeType: $message';
}

final class TokenFormatException extends TokenException {
  const TokenFormatException(super.message);
}

final class TokenSignatureException extends TokenException {
  const TokenSignatureException(super.message);
}

final class TokenExpiredException extends TokenException {
  const TokenExpiredException(super.message);
}

final class TokenRevokedException extends TokenException {
  const TokenRevokedException(super.message);
}

final class TokenInvalidTypeException extends TokenException {
  const TokenInvalidTypeException(super.message);
}
