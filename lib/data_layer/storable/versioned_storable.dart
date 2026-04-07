import 'sharable.dart';
import 'versionable.dart';

/// Marker interface for versioned storage.
/// Entities have semver lifecycle, branching, and access control.
///
/// Combines [Sharable] (multi-tenancy + sharing) and [Versionable]
/// (schema versioning + migrations).
abstract interface class VersionedStorable implements Sharable, Versionable {
  /// Access grants for other actors.
  /// Used by VersionedRepository for fine-grained access control.
  List<Object> get accessGrants;
}
