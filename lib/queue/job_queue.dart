/// Abstract queue and registry interfaces — implemented by aq_queue package.
///
/// Defined here in aq_schema so any package can depend on the interface
/// without depending on Redis or any specific broker implementation.
library;

import 'package:aq_schema/mcp/models/mcp_tool.dart';
import 'package:aq_schema/worker/models/worker_models.dart';

import 'models/queue_job_status.dart';

/// Redis key naming convention (for documentation reference).
///
/// aq:queue:jobs               — LIST  (global queue, LPUSH/BRPOP)
/// aq:queue:jobs:{worker_id}   — LIST  (per-worker queue, LPUSH/BRPOP)
/// aq:result:{job_id}          — STRING JSON, TTL 1h
/// aq:status:{job_id}          — STRING JSON, TTL 24h
/// aq:worker:registry          — HASH  {worker_id → JSON registration}
/// aq:worker:health:{worker_id}— STRING JSON, TTL 90s

/// Abstract interface for the Redis job queue.
///
/// The adapter uses this to enqueue jobs and await results.
/// Workers use this to dequeue jobs and write results.
abstract interface class JobQueue {
  /// Enqueues a job and returns its job_id.
  Future<String> enqueue(WorkerJobImpl job, {String? workerId});

  /// Blocks until a job is available in the queue.
  /// Returns null on timeout.
  Future<WorkerJobImpl?> dequeue({
    String? workerId,
    Duration timeout = const Duration(seconds: 5),
  });

  /// Stores the final result for a job.
  /// Sets TTL of 1 hour.
  Future<void> setResult(String jobId, WorkerResultImpl result);

  /// Retrieves the final result for a job.
  /// Returns null if result not yet available or TTL expired.
  Future<WorkerResultImpl?> getResult(String jobId);

  /// Gets the current status of a job (including result if done).
  Future<QueueJobStatus> getStatus(String jobId);

  /// Updates job status (pending → running, etc.).
  Future<void> setStatus(String jobId, JobStatus status, {String? workerId});

  /// Closes queue connections. Call on shutdown.
  Future<void> close();
}

/// Abstract interface for the worker registry.
///
/// The adapter uses this to register workers, aggregate their tools,
/// and evict unhealthy workers.
abstract interface class WorkerRegistry {
  /// Registers a worker. Overwrites if same worker_id exists.
  Future<void> register(WorkerRegistration registration);

  /// Updates health status for a worker. Resets TTL.
  Future<void> updateHealth(WorkerHealth health);

  /// Returns all currently active (healthy or degraded) worker registrations.
  List<WorkerRegistration> get activeWorkers;

  /// Finds any worker that can handle [toolName].
  /// Returns null if no worker is available for that tool.
  WorkerRegistration? findWorker(String toolName);

  /// Removes a worker from the registry (e.g. after missed health checks).
  Future<void> evict(String workerId);

  /// Returns all tools aggregated from all active workers.
  List<McpToolImpl> get allTools;

  /// Starts the health-check eviction loop.
  /// Workers that miss [missedChecksBeforeEvict] consecutive checks are evicted.
  void startEvictionLoop({
    Duration checkInterval = const Duration(seconds: 30),
    int missedChecksBeforeEvict = 3,
  });

  /// Stops the eviction loop cleanly.
  void stopEvictionLoop();

  /// Closes registry connections. Call on shutdown.
  Future<void> close();
}
