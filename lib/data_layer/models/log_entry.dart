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

  Map<String, dynamic> toMap() => {
        'entryId': entryId,
        'entityId': entityId,
        'collectionId': collectionId,
        'changedBy': changedBy,
        'changedAt': changedAt.toIso8601String(),
        'operation': operation.name,
        'diff': jsonEncode(
          diff.map((k, v) => MapEntry(k, v.toMap())),
        ),
        'snapshot': snapshot != null ? jsonEncode(snapshot) : null,
        'rollbackToEntryId': rollbackToEntryId,
      };

  factory LogEntry.fromMap(Map<String, dynamic> m) {
    // Decode diff
    final rawDiff = m['diff'];
    final Map<String, FieldDiff> diff;
    if (rawDiff is String && rawDiff.isNotEmpty) {
      final decoded = jsonDecode(rawDiff) as Map<String, dynamic>? ?? {};
      diff = decoded.map(
        (k, v) => MapEntry(k, FieldDiff.fromMap(v as Map<String, dynamic>)),
      );
    } else if (rawDiff is Map) {
      diff = (rawDiff as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, FieldDiff.fromMap(v as Map<String, dynamic>)),
      );
    } else {
      diff = {};
    }

    // Decode snapshot
    final rawSnap = m['snapshot'];
    Map<String, dynamic>? snapshot;
    if (rawSnap is String && rawSnap.isNotEmpty) {
      snapshot = jsonDecode(rawSnap) as Map<String, dynamic>?;
    } else if (rawSnap is Map) {
      snapshot = Map<String, dynamic>.from(rawSnap);
    }

    return LogEntry(
      entryId: m['entryId'] as String,
      entityId: m['entityId'] as String,
      collectionId: m['collectionId'] as String? ?? '',
      changedBy: m['changedBy'] as String? ?? '',
      changedAt: DateTime.tryParse(m['changedAt'] as String? ?? '') ?? DateTime.now(),
      operation: LogOperation.fromString(m['operation'] as String? ?? 'updated'),
      diff: diff,
      snapshot: snapshot,
      rollbackToEntryId: m['rollbackToEntryId'] as String?,
    );
  }

  @override
  String toString() =>
      'LogEntry($entryId op:${operation.name} by:$changedBy at:${changedAt.toIso8601String()})';
}
