import 'dart:convert';
import 'log_operation.dart';
import 'field_diff.dart';

/// An immutable record of one change to a [LoggedStorable] entity.
final class LogEntry {
  final String entryId;
  final String entityId;
  final String collectionId;
  final String changedBy;
  final DateTime changedAt;
  final LogOperation operation;

  /// Field-level diffs. Key = field name.
  final Map<String, FieldDiff> diff;

  /// Full snapshot of the entity after this change.
  /// Non-null when [LoggedRepository] was created with captureFullSnapshot=true.
  final Map<String, dynamic>? snapshot;

  /// For rollback entries: the entry this rolled back to.
  final String? rollbackToEntryId;

  const LogEntry({
    required this.entryId,
    required this.entityId,
    required this.collectionId,
    required this.changedBy,
    required this.changedAt,
    required this.operation,
    this.diff = const {},
    this.snapshot,
    this.rollbackToEntryId,
  });

  /// 3-level constants system: Domain → Sphere → Key
  static final keys = _LogEntryKeys._();

  // ── Serialization ───────────────────────────────────────────────────────────

  Map<String, dynamic> toMap() {
    final k = LogEntry.keys.jsonKeys;
    return {
      k.entryId: entryId,
      k.entityId: entityId,
      k.collectionId: collectionId,
      k.changedBy: changedBy,
      k.changedAt: changedAt.toIso8601String(),
      k.operation: operation.name,
      k.diff: jsonEncode(
        diff.map((key, value) => MapEntry(key, value.toMap())),
      ),
      k.snapshot: snapshot != null ? jsonEncode(snapshot) : null,
      k.rollbackToEntryId: rollbackToEntryId,
    };
  }

  factory LogEntry.fromMap(Map<String, dynamic> m) {
    final k = LogEntry.keys.jsonKeys;

    // Decode diff
    final rawDiff = m[k.diff];
    final Map<String, FieldDiff> diff;
    if (rawDiff is String && rawDiff.isNotEmpty) {
      final decoded = jsonDecode(rawDiff) as Map<String, dynamic>? ?? {};
      diff = decoded.map(
        (key, value) => MapEntry(key, FieldDiff.fromMap(value as Map<String, dynamic>)),
      );
    } else if (rawDiff is Map) {
      diff = (rawDiff as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, FieldDiff.fromMap(value as Map<String, dynamic>)),
      );
    } else {
      diff = {};
    }

    // Decode snapshot
    final rawSnap = m[k.snapshot];
    Map<String, dynamic>? snapshot;
    if (rawSnap is String && rawSnap.isNotEmpty) {
      snapshot = jsonDecode(rawSnap) as Map<String, dynamic>?;
    } else if (rawSnap is Map) {
      snapshot = Map<String, dynamic>.from(rawSnap);
    }

    return LogEntry(
      entryId: m[k.entryId] as String,
      entityId: m[k.entityId] as String,
      collectionId: m[k.collectionId] as String? ?? '',
      changedBy: m[k.changedBy] as String? ?? '',
      changedAt: DateTime.tryParse(m[k.changedAt] as String? ?? '') ?? DateTime.now(),
      operation: LogOperation.fromString(m[k.operation] as String? ?? 'updated'),
      diff: diff,
      snapshot: snapshot,
      rollbackToEntryId: m[k.rollbackToEntryId] as String?,
    );
  }

  @override
  String toString() =>
      'LogEntry($entryId op:${operation.name} by:$changedBy at:${changedAt.toIso8601String()})';
}

// ── Level 2: Spheres ──────────────────────────────────────────────────────────

class _LogEntryKeys {
  _LogEntryKeys._();

  final jsonKeys = _LogEntryJsonKeys._();
}

// ── Level 3: JSON Keys ────────────────────────────────────────────────────────

class _LogEntryJsonKeys {
  _LogEntryJsonKeys._();

  final String entryId = 'entryId';
  final String entityId = 'entityId';
  final String collectionId = 'collectionId';
  final String changedBy = 'changedBy';
  final String changedAt = 'changedAt';
  final String operation = 'operation';
  final String diff = 'diff';
  final String snapshot = 'snapshot';
  final String rollbackToEntryId = 'rollbackToEntryId';
}
