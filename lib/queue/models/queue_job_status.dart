/// Queue domain model — job status tracking.
library;

import 'package:aq_schema/worker/models/worker_models.dart';

/// Current status of a job in the queue.
/// Used for polling via the get_job_status tool (AQ extension).
final class QueueJobStatus {
  const QueueJobStatus({
    required this.jobId,
    required this.status,
    this.workerId,
    this.workerResult,
    this.createdAt,
    this.startedAt,
    this.completedAt,
  });

  factory QueueJobStatus.fromJson(Map<String, dynamic> json) {
    final resultRaw = json['result'] as Map<String, dynamic>?;
    return QueueJobStatus(
      jobId: json['job_id'] as String,
      status: JobStatus.fromString(json['status'] as String),
      workerId: json['worker_id'] as String?,
      workerResult: resultRaw != null
          ? WorkerResultImpl.fromJson(resultRaw)
          : null,
      createdAt: json['created_at'] as int?,
      startedAt: json['started_at'] as int?,
      completedAt: json['completed_at'] as int?,
    );
  }

  final String jobId;
  final JobStatus status;
  final String? workerId;
  final WorkerResultImpl? workerResult;
  final int? createdAt;
  final int? startedAt;
  final int? completedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'job_id': jobId, 'status': status.value};
    if (workerId != null) map['worker_id'] = workerId;
    if (workerResult != null) map['result'] = workerResult!.toJson();
    if (createdAt != null) map['created_at'] = createdAt;
    if (startedAt != null) map['started_at'] = startedAt;
    if (completedAt != null) map['completed_at'] = completedAt;
    return map;
  }

  @override
  String toString() => 'QueueJobStatus(id: $jobId, status: ${status.value})';
}
