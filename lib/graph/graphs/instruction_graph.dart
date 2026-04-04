import 'package:aq_schema/graph/core/graph_def.dart';
import 'package:aq_schema/graph/graphs/contract_schema.dart';

import 'contract_schema.dart';

// --- ENUM ТИПОВ ---
enum InstructionNodeType {
  stepDescription, // Описание шага для пользователя (ТЗ, Идея)
  userInputRequest, // Ожидание ввода от юзера
  validationCheck, // Проверка условий
  systemAction; // Действие системы (сохранить, обновить)

  String toJson() => name;
  static InstructionNodeType fromJson(String json) => values.byName(json);
}

// --- УЗЕЛ ---
class InstructionNode extends $Node {
  @override
  final String id;
  final InstructionNodeType type;
  final Map<String, dynamic>
  payload; // { "message": "Опишите идею", "required_fields": ["name"], "comment": "..." }

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
  }) {
    return InstructionNode(
      id: id ?? this.id,
      type: type ?? this.type,
      payload: payload ?? this.payload,
    );
  }

  /// Получить комментарий узла (удобный геттер)
  String? get comment => payload['comment'] as String?;

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.toJson(),
    'payload': payload,
  };

  factory InstructionNode.fromJson(Map<String, dynamic> json) {
    return InstructionNode(
      id: json['id'] as String,
      type: InstructionNodeType.fromJson(json['type'] as String),
      payload: json['payload'] as Map<String, dynamic>,
    );
  }
}

// --- РЕБРО ---
class InstructionEdge extends $Edge {
  @override
  final String id;
  @override
  final String sourceId;
  @override
  final String targetId;
  final String trigger; // Например: "user_submitted", "validated"
  final String branchName;
  const InstructionEdge({
    required this.branchName,
    required this.id,
    required this.sourceId,
    required this.targetId,
    required this.trigger,
  });

  @override
  InstructionEdge copyWith({
    String? id,
    String? sourceId,
    String? targetId,
    String? trigger,
    String? branchName,
  }) {
    return InstructionEdge(
      id: id ?? this.id,
      sourceId: sourceId ?? this.sourceId,
      targetId: targetId ?? this.targetId,
      trigger: trigger ?? this.trigger,
      branchName: branchName ?? this.branchName,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'sourceId': sourceId,
    'targetId': targetId,
    'trigger': trigger,
    'branchName': branchName,
  };

  factory InstructionEdge.fromJson(Map<String, dynamic> json) {
    return InstructionEdge(
      branchName: json['branchName'] as String,
      id: json['id'] as String,
      sourceId: json['sourceId'] as String,
      targetId: json['targetId'] as String,
      trigger: json['trigger'] as String,
    );
  }
}

// --- ГРАФ ---
class InstructionGraph extends $Graph<InstructionNode, InstructionEdge> {
  final Map<String, dynamic> contract;
  final List<Map<String, dynamic>> tests; // <--- ДОБАВИЛИ ПОЛЕ ДЛЯ ТЕСТОВ
  final ContractSchema? contractSchema; // <--- НОВОЕ ПОЛЕ: СХЕМА КОНТРАКТА

  const InstructionGraph({
    super.nodes = const {},
    super.edges = const {},
    this.contract = const {'inputs': [], 'outputs': []},
    this.tests = const [], // <--- ИНИЦИАЛИЗАЦИЯ
    this.contractSchema,
  });

  factory InstructionGraph.empty() => const InstructionGraph(
    contract: {'inputs': [], 'outputs': []},
    tests: [],
  );

  @override
  InstructionGraph addNode(InstructionNode node) {
    return InstructionGraph(
      nodes: {...nodes, node.id: node},
      edges: edges,
      contract: contract,
      tests: tests,
      contractSchema: contractSchema,
    );
  }

  @override
  InstructionGraph removeNode(String nodeId) {
    final newNodes = Map<String, InstructionNode>.from(nodes)..remove(nodeId);
    final newEdges = Map<String, InstructionEdge>.from(edges)
      ..removeWhere(
        (_, edge) => edge.sourceId == nodeId || edge.targetId == nodeId,
      );
    return InstructionGraph(
      nodes: newNodes,
      edges: newEdges,
      contract: contract,
      tests: tests,
      contractSchema: contractSchema,
    );
  }

  @override
  InstructionGraph addEdge(InstructionEdge edge) {
    return InstructionGraph(
      nodes: nodes,
      edges: {...edges, edge.id: edge},
      contract: contract,
      tests: tests,
      contractSchema: contractSchema,
    );
  }

  @override
  InstructionGraph removeEdge(String edgeId) {
    final newEdges = Map<String, InstructionEdge>.from(edges)..remove(edgeId);
    return InstructionGraph(
      nodes: nodes,
      edges: newEdges,
      contract: contract,
      tests: tests,
      contractSchema: contractSchema,
    );
  }

  InstructionGraph updateContract(Map<String, dynamic> newContract) {
    return InstructionGraph(
      nodes: nodes,
      edges: edges,
      contract: newContract,
      tests: tests,
      contractSchema: contractSchema,
    );
  }

  // <--- НОВЫЙ МЕТОД ДЛЯ ОБНОВЛЕНИЯ ТЕСТОВ --->
  InstructionGraph updateTests(List<Map<String, dynamic>> newTests) {
    return InstructionGraph(
      nodes: nodes,
      edges: edges,
      contract: contract,
      tests: newTests,
      contractSchema: contractSchema,
    );
  }

  // <--- НОВЫЙ МЕТОД ДЛЯ ОБНОВЛЕНИЯ СХЕМЫ КОНТРАКТА --->
  InstructionGraph updateContractSchema(ContractSchema? newContractSchema) {
    return InstructionGraph(
      nodes: nodes,
      edges: edges,
      contract: contract,
      tests: tests,
      contractSchema: newContractSchema,
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      'nodes': nodes.values.map((n) => n.toJson()).toList(),
      'edges': edges.values.map((e) => e.toJson()).toList(),
      'contract': contract,
      'tests': tests, // <--- СОХРАНЯЕМ
    };

    // Добавляем схему контракта, если она есть
    if (contractSchema != null) {
      json['contractSchema'] = contractSchema!.toJson();
    }

    return json;
  }

  factory InstructionGraph.fromJson(Map<String, dynamic> json) {
    final nodeList =
        (json['nodes'] as List?)?.map((e) => InstructionNode.fromJson(e)) ?? [];
    final edgeList =
        (json['edges'] as List?)?.map((e) => InstructionEdge.fromJson(e)) ?? [];
    final contractData =
        json['contract'] as Map<String, dynamic>? ??
        {'inputs': [], 'outputs': []};

    // <--- ЧИТАЕМ ТЕСТЫ ИЗ БАЗЫ --->
    List<Map<String, dynamic>> loadedTests = [];
    if (json['tests'] != null) {
      loadedTests = List<Map<String, dynamic>>.from(json['tests']);
    }

    // <--- ЧИТАЕМ СХЕМУ КОНТРАКТА ИЗ БАЗЫ --->
    ContractSchema? loadedContractSchema;
    if (json['contractSchema'] != null) {
      loadedContractSchema = ContractSchema.fromJson(
        json['contractSchema'] as Map<String, dynamic>,
      );
    }

    return InstructionGraph(
      nodes: {for (var n in nodeList) n.id: n},
      edges: {for (var e in edgeList) e.id: e},
      contract: contractData,
      tests: loadedTests,
      contractSchema: loadedContractSchema,
    );
  }

  /// Возвращает схему контракта для этого графа.
  /// Если явная схема не задана, возвращает схему по умолчанию.
  ContractSchema getContractSchema() {
    return contractSchema ?? ContractSchema.defaultInstructionContract();
  }

  /// Проверяет контракт графа на соответствие схеме.
  /// Возвращает список ошибок валидации.
  Future<List<SchemaValidationError>> validateContract() async {
    final schema = getContractSchema();
    return await schema.validateContract(contract);
  }

  /// Проверяет, совместим ли текущий контракт с устаревшим форматом.
  bool isContractCompatibleWithLegacyFormat() {
    final schema = getContractSchema();
    return schema.isCompatibleWithLegacyFormat(contract);
  }

  /// Преобразует текущий контракт в стандартизированный формат, если он в устаревшем формате.
  /// Возвращает новый граф с обновленным контрактом.
  Future<InstructionGraph> migrateToStandardizedContract() async {
    if (isContractCompatibleWithLegacyFormat()) {
      final schema = getContractSchema();
      final newContract = schema.convertLegacyContract(contract);
      return updateContract(newContract);
    }
    return this;
  }
}
