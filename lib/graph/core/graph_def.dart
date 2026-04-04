// Базовые абстракции графа — Узел, Ребро, Граф.
// Все конкретные графы (Workflow, Instruction, Prompt) наследуют отсюда.
import 'package:meta/meta.dart';

// ─────────────────────────────────────────────────────────────────────────────
// БАЗОВЫЙ УЗЕЛ
// ─────────────────────────────────────────────────────────────────────────────

@immutable
abstract class $Node {
  String get id;

  const $Node();

  $Node copyWith();
}

// ─────────────────────────────────────────────────────────────────────────────
// БАЗОВОЕ РЕБРО (связь между узлами)
// ─────────────────────────────────────────────────────────────────────────────

@immutable
abstract class $Edge {
  String get id;
  String get sourceId;
  String get targetId;
  String get branchName;

  const $Edge();

  $Edge copyWith();
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
