// Корневой интерфейс для узлов которые влияют на управление состоянием.
// Runner проверяет этот интерфейс и адаптирует поведение checkpoint/restore.

import 'package:aq_schema/graph/nodes/base/i_workflow_node.dart';

/// Подсказка runner'у как обрабатывать состояние этого узла.
enum NodeStateHint {
  /// Обычный узел — стратегия IRunStateManager по умолчанию.
  normal,

  /// Checkpoint обязателен ПОСЛЕ выполнения.
  checkpoint,

  /// Checkpoint обязателен ДО и ПОСЛЕ выполнения.
  critical,

  /// Не сохранять состояние — быстрые/дешёвые вычисления.
  transient,
}

/// Корневой capability interface — узел влияет на управление состоянием.
///
/// Runner проверяет: `if (node is IStatefulNode)` и адаптирует поведение.
abstract interface class IStatefulNode implements IWorkflowNode {
  NodeStateHint get stateHint;
}
