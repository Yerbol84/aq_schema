// Базовые абстракции графа — Узел, Ребро, Граф.
// Все конкретные графы (Workflow, Instruction, Prompt) наследуют отсюда.
import 'package:meta/meta.dart';

// ─────────────────────────────────────────────────────────────────────────────
// БАЗОВЫЙ УЗЕЛ
// ─────────────────────────────────────────────────────────────────────────────

/// Стратегия обработки входящих рёбер
enum NodeJoinStrategy {
  /// Первый пришёл - первый обслужился (по умолчанию)
  firstCome,

  /// Ждать все входящие рёбра (join/merge pattern)
  waitAll,

  /// Ждать любое из приоритетных рёбер
  waitPriority,
}

@immutable
abstract class $Node {
  String get id;

  const $Node();

  $Node copyWith();

  // ── Управление исходящими рёбрами ──────────────────────────────────────────

  /// Выбор исходящих рёбер после выполнения узла.
  ///
  /// Если возвращает null - движок использует стандартную логику (все подходящие рёбра).
  /// Если возвращает List<String> - выполняются только указанные рёбра по ID.
  ///
  /// [availableEdges] - рёбра которые прошли фильтрацию по типу (onSuccess/onError)
  /// [executionResult] - результат выполнения узла
  ///
  /// Пример: узел может выбрать только одно ребро на основе результата
  List<String>? selectOutgoingEdges(
    List<$Edge> availableEdges,
    dynamic executionResult,
  ) =>
      null; // По умолчанию - стандартная логика

  // ── Управление входящими рёбрами ───────────────────────────────────────────

  /// Стратегия обработки входящих рёбер
  NodeJoinStrategy get joinStrategy => NodeJoinStrategy.firstCome;

  /// Приоритеты входящих рёбер (edgeId -> priority)
  ///
  /// Используется со стратегией waitPriority.
  /// Узел будет ждать приоритетное ребро даже если пришли другие.
  ///
  /// Пример: {'edge1': 100, 'edge2': 50} - edge1 важнее
  Map<String, int>? get incomingEdgePriorities => null;
}

// ─────────────────────────────────────────────────────────────────────────────
// БАЗОВОЕ РЕБРО (связь между узлами)
// ─────────────────────────────────────────────────────────────────────────────

/// Режим выполнения ребра
enum EdgeExecutionMode {
  /// Последовательное выполнение - ждёт завершения предыдущего ребра
  sequential,

  /// Параллельное выполнение - запускается в отдельном потоке
  parallel,

  /// Отложенное выполнение - ждёт сигнала от других рёбер
  deferred,
}

@immutable
abstract class $Edge {
  String get id;
  String get sourceId;
  String get targetId;
  String get branchName;

  const $Edge();

  $Edge copyWith();

  // ── Управление выполнением ─────────────────────────────────────────────────

  /// Приоритет ребра (0-100, по умолчанию 50)
  ///
  /// Чем выше приоритет - тем раньше выполняется ребро.
  /// Используется для сортировки исходящих рёбер от узла.
  int get priority => 50;

  /// Режим выполнения ребра
  ///
  /// - sequential: выполняется последовательно, ждёт завершения предыдущего
  /// - parallel: выполняется параллельно в отдельном потоке
  /// - deferred: откладывается до получения сигнала
  EdgeExecutionMode get executionMode => EdgeExecutionMode.sequential;

  /// Ревнивое ребро - блокирует выполнение других исходящих рёбер
  ///
  /// Если true - после выполнения этого ребра остальные рёбра игнорируются.
  /// По умолчанию true для onSuccess/onError рёбер (взаимоисключающие).
  ///
  /// Пример: onSuccess ревнивое - если узел успешен, onError не выполняется
  bool get isExclusive => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// БАЗОВЫЙ ГРАФ (контейнер узлов и рёбер)
// N — тип узла (например, WorkflowNode), E — тип ребра (например, WorkflowEdge)
// ─────────────────────────────────────────────────────────────────────────────

@immutable
abstract class $Graph<N extends $Node, E extends $Edge> {
  // Map для O(1) доступа по ID
  final Map<String, N> nodes;
  final Map<String, E> edges;

  const $Graph({required this.nodes, required this.edges});

  $Graph<N, E> addNode(N node);
  $Graph<N, E> removeNode(String nodeId);
  $Graph<N, E> addEdge(E edge);
  $Graph<N, E> removeEdge(String edgeId);

  /// Проверка целостности: нет ли рёбер, ссылающихся на несуществующие узлы
  bool validate() {
    for (final edge in edges.values) {
      if (!nodes.containsKey(edge.sourceId) ||
          !nodes.containsKey(edge.targetId)) {
        return false;
      }
    }
    return true;
  }
}
