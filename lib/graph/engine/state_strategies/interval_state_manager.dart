// Стратегия: checkpoint каждые N шагов + всегда при critical.

import 'dart:convert';
import 'package:aq_schema/graph/engine/run_context.dart';
import 'package:aq_schema/graph/nodes/state/i_stateful_node.dart';
import '../i_run_state_manager.dart';

/// Checkpoint каждые [interval] шагов + обязательно при critical.
///
/// Баланс между надёжностью и производительностью.
/// Используй для: production графы средней длины.
///
/// [persist] и [load] — callbacks для персистентного хранилища.
/// IntervalStateManager не знает куда сохранять — это ответственность вызывающего.
final class IntervalStateManager implements IRunStateManager {
  final int interval;
  final Future<void> Function(String runId, String contextJson) _persist;
  final Future<String?> Function(String runId) _load;

  final _stepCounts = <String, int>{};
  final _hotCache = <String, String>{}; // runId → contextJson

  @override
  final metrics = RunStateMetrics();

  IntervalStateManager({
    this.interval = 5,
    required Future<void> Function(String runId, String contextJson) persist,
    required Future<String?> Function(String runId) load,
  })  : _persist = persist,
        _load = load;

  @override
  Future<void> checkpoint(String runId, RunContext context) async {
    final start = DateTime.now();
    final json = jsonEncode(context.toJson());
    _hotCache[runId] = json;
    await _persist(runId, json);
    metrics.checkpoints++;
    metrics.totalCheckpointTime += DateTime.now().difference(start);
  }

  @override
  Future<void> checkpointForNode(
    String runId,
    RunContext context,
    NodeStateHint hint,
  ) async {
    switch (hint) {
      case NodeStateHint.transient:
        return;
      case NodeStateHint.critical:
      case NodeStateHint.checkpoint:
        await checkpoint(runId, context);
        _stepCounts[runId] = 0;
      case NodeStateHint.normal:
        final steps = (_stepCounts[runId] ?? 0) + 1;
        _stepCounts[runId] = steps;
        if (steps >= interval) {
          await checkpoint(runId, context);
          _stepCounts[runId] = 0;
        } else {
          _hotCache[runId] = jsonEncode(context.toJson()); // только hot cache
        }
    }
  }

  @override
  Future<RunContext?> restore(String runId) async {
    final hot = _hotCache[runId];
    if (hot != null) {
      metrics.restores++;
      metrics.hotHits++;
      return RunContext.fromJson(
        jsonDecode(hot) as Map<String, dynamic>,
        (msg, {type = 'info', depth = 0, required branch, details}) {},
      );
    }
    final cold = await _load(runId);
    if (cold == null) return null;
    _hotCache[runId] = cold;
    metrics.restores++;
    metrics.coldHits++;
    return RunContext.fromJson(
      jsonDecode(cold) as Map<String, dynamic>,
      (msg, {type = 'info', depth = 0, required branch, details}) {},
    );
  }

  @override
  Future<void> evict(String runId) async {
    _hotCache.remove(runId);
    _stepCounts.remove(runId);
  }
}
