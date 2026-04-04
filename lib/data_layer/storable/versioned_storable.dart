import 'storable.dart';

/// Marker interface for versioned storage.
/// Entities have semver lifecycle, branching, and access control.
abstract interface class VersionedStorable implements Storable {
  /// Owner of this entity (user/tenant ID).
  String get ownerId;

  /// Access grants for other actors.
  List<Object> get accessGrants;
}
