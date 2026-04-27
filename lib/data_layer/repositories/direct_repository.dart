import 'package:aq_schema/aq_schema.dart';

/// Repository for simple CRUD — no versioning, no change log.
///
/// Use for: settings, API keys, configuration, lookup tables.
abstract interface class DirectRepository<T extends DirectStorable> {
  // ── Write ──────────────────────────────────────────────────────────────────

  Future<void> save(T entity);
  Future<void> saveAll(List<T> entities);
  Future<void> delete(String id);

  /// Restore a soft-deleted entity by clearing its deletedAt field.
  /// Only works for entities with softDelete = true.
  /// Throws if entity doesn't exist or was hard-deleted.
  Future<void> restore(String id);

  // ── Read ───────────────────────────────────────────────────────────────────

  Future<T?> findById(String id);
  Future<List<T>> findAll({VaultQuery? query});

  /// Find all entities including soft-deleted ones (deletedAt != null).
  /// Use this to show "trash" or "deleted items" view.
  Future<List<T>> findAllIncludingDeleted({VaultQuery? query});

  Future<bool> exists(String id);
  Future<int> count({VaultQuery? query});

  // ── Pagination ─────────────────────────────────────────────────────────────

  /// Fetch a single page. Requires [query.limit] to be set.
  Future<PageResult<T>> findPage(VaultQuery query);

  // ── Indexes ────────────────────────────────────────────────────────────────

  Future<void> registerIndex(VaultIndex index);

  // ── Streams ────────────────────────────────────────────────────────────────

  Stream<List<T>> watchAll({VaultQuery? query});
}
