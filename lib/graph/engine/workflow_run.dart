// Модель запуска графа (WorkflowRun)
// LoggedStorable - каждое изменение статуса записывается в audit trail

import 'package:aq_schema/data_layer/storable/logged_storable.dart';

/// Статус выполнения графа
enum WorkflowRunStatus {
  running('running'),
  suspended('suspended'),
  completed('completed'),
  failed('failed'),
  cancelled('cancelled');

  const WorkflowRunStatus(this.value);
  final String value;

  static WorkflowRunStatus fromString(String s) {
    return values.firstWhere(
      (e) => e.value == s,
      orElse: () => WorkflowRunStatus.running,
    );
  }
}

/// Запуск графа - хранит состояние выполнения
/// LoggedStorable - отслеживаем изменения статуса, логов, контекста
final class WorkflowRun implements LoggedStorable {
  static const kCollection = 'workflow_runs';
  static const kJsonSchema = {
    'type': 'object',
    'properties': {
      'id': {'type': 'string'},
      'projectId': {'type': 'string'},
      'blueprintId': {'type': 'string'},
      'graphSnapshot': {'type': 'object'},
      'status': {'type': 'string'},
      'logsJson': {'type': 'string'},
      'contextJson': {'type': 'string'},
      'suspendedNodeId': {'type': 'string'},
      'createdAt': {'type': 'string', 'format': 'date-time'},
    },
    'required': ['id', 'projectId', 'blueprintId', 'graphSnapshot', 'status', 'logsJson', 'createdAt'],
  };

  /// ID запуска (UUID)
  final String id;

  /// ID проекта, в котором выполняется граф
  final String projectId;

  /// ID blueprint графа (WorkflowGraph.id)
  final String blueprintId;

  /// Снимок графа на момент запуска (JSON)
  final Map<String, dynamic> graphSnapshot;

  /// Текущий статус выполнения
  final WorkflowRunStatus status;

  /// Логи выполнения (JSON array строк)
  final String logsJson;

  /// Контекст выполнения (JSON) - для resume после suspend
  final String? contextJson;

  /// ID узла, на котором приостановлен граф
  final String? suspendedNodeId;

  /// Время создания
  final DateTime createdAt;

  /// Время удаления (для soft delete)
  final DateTime? deletedAt;

  const WorkflowRun({
    required this.id,
    required this.projectId,
    required this.blueprintId,
    required this.graphSnapshot,
    required this.status,
    required this.logsJson,
    this.contextJson,
    this.suspendedNodeId,
    required this.createdAt,
    this.deletedAt,
  });

  // ── Storable interface ──────────────────────────────────────────────────────

  @override
  String get collectionName => 'workflow_runs';

  @override
  bool get softDelete => true;

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'projectId': projectId,
        'blueprintId': blueprintId,
        'graphSnapshot': graphSnapshot,
        'status': status.value,
        'logsJson': logsJson,
        'contextJson': contextJson,
        'suspendedNodeId': suspendedNodeId,
        'createdAt': createdAt.toIso8601String(),
        'deletedAt': deletedAt?.toIso8601String(),
      };

  @override
  Map<String, dynamic> get indexFields => {
        'projectId': projectId,
        'blueprintId': blueprintId,
        'status': status.value,
        'createdAt': createdAt.toIso8601String(),
      };

  @override
  Map<String, dynamic> get jsonSchema => kJsonSchema;

  // ── LoggedStorable interface ────────────────────────────────────────────────

  /// Отслеживаем изменения статуса, логов, контекста
  @override
  Set<String> get trackedFields => {
        'status',
        'logsJson',
        'contextJson',
        'suspendedNodeId',
      };

  // ── Factory ─────────────────────────────────────────────────────────────────

  factory WorkflowRun.fromMap(Map<String, dynamic> m) {
    return WorkflowRun(
      id: m['id'] as String,
      projectId: m['projectId'] as String,
      blueprintId: m['blueprintId'] as String,
      graphSnapshot: (m['graphSnapshot'] as Map<String, dynamic>?) ?? const {},
      status: WorkflowRunStatus.fromString(m['status'] as String? ?? 'running'),
      logsJson: m['logsJson'] as String? ?? '[]',
      contextJson: m['contextJson'] as String?,
      suspendedNodeId: m['suspendedNodeId'] as String?,
      createdAt: DateTime.tryParse(m['createdAt'] as String? ?? '') ?? DateTime.now(),
      deletedAt: m['deletedAt'] != null
          ? DateTime.tryParse(m['deletedAt'] as String)
          : null,
    );
  }

  // ── copyWith ────────────────────────────────────────────────────────────────

  WorkflowRun copyWith({
    String? id,
    String? projectId,
    String? blueprintId,
    Map<String, dynamic>? graphSnapshot,
    WorkflowRunStatus? status,
    String? logsJson,
    String? contextJson,
    String? suspendedNodeId,
    DateTime? createdAt,
    DateTime? deletedAt,
  }) {
    return WorkflowRun(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      blueprintId: blueprintId ?? this.blueprintId,
      graphSnapshot: graphSnapshot ?? this.graphSnapshot,
      status: status ?? this.status,
      logsJson: logsJson ?? this.logsJson,
      contextJson: contextJson ?? this.contextJson,
      suspendedNodeId: suspendedNodeId ?? this.suspendedNodeId,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
