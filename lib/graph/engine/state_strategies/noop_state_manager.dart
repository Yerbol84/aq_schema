// Стратегия: ничего не сохраняет. Для fire-and-forget графов.

import 'package:aq_schema/graph/engine/run_context.dart';
import 'package:aq_schema/graph/nodes/state/i_stateful_node.dart';
import '../i_run_state_manager.dart';

/// Не кэширует RunContext вообще.
///
/// Используй для: короткие атомарные графы без suspend,
/// batch-обработка где потеря промежуточного состояния допустима.
final class NoopStateManager implements IRunStateManager {
  @override
  final metrics = RunStateMetrics();

  @override Future<void> checkpoint(String runId, RunContext context) async {}
  @override Future<void> checkpointForNode(String runId, RunContext context, NodeStateHint hint) async {}
  @override Future<RunContext?> restore(String runId) async => null;
  @override Future<void> evict(String runId) async {}
}
