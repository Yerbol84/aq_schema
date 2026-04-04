/// In-memory implementation of [JobQueue] for testing.
///
/// Use this in unit tests and fast CI pipelines where Redis is not available.
/// The behavior is identical to [RedisJobQueue] (same contract),
/// except all state lives in-memory and is lost when the object is disposed.
///
/// This class is intentionally in aq_schema (not aq_queue) so that:
///   - Workers can test their logic without depending on aq_queue
///   - Consumers can test their logic without depending on aq_queue
///   - Contract tests in aq_queue run the same tests against both impls
library;

import 'dart:async';
import 'dart:collection';

import 'package:aq_schema/queue/job_queue.dart';
import 'package:aq_schema/queue/models/queue_job_status.dart';
import 'package:aq_schema/queue/roles/job_consumer.dart';
import 'package:aq_schema/queue/roles/job_worker_client.dart';
import 'package:aq_schema/worker/models/worker_models.dart';
import 'package:aq_schema/mcp/models/mcp_tool.dart';

/// In-memory [JobQueue] implementation.
///
/// Thread-safe for single-isolate use (Dart's event loop guarantees).
/// NOT suitable for production — state is ephemeral.
///
/// Implements all three interfaces:
///   [JobConsumer] — consumer role
///   [JobWorkerClient] — worker role
///   [JobQueue] — full orchestrator interface
final class InMemoryJobQueue implements JobQueue, JobConsumer, JobWorkerClient {
  InMemoryJobQueue();

  // ── Internal state ─────────────────────────────────────

  // queue key → FIFO list of serialized jobs
  final _queues = <String, Queue<WorkerJobImpl>>{};

  // waiters blocked on BRPOP: queue key → list of completers
  final _waiters = <String, List<Completer<WorkerJobImpl?>>>{};

  // job_id → status
  final _statuses = <String, QueueJobStatus>{};

  // job_id → result
  final _results = <String, WorkerResultImpl>{};

  bool _closed = false;

  static const _globalKey = 'aq:queue:jobs';

  String _workerKey(String workerId) => 'aq:queue:jobs:$workerId';

  // ── JobConsumer / JobQueue ─────────────────────────────

  @override
  Future<String> enqueue(WorkerJobImpl job, {String? workerId}) async {
    _assertOpen();
    final key = workerId != null ? _workerKey(workerId) : _globalKey;

    final status = QueueJobStatus(
      jobId: job.jobId,
      status: JobStatus.pending,
      createdAt: job.createdAt,
    );
    _statuses[job.jobId] = status;

    // Wake up a waiter if any
    final waiters = _waiters[key] ?? [];
    if (waiters.isNotEmpty) {
      final completer = waiters.removeAt(0);
      if (waiters.isEmpty) _waiters.remove(key);
      completer.complete(job);
    } else {
      (_queues[key] ??= Queue()).addLast(job);
    }

    return job.jobId;
  }

  @override
  Future<WorkerResultImpl?> getResult(String jobId) async {
    return _results[jobId];
  }

  @override
  Future<QueueJobStatus> getStatus(String jobId) async {
    return _statuses[jobId] ??
        QueueJobStatus(jobId: jobId, status: JobStatus.pending);
  }

  // ── JobWorkerClient / JobQueue ─────────────────────────

  @override
  Future<WorkerJobImpl?> dequeue({
    String? workerId,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    _assertOpen();
    final key = workerId != null ? _workerKey(workerId) : _globalKey;

    // Check queue first (non-blocking fast path)
    final queue = _queues[key];
    if (queue != null && queue.isNotEmpty) {
      return queue.removeFirst();
    }

    // Block: register waiter and wait
    final completer = Completer<WorkerJobImpl?>();
    (_waiters[key] ??= []).add(completer);

    // Timeout cancels the waiter
    final timer = Timer(timeout, () {
      final list = _waiters[key];
      if (list != null) {
        list.remove(completer);
        if (list.isEmpty) _waiters.remove(key);
      }
      if (!completer.isCompleted) completer.complete(null);
    });

    final result = await completer.future;
    timer.cancel();
    return result;
  }

  @override
  Future<void> setResult(String jobId, WorkerResultImpl result) async {
    _results[jobId] = result;

    final current = _statuses[jobId];
    _statuses[jobId] = QueueJobStatus(
      jobId: jobId,
      status: result.status,
      workerId: current?.workerId,
      workerResult: result,
      createdAt: current?.createdAt,
      startedAt: current?.startedAt,
      completedAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    );
  }

  @override
  Future<void> setStatus(
    String jobId,
    JobStatus status, {
    String? workerId,
  }) async {
    final current = _statuses[jobId];
    _statuses[jobId] = QueueJobStatus(
      jobId: jobId,
      status: status,
      workerId: workerId ?? current?.workerId,
      workerResult: current?.workerResult,
      createdAt: current?.createdAt,
      startedAt: status == JobStatus.running
          ? DateTime.now().millisecondsSinceEpoch ~/ 1000
          : current?.startedAt,
      completedAt: status.isTerminal
          ? DateTime.now().millisecondsSinceEpoch ~/ 1000
          : current?.completedAt,
    );
  }

  // ── JobQueue full interface ────────────────────────────

  @override
  Future<void> close() async {
    _closed = true;
    // Cancel all waiting dequeue calls
    for (final waiters in _waiters.values) {
      for (final c in waiters) {
        if (!c.isCompleted) c.complete(null);
      }
    }
    _waiters.clear();
  }

  // ── Helpers ───────────────────────────────────────────

  void _assertOpen() {
    if (_closed) throw StateError('InMemoryJobQueue is closed');
  }

  /// Returns count of pending jobs in global queue (for assertions in tests).
  int get pendingCount => (_queues[_globalKey] ?? Queue()).length;

  /// Returns count of pending jobs for a specific worker queue.
  int workerQueueCount(String workerId) =>
      (_queues[_workerKey(workerId)] ?? Queue()).length;
}

/// In-memory [WorkerRegistry] for testing.
final class InMemoryWorkerRegistry implements WorkerRegistry {
  final _workers = <String, WorkerRegistration>{};
  final _health = <String, WorkerHealth>{};
  final _missCounts = <String, int>{};

  Timer? _evictionTimer;
  bool _closed = false;

  @override
  Future<void> register(WorkerRegistration registration) async {
    _workers[registration.workerId] = registration;
    _missCounts[registration.workerId] = 0;
  }

  @override
  Future<void> updateHealth(WorkerHealth health) async {
    _health[health.workerId] = health;
    _missCounts[health.workerId] = 0;
  }

  @override
  List<WorkerRegistration> get activeWorkers =>
      List.unmodifiable(_workers.values);

  @override
  WorkerRegistration? findWorker(String toolName) {
    final candidates = _workers.values
        .where((w) => w.tools.any((t) => t.name == toolName))
        .toList();
    if (candidates.isEmpty) return null;
    // Round-robin by rotating list
    final first = candidates.first;
    _workers.remove(first.workerId);
    _workers[first.workerId] = first;
    return first;
  }

  @override
  Future<void> evict(String workerId) async {
    _workers.remove(workerId);
    _health.remove(workerId);
    _missCounts.remove(workerId);
  }

  @override
  List<McpToolImpl> get allTools {
    final seen = <String>{};
    final tools = <McpToolImpl>[];
    for (final w in _workers.values) {
      for (final t in w.tools) {
        if (seen.add(t.name)) tools.add(t);
      }
    }
    return tools;
  }

  @override
  void startEvictionLoop({
    Duration checkInterval = const Duration(seconds: 30),
    int missedChecksBeforeEvict = 3,
  }) {
    _evictionTimer = Timer.periodic(checkInterval, (_) async {
      final toEvict = <String>[];
      for (final workerId in _workers.keys) {
        final lastHealth = _health[workerId];
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final missed =
            lastHealth == null ||
            (now - lastHealth.timestamp) > checkInterval.inSeconds;

        if (missed) {
          _missCounts[workerId] = (_missCounts[workerId] ?? 0) + 1;
          if ((_missCounts[workerId] ?? 0) >= missedChecksBeforeEvict) {
            toEvict.add(workerId);
          }
        } else {
          _missCounts[workerId] = 0;
        }
      }
      for (final id in toEvict) {
        await evict(id);
      }
    });
  }

  @override
  void stopEvictionLoop() {
    _evictionTimer?.cancel();
    _evictionTimer = null;
  }

  @override
  Future<void> close() async {
    stopEvictionLoop();
    _closed = true;
  }

  /// For test assertions.
  bool isRegistered(String workerId) => _workers.containsKey(workerId);
}
