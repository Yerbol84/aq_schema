import 'package:aq_schema/aq_schema.dart';

/// Core storage backend interface.
///
/// All three repositories depend only on this abstraction.
/// Implement it for Supabase, PostgreSQL, Hive, etc., or use
/// the built-in [InMemoryVaultStorage] / [SupabaseVaultStorage].
///
/// ## Serialisation contract
/// All values passed to [put] / [putAll] must be JSON-safe:
/// String, num, bool, null, List<dynamic>, Map<String, dynamic>.
/// The storage layer MUST NOT call `.toString()` on arbitrary objects.
abstract interface class VaultStorage {
  // ── Collections ────────────────────────────────────────────────────────────

  /// Ensure the collection exists (idempotent).
  Future<void> ensureCollection(String collection);

  // ── CRUD ───────────────────────────────────────────────────────────────────

  Future<void> put(String collection, String id, Map<String, dynamic> data);
  Future<Map<String, dynamic>?> get(String collection, String id);
  Future<void> delete(String collection, String id);
  Future<bool> exists(String collection, String id);

  /// Batch write — more efficient than multiple [put] calls.
  Future<void> putAll(
    String collection,
    Map<String, Map<String, dynamic>> entries,
  );

  // ── Queries ────────────────────────────────────────────────────────────────

  /// Returns all records matching [query].
  /// For large datasets, prefer [queryPage] to avoid loading everything.
  Future<List<Map<String, dynamic>>> query(
    String collection,
    VaultQuery query,
  );

  /// Returns a page of results using [query.limit] and [query.offset].
  /// [PageResult.total] reflects the count of all matching records.
  Future<PageResult<Map<String, dynamic>>> queryPage(
    String collection,
    VaultQuery query,
  );

  Future<int> count(String collection, VaultQuery query);

  // ── Indexes ────────────────────────────────────────────────────────────────

  Future<void> createIndex(String collection, VaultIndex index);

  /// Update index entries for a record after it was written.
  Future<void> updateIndex(
    String collection,
    String id,
    Map<String, dynamic> indexData,
  );

  Future<void> removeFromIndex(String collection, String id);

  // ── Transactions ───────────────────────────────────────────────────────────

  /// Run [action] inside a storage transaction.
  /// On failure, all writes performed inside [action] must be rolled back.
  Future<T> transaction<T>(Future<T> Function(VaultStorage tx) action);

  // ── Reactivity ─────────────────────────────────────────────────────────────

  /// Emits an event whenever any record in [collection] is modified.
  Stream<void> watchChanges(String collection);

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  Future<void> clear(String collection);
  Future<void> dispose();
}
