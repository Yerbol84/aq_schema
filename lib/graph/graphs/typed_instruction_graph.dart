// TypedInstructionGraph — типобезопасный InstructionGraph с IInstructionNode.
// Замена InstructionGraph (data-class узлы) на полиморфные IInstructionNode.
// Узлы хранятся как IInstructionNode — node.execute(context) без конвертации.

import 'package:aq_schema/graph/core/graph_def.dart';
import 'package:aq_schema/graph/graphs/instruction_graph.dart' show InstructionEdge;
import 'package:aq_schema/graph/nodes/base/i_instruction_node.dart';
import 'package:aq_schema/data_layer/storable/versioned_storable.dart';
import 'package:aq_schema/graph/graphs/contract_schema.dart';

/// Интерфейс для десериализации IInstructionNode.
/// Реализуется в aq_graph_engine через NodeTypeRegistry.
abstract interface class IInstructionNodeSerializer {
  IInstructionNode fromJson(Map<String, dynamic> json);
}

/// Типобезопасный InstructionGraph.
///
/// Хранит узлы как [IInstructionNode] — полиморфные объекты с методом execute().
/// Рёбра — те же [InstructionEdge].
///
/// Для десериализации из БД требуется [IInstructionNodeSerializer].
class TypedInstructionGraph extends $Graph<IInstructionNode, InstructionEdge>
    implements VersionedStorable {
  static const kCollection = 'instruction_graphs';
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
  final Map<String, dynamic> contract;
  final List<Map<String, dynamic>> tests;
  final ContractSchema? contractSchema;

  @override String get collectionName => kCollection;
  @override String get schemaVersion => kSchemaVersion;
  @override List<Object> get migrations => const [];
  @override Map<String, dynamic> get jsonSchema => kJsonSchema;
  @override String get defaultSharingPolicy => 'tenant';
  @override bool get softDelete => true;

  const TypedInstructionGraph({
    required this.id,
    required this.tenantId,
    required this.ownerId,
    required this.name,
    this.contract = const {},
    this.tests = const [],
    this.contractSchema,
    super.nodes = const {},
    super.edges = const {},
  });

  @override
  TypedInstructionGraph addNode(IInstructionNode node) =>
      _copy(nodes: {...nodes, node.id: node});

  @override
  TypedInstructionGraph removeNode(String nodeId) => _copy(
        nodes: Map.from(nodes)..remove(nodeId),
        edges: Map.from(edges)
          ..removeWhere((_, e) => e.sourceId == nodeId || e.targetId == nodeId),
      );

  @override
  TypedInstructionGraph addEdge(InstructionEdge edge) =>
      _copy(edges: {...edges, edge.id: edge});

  @override
  TypedInstructionGraph removeEdge(String edgeId) =>
      _copy(edges: Map.from(edges)..remove(edgeId));

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'tenantId': tenantId,
        'ownerId': ownerId,
        'name': name,
        'schemaVersion': kSchemaVersion,
        'contract': contract,
        'tests': tests,
        'nodes': nodes.values.map((n) => n.toJson()).toList(),
        'edges': edges.values.map((e) => e.toJson()).toList(),
      };

  @override
  Map<String, dynamic> get indexFields => {'ownerId': ownerId, 'name': name};

  static TypedInstructionGraph fromMap(
    Map<String, dynamic> m,
    IInstructionNodeSerializer serializer,
  ) {
    final nList = ((m['nodes'] as List?) ?? [])
        .map((e) => serializer.fromJson(e as Map<String, dynamic>));
    final eList = ((m['edges'] as List?) ?? [])
        .map((e) => InstructionEdge.fromJson(e as Map<String, dynamic>));
    return TypedInstructionGraph(
      id: m['id'] as String,
      tenantId: m['tenantId'] as String? ?? 'system',
      ownerId: m['ownerId'] as String? ?? '',
      name: m['name'] as String? ?? '',
      contract: (m['contract'] as Map<String, dynamic>?) ?? {},
      tests: ((m['tests'] as List?) ?? []).cast<Map<String, dynamic>>(),
      nodes: {for (final n in nList) n.id: n},
      edges: {for (final e in eList) e.id: e},
    );
  }

  TypedInstructionGraph _copy({
    Map<String, IInstructionNode>? nodes,
    Map<String, InstructionEdge>? edges,
  }) => TypedInstructionGraph(
        id: id, tenantId: tenantId, ownerId: ownerId, name: name,
        contract: contract, tests: tests, contractSchema: contractSchema,
        nodes: nodes ?? this.nodes, edges: edges ?? this.edges,
      );
}
