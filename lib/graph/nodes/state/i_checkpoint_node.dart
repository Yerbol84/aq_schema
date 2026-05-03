// Узел требует checkpoint после выполнения.

import 'i_stateful_node.dart';

/// Узел требует checkpoint после выполнения.
///
/// Используй для: LLM вызовы, API запросы, долгие операции.
/// Runner сохранит состояние сразу после выполнения этого узла.
abstract interface class ICheckpointNode implements IStatefulNode {
  @override
  NodeStateHint get stateHint => NodeStateHint.checkpoint;
}
