// Композитный узел - содержит другой граф

import 'package:aq_schema/graph/nodes/base/i_workflow_node.dart';
import 'package:aq_schema/graph/engine/run_context.dart';
import 'package:aq_schema/graph/core/graph_def.dart';

/// Композитный узел - содержит другой граф
///
/// Примеры: SubGraphNode, RunInstructionNode
///
/// Композитные узлы:
/// - Загружают вложенный граф (WorkflowGraph или InstructionGraph)
/// - Выполняют его как подзадачу
/// - Передают переменные через input/output mapping
abstract class CompositeNode implements IWorkflowNode {
  /// ID вложенного графа для загрузки
  String get subGraphId;

  /// Маппинг входных переменных
  ///
  /// Формат: { "subGraphVar": "parentVar" }
  /// Пример: { "input": "llm_result" } - передать llm_result как input
  Map<String, String> get inputMapping;

  /// Маппинг выходных переменных
  ///
  /// Формат: { "parentVar": "subGraphVar" }
  /// Пример: { "result": "output" } - сохранить output как result
  Map<String, String> get outputMapping;

  /// Применить input mapping - скопировать переменные из parent в sub context
  void applyInputMapping(RunContext parentContext, RunContext subContext) {
    for (final entry in inputMapping.entries) {
      final subVar = entry.key;
      final parentVar = entry.value;
      final value = parentContext.getVar(parentVar);
      if (value != null) {
        subContext.setVar(subVar, value);
      }
    }
  }

  /// Применить output mapping - скопировать переменные из sub в parent context
  void applyOutputMapping(RunContext subContext, RunContext parentContext) {
    for (final entry in outputMapping.entries) {
      final parentVar = entry.key;
      final subVar = entry.value;
      final value = subContext.getVar(subVar);
      if (value != null) {
        parentContext.setVar(parentVar, value);
      }
    }
  }

  // ── Реализации по умолчанию из IWorkflowNode ───────────────────────────────

  @override
  List<String>? selectOutgoingEdges(
    List<$Edge> availableEdges,
    dynamic executionResult,
  ) =>
      null; // Стандартная логика движка

  @override
  NodeJoinStrategy get joinStrategy => NodeJoinStrategy.firstCome;

  @override
  Map<String, int>? get incomingEdgePriorities => null;

  // ── Retry configuration ─────────────────────────────────────────────────────

  @override
  int get maxRetries => 0;

  @override
  int get retryDelayMs => 1000;

  @override
  bool get useExponentialBackoff => true;

  @override
  List<Type>? get retryableExceptions => null;
}
