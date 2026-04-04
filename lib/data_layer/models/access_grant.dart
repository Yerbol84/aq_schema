import 'access_level.dart';

/// Grants [level] access to [actorId] on a versioned entity.
final class AccessGrant {
  final String actorId;
  final AccessLevel level;

  const AccessGrant({required this.actorId, required this.level});

  Map<String, dynamic> toMap() => {
        'actorId': actorId,
        'level': level.name,
      };

  factory AccessGrant.fromMap(Map<String, dynamic> m) => AccessGrant(
        actorId: m['actorId'] as String,
        level: AccessLevel.fromString(m['level'] as String? ?? 'read'),
      );
}
