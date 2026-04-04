/// Role contract: Job Worker Client (worker side).
///
/// A Worker dequeues jobs, executes them, and writes results.
/// It does NOT submit jobs or query results.
///
/// Workers are stateless by design:
///   1. Dequeue a job
///   2. Update status → running
///   3. Execute (business logic, defined by the worker implementation)
///   4. Write result → done / failed / timeout
///
/// Workers must also register themselves and report health via [WorkerRegistry].
/// These two interfaces together define the full worker contract.
///
/// Workers MUST follow these invariants (enforced by WorkerValidator):
///   - Report health every ≤ 30 seconds
///   - Set result for every dequeued job (including failures)
///   - Respect meta.timeout_ms
///   - Be idempotent (retrying the same job_id is safe)
library;

import 'package:aq_schema/worker/models/worker_models.dart';

/// The Worker role interface for queue interaction.
///
/// Workers implement their business logic and call these methods.
/// The [dequeue] call blocks until a job is available.
///
/// Usage contract enforced in worker_validator.dart:
///   - Every dequeued job MUST have setResult called eventually.
///   - Status MUST transition: pending → running → (done|failed|timeout)
///   - Timeout MUST be respected: honor [JobMeta.timeout].
///
/// Example:
/// ```dart
/// final client = RedisJobQueue.connect(...) as JobWorkerClient;
/// while (running) {
///   final job = await client.dequeue(workerId: myId, timeout: 5.seconds);
///   if (job == null) continue; // timeout, loop
///   try {
///     final result = await myBusinessLogic(job);
///     await client.setResult(job.jobId, WorkerResultImpl.success(...));
///   } catch (e) {
///     await client.setResult(job.jobId, WorkerResultImpl.failure(...));
///   }
/// }
/// ```
abstract interface class JobWorkerClient {
  /// Blocks until a job is available or [timeout] expires.
  ///
  /// Returns null on timeout — this is NORMAL, not an error.
  /// Workers should loop and call dequeue again.
  ///
  /// [workerId] — listen on dedicated worker queue.
  ///   If null, listens on the global queue (round-robin across workers).
  ///
  /// Contract invariant: caller MUST call [setResult] for every
  /// non-null return value, even on failure.
  Future<WorkerJobImpl?> dequeue({
    String? workerId,
    Duration timeout = const Duration(seconds: 5),
  });

  /// Writes the final result to the result store.
  ///
  /// Must be called for EVERY dequeued job without exception.
  /// Failure to call this causes jobs to appear "stuck" to consumers.
  ///
  /// Automatically updates status to the result's [WorkerResultImpl.status].
  Future<void> setResult(String jobId, WorkerResultImpl result);

  /// Updates the intermediate job status.
  ///
  /// Workers MUST call this with [JobStatus.running] immediately after
  /// successfully dequeuing a job, so consumers can observe progress.
  ///
  /// [workerId] is stored in the status for observability.
  Future<void> setStatus(
    String jobId,
    JobStatus status, {
    String? workerId,
  });
}

/// Contract for worker registration and health reporting.
///
/// Separate from [JobWorkerClient] because in some architectures
/// the adapter manages registration on behalf of the worker.
///
/// Workers MUST implement both [JobWorkerClient] and this interface.
abstract interface class WorkerLifecycle {
  /// Called once on worker startup to register capabilities.
  ///
  /// Must be called before [JobWorkerClient.dequeue].
  /// Re-registration with the same [WorkerRegistration.workerId] is
  /// idempotent — overwrites the previous registration.
  Future<void> register(WorkerRegistration registration);

  /// Called periodically (every ≤ 30 seconds) to signal liveness.
  ///
  /// If health is not reported for [evictionThreshold] intervals,
  /// the orchestrator will evict this worker from the registry,
  /// meaning new jobs will no longer be routed to it.
  ///
  /// Workers SHOULD report [WorkerStatus.unhealthy] before intentional
  /// shutdown to allow graceful eviction.
  Future<void> reportHealth(WorkerHealth health);
}
