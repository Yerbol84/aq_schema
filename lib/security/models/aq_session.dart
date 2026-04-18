// pkgs/aq_schema/lib/security/models/aq_session.dart
//
// Authenticated session. One session per login.
// Session ID is embedded in every JWT (sid claim).

import 'aq_user.dart';

enum SessionStatus {
  active('active'),
  expired('expired'),
  revoked('revoked');

  const SessionStatus(this.value);
  final String value;

  static SessionStatus fromString(String s) =>
      SessionStatus.values.firstWhere((e) => e.value == s,
          orElse: () => SessionStatus.active);
}

final class AqSession {
  const AqSession({
    required this.id,
    required this.userId,
    required this.tenantId,
    required this.status,
    required this.authProvider,
    required this.createdAt,
    required this.expiresAt,
    required this.lastSeenAt,
    this.ipAddress,
    this.userAgent,
    this.deviceHint,
    this.revokedAt,
    this.revokedReason,
  });

  /// Session ID — matches `sid` JWT claim.
  final String id;
  final String userId;
  final String tenantId;
  final SessionStatus status;
  final IdentityProvider authProvider;
  final String? ipAddress;
  final String? userAgent;

  /// Short browser/OS hint for UI display.
  final String? deviceHint;

  final int createdAt;
  final int expiresAt;
  final int lastSeenAt;
  final int? revokedAt;
  final String? revokedReason;

  bool get isActive {
    if (status != SessionStatus.active) return false;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return now < expiresAt;
  }

  AqSession copyWith({
    SessionStatus? status,
    int? lastSeenAt,
    int? revokedAt,
    String? revokedReason,
  }) =>
      AqSession(
        id: id,
        userId: userId,
        tenantId: tenantId,
        status: status ?? this.status,
        authProvider: authProvider,
        ipAddress: ipAddress,
        userAgent: userAgent,
        deviceHint: deviceHint,
        createdAt: createdAt,
        expiresAt: expiresAt,
        lastSeenAt: lastSeenAt ?? this.lastSeenAt,
        revokedAt: revokedAt ?? this.revokedAt,
        revokedReason: revokedReason ?? this.revokedReason,
      );

  factory AqSession.fromJson(Map<String, dynamic> json) => AqSession(
        id: json['id'] as String,
        userId: json['userId'] as String,
        tenantId: json['tenantId'] as String,
        status: SessionStatus.fromString(json['status'] as String? ?? 'active'),
        authProvider: IdentityProvider.fromString(
            json['authProvider'] as String? ?? 'mock'),
        ipAddress: json['ipAddress'] as String?,
        userAgent: json['userAgent'] as String?,
        deviceHint: json['deviceHint'] as String?,
        createdAt: json['createdAt'] as int,
        expiresAt: json['expiresAt'] as int,
        lastSeenAt: json['lastSeenAt'] as int,
        revokedAt: json['revokedAt'] as int?,
        revokedReason: json['revokedReason'] as String?,
      );

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'id': id,
      'userId': userId,
      'tenantId': tenantId,
      'status': status.value,
      'authProvider': authProvider.value,
      'createdAt': createdAt,
      'expiresAt': expiresAt,
      'lastSeenAt': lastSeenAt,
    };
    if (ipAddress != null) m['ipAddress'] = ipAddress;
    if (userAgent != null) m['userAgent'] = userAgent;
    if (deviceHint != null) m['deviceHint'] = deviceHint;
    if (revokedAt != null) m['revokedAt'] = revokedAt;
    if (revokedReason != null) m['revokedReason'] = revokedReason;
    return m;
  }

  @override
  String toString() => 'AqSession(id: $id, userId: $userId, status: ${status.value})';
}
