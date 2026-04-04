import 'package:aq_schema/graph/core/graph_def.dart';

// --- ENUM ТИПОВ ---
enum PromptNodeType {
  textBlock,
  variable,
  fileContext;

  String toJson() => name;
  static PromptNodeType fromJson(String json) => values.byName(json);
}

// --- УЗЕЛ ---
class PromptNode extends $Node {
  @override
  final String id;
  final PromptNodeType type;
  final Map<String, dynamic> data; // { ..., "comment": "..." }

  const PromptNode({
    required this.id,
    required this.type,
    this.data = const {},
  });

  @override
  PromptNode copyWith({
    String? id,
    PromptNodeType? type,
    Map<String, dynamic>? data,
  }) {
    return PromptNode(
      id: id ?? this.id,
      type: type ?? this.type,
      data: data ?? this.data,
    );
  }

  /// Получить комментарий узла (удобный геттер)
  String? get comment => data['comment'] as String?;

  // СЕРИАЛИЗАЦИЯ
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.toJson(),
    'data': data,
  };

  factory PromptNode.fromJson(Map<String, dynamic> json) {
    return PromptNode(
      id: json['id'] as String,
      type: PromptNodeType.fromJson(json['type'] as String),
      data: json['data'] as Map<String, dynamic>,
    );
  }
}

// --- РЕБРО ---
class PromptEdge extends $Edge {
  @override
  final String id;
  @override
  final String sourceId;
  @override
  final String targetId;
  @override
  final String branchName;
  const PromptEdge({
    required this.id,
    required this.sourceId,
    required this.targetId,
    required this.branchName,
  });

  @override
  PromptEdge copyWith({
    String? id,
    String? sourceId,
    String? targetId,
    String? branchName,
  }) {
    return PromptEdge(
      id: id ?? this.id,
      sourceId: sourceId ?? this.sourceId,
      targetId: targetId ?? this.targetId,
      branchName: branchName ?? this.branchName,
    );
  }

  // СЕРИАЛИЗАЦИЯ
  Map<String, dynamic> toJson() => {
    'id': id,
    'sourceId': sourceId,
    'targetId': targetId,
    'branchName': branchName,
  };

  factory PromptEdge.fromJson(Map<String, dynamic> json) {
    return PromptEdge(
      id: json['id'] as String,
      sourceId: json['sourceId'] as String,
      targetId: json['targetId'] as String,
      branchName: json['branchName'] as String,
    );
  }
}

// --- ГРАФ ---
class PromptGraph extends $Graph<PromptNode, PromptEdge> {
  const PromptGraph({super.nodes = const {}, super.edges = const {}});

  factory PromptGraph.empty() => const PromptGraph();

  @override
  PromptGraph addNode(PromptNode node) {
    return PromptGraph(nodes: {...nodes, node.id: node}, edges: edges);
  }

  @override
  PromptGraph removeNode(String nodeId) {
    final newNodes = Map<String, PromptNode>.from(nodes)..remove(nodeId);
    final newEdges = Map<String, PromptEdge>.from(edges)
      ..removeWhere(
        (_, edge) => edge.sourceId == nodeId || edge.targetId == nodeId,
      );
    return PromptGraph(nodes: newNodes, edges: newEdges);
  }

  @override
  PromptGraph addEdge(PromptEdge edge) {
    return PromptGraph(nodes: nodes, edges: {...edges, edge.id: edge});
  }

  @override
  PromptGraph removeEdge(String edgeId) {
    final newEdges = Map<String, PromptEdge>.from(edges)..remove(edgeId);
    return PromptGraph(nodes: nodes, edges: newEdges);
  }

  // СЕРИАЛИЗАЦИЯ ГРАФА
  Map<String, dynamic> toJson() => {
    'nodes': nodes.values.map((n) => n.toJson()).toList(),
    'edges': edges.values.map((e) => e.toJson()).toList(),
  };

  factory PromptGraph.fromJson(Map<String, dynamic> json) {
    final nodeList = (json['nodes'] as List).map((e) => PromptNode.fromJson(e));
    final edgeList = (json['edges'] as List).map((e) => PromptEdge.fromJson(e));

    return PromptGraph(
      nodes: {for (var n in nodeList) n.id: n},
      edges: {for (var e in edgeList) e.id: e},
    );
  }
}
