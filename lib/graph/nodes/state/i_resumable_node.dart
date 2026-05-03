// Узел умеет сам управлять своим состоянием при suspend/resume.

import 'package:aq_schema/graph/engine/run_context.dart';
import 'i_stateful_node.dart';

/// Узел умеет сохранять и восстанавливать своё внутреннее состояние.
///
/// Используй для: streaming LLM, долгие загрузки, чат-узлы.
/// Runner вызывает [persistState] перед suspend и [restoreState] при resume.
abstract interface class IResumableNode implements IStatefulNode {
  @override
  NodeStateHint get stateHint => NodeStateHint.normal;

  /// Сохранить внутреннее состояние узла в контекст перед suspend.
  Future<void> persistState(RunContext context);

  /// Восстановить внутреннее состояние узла из контекста при resume.
  Future<void> restoreState(RunContext context);
}
