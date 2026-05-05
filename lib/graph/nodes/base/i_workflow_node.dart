// Базовый интерфейс для всех узлов Workflow графа
// Заменяет enum-based подход на полиморфную иерархию

import 'package:aq_schema/graph/core/graph_def.dart';
import 'package:aq_schema/graph/engine/run_context.dart';

/// Базовый интерфейс для всех узлов Workflow графа
///
/// Все конкретные узлы (AutomaticWorkflowNode, UserInputNode, etc.) реализуют этот интерфейс.
/// Это позволяет:
/// - Типобезопасность (вместо Map<String, dynamic> config)
/// - Расширяемость (добавить новый узел без изменения WorkflowRunner)
/// - Полиморфизм (await node.execute() вместо гигантского switch)
abstract class IWorkflowNode extends $Node {
  @override
  String get id;

  /// Тип узла для сериализации (llmAction, fileRead, etc.)
  /// Используется при сохранении в JSON
  String get nodeType;

  /// Выполнить узел
  ///
  /// [context] - контекст выполнения с переменными
  /// [tools] - сервис для доступа к LLM, Vault и другим инструментам
  ///
  /// Возвращает результат выполнения (может быть null)
  Future<dynamic> execute(
    RunContext context,
  );

  /// Сериализация в JSON
  /// Формат: { "id": "...", "type": "...", "config": {...} }
  Map<String, dynamic> toJson();

  @override
  IWorkflowNode copyWith();

  // ── Управление исходящими рёбрами (из $Node) ───────────────────────────────

  @override
  List<String>? selectOutgoingEdges(
    List<$Edge> availableEdges,
    dynamic executionResult,
  ) =>
      null; // По умолчанию - стандартная логика движка

  // ── Управление входящими рёбрами (из $Node) ────────────────────────────────

  @override
  NodeJoinStrategy get joinStrategy => NodeJoinStrategy.firstCome;

  @override
  Map<String, int>? get incomingEdgePriorities => null;

  // ── Retry конфигурация ──────────────────────────────────────────────────────

  /// Максимальное количество попыток выполнения (0 = без retry)
  int get maxRetries => 0;

  /// Начальная задержка между попытками (в миллисекундах)
  int get retryDelayMs => 1000;

  /// Использовать экспоненциальный backoff (задержка удваивается с каждой попыткой)
  bool get useExponentialBackoff => true;

  /// Типы ошибок, при которых нужно делать retry (null = retry для всех ошибок)
  List<Type>? get retryableExceptions => null;
}
