/// Role contract: Job Consumer (client side).
///
/// A Consumer submits jobs and polls for results.
/// It does NOT dequeue, execute, or manage workers.
///
/// Role separation principle:
///   Consumer  ← enqueue / getResult / getStatus
///   Worker    ← dequeue / setResult / setStatus
///   Registry  ← register / health / evict
///   Adapter   ← all of the above (orchestrator)
///
/// Consumers and Workers NEVER know about each other.
/// They only know the shared contract defined in aq_schema.
library;

import 'package:aq_schema/queue/models/queue_job_status.dart';
import 'package:aq_schema/worker/models/worker_models.dart';

/// The Consumer role interface.
///
/// Implemented by [JobQueue] in aq_queue.
/// Any client that wants to submit jobs should depend only on this interface,
/// not on [JobQueue] which exposes orchestrator-level methods.
///
/// Example usage:
/// ```dart
/// final consumer = RedisJobQueue.connect(...) as JobConsumer;
/// final jobId = await consumer.enqueue(job);
/// final status = await consumer.getStatus(jobId);
/// if (status.status == JobStatus.done) {
///   final result = await consumer.getResult(jobId);
/// }
/// ```
abstract interface class JobConsumer {
  /// Submits a job to the queue.
  ///
  /// If [workerId] is specified, routes the job to that worker's
  /// dedicated queue. Otherwise goes to the global queue.
  ///
  /// Returns the [WorkerJobImpl.jobId] for polling.
  Future<String> enqueue(WorkerJobImpl job, {String? workerId});

  /// Retrieves the final result for a completed job.
  ///
  /// Returns null if the job is not yet done or TTL has expired.
  /// TTL on results is 1 hour.
  ///
  /// Poll [getStatus] first to avoid repeated null returns.
  Future<WorkerResultImpl?> getResult(String jobId);

  /// Returns the current status of a job.
  ///
  /// Includes result when status is [JobStatus.done],
  /// and error when status is [JobStatus.failed] or [JobStatus.timeout].
  /// TTL on status is 24 hours.
  Future<QueueJobStatus> getStatus(String jobId);
}
