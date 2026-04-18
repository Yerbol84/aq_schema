// Валидатор структуры графов
// ИСПРАВЛЕНИЕ: Добавлена валидация графа перед выполнением

import '../core/graph_def.dart';
import '../graphs/workflow_graph.dart';
import '../graphs/instruction_graph.dart';

/// Результат валидации графа
class GraphValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  const GraphValidationResult({
    required this.isValid,
    this.errors = const [],
    this.warnings = const [],
  });

  factory GraphValidationResult.valid() =>
      const GraphValidationResult(isValid: true);

  factory GraphValidationResult.invalid(List<String> errors,
          [List<String> warnings = const []]) =>
      GraphValidationResult(
        isValid: false,
        errors: errors,
        warnings: warnings,
      );
}

/// Валидатор графов
class GraphValidator {
  /// Валидирует WorkflowGraph
  static GraphValidationResult validateWorkflowGraph(WorkflowGraph graph) {
    return _validateGraphStructure(graph.nodes, graph.edges);
  }

  /// Валидирует InstructionGraph
  static GraphValidationResult validateInstructionGraph(
      InstructionGraph graph) {
    final errors = <String>[];
    final warnings = <String>[];

    // 1. Базовая валидация структуры
    final baseResult = _validateGraphStructure(graph.nodes, graph.edges);
    errors.addAll(baseResult.errors);
    warnings.addAll(baseResult.warnings);

    if (errors.isNotEmpty) {
      return GraphValidationResult.invalid(errors, warnings);
    }

    // 2. Валидация contract
    final contractResult = _validateContract(graph.contract);
    errors.addAll(contractResult.errors);
    warnings.addAll(contractResult.warnings);

    if (errors.isNotEmpty) {
      return GraphValidationResult.invalid(errors, warnings);
    }

    return GraphValidationResult(
      isValid: true,
      errors: [],
      warnings: warnings,
    );
  }

  /// Generic метод валидации структуры графа
  static GraphValidationResult _validateGraphStructure<N extends $Node, E extends $Edge>(
    Map<String, N> nodes,
    Map<String, E> edges,
  ) {
    final errors = <String>[];
    final warnings = <String>[];

    // 1. Граф должен содержать хотя бы один узел
    if (nodes.isEmpty) {
      errors.add('Граф не содержит узлов');
      return GraphValidationResult.invalid(errors, warnings);
    }

    // 2. Все edges должны ссылаться на существующие узлы
    final nodeIds = nodes.keys.toSet();
    for (final edge in edges.values) {
      if (!nodeIds.contains(edge.sourceId)) {
        errors.add('Edge ${edge.id}: sourceId "${edge.sourceId}" не существует');
      }
      if (!nodeIds.contains(edge.targetId)) {
        errors.add('Edge ${edge.id}: targetId "${edge.targetId}" не существует');
      }
    }

    if (errors.isNotEmpty) {
      return GraphValidationResult.invalid(errors, warnings);
    }

    // 3. Граф не должен содержать циклы
    if (_hasCycleGeneric(nodes, edges)) {
      errors.add('Граф содержит цикл');
    }

    // 4. Граф должен иметь ровно один start node
    final startNodes = _findStartNodesGeneric(nodes, edges);
    if (startNodes.isEmpty) {
      errors.add('Граф не имеет start node (узла без входящих edges)');
    } else if (startNodes.length > 1) {
      warnings.add(
          'Граф имеет ${startNodes.length} start nodes: ${startNodes.join(", ")}');
    }

    // 5. Граф должен иметь хотя бы один end node
    final endNodes = _findEndNodesGeneric(nodes, edges);
    if (endNodes.isEmpty) {
      warnings.add('Граф не имеет end node (узла без исходящих edges)');
    }

    if (errors.isNotEmpty) {
      return GraphValidationResult.invalid(errors, warnings);
    }

    return GraphValidationResult(
      isValid: true,
      errors: [],
      warnings: warnings,
    );
  }

  /// Валидирует contract
  static GraphValidationResult _validateContract(Map<String, dynamic> contract) {
    final errors = <String>[];
    final warnings = <String>[];

    // Contract должен иметь inputs
    final inputs = contract['inputs'] as Map<String, dynamic>?;
    if (inputs == null || inputs.isEmpty) {
      warnings.add('Contract не содержит inputs');
    }

    // Валидация типов в inputs
    if (inputs != null) {
      final validTypes = {'string', 'number', 'boolean', 'object', 'array'};
      for (final entry in inputs.entries) {
        final inputDef = entry.value as Map<String, dynamic>;
        final type = inputDef['type'] as String?;

        if (type == null) {
          errors.add('Input "${entry.key}": отсутствует тип');
        } else if (!validTypes.contains(type)) {
          errors.add('Input "${entry.key}": невалидный тип "$type"');
        }
      }
    }

    // Contract должен иметь outputs
    final outputs = contract['outputs'] as Map<String, dynamic>?;
    if (outputs == null || outputs.isEmpty) {
      warnings.add('Contract не содержит outputs');
    }

    return GraphValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Валидирует параметры вызова instruction
  static GraphValidationResult validateInstructionCall(
    InstructionGraph graph,
    Map<String, dynamic> providedInputs,
  ) {
    final errors = <String>[];
    final warnings = <String>[];

    final inputs = graph.contract['inputs'] as Map<String, dynamic>?;
    if (inputs == null) {
      return GraphValidationResult.valid();
    }

    // Проверка required параметров
    for (final entry in inputs.entries) {
      final inputDef = entry.value as Map<String, dynamic>;
      final isRequired = inputDef['required'] == true;

      if (isRequired && !providedInputs.containsKey(entry.key)) {
        errors.add('Отсутствует обязательный параметр "${entry.key}"');
      }
    }

    // Проверка типов параметров
    for (final entry in providedInputs.entries) {
      final inputDef = inputs[entry.key] as Map<String, dynamic>?;
      if (inputDef == null) {
        warnings.add('Неизвестный параметр "${entry.key}"');
        continue;
      }

      final expectedType = inputDef['type'] as String;
      final value = entry.value;

      final actualType = _getValueType(value);
      if (actualType != expectedType) {
        errors.add(
            'Параметр "${entry.key}": ожидается тип "$expectedType", получен "$actualType"');
      }
    }

    return GraphValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Определяет тип значения
  static String _getValueType(dynamic value) {
    if (value is String) return 'string';
    if (value is num) return 'number';
    if (value is bool) return 'boolean';
    if (value is List) return 'array';
    if (value is Map) return 'object';
    return 'unknown';
  }

  /// Находит start nodes (узлы без входящих edges)
  static List<String> _findStartNodesGeneric<N extends $Node, E extends $Edge>(
    Map<String, N> nodes,
    Map<String, E> edges,
  ) {
    final nodesWithIncomingEdges = edges.values.map((e) => e.targetId).toSet();
    return nodes.keys
        .where((nodeId) => !nodesWithIncomingEdges.contains(nodeId))
        .toList();
  }

  /// Находит end nodes (узлы без исходящих edges)
  static List<String> _findEndNodesGeneric<N extends $Node, E extends $Edge>(
    Map<String, N> nodes,
    Map<String, E> edges,
  ) {
    final nodesWithOutgoingEdges = edges.values.map((e) => e.sourceId).toSet();
    return nodes.keys
        .where((nodeId) => !nodesWithOutgoingEdges.contains(nodeId))
        .toList();
  }

  /// Проверяет наличие циклов в графе (DFS)
  static bool _hasCycleGeneric<N extends $Node, E extends $Edge>(
    Map<String, N> nodes,
    Map<String, E> edges,
  ) {
    final visited = <String>{};
    final recursionStack = <String>{};

    bool dfs(String nodeId) {
      if (recursionStack.contains(nodeId)) {
        return true; // Цикл обнаружен
      }
      if (visited.contains(nodeId)) {
        return false; // Уже проверяли
      }

      visited.add(nodeId);
      recursionStack.add(nodeId);

      // Проверяем все исходящие edges
      final outgoingEdges = edges.values.where((e) => e.sourceId == nodeId);
      for (final edge in outgoingEdges) {
        if (dfs(edge.targetId)) {
          return true;
        }
      }

      recursionStack.remove(nodeId);
      return false;
    }

    // Проверяем все узлы (граф может быть несвязным)
    for (final nodeId in nodes.keys) {
      if (!visited.contains(nodeId)) {
        if (dfs(nodeId)) {
          return true;
        }
      }
    }

    return false;
  }
}
