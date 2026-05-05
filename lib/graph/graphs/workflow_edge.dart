import '../core/graph_def.dart';

enum WorkflowEdgeType {
  onSuccess,
  onError,
  conditional;

  String toJson() => name;
  static WorkflowEdgeType fromJson(String json) => values.byName(json);
}

class WorkflowEdge extends $Edge {
  @override final String id;
  @override final String sourceId;
  @override final String targetId;
  @override final String branchName;
  final WorkflowEdgeType type;
  final String? conditionExpression;
  @override final int priority;
  @override final EdgeExecutionMode executionMode;
  @override final bool isExclusive;

  const WorkflowEdge({
    required this.id,
    required this.sourceId,
    required this.targetId,
    this.branchName = 'main',
    this.type = WorkflowEdgeType.onSuccess,
    this.conditionExpression,
    this.priority = 50,
    this.executionMode = EdgeExecutionMode.sequential,
    bool? isExclusive,
  }) : isExclusive = isExclusive ??
            (type == WorkflowEdgeType.onSuccess ||
                type == WorkflowEdgeType.onError);

  @override
  WorkflowEdge copyWith({
    String? id,
    String? sourceId,
    String? targetId,
    String? branchName,
    WorkflowEdgeType? type,
    String? conditionExpression,
    int? priority,
    EdgeExecutionMode? executionMode,
    bool? isExclusive,
  }) =>
      WorkflowEdge(
        id: id ?? this.id,
        sourceId: sourceId ?? this.sourceId,
        targetId: targetId ?? this.targetId,
        branchName: branchName ?? this.branchName,
        type: type ?? this.type,
        conditionExpression: conditionExpression ?? this.conditionExpression,
        priority: priority ?? this.priority,
        executionMode: executionMode ?? this.executionMode,
        isExclusive: isExclusive ?? this.isExclusive,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'sourceId': sourceId,
        'targetId': targetId,
        'branchName': branchName,
        'type': type.toJson(),
        'conditionExpression': conditionExpression,
        'priority': priority,
        'executionMode': executionMode.name,
        'isExclusive': isExclusive,
      };

  factory WorkflowEdge.fromJson(Map<String, dynamic> json) => WorkflowEdge(
        id: json['id'] as String,
        sourceId: json['sourceId'] as String,
        targetId: json['targetId'] as String,
        branchName: json['branchName'] as String? ?? 'main',
        type: WorkflowEdgeType.fromJson(json['type'] as String),
        conditionExpression: json['conditionExpression'] as String?,
        priority: json['priority'] as int? ?? 50,
        executionMode: json['executionMode'] != null
            ? EdgeExecutionMode.values.byName(json['executionMode'] as String)
            : EdgeExecutionMode.sequential,
        isExclusive: json['isExclusive'] as bool?,
      );
}
