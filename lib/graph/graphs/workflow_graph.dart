import 'package:aq_schema/graph/core/graph_def.dart';
import 'package:aq_schema/aq_schema.dart';

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
  final Map<String, dynamic> config;

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
  }) =>
      WorkflowNode(
        id: id ?? this.id,
        type: type ?? this.type,
        config: config ?? this.config,
      );

  String? get comment => config['comment'] as String?;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.toJson(),
        'config': config,
      };

  factory WorkflowNode.fromJson(Map<String, dynamic> json) => WorkflowNode(
        id: json['id'] as String,
        type: WorkflowNodeType.fromJson(json['type'] as String),
        config: (json['config'] as Map<String, dynamic>?) ?? {},
      );
}

class WorkflowEdge extends $Edge {
  @override
  final String id;
  @override
  final String sourceId;
  @override
  final String targetId;
  @override
  final String branchName;
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
  }) =>
      WorkflowEdge(
        id: id ?? this.id,
        sourceId: sourceId ?? this.sourceId,
        targetId: targetId ?? this.targetId,
        branchName: branchName ?? this.branchName,
        type: type ?? this.type,
        conditionExpression: conditionExpression ?? this.conditionExpression,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'sourceId': sourceId,
        'targetId': targetId,
        'branchName': branchName,
        'type': type.toJson(),
        'conditionExpression': conditionExpression,
      };

  factory WorkflowEdge.fromJson(Map<String, dynamic> json) => WorkflowEdge(
        id: json['id'] as String,
        sourceId: json['sourceId'] as String,
        targetId: json['targetId'] as String,
        branchName: json['branchName'] as String? ?? 'main',
        type: WorkflowEdgeType.fromJson(json['type'] as String),
        conditionExpression: json['conditionExpression'] as String?,
      );
}

/// Workflow graph — a project's automation flow.
/// Implements [VersionedStorable]: every save creates a semver version.
/// [ownerId] = projectId — the project this graph belongs to.
class WorkflowGraph extends $Graph<WorkflowNode, WorkflowEdge>
    implements VersionedStorable {
  /// Storage collection name — shared between client and server.
  static const kCollection = 'workflow_graphs';

  /// Current schema version.
  static const kSchemaVersion = '1.0.0';

  /// JSON Schema for automatic table creation.
  static const kJsonSchema = {
    'type': 'object',
    'properties': {
      'id': {'type': 'string', 'format': 'uuid'},
      'tenantId': {'type': 'string'},
      'ownerId': {'type': 'string'},
      'name': {'type': 'string'},
      'nodes': {
        'type': 'array',
        'items': {'type': 'object'}
      },
      'edges': {
        'type': 'array',
        'items': {'type': 'object'}
      },
      'accessGrants': {
        'type': 'array',
        'items': {'type': 'object'}
      },
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

  /// Human-readable name shown in the project panel.
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

  const WorkflowGraph({
    required this.id,
    required this.tenantId,
    required this.ownerId,
    required this.name,
    super.nodes = const {},
    super.edges = const {},
    this.accessGrants = const [],
  });

  factory WorkflowGraph.empty({
    String id = 'id',
    String tenantId = 'system',
    String projectId = 'projectid',
    String name = 'projectName',
  }) =>
      WorkflowGraph(
        id: id,
        tenantId: tenantId,
        ownerId: projectId,
        name: name,
      );

  // ── $Graph overrides ────────────────────────────────────────────────────────

  @override
  WorkflowGraph addNode(WorkflowNode node) =>
      _copy(nodes: {...nodes, node.id: node});

  @override
  WorkflowGraph removeNode(String nodeId) => _copy(
        nodes: Map.from(nodes)..remove(nodeId),
        edges: Map.from(edges)
          ..removeWhere((_, e) => e.sourceId == nodeId || e.targetId == nodeId),
      );

  @override
  WorkflowGraph addEdge(WorkflowEdge edge) =>
      _copy(edges: {...edges, edge.id: edge});

  @override
  WorkflowGraph removeEdge(String edgeId) =>
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

  /// Deserialise from storage map.
  static WorkflowGraph fromMap(Map<String, dynamic> m) {
    final nList = ((m['nodes'] as List?) ?? [])
        .map((e) => WorkflowNode.fromJson(e as Map<String, dynamic>));
    final eList = ((m['edges'] as List?) ?? [])
        .map((e) => WorkflowEdge.fromJson(e as Map<String, dynamic>));
    return WorkflowGraph(
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

  WorkflowGraph copyWith({
    String? name,
    Map<String, WorkflowNode>? nodes,
    Map<String, WorkflowEdge>? edges,
    List<AccessGrant>? accessGrants,
  }) =>
      _copy(name: name, nodes: nodes, edges: edges, accessGrants: accessGrants);

  WorkflowGraph _copy({
    String? name,
    Map<String, WorkflowNode>? nodes,
    Map<String, WorkflowEdge>? edges,
    List<AccessGrant>? accessGrants,
  }) =>
      WorkflowGraph(
        id: id,
        tenantId: tenantId,
        ownerId: ownerId,
        name: name ?? this.name,
        nodes: nodes ?? this.nodes,
        edges: edges ?? this.edges,
        accessGrants: accessGrants ?? this.accessGrants,
      );
}
