import 'package:aq_schema/graph/core/graph_def.dart';

enum WorkflowNodeType {
  llmAction,
  fileWrite,
  fileRead,
  gitCommit,
  subGraph,
  manualReview,
  fileUpload,
  userInput,
  coCreationChat,
  runInstruction;

  String toJson() => name;
  static WorkflowNodeType fromJson(String json) => values.byName(json);
}

enum WorkflowEdgeType {
  onSuccess,
  onError,
  conditional;

  String toJson() => name;
  static WorkflowEdgeType fromJson(String json) => values.byName(json);
}

class WorkflowNode extends $Node {
  @override
  final String id;
  final WorkflowNodeType type;
  final Map<String, dynamic> config; // { ..., "comment": "..." }

  const WorkflowNode({
    required this.id,
    required this.type,
    this.config = const {},
  });

  @override
  WorkflowNode copyWith({
    String? id,
    WorkflowNodeType? type,
    Map<String, dynamic>? config,
  }) {
    return WorkflowNode(
      id: id ?? this.id,
      type: type ?? this.type,
      config: config ?? this.config,
    );
  }

  /// Получить комментарий узла (удобный геттер)
  String? get comment => config['comment'] as String?;

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.toJson(),
    'config': config,
  };

  factory WorkflowNode.fromJson(Map<String, dynamic> json) {
    return WorkflowNode(
      id: json['id'] as String,
      type: WorkflowNodeType.fromJson(json['type'] as String),
      config: json['config'] as Map<String, dynamic>,
    );
  }
}

class WorkflowEdge extends $Edge {
  @override
  final String id;
  @override
  final String sourceId;
  @override
  final String targetId;
  @override
  final String branchName; // <--- ДОБАВЛЕНО
  final WorkflowEdgeType type;
  final String? conditionExpression;

  const WorkflowEdge({
    required this.id,
    required this.sourceId,
    required this.targetId,
    this.branchName = 'main',
    this.type = WorkflowEdgeType.onSuccess,
    this.conditionExpression,
  });

  @override
  WorkflowEdge copyWith({
    String? id,
    String? sourceId,
    String? targetId,
    String? branchName,
    WorkflowEdgeType? type,
    String? conditionExpression,
  }) {
    return WorkflowEdge(
      id: id ?? this.id,
      sourceId: sourceId ?? this.sourceId,
      targetId: targetId ?? this.targetId,
      branchName: branchName ?? this.branchName,
      type: type ?? this.type,
      conditionExpression: conditionExpression ?? this.conditionExpression,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'sourceId': sourceId,
    'targetId': targetId,
    'branchName': branchName,
    'type': type.toJson(),
    'conditionExpression': conditionExpression,
  };

  factory WorkflowEdge.fromJson(Map<String, dynamic> json) {
    return WorkflowEdge(
      id: json['id'] as String,
      sourceId: json['sourceId'] as String,
      targetId: json['targetId'] as String,
      branchName:
          json['branchName'] as String? ?? 'main', // Совместимость со старой БД
      type: WorkflowEdgeType.fromJson(json['type'] as String),
      conditionExpression: json['conditionExpression'] as String?,
    );
  }
}

class WorkflowGraph extends $Graph<WorkflowNode, WorkflowEdge> {
  const WorkflowGraph({super.nodes = const {}, super.edges = const {}});
  factory WorkflowGraph.empty() => const WorkflowGraph();

  @override
  WorkflowGraph addNode(WorkflowNode node) =>
      WorkflowGraph(nodes: {...nodes, node.id: node}, edges: edges);

  @override
  WorkflowGraph removeNode(String nodeId) {
    final newNodes = Map<String, WorkflowNode>.from(nodes)..remove(nodeId);
    final newEdges = Map<String, WorkflowEdge>.from(edges)
      ..removeWhere((_, e) => e.sourceId == nodeId || e.targetId == nodeId);
    return WorkflowGraph(nodes: newNodes, edges: newEdges);
  }

  @override
  WorkflowGraph addEdge(WorkflowEdge edge) =>
      WorkflowGraph(nodes: nodes, edges: {...edges, edge.id: edge});

  @override
  WorkflowGraph removeEdge(String edgeId) {
    final newEdges = Map<String, WorkflowEdge>.from(edges)..remove(edgeId);
    return WorkflowGraph(nodes: nodes, edges: newEdges);
  }

  Map<String, dynamic> toJson() => {
    'nodes': nodes.values.map((n) => n.toJson()).toList(),
    'edges': edges.values.map((e) => e.toJson()).toList(),
  };

  factory WorkflowGraph.fromJson(Map<String, dynamic> json) {
    final nList = (json['nodes'] as List).map((e) => WorkflowNode.fromJson(e));
    final eList = (json['edges'] as List).map((e) => WorkflowEdge.fromJson(e));
    return WorkflowGraph(
      nodes: {for (var n in nList) n.id: n},
      edges: {for (var e in eList) e.id: e},
    );
  }
}
