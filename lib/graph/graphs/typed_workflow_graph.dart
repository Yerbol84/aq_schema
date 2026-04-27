// TypedWorkflowGraph — типобезопасный WorkflowGraph с IWorkflowNode.
//
// Это правильная замена deprecated WorkflowGraph.
// Узлы хранятся как IWorkflowNode — полиморфные объекты,
// а не как Map<String, dynamic> config с enum-based типом.
//
// Сериализация/десериализация узлов делегируется NodeTypeRegistry
// через IWorkflowNodeSerializer — чтобы не создавать зависимость
// aq_schema → aq_graph_engine.

import 'package:aq_schema/graph/core/graph_def.dart';
import 'package:aq_schema/graph/graphs/workflow_graph.dart'
    show WorkflowEdge, WorkflowEdgeType;
import 'package:aq_schema/graph/nodes/base/i_workflow_node.dart';
import 'package:aq_schema/data_layer/storable/versioned_storable.dart';

/// Интерфейс для сериализации/десериализации IWorkflowNode.
///
/// Реализуется в aq_graph_engine через NodeTypeRegistry.
/// Это позволяет TypedWorkflowGraph не зависеть от конкретных реализаций узлов.
abstract interface class IWorkflowNodeSerializer {
  IWorkflowNode fromJson(Map<String, dynamic> json);
}

/// Типобезопасный WorkflowGraph.
///
/// Хранит узлы как [IWorkflowNode] — полиморфные объекты с методом execute().
/// Рёбра — те же [WorkflowEdge] с поддержкой onSuccess/onError/conditional.
///
/// Для десериализации из БД требуется [IWorkflowNodeSerializer].
class TypedWorkflowGraph extends $Graph<IWorkflowNode, WorkflowEdge>
    implements VersionedStorable {
  static const kCollection = 'workflow_graphs';
  static const kSchemaVersion = '2.0.0';

  static const kJsonSchema = {
    'type': 'object',
    'properties': {
      'id': {'type': 'string', 'format': 'uuid'},
      'tenantId': {'type': 'string'},
      'ownerId': {'type': 'string'},
      'name': {'type': 'string'},
      'nodes': {'type': 'array', 'items': {'type': 'object'}},
      'edges': {'type': 'array', 'items': {'type': 'object'}},
    },
    'required': ['id', 'tenantId', 'ownerId', 'name'],
  };

  @override
  final String id;

  @override
  final String tenantId;

  @override
  final String ownerId; // projectId

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

  @override
  bool get softDelete => true;

  const TypedWorkflowGraph({
    required this.id,
    required this.tenantId,
    required this.ownerId,
    required this.name,
    super.nodes = const {},
    super.edges = const {},
  });

  factory TypedWorkflowGraph.empty({
    String id = 'id',
    String tenantId = 'system',
    String projectId = 'projectid',
    String name = 'projectName',
  }) =>
      TypedWorkflowGraph(
        id: id,
        tenantId: tenantId,
        ownerId: projectId,
        name: name,
      );

  // ── $Graph overrides ────────────────────────────────────────────────────────

  @override
  TypedWorkflowGraph addNode(IWorkflowNode node) =>
      _copy(nodes: {...nodes, node.id: node});

  @override
  TypedWorkflowGraph removeNode(String nodeId) => _copy(
        nodes: Map.from(nodes)..remove(nodeId),
        edges: Map.from(edges)
          ..removeWhere((_, e) => e.sourceId == nodeId || e.targetId == nodeId),
      );

  @override
  TypedWorkflowGraph addEdge(WorkflowEdge edge) =>
      _copy(edges: {...edges, edge.id: edge});

  @override
  TypedWorkflowGraph removeEdge(String edgeId) =>
      _copy(edges: Map.from(edges)..remove(edgeId));

  // ── Storable ────────────────────────────────────────────────────────────────

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'tenantId': tenantId,
        'ownerId': ownerId,
        'name': name,
        'schemaVersion': kSchemaVersion,
        'nodes': nodes.values.map((n) => n.toJson()).toList(),
        'edges': edges.values.map((e) => e.toJson()).toList(),
      };

  @override
  Map<String, dynamic> get indexFields => {
        'ownerId': ownerId,
        'name': name,
      };

  /// Десериализация из БД.
  ///
  /// Требует [serializer] для создания конкретных IWorkflowNode из JSON.
  /// В приложении передаётся NodeTypeRegistry из aq_graph_engine.
  static TypedWorkflowGraph fromMap(
    Map<String, dynamic> m,
    IWorkflowNodeSerializer serializer,
  ) {
    final nList = ((m['nodes'] as List?) ?? [])
        .map((e) => serializer.fromJson(e as Map<String, dynamic>));
    final eList = ((m['edges'] as List?) ?? [])
        .map((e) => WorkflowEdge.fromJson(e as Map<String, dynamic>));
    return TypedWorkflowGraph(
      id: m['id'] as String,
      tenantId: m['tenantId'] as String? ?? 'system',
      ownerId: m['ownerId'] as String? ?? '',
      name: m['name'] as String? ?? '',
      nodes: {for (final n in nList) n.id: n},
      edges: {for (final e in eList) e.id: e},
    );
  }

  TypedWorkflowGraph copyWith({
    String? name,
    Map<String, IWorkflowNode>? nodes,
    Map<String, WorkflowEdge>? edges,
  }) =>
      _copy(name: name, nodes: nodes, edges: edges);

  TypedWorkflowGraph _copy({
    String? name,
    Map<String, IWorkflowNode>? nodes,
    Map<String, WorkflowEdge>? edges,
  }) =>
      TypedWorkflowGraph(
        id: id,
        tenantId: tenantId,
        ownerId: ownerId,
        name: name ?? this.name,
        nodes: nodes ?? this.nodes,
        edges: edges ?? this.edges,
      );
}
