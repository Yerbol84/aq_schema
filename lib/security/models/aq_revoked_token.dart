// pkgs/aq_schema/lib/security/models/aq_revoked_token.dart
//
// Revoked token record для blacklist.
// Хранится в БД для distributed revocation.

final class AqRevokedToken {
  const AqRevokedToken({
    required this.jti,
    required this.userId,
    required this.tenantId,
    required this.revokedAt,
    required this.expiresAt,
    required this.reason,
    this.revokedBy,
  });

  /// Token ID (jti claim)
  final String jti;

  /// User ID (sub claim)
  final String userId;

  /// Tenant ID (tid claim)
  final String tenantId;

  /// Timestamp когда token был revoked
  final int revokedAt;

  /// Timestamp когда token истекает (для cleanup)
  final int expiresAt;

  /// Причина revocation
  final String reason;

  /// Кто revoked (user ID или 'system')
  final String? revokedBy;

  bool get isExpired {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return now >= expiresAt;
  }

  factory AqRevokedToken.fromJson(Map<String, dynamic> json) => AqRevokedToken(
        jti: json['jti'] as String,
        userId: json['userId'] as String,
        tenantId: json['tenantId'] as String,
        revokedAt: json['revokedAt'] as int,
        expiresAt: json['expiresAt'] as int,
        reason: json['reason'] as String,
        revokedBy: json['revokedBy'] as String?,
      );

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'jti': jti,
      'userId': userId,
      'tenantId': tenantId,
      'revokedAt': revokedAt,
      'expiresAt': expiresAt,
      'reason': reason,
    };
    if (revokedBy != null) m['revokedBy'] = revokedBy;
    return m;
  }
}

/// Repository interface для revoked tokens.
abstract interface class IRevokedTokenRepository {
  /// Добавить token в blacklist
  Future<void> revoke(AqRevokedToken token);

  /// Проверить, revoked ли token
  Future<bool> isRevoked(String jti);

  /// Получить revoked token по jti
  Future<AqRevokedToken?> findByJti(String jti);

  /// Revoke все tokens пользователя
  Future<int> revokeAllForUser(String userId, {String? reason});

  /// Revoke все tokens сессии
  Future<int> revokeAllForSession(String sessionId, {String? reason});

  /// Удалить истёкшие tokens из blacklist
  Future<int> cleanupExpired();

  /// Получить список revoked tokens пользователя
  Future<List<AqRevokedToken>> listByUser(String userId);
}
