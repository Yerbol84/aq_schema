// Интерактивный узел - требует ввода пользователя

import 'package:aq_schema/graph/nodes/base/i_workflow_node.dart';
import 'package:aq_schema/graph/engine/run_context.dart';
import 'package:aq_schema/graph/core/graph_def.dart';

/// Интерактивный узел - требует ввода пользователя
///
/// Примеры: UserInputNode, ManualReviewNode, FileUploadNode, CoCreationChatNode
///
/// Интерактивные узлы:
/// - Приостанавливают выполнение графа
/// - Ждут ввода пользователя через UI
/// - Сохраняют состояние для resume
abstract class InteractiveNode implements IWorkflowNode {
  /// Проверить, есть ли уже ответ пользователя в контексте
  ///
  /// [targetVar] - имя переменной где должен быть ответ
  /// Возвращает true если пользователь уже ответил (resume после suspend)
  bool hasUserResponse(RunContext context, String targetVar) {
    final value = context.getVar(targetVar);
    return value != null;
  }

  /// UI конфигурация для отображения
  ///
  /// Возвращает Map с параметрами для UI:
  /// - title: заголовок формы
  /// - message: описание что нужно ввести
  /// - type: тип UI (text_input, approval, file_upload, chat)
  /// - etc.
  Map<String, dynamic> getUiConfig();

  /// Выбросить исключение для suspend
  ///
  /// Runner должен поймать это исключение и сохранить состояние
  Never throwSuspendException(String nodeId, String reason) {
    throw SuspendExecutionException(nodeId: nodeId, reason: reason);
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

/// Исключение для приостановки выполнения
class SuspendExecutionException implements Exception {
  final String nodeId;
  final String reason;

  SuspendExecutionException({
    required this.nodeId,
    this.reason = 'Waiting for user input',
  });

  @override
  String toString() => 'SuspendExecutionException: $reason (node: $nodeId)';
}
