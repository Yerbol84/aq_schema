// TypedPromptGraph — типобезопасный PromptGraph с IPromptNode.
// Замена PromptGraph (data-class узлы) на полиморфные IPromptNode.
// Узлы хранятся как IPromptNode — node.execute(context) без конвертации.

import 'package:aq_schema/graph/core/graph_def.dart';
import 'package:aq_schema/graph/graphs/prompt_graph.dart' show PromptEdge;
import 'package:aq_schema/graph/nodes/base/i_prompt_node.dart';
import 'package:aq_schema/data_layer/storable/versioned_storable.dart';

/// Интерфейс для десериализации IPromptNode.
/// Реализуется в aq_graph_engine через NodeTypeRegistry.
abstract interface class IPromptNodeSerializer {
  IPromptNode fromJson(Map<String, dynamic> json);
}

/// Типобезопасный PromptGraph.
///
/// Хранит узлы как [IPromptNode] — полиморфные объекты с методом execute().
/// Рёбра — те же [PromptEdge].
///
/// Для десериализации из БД требуется [IPromptNodeSerializer].
class TypedPromptGraph extends $Graph<IPromptNode, PromptEdge>
    implements VersionedStorable {
  static const kCollection = 'prompt_graphs';
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

  @override final String id;
  @override final String tenantId;
  @override final String ownerId;
  final String name;

  @override String get collectionName => kCollection;
  @override String get schemaVersion => kSchemaVersion;
  @override List<Object> get migrations => const [];
  @override Map<String, dynamic> get jsonSchema => kJsonSchema;
  @override String get defaultSharingPolicy => 'tenant';
  @override bool get softDelete => true;

  const TypedPromptGraph({
    required this.id,
    required this.tenantId,
    required this.ownerId,
    required this.name,
    super.nodes = const {},
    super.edges = const {},
  });

  @override
  TypedPromptGraph addNode(IPromptNode node) =>
      _copy(nodes: {...nodes, node.id: node});

  @override
  TypedPromptGraph removeNode(String nodeId) => _copy(
        nodes: Map.from(nodes)..remove(nodeId),
        edges: Map.from(edges)
          ..removeWhere((_, e) => e.sourceId == nodeId || e.targetId == nodeId),
      );

  @override
  TypedPromptGraph addEdge(PromptEdge edge) =>
      _copy(edges: {...edges, edge.id: edge});

  @override
  TypedPromptGraph removeEdge(String edgeId) =>
      _copy(edges: Map.from(edges)..remove(edgeId));

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
  Map<String, dynamic> get indexFields => {'ownerId': ownerId, 'name': name};

  static TypedPromptGraph fromMap(
    Map<String, dynamic> m,
    IPromptNodeSerializer serializer,
  ) {
    final nList = ((m['nodes'] as List?) ?? [])
        .map((e) => serializer.fromJson(e as Map<String, dynamic>));
    final eList = ((m['edges'] as List?) ?? [])
        .map((e) => PromptEdge.fromJson(e as Map<String, dynamic>));
    return TypedPromptGraph(
      id: m['id'] as String,
      tenantId: m['tenantId'] as String? ?? 'system',
      ownerId: m['ownerId'] as String? ?? '',
      name: m['name'] as String? ?? '',
      nodes: {for (final n in nList) n.id: n},
      edges: {for (final e in eList) e.id: e},
    );
  }

  TypedPromptGraph _copy({
    Map<String, IPromptNode>? nodes,
    Map<String, PromptEdge>? edges,
  }) => TypedPromptGraph(
        id: id, tenantId: tenantId, ownerId: ownerId, name: name,
        nodes: nodes ?? this.nodes, edges: edges ?? this.edges,
      );
}
