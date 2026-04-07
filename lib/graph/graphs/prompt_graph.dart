import 'package:aq_schema/graph/core/graph_def.dart';
import 'package:aq_schema/aq_schema.dart';

enum PromptNodeType {
  textBlock,
  variable,
  fileContext;

  String toJson() => name;
  static PromptNodeType fromJson(String json) => values.byName(json);
}

class PromptNode extends $Node {
  @override
  final String id;
  final PromptNodeType type;
  final Map<String, dynamic> data;

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
  }) =>
      PromptNode(
        id: id ?? this.id,
        type: type ?? this.type,
        data: data ?? this.data,
      );

  String? get comment => data['comment'] as String?;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.toJson(),
        'data': data,
      };

  factory PromptNode.fromJson(Map<String, dynamic> json) => PromptNode(
        id: json['id'] as String,
        type: PromptNodeType.fromJson(json['type'] as String),
        data: (json['data'] as Map<String, dynamic>?) ?? {},
      );
}

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
    this.branchName = 'main',
  });

  @override
  PromptEdge copyWith({
    String? id,
    String? sourceId,
    String? targetId,
    String? branchName,
  }) =>
      PromptEdge(
        id: id ?? this.id,
        sourceId: sourceId ?? this.sourceId,
        targetId: targetId ?? this.targetId,
        branchName: branchName ?? this.branchName,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'sourceId': sourceId,
        'targetId': targetId,
        'branchName': branchName,
      };

  factory PromptEdge.fromJson(Map<String, dynamic> json) => PromptEdge(
        id: json['id'] as String,
        sourceId: json['sourceId'] as String,
        targetId: json['targetId'] as String,
        branchName: json['branchName'] as String? ?? 'main',
      );
}

/// Prompt graph — an LLM prompt template with variable blocks.
/// Implements [VersionedStorable]: prompts are versioned like graphs.
/// [ownerId] = projectId.
class PromptGraph extends $Graph<PromptNode, PromptEdge>
    implements VersionedStorable {
  static const kCollection = 'prompt_graphs';
  static const kSchemaVersion = '1.0.0';
  static const kJsonSchema = {
    'type': 'object',
    'properties': {
      'id': {'type': 'string', 'format': 'uuid'},
      'tenantId': {'type': 'string'},
      'ownerId': {'type': 'string'},
      'name': {'type': 'string'},
      'nodes': {'type': 'array', 'items': {'type': 'object'}},
      'edges': {'type': 'array', 'items': {'type': 'object'}},
      'accessGrants': {'type': 'array', 'items': {'type': 'object'}},
    },
    'required': ['id', 'tenantId', 'ownerId', 'name'],
  };

  @override
  final String id;

  @override
  final String tenantId;

  @override
  final String ownerId; // projectId

  @override
  final List<AccessGrant> accessGrants;

  final String name;

  @override
  String get collectionName => kCollection;

  @override
  String get schemaVersion => kSchemaVersion;

  @override
  List<Object> get migrations => const [];

  @override
  Map<String, dynamic> get jsonSchema => kJsonSchema;

  @override
  String get defaultSharingPolicy => 'tenant';

  const PromptGraph({
    required this.id,
    required this.tenantId,
    required this.ownerId,
    required this.name,
    super.nodes = const {},
    super.edges = const {},
    this.accessGrants = const [],
  });

  factory PromptGraph.empty({
    String id = 'id',
    String tenantId = 'system',
    String projectId = 'id',
    String name = 'name',
  }) =>
      PromptGraph(
        id: id,
        tenantId: tenantId,
        ownerId: projectId,
        name: name,
      );

  // ── $Graph ──────────────────────────────────────────────────────────────────

  @override
  PromptGraph addNode(PromptNode node) =>
      _copy(nodes: {...nodes, node.id: node});

  @override
  PromptGraph removeNode(String nodeId) => _copy(
        nodes: Map.from(nodes)..remove(nodeId),
        edges: Map.from(edges)
          ..removeWhere((_, e) => e.sourceId == nodeId || e.targetId == nodeId),
      );

  @override
  PromptGraph addEdge(PromptEdge edge) =>
      _copy(edges: {...edges, edge.id: edge});

  @override
  PromptGraph removeEdge(String edgeId) =>
      _copy(edges: Map.from(edges)..remove(edgeId));

  // ── Storable ────────────────────────────────────────────────────────────────

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'tenantId': tenantId,
        'ownerId': ownerId,
        'name': name,
        'nodes': nodes.values.map((n) => n.toJson()).toList(),
        'edges': edges.values.map((e) => e.toJson()).toList(),
        'accessGrants': accessGrants.map((g) => g.toMap()).toList(),
      };

  @override
  Map<String, dynamic> get indexFields => {
        'ownerId': ownerId,
        'name': name,
      };

  static PromptGraph fromMap(Map<String, dynamic> m) {
    final nList = ((m['nodes'] as List?) ?? [])
        .map((e) => PromptNode.fromJson(e as Map<String, dynamic>));
    final eList = ((m['edges'] as List?) ?? [])
        .map((e) => PromptEdge.fromJson(e as Map<String, dynamic>));
    return PromptGraph(
      id: m['id'] as String,
      tenantId: m['tenantId'] as String? ?? 'system',
      ownerId: m['ownerId'] as String? ?? '',
      name: m['name'] as String? ?? '',
      nodes: {for (var n in nList) n.id: n},
      edges: {for (var e in eList) e.id: e},
      accessGrants: ((m['accessGrants'] as List?) ?? [])
          .whereType<Map<String, dynamic>>()
          .map(AccessGrant.fromMap)
          .toList(),
    );
  }

  PromptGraph copyWith({
    String? name,
    Map<String, PromptNode>? nodes,
    Map<String, PromptEdge>? edges,
    List<AccessGrant>? accessGrants,
  }) =>
      _copy(name: name, nodes: nodes, edges: edges, accessGrants: accessGrants);

  PromptGraph _copy({
    String? name,
    Map<String, PromptNode>? nodes,
    Map<String, PromptEdge>? edges,
    List<AccessGrant>? accessGrants,
  }) =>
      PromptGraph(
        id: id,
        tenantId: tenantId,
        ownerId: ownerId,
        name: name ?? this.name,
        nodes: nodes ?? this.nodes,
        edges: edges ?? this.edges,
        accessGrants: accessGrants ?? this.accessGrants,
      );
}
