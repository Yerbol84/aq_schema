import 'package:aq_schema/graph/core/graph_def.dart';
import 'package:aq_schema/aq_schema.dart';

// ============================================================================
// DEPRECATED! НЕ ИСПОЛЬЗОВАТЬ!
// Используй IWorkflowNode вместо enum
// TODO: Удалить после полного перехода на типобезопасные узлы
// ============================================================================
@Deprecated('Используй IWorkflowNode вместо enum')
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

// ============================================================================
// DEPRECATED! НЕ ИСПОЛЬЗОВАТЬ!
// Используй IWorkflowNode вместо этого класса
// TODO: Удалить после полного перехода на типобезопасные узлы
// ============================================================================
@Deprecated('Используй IWorkflowNode')
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

  // Новые свойства из $Edge
  @override
  final int priority;
  @override
  final EdgeExecutionMode executionMode;
  @override
  final bool isExclusive;

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
            // По умолчанию onSuccess/onError ревнивые (взаимоисключающие)
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

// ============================================================================
// DEPRECATED! НЕ ИСПОЛЬЗОВАТЬ!
// Используй новый WorkflowGraph с IWorkflowNode (см. TypedWorkflowGraph в тестах)
// TODO: Удалить после полного перехода на типобезопасные узлы
// Этот класс - рудимент для старого UI прототипа
// ============================================================================
@Deprecated('Используй TypedWorkflowGraph с IWorkflowNode')
class WorkflowGraph extends $Graph<WorkflowNode, WorkflowEdge>
    implements VersionedStorable {
  /// Storage collection name — shared between client and server.
  static const kCollection = 'workflow_graphs';

  @override
  bool get softDelete => true;

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
    },
    'required': ['id', 'tenantId', 'ownerId', 'name'],
  };

  @override
  final String id;

  @override
  final String tenantId;

  @override
  final String ownerId; // projectId

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
    );
  }

  WorkflowGraph copyWith({
    String? name,
    Map<String, WorkflowNode>? nodes,
    Map<String, WorkflowEdge>? edges,
  }) =>
      _copy(name: name, nodes: nodes, edges: edges);

  WorkflowGraph _copy({
    String? name,
    Map<String, WorkflowNode>? nodes,
    Map<String, WorkflowEdge>? edges,
  }) =>
      WorkflowGraph(
        id: id,
        tenantId: tenantId,
        ownerId: ownerId,
        name: name ?? this.name,
        nodes: nodes ?? this.nodes,
        edges: edges ?? this.edges,
      );
}
