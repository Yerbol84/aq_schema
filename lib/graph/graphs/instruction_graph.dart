import 'package:aq_schema/graph/core/graph_def.dart';
import 'package:aq_schema/graph/graphs/contract_schema.dart';
import 'package:aq_schema/aq_schema.dart';

enum InstructionNodeType {
  stepDescription,
  userInputRequest,
  validationCheck,
  systemAction;

  String toJson() => name;
  static InstructionNodeType fromJson(String json) => values.byName(json);
}

class InstructionNode extends $Node {
  @override
  final String id;
  final InstructionNodeType type;
  final Map<String, dynamic> payload;

  const InstructionNode({
    required this.id,
    required this.type,
    this.payload = const {},
  });

  @override
  InstructionNode copyWith({
    String? id,
    InstructionNodeType? type,
    Map<String, dynamic>? payload,
  }) =>
      InstructionNode(
        id: id ?? this.id,
        type: type ?? this.type,
        payload: payload ?? this.payload,
      );

  String? get comment => payload['comment'] as String?;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.toJson(),
        'payload': payload,
      };

  factory InstructionNode.fromJson(Map<String, dynamic> json) =>
      InstructionNode(
        id: json['id'] as String,
        type: InstructionNodeType.fromJson(json['type'] as String),
        payload: (json['payload'] as Map<String, dynamic>?) ?? {},
      );
}

class InstructionEdge extends $Edge {
  @override
  final String id;
  @override
  final String sourceId;
  @override
  final String targetId;
  @override
  final String branchName;
  final String trigger;

  const InstructionEdge({
    required this.id,
    required this.sourceId,
    required this.targetId,
    required this.trigger,
    this.branchName = 'main',
  });

  @override
  InstructionEdge copyWith({
    String? id,
    String? sourceId,
    String? targetId,
    String? trigger,
    String? branchName,
  }) =>
      InstructionEdge(
        id: id ?? this.id,
        sourceId: sourceId ?? this.sourceId,
        targetId: targetId ?? this.targetId,
        trigger: trigger ?? this.trigger,
        branchName: branchName ?? this.branchName,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'sourceId': sourceId,
        'targetId': targetId,
        'trigger': trigger,
        'branchName': branchName,
      };

  factory InstructionEdge.fromJson(Map<String, dynamic> json) =>
      InstructionEdge(
        id: json['id'] as String,
        sourceId: json['sourceId'] as String,
        targetId: json['targetId'] as String,
        trigger: json['trigger'] as String,
        branchName: json['branchName'] as String? ?? 'main',
      );
}

/// Instruction graph — a reusable AI instruction with contract (inputs/outputs).
/// Implements [VersionedStorable]: every save creates a semver version.
/// [ownerId] = projectId.
class InstructionGraph extends $Graph<InstructionNode, InstructionEdge>
    implements VersionedStorable {
  static const kCollection = 'instruction_graphs';
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
      'contract': {'type': 'object'},
      'tests': {'type': 'array', 'items': {'type': 'object'}},
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

  /// Inputs/outputs contract — what this instruction accepts and returns.
  final Map<String, dynamic> contract;

  /// Test cases for TDD-style validation.
  final List<Map<String, dynamic>> tests;

  final ContractSchema? contractSchema;

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

  const InstructionGraph({
    required this.id,
    required this.tenantId,
    required this.ownerId,
    required this.name,
    super.nodes = const {},
    super.edges = const {},
    this.contract = const {'inputs': [], 'outputs': []},
    this.tests = const [],
    this.contractSchema,
  });

  factory InstructionGraph.empty({
    String id = 'id',
    String tenantId = 'system',
    String projectId = 'id',
    String name = 'name',
  }) =>
      InstructionGraph(
        id: id,
        tenantId: tenantId,
        ownerId: projectId,
        name: name,
      );

  // ── $Graph ──────────────────────────────────────────────────────────────────

  @override
  InstructionGraph addNode(InstructionNode node) =>
      _copy(nodes: {...nodes, node.id: node});

  @override
  InstructionGraph removeNode(String nodeId) => _copy(
        nodes: Map.from(nodes)..remove(nodeId),
        edges: Map.from(edges)
          ..removeWhere((_, e) => e.sourceId == nodeId || e.targetId == nodeId),
      );

  @override
  InstructionGraph addEdge(InstructionEdge edge) =>
      _copy(edges: {...edges, edge.id: edge});

  @override
  InstructionGraph removeEdge(String edgeId) =>
      _copy(edges: Map.from(edges)..remove(edgeId));

  InstructionGraph updateContract(Map<String, dynamic> newContract) =>
      _copy(contract: newContract);

  InstructionGraph updateTests(List<Map<String, dynamic>> newTests) =>
      _copy(tests: newTests);

  // ── Storable ────────────────────────────────────────────────────────────────

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'tenantId': tenantId,
        'ownerId': ownerId,
        'name': name,
        'nodes': nodes.values.map((n) => n.toJson()).toList(),
        'edges': edges.values.map((e) => e.toJson()).toList(),
        'contract': contract,
        'tests': tests,
        if (contractSchema != null) 'contractSchema': contractSchema!.toJson(),
      };

  @override
  Map<String, dynamic> get indexFields => {
        'ownerId': ownerId,
        'name': name,
      };

  static InstructionGraph fromMap(Map<String, dynamic> m) {
    final nList = ((m['nodes'] as List?) ?? [])
        .map((e) => InstructionNode.fromJson(e as Map<String, dynamic>));
    final eList = ((m['edges'] as List?) ?? [])
        .map((e) => InstructionEdge.fromJson(e as Map<String, dynamic>));
    return InstructionGraph(
      id: m['id'] as String,
      tenantId: m['tenantId'] as String? ?? 'system',
      ownerId: m['ownerId'] as String? ?? '',
      name: m['name'] as String? ?? '',
      nodes: {for (var n in nList) n.id: n},
      edges: {for (var e in eList) e.id: e},
      contract: (m['contract'] as Map<String, dynamic>?) ??
          {'inputs': [], 'outputs': []},
      tests: ((m['tests'] as List?) ?? []).cast<Map<String, dynamic>>(),
      contractSchema: m['contractSchema'] != null
          ? ContractSchema.fromJson(m['contractSchema'] as Map<String, dynamic>)
          : null,
    );
  }

  InstructionGraph copyWith({
    String? name,
    Map<String, InstructionNode>? nodes,
    Map<String, InstructionEdge>? edges,
    Map<String, dynamic>? contract,
    List<Map<String, dynamic>>? tests,
  }) =>
      _copy(
          name: name,
          nodes: nodes,
          edges: edges,
          contract: contract,
          tests: tests);

  InstructionGraph _copy({
    String? name,
    Map<String, InstructionNode>? nodes,
    Map<String, InstructionEdge>? edges,
    Map<String, dynamic>? contract,
    List<Map<String, dynamic>>? tests,
    ContractSchema? contractSchema,
  }) =>
      InstructionGraph(
        id: id,
        tenantId: tenantId,
        ownerId: ownerId,
        name: name ?? this.name,
        nodes: nodes ?? this.nodes,
        edges: edges ?? this.edges,
        contract: contract ?? this.contract,
        tests: tests ?? this.tests,
        contractSchema: contractSchema ?? this.contractSchema,
      );

  ContractSchema getContractSchema() =>
      contractSchema ?? ContractSchema.defaultInstructionContract();
}
