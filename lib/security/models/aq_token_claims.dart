// pkgs/aq_schema/lib/security/models/aq_token_claims.dart
//
// JWT payload model. SHARED between client and server — pure Dart, no deps.
// Both access and refresh tokens use this structure.
//
// Access token:  type='access',  exp=now+900
// Refresh token: type='refresh', exp=now+2592000

import 'aq_user.dart';

enum TokenType {
  access('access'),
  refresh('refresh'),
  id('id');

  const TokenType(this.value);
  final String value;

  static TokenType fromString(String s) =>
      TokenType.values.firstWhere((e) => e.value == s,
          orElse: () => TokenType.access);
}

/// JWT payload. Shared between all nodes — client, server, worker.
final class AqTokenClaims {
  const AqTokenClaims({
    required this.sub,
    required this.tid,
    required this.email,
    required this.type,
    required this.iat,
    required this.exp,
    required this.jti,
    required this.sid,
    this.name,
    this.roles = const [],
    this.perms = const [],
    this.utype = UserType.endUser,
  });

  /// Subject — AqUser.id
  final String sub;

  /// Tenant ID — AqTenant.id
  final String tid;

  final String email;
  final String? name;
  final TokenType type;

  /// Active role names
  final List<String> roles;

  /// Flattened permission keys from all roles
  final List<String> perms;

  /// UserType shortcut — avoids role lookup on every request
  final UserType utype;

  /// Issued at (Unix seconds)
  final int iat;

  /// Expires at (Unix seconds)
  final int exp;

  /// Unique token ID — used for revocation
  final String jti;

  /// Session ID — matches AqSession.id
  final String sid;

  bool get isExpired {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return now >= exp;
  }

  bool hasPermission(String perm) {
    if (perms.contains('*')) return true;
    if (perms.contains(perm)) return true;
    final parts = perm.split(':');
    if (parts.length == 2) return perms.contains('${parts[0]}:*');
    return false;
  }

  bool hasAllPermissions(List<String> required) =>
      required.every(hasPermission);

  factory AqTokenClaims.fromJson(Map<String, dynamic> json) => AqTokenClaims(
        sub: json['sub'] as String,
        tid: json['tid'] as String,
        email: json['email'] as String,
        name: json['name'] as String?,
        type: TokenType.fromString(json['type'] as String? ?? 'access'),
        roles: (json['roles'] as List<dynamic>?)?.cast<String>() ?? [],
        perms: (json['perms'] as List<dynamic>?)?.cast<String>() ?? [],
        utype: UserType.fromString(json['utype'] as String? ?? 'end_user'),
        iat: json['iat'] as int,
        exp: json['exp'] as int,
        jti: json['jti'] as String,
        sid: json['sid'] as String,
      );

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'sub': sub,
      'tid': tid,
      'email': email,
      'type': type.value,
      'utype': utype.value,
      'iat': iat,
      'exp': exp,
      'jti': jti,
      'sid': sid,
    };
    if (name != null) m['name'] = name;
    if (roles.isNotEmpty) m['roles'] = roles;
    if (perms.isNotEmpty) m['perms'] = perms;
    return m;
  }

  @override
  String toString() =>
      'AqTokenClaims(sub: $sub, type: ${type.value}, exp: $exp)';
}

/// Access + Refresh token pair returned on successful auth.
final class TokenPair {
  const TokenPair({
    required this.accessToken,
    required this.refreshToken,
    required this.accessExpiresAt,
    required this.refreshExpiresAt,
    this.tokenType = 'Bearer',
  });

  final String accessToken;
  final String refreshToken;
  final int accessExpiresAt;
  final int refreshExpiresAt;
  final String tokenType;

  factory TokenPair.fromJson(Map<String, dynamic> json) => TokenPair(
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
        accessExpiresAt: json['accessExpiresAt'] as int,
        refreshExpiresAt: json['refreshExpiresAt'] as int,
        tokenType: json['tokenType'] as String? ?? 'Bearer',
      );

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'accessExpiresAt': accessExpiresAt,
        'refreshExpiresAt': refreshExpiresAt,
        'tokenType': tokenType,
      };
}
