// Временный узел — не требует сохранения состояния.

import 'i_stateful_node.dart';

/// Узел не нуждается в checkpoint.
///
/// Используй для: форматирование, математика, простые трансформации.
/// Runner пропустит checkpoint для этого узла.
abstract interface class ITransientNode implements IStatefulNode {
  @override
  NodeStateHint get stateHint => NodeStateHint.transient;
}
