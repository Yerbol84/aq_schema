// Стратегия: всё в памяти. Для тестов и desktop-режима.

import 'dart:convert';
import 'package:aq_schema/graph/engine/run_context.dart';
import 'package:aq_schema/graph/nodes/state/i_stateful_node.dart';
import '../i_run_state_manager.dart';

/// Хранит RunContext в памяти процесса.
///
/// Плюсы: быстро, без зависимостей, идеально для тестов.
/// Минусы: состояние теряется при перезапуске процесса.
///
/// Используй для: тесты, desktop-приложения, короткие сессии.
final class InMemoryStateManager implements IRunStateManager {
  final _cache = <String, String>{}; // runId → contextJson

  @override
  final metrics = RunStateMetrics();

  @override
  Future<void> checkpoint(String runId, RunContext context) async {
    final start = DateTime.now();
    _cache[runId] = jsonEncode(context.toJson());
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
      case NodeStateHint.normal:
        await checkpoint(runId, context); // InMemory — всегда сохраняем (дёшево)
    }
  }

  @override
  Future<RunContext?> restore(String runId) async {
    final json = _cache[runId];
    if (json == null) return null;
    metrics.restores++;
    metrics.hotHits++;
    return RunContext.fromJson(
      jsonDecode(json) as Map<String, dynamic>,
      (msg, {type = 'info', depth = 0, required branch, details}) {},
    );
  }

  @override
  Future<void> evict(String runId) async => _cache.remove(runId);
}
