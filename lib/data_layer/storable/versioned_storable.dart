import 'sharable.dart';
import 'versionable.dart';

/// Marker interface for versioned storage.
/// Entities have semver lifecycle, branching, and access control.
///
/// Combines [Sharable] (multi-tenancy + sharing) and [Versionable]
/// (schema versioning + migrations).
///
/// Access control is managed by security layer via IVaultSecurityProtocol.
abstract interface class VersionedStorable implements Sharable, Versionable {
  // Access grants removed - managed by security layer
}
