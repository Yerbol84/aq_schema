import 'direct_storable.dart';

/// Metadata record for a stored artifact (file).
///
/// The binary content is managed by [ArtifactStorage]; this model holds
/// only the metadata that is stored in [VaultStorage] (key-value).
abstract interface class ArtifactEntry implements DirectStorable {
  /// Logical storage key / path (e.g. "projects/abc/report.pdf").
  String get storageKey;

  /// Original file name as provided by the user.
  String get fileName;

  /// MIME content type (e.g. "application/pdf", "image/png").
  String get contentType;

  /// File size in bytes.
  int get sizeBytes;

  /// SHA-256 checksum of the raw content (hex string).
  String get checksum;

  /// Arbitrary metadata map (tags, project ID, run ID, etc.).
  Map<String, String> get meta;

  /// UTC timestamp when this artifact was created.
  DateTime get createdAt;
}
