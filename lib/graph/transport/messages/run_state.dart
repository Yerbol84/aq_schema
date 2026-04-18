// Модель состояния выполнения графа для персистентности

import '../../../data_layer/storable/direct_storable.dart';
import 'run_status.dart';

/// Состояние выполнения графа
///
/// Используется для сохранения и восстановления состояния runs
/// между graph_engine_server и data_service
class GraphRunState implements DirectStorable {
  @override
  final String id; // runId используется как id

  final String runId;
  final String blueprintId;
  final String projectId;
  final GraphRunStatus status;
  final String? currentNodeId;
  final Map<String, dynamic> variables;
  final DateTime startedAt;
  final DateTime? completedAt;
  final String? error;

  const GraphRunState({
    required this.runId,
    required this.blueprintId,
    required this.projectId,
    required this.status,
    this.currentNodeId,
    this.variables = const {},
    required this.startedAt,
    this.completedAt,
    this.error,
  }) : id = runId;

  @override
  String get collectionName => 'graph_run_states';

  @override
  Map<String, dynamic> toMap() => toJson();

  @override
  Map<String, dynamic> get indexFields => {
        'blueprintId': blueprintId,
        'projectId': projectId,
        'status': status.name,
        'startedAt': startedAt.toIso8601String(),
      };

  @override
  Map<String, dynamic> get jsonSchema => {
        'type': 'object',
        'properties': {
          'id': {'type': 'string'},
          'runId': {'type': 'string'},
          'blueprintId': {'type': 'string'},
          'projectId': {'type': 'string'},
          'status': {'type': 'string'},
          'currentNodeId': {'type': 'string'},
          'variables': {'type': 'object'},
          'startedAt': {'type': 'string', 'format': 'date-time'},
          'completedAt': {'type': 'string', 'format': 'date-time'},
          'error': {'type': 'string'},
        },
        'required': ['id', 'runId', 'blueprintId', 'projectId', 'status', 'startedAt'],
      };

  /// Создать копию с изменениями
  GraphRunState copyWith({
    GraphRunStatus? status,
    String? currentNodeId,
    Map<String, dynamic>? variables,
    DateTime? completedAt,
    String? error,
  }) {
    return GraphRunState(
      runId: runId,
      blueprintId: blueprintId,
      projectId: projectId,
      status: status ?? this.status,
      currentNodeId: currentNodeId ?? this.currentNodeId,
      variables: variables ?? this.variables,
      startedAt: startedAt,
      completedAt: completedAt ?? this.completedAt,
      error: error ?? this.error,
    );
  }

  /// Сериализация в JSON
  Map<String, dynamic> toJson() => {
    'runId': runId,
    'blueprintId': blueprintId,
    'projectId': projectId,
    'status': status.toJson(),
    'currentNodeId': currentNodeId,
    'variables': variables,
    'startedAt': startedAt.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'error': error,
  };

  /// Десериализация из JSON
  factory GraphRunState.fromJson(Map<String, dynamic> json) {
    return GraphRunState(
      runId: json['runId'] as String,
      blueprintId: json['blueprintId'] as String,
      projectId: json['projectId'] as String,
      status: GraphRunStatus.fromJson(json['status'] as String),
      currentNodeId: json['currentNodeId'] as String?,
      variables: (json['variables'] as Map<String, dynamic>?) ?? {},
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      error: json['error'] as String?,
    );
  }

  @override
  String toString() => 'GraphRunState(runId: $runId, status: $status)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GraphRunState &&
          runtimeType == other.runtimeType &&
          runId == other.runId &&
          blueprintId == other.blueprintId &&
          projectId == other.projectId &&
          status == other.status;

  @override
  int get hashCode => Object.hash(runId, blueprintId, projectId, status);
}
