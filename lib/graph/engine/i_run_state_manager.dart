// ═══════════════════════════════════════════════════════════════════════════
// IRunStateManager — СТРАТЕГИЯ КЭШИРОВАНИЯ RunContext
// ═══════════════════════════════════════════════════════════════════════════
//
// ОТВЕЧАЕТ ЗА:
//   Когда и как кэшировать RunContext (переменные выполнения) между узлами.
//   Это стратегия — реализация решает: в памяти, каждые N шагов, или никогда.
//
// НЕ ОТВЕЧАЕТ ЗА:
//   - Статус run (running/suspended/completed) → IRunRepository
//   - Логи выполнения → IRunRepository
//   - Lifecycle run (suspend/resume/complete) → IRunRepository
//   - graphSnapshot, suspendedNodeId → IRunRepository
//
// АНАЛОГИЯ:
//   Буфер записи на диск. Решает когда сбрасывать буфер,
//   но не знает что именно происходит с файлом.
//
// РЕАЛИЗАЦИИ:
//   InMemoryStateManager  — всё в памяти, для тестов и desktop
//   NoopStateManager      — ничего не сохраняет, для fire-and-forget графов
//   IntervalStateManager  — checkpoint каждые N шагов, для production
//
// ИСПОЛЬЗОВАНИЕ:
//   // После выполнения узла с IStatefulNode:
//   if (node is IStatefulNode) {
//     await stateManager.checkpointForNode(runId, context, node.stateHint);
//   }
//
//   // При resume — восстановить RunContext из кэша:
//   final ctx = await stateManager.restore(runId);
//
// НЕ ИСПОЛЬЗОВАТЬ ДЛЯ:
//   await stateManager.suspend(...)  // ← НЕПРАВИЛЬНО, используй IRunRepository
//   await stateManager.resume(...)   // ← НЕПРАВИЛЬНО, используй IRunRepository

import 'package:aq_schema/graph/engine/run_context.dart';
import 'package:aq_schema/graph/nodes/state/i_stateful_node.dart';

/// Метрики стратегии кэширования.
class RunStateMetrics {
  int checkpoints = 0;
  int restores = 0;
  int hotHits = 0;   // восстановлено из памяти
  int coldHits = 0;  // восстановлено из персистентного хранилища
  Duration totalCheckpointTime = Duration.zero;

  @override
  String toString() =>
      'checkpoints=$checkpoints restores=$restores '
      'hot=$hotHits cold=$coldHits';
}

/// Стратегия кэширования RunContext между узлами графа.
///
/// Не управляет lifecycle run — только кэшем контекста.
/// Для lifecycle (suspend/resume/complete) используй [IRunRepository].
abstract interface class IRunStateManager {

  // ── Checkpoint ─────────────────────────────────────────────────────────────

  /// Сохранить RunContext в кэш.
  ///
  /// Реализация решает — сохранять сейчас или отложить.
  Future<void> checkpoint(String runId, RunContext context);

  /// Сохранить RunContext с учётом типа узла.
  ///
  /// - critical: сохранить немедленно (LLM вызов, API запрос)
  /// - checkpoint: сохранить после выполнения
  /// - transient: пропустить (быстрые вычисления)
  /// - normal: по стратегии реализации
  Future<void> checkpointForNode(
    String runId,
    RunContext context,
    NodeStateHint hint,
  );

  // ── Restore ────────────────────────────────────────────────────────────────

  /// Восстановить RunContext из кэша.
  ///
  /// Возвращает null если кэш пуст.
  /// Сначала проверяет hot cache (память), потом cold storage.
  Future<RunContext?> restore(String runId);

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  /// Очистить кэш для завершённого run.
  ///
  /// Вызывается после completed/failed — освобождает память.
  Future<void> evict(String runId);

  /// Метрики этой реализации.
  RunStateMetrics get metrics;
}
