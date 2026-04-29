// aq_schema/lib/tools/models/tool_call_log.dart
//
// Лог вызова инструмента (append-only).
// Используется для статистики, audit trail, debugging.
//
// ═══════════════════════════════════════════════════════════════════════════════
// ИСПОЛЬЗОВАНИЕ DATA_LAYER
// ═══════════════════════════════════════════════════════════════════════════════
//
// ToolCallLog — это DirectStorable (append-only). Используй directRepository<ToolCallLog>().
//
// ⚠️ ВАЖНО: Логи ТОЛЬКО создаются, никогда не обновляются и не удаляются!
//
// ── Залогировать вызов инструмента ────────────────────────────────────────────
//
// import 'package:uuid/uuid.dart';
//
// final log = ToolCallLog(
//   id: Uuid().v4(),
//   toolRef: ToolRef('llm_complete', namespace: 'aq/llm'),
//   workspaceId: 'workspace123',
//   calledAt: DateTime.now(),
//   elapsed: Duration(milliseconds: 1234),
//   success: true,
//   runId: 'run-456',
//   userId: 'user789',
// );
//
// await dataLayer.directRepository<ToolCallLog>().create(log);
//
// ── Получить логи для инструмента ─────────────────────────────────────────────
//
// final query = QueryBuilder()
//     .where('tool_ref.name', '=', 'llm_complete')
//     .where('workspace_id', '=', 'workspace123')
//     .orderBy('called_at', descending: true)
//     .limit(100)
//     .build();
//
// final logs = await dataLayer
//     .directRepository<ToolCallLog>()
//     .query(query);
//
// ── Статистика за период ──────────────────────────────────────────────────────
//
// final query = QueryBuilder()
//     .where('workspace_id', '=', 'workspace123')
//     .where('called_at', '>=', DateTime.now().subtract(Duration(days: 7)))
//     .build();
//
// final logs = await dataLayer.directRepository<ToolCallLog>().query(query);
//
// final totalCalls = logs.length;
// final failedCalls = logs.where((l) => !l.success).length;
// final avgLatency = logs.map((l) => l.elapsed.inMilliseconds).reduce((a, b) => a + b) / logs.length;
//
// ── Логи для конкретного run ──────────────────────────────────────────────────
//
// final query = QueryBuilder()
//     .where('run_id', '=', 'run-456')
//     .orderBy('called_at')
//     .build();
//
// final runLogs = await dataLayer.directRepository<ToolCallLog>().query(query);
//
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:aq_schema/aq_schema.dart';

import '../../data_layer/storable/storable.dart';
import 'tool_ref.dart';

/// Лог вызова инструмента.
///
/// Append-only модель для статистики и audit.
/// Пишется при каждом вызове инструмента через Runtime.
///
/// ```dart
/// final log = ToolCallLog(
///   id: uuid.v4(),
///   toolRef: ToolRef('llm_complete', namespace: 'aq/llm'),
///   workspaceId: 'workspace123',
///   calledAt: DateTime.now(),
///   elapsed: Duration(milliseconds: 1234),
///   success: true,
///   runId: 'run-456',
/// );
///
/// await dataLayer.directRepository<ToolCallLog>().create(log);
/// ```
final class ToolCallLog implements DirectStorable {
  static final _ToolCallLogKeys _keys = _ToolCallLogKeys._();
  static _ToolCallLogKeys get keys => _keys;

  @override
  final String id; // UUID

  final ToolRef toolRef;
  final String workspaceId;
  final DateTime calledAt;
  final Duration elapsed;
  final bool success;
  final String? errorCode;
  final String? runId; // связь с graph run
  final String? userId;
  final String? sandboxId;

  const ToolCallLog({
    required this.id,
    required this.toolRef,
    required this.workspaceId,
    required this.calledAt,
    required this.elapsed,
    required this.success,
    this.errorCode,
    this.runId,
    this.userId,
    this.sandboxId,
  });

  @override
  String get domain => 'tools';

  @override
  Map<String, dynamic> toJson() => {
        ToolCallLog.keys.id: id,
        ToolCallLog.keys.toolRef: toolRef.toJson(),
        ToolCallLog.keys.workspaceId: workspaceId,
        ToolCallLog.keys.calledAt: calledAt.toIso8601String(),
        ToolCallLog.keys.elapsedMs: elapsed.inMilliseconds,
        ToolCallLog.keys.success: success,
        if (errorCode != null) ToolCallLog.keys.errorCode: errorCode,
        if (runId != null) ToolCallLog.keys.runId: runId,
        if (userId != null) ToolCallLog.keys.userId: userId,
        if (sandboxId != null) ToolCallLog.keys.sandboxId: sandboxId,
      };

  factory ToolCallLog.fromJson(Map<String, dynamic> json) => ToolCallLog(
        id: json[ToolCallLog.keys.id] as String,
        toolRef: ToolRef.fromJson(
            json[ToolCallLog.keys.toolRef] as Map<String, dynamic>),
        workspaceId: json[ToolCallLog.keys.workspaceId] as String,
        calledAt: DateTime.parse(json[ToolCallLog.keys.calledAt] as String),
        elapsed:
            Duration(milliseconds: json[ToolCallLog.keys.elapsedMs] as int),
        success: json[ToolCallLog.keys.success] as bool,
        errorCode: json[ToolCallLog.keys.errorCode] as String?,
        runId: json[ToolCallLog.keys.runId] as String?,
        userId: json[ToolCallLog.keys.userId] as String?,
        sandboxId: json[ToolCallLog.keys.sandboxId] as String?,
      );

  @override
  String toString() =>
      'ToolCallLog(${toolRef.fullId} @ $calledAt, success: $success)';

  @override
  // TODO: implement collectionName
  String get collectionName => throw UnimplementedError();

  @override
  // TODO: implement indexFields
  Map<String, dynamic> get indexFields => throw UnimplementedError();

  @override
  // TODO: implement jsonSchema
  Map<String, dynamic> get jsonSchema => throw UnimplementedError();

  @override
  // TODO: implement softDelete
  bool get softDelete => throw UnimplementedError();

  @override
  Map<String, dynamic> toMap() {
    // TODO: implement toMap
    throw UnimplementedError();
  }
}

class _ToolCallLogKeys {
  _ToolCallLogKeys._();

  final String id = 'id';
  final String toolRef = 'tool_ref';
  final String workspaceId = 'workspace_id';
  final String calledAt = 'called_at';
  final String elapsedMs = 'elapsed_ms';
  final String success = 'success';
  final String errorCode = 'error_code';
  final String runId = 'run_id';
  final String userId = 'user_id';
  final String sandboxId = 'sandbox_id';

  List<String> get all => [
        id,
        toolRef,
        workspaceId,
        calledAt,
        elapsedMs,
        success,
        errorCode,
        runId,
        userId,
        sandboxId
      ];
  Set<String> get required =>
      {id, toolRef, workspaceId, calledAt, elapsedMs, success};
}
