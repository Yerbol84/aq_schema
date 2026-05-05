// Валидатор структуры графов — проверяет перед запуском.

import '../core/graph_def.dart';
import '../graphs/typed_workflow_graph.dart';
import '../graphs/instruction_graph.dart';
import '../graphs/prompt_graph.dart';

/// Результат валидации графа.
class GraphValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  const GraphValidationResult({
    required this.isValid,
    this.errors = const [],
    this.warnings = const [],
  });

  factory GraphValidationResult.valid([List<String> warnings = const []]) =>
      GraphValidationResult(isValid: true, warnings: warnings);

  factory GraphValidationResult.invalid(List<String> errors,
          [List<String> warnings = const []]) =>
      GraphValidationResult(isValid: false, errors: errors, warnings: warnings);
}

/// Валидатор графов — статические методы, вызываются перед запуском.
class GraphValidator {
  GraphValidator._();

  static GraphValidationResult validate($Graph graph) {
    if (graph is TypedWorkflowGraph) return validateWorkflow(graph);
    if (graph is InstructionGraph) return validateInstruction(graph);
    if (graph is PromptGraph) return validatePrompt(graph);
    return GraphValidationResult.invalid(['Неизвестный тип графа: ${graph.runtimeType}']);
  }

  static GraphValidationResult validateWorkflow(TypedWorkflowGraph graph) =>
      _validateStructure(graph.nodes, graph.edges);

  static GraphValidationResult validateInstruction(InstructionGraph graph) {
    final base = _validateStructure(graph.nodes, graph.edges);
    if (!base.isValid) return base;
    final warnings = List<String>.from(base.warnings);
    if ((graph.contract['inputs'] as Map?)?.isEmpty ?? true) {
      warnings.add('Contract не содержит inputs');
    }
    if ((graph.contract['outputs'] as Map?)?.isEmpty ?? true) {
      warnings.add('Contract не содержит outputs');
    }
    return GraphValidationResult.valid(warnings);
  }

  static GraphValidationResult validatePrompt(PromptGraph graph) =>
      _validateStructure(graph.nodes, graph.edges);

  static GraphValidationResult _validateStructure<N extends $Node, E extends $Edge>(
    Map<String, N> nodes,
    Map<String, E> edges,
  ) {
    final errors = <String>[];
    final warnings = <String>[];

    if (nodes.isEmpty) {
      return GraphValidationResult.invalid(['Граф не содержит узлов']);
    }

    // Все рёбра ссылаются на существующие узлы
    final nodeIds = nodes.keys.toSet();
    for (final edge in edges.values) {
      if (!nodeIds.contains(edge.sourceId)) {
        errors.add('Edge ${edge.id}: sourceId "${edge.sourceId}" не существует');
      }
      if (!nodeIds.contains(edge.targetId)) {
        errors.add('Edge ${edge.id}: targetId "${edge.targetId}" не существует');
      }
    }
    if (errors.isNotEmpty) return GraphValidationResult.invalid(errors, warnings);

    // Start nodes (без входящих рёбер)
    final targets = edges.values.map((e) => e.targetId).toSet();
    final startNodes = nodeIds.where((id) => !targets.contains(id)).toList();
    if (startNodes.isEmpty) {
      errors.add('Граф не имеет start node');
    } else if (startNodes.length > 1) {
      warnings.add('Граф имеет ${startNodes.length} start nodes: ${startNodes.join(", ")}');
    }

    if (errors.isNotEmpty) return GraphValidationResult.invalid(errors, warnings);
    return GraphValidationResult.valid(warnings);
  }
}
