// Автоматический узел - выполняется без участия пользователя

import 'package:aq_schema/graph/nodes/base/i_workflow_node.dart';
import 'package:aq_schema/graph/engine/run_context.dart';
import 'package:aq_schema/graph/core/graph_def.dart';

/// Автоматический узел - выполняется без участия пользователя
///
/// Примеры: LlmActionNode, FileReadNode, FileWriteNode, GitCommitNode
///
/// Автоматические узлы:
/// - Выполняются сразу без ожидания UI
/// - Используют AQToolService для действий
/// - Сохраняют результат в RunContext
abstract class AutomaticNode implements IWorkflowNode {
  /// Подстановка переменных в строку ({{varName}} → значение)
  ///
  /// Используется для компиляции промптов, путей к файлам, etc.
  String substituteVariables(String template, RunContext context) {
    final regex = RegExp(r'\{\{(.*?)\}\}');
    return template.replaceAllMapped(regex, (match) {
      final varName = match.group(1)?.trim();
      final value = context.getVar(varName ?? '');
      return value?.toString() ?? '[MISSING: $varName]';
    });
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
