import 'package:aq_schema/aq_schema.dart';

/// Repository that records a full change history for every mutation.
///
/// Use for: audit trails, workflow run logs, document edits, compliance.
///
/// Every [save] and [delete] appends a [LogEntry]. [rollbackTo] restores
/// an entity to any past state without removing the log — the rollback
/// itself is recorded as a new entry.
abstract interface class LoggedRepository<T extends LoggedStorable> {
  // ── Write ──────────────────────────────────────────────────────────────────

  /// Insert or update [entity], recording the change in the log.
  Future<void> save(T entity, {required String actorId});

  /// Delete [entityId], recording a deletion entry.
  Future<void> delete(String entityId, {required String actorId});

  /// Restore a soft-deleted entity by clearing its deletedAt field.
  /// Only works for entities with softDelete = true.
  /// Records the restore as a new log entry.
  Future<void> restore(String entityId, {required String actorId});

  // ── Read ───────────────────────────────────────────────────────────────────

  Future<T?> findById(String id);
  Future<List<T>> findAll({VaultQuery? query});

  /// Find all entities including soft-deleted ones (deletedAt != null).
  /// Use this to show "trash" or "deleted items" view.
  Future<List<T>> findAllIncludingDeleted({VaultQuery? query});

  Future<PageResult<T>> findPage(VaultQuery query);
  Future<bool> exists(String id);
  Future<int> count({VaultQuery? query});

  // ── History ────────────────────────────────────────────────────────────────

  Future<List<LogEntry>> getHistory(String entityId);

  Future<List<LogEntry>> queryHistory(String entityId, VaultQuery query);

  Future<PageResult<LogEntry>> getHistoryPage(
      String entityId, VaultQuery query);

  /// Reconstruct entity state at [moment] by replaying log entries.
  Future<T?> getStateAt(String entityId, DateTime moment);

  Future<LogEntry?> getLastEntry(String entityId);

  /// All log entries in this collection, optionally filtered by date range.
  Future<List<LogEntry>> getCollectionLog({DateTime? from, DateTime? to});

  // ── Rollback ───────────────────────────────────────────────────────────────

  /// Restore [entityId] to the state at [entryId].
  /// Records the rollback as a new log entry — history is never truncated.
  Future<void> rollbackTo(
    String entityId,
    String entryId, {
    required String actorId,
  });

  // ── Indexes ────────────────────────────────────────────────────────────────

  Future<void> registerIndex(VaultIndex index);

  // ── Streams ────────────────────────────────────────────────────────────────

  Stream<List<LogEntry>> watchHistory(String entityId);
  Stream<List<T>> watchAll({VaultQuery? query});
}
