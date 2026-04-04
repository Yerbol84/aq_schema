/// Backend interface for binary file storage.
///
/// dart_vault separates concerns:
/// - [VaultStorage]    — key/value metadata (JSON)
/// - [ArtifactStorage] — binary content (bytes)
///
/// Implementations:
/// - [LocalArtifactStorage]    — files on the local filesystem (`dart:io`)
/// - `S3ArtifactStorage`       — implement using your HTTP client of choice
/// - `SupabaseArtifactStorage` — Supabase Storage API
///
/// ## Key format
///
/// Keys are hierarchical slash-separated paths:
///   `{tenantId}/{collection}/{id}/{fileName}`
///
/// The [ArtifactRepository] builds keys automatically.
/// You can use any path scheme that fits your storage backend.
abstract interface class ArtifactStorage {
  // ── Write ──────────────────────────────────────────────────────────────────

  /// Store [bytes] under [key].  Overwrites if [key] already exists.
  Future<void> put(String key, List<int> bytes, {String? contentType});

  // ── Read ───────────────────────────────────────────────────────────────────

  Future<List<int>?> get(String key);

  Future<bool> exists(String key);

  /// Returns the content length in bytes, or null if key does not exist.
  Future<int?> size(String key);

  // ── Stream ─────────────────────────────────────────────────────────────────

  /// Stream content in chunks for large files.
  Stream<List<int>> stream(String key);

  // ── Delete ─────────────────────────────────────────────────────────────────

  Future<void> delete(String key);

  /// Delete all keys with the given [prefix].
  Future<void> deleteByPrefix(String prefix);

  // ── List ───────────────────────────────────────────────────────────────────

  /// List all keys with the given [prefix].
  Future<List<String>> list(String prefix);

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  Future<void> dispose();
}
