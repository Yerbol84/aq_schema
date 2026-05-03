// ═══════════════════════════════════════════════════════════════════════════
// IRunRepository — ПЕРСИСТЕНТНОСТЬ LIFECYCLE RUN
// ═══════════════════════════════════════════════════════════════════════════
//
// ОТВЕЧАЕТ ЗА:
//   Хранение всего что связано с жизненным циклом run:
//   - Статус (running / suspended / completed / failed / cancelled)
//   - Логи выполнения
//   - contextJson — снапшот RunContext для resume после suspend
//   - suspendedNodeId — с какого узла возобновить
//   - graphSnapshot — граф на момент запуска
//
// НЕ ОТВЕЧАЕТ ЗА:
//   - Промежуточный кэш RunContext между узлами → IRunStateManager
//   - Стратегию checkpoint (когда/как кэшировать) → IRunStateManager
//   - Hot cache для быстрого restore → IRunStateManager
//
// АНАЛОГИЯ:
//   Журнал событий. Каждая запись — факт о run.
//   "Run X перешёл в статус suspended на узле Y с контекстом Z."
//
// РЕАЛИЗАЦИИ:
//   DataLayerRunRepository  — через IDataLayer (Postgres/Supabase), production
//   InMemoryRunRepo         — в памяти, для тестов и сценариев
//   VaultRunRepository      — через VaultStorage, для интеграционных тестов
//
// ИСПОЛЬЗОВАНИЕ:
//   // Создать run:
//   await repo.createRun(WorkflowRun(...));
//
//   // Обновить статус и логи:
//   await repo.updateRunLog(runId, logs, status: WorkflowRunStatus.completed);
//
//   // Suspend — сохранить контекст для resume:
//   await repo.suspendRun(runId: runId, contextJson: json, nodeId: nodeId);
//
//   // Resume — получить контекст:
//   final run = await repo.getRun(runId);
//   final context = run?.contextJson; // восстановить RunContext из этого JSON
//
// НЕ ИСПОЛЬЗОВАТЬ ДЛЯ:
//   await repo.checkpoint(...)  // ← нет такого метода, используй IRunStateManager
//   await repo.restore(...)     // ← нет такого метода, используй IRunStateManager

import 'package:aq_schema/graph/engine/workflow_run.dart';

abstract class IRunRepository {

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  /// Создать запись о новом run.
  Future<void> createRun(WorkflowRun run);

  /// Обновить логи и (опционально) статус run.
  ///
  /// Guard: если logs пуст и status == null — no-op (не делает write в БД).
  Future<void> updateRunLog(
    String runId,
    List<String> logs, {
    WorkflowRunStatus? status,
  });

  /// Приостановить run — сохранить contextJson и suspendedNodeId.
  ///
  /// contextJson содержит сериализованный RunContext для восстановления при resume.
  /// Статус автоматически меняется на suspended.
  Future<void> suspendRun({
    required String runId,
    required String contextJson,
    required String nodeId,
  });

  /// Возобновить run — сбросить suspended state.
  ///
  /// Вызывается перед новым запуском runner'а при resume.
  /// Дефолт: no-op (реализации переопределяют при необходимости).
  Future<void> resume(String runId) async {}

  /// Завершить run — cleanup после completed/failed.
  ///
  /// Дефолт: no-op (реализации переопределяют при необходимости).
  Future<void> complete(String runId) async {}

  // ── Query ──────────────────────────────────────────────────────────────────

  /// Получить run по ID.
  ///
  /// Возвращает null если run не найден.
  Future<WorkflowRun?> getRun(String runId);

  /// Append-only добавление строки лога.
  ///
  /// Дефолт: no-op. Реализации переопределяют для эффективного append.
  /// Основной путь записи логов — updateRunLog.
  Future<void> appendLog(String runId, String entry) async {}

  // ── Concurrency ────────────────────────────────────────────────────────────

  /// Atomic compare-and-set статуса.
  ///
  /// Защита от race condition при параллельных воркерах.
  Future<bool> compareAndSetStatus({
    required String runId,
    required WorkflowRunStatus expectedStatus,
    required WorkflowRunStatus newStatus,
  });

  /// Захватить distributed lock на run.
  ///
  /// TECH DEBT: текущие реализации возвращают true (single-worker only).
  /// Требует Postgres advisory locks для multi-worker.
  Future<bool> tryAcquireLock({
    required String runId,
    required String workerId,
    required Duration ttl,
  });

  /// Освободить lock.
  Future<bool> releaseLock({
    required String runId,
    required String workerId,
  });

  // ── Dead Letter Queue ──────────────────────────────────────────────────────

  /// Переместить failed run в DLQ для анализа и ручного retry.
  Future<void> moveToDLQ({
    required String runId,
    required String reason,
    required int failureCount,
    String? lastError,
  });

  /// Получить runs в DLQ (статус failed).
  Future<List<WorkflowRun>> getDLQJobs({int limit = 100, int offset = 0});

  /// Retry run из DLQ — переводит failed → running.
  Future<bool> retryFromDLQ({required String runId});

  /// Удалить старые записи из DLQ (soft delete).
  Future<int> cleanupDLQ({required Duration olderThan});
}
