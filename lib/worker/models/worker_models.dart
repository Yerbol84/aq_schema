/// Worker domain models — the job contract between adapter and workers.
library;

import 'package:aq_schema/auth/models/auth_context.dart';
import 'package:aq_schema/mcp/models/mcp_tool.dart';

// ══════════════════════════════════════════════════════════
//  Enums
// ══════════════════════════════════════════════════════════

/// Terminal and intermediate job statuses.
enum JobStatus {
  pending('pending'),
  running('running'),
  done('done'),
  failed('failed'),
  timeout('timeout');

  const JobStatus(this.value);
  final String value;

  bool get isTerminal =>
      this == JobStatus.done ||
      this == JobStatus.failed ||
      this == JobStatus.timeout;

  static JobStatus fromString(String s) => JobStatus.values.firstWhere(
    (e) => e.value == s,
    orElse: () => JobStatus.failed,
  );
}

/// Worker health status.
enum WorkerStatus {
  healthy('healthy'),
  degraded('degraded'),
  unhealthy('unhealthy');

  const WorkerStatus(this.value);
  final String value;

  static WorkerStatus fromString(String s) => WorkerStatus.values.firstWhere(
    (e) => e.value == s,
    orElse: () => WorkerStatus.unhealthy,
  );
}

/// Error type categories for result normalization.
enum WorkerErrorType {
  executionError('execution_error'),
  validationError('validation_error'),
  authError('auth_error'),
  timeout('timeout'),
  internal('internal');

  const WorkerErrorType(this.value);
  final String value;

  static WorkerErrorType fromString(String s) => WorkerErrorType.values
      .firstWhere((e) => e.value == s, orElse: () => WorkerErrorType.internal);
}

// ══════════════════════════════════════════════════════════
//  JobMeta
// ══════════════════════════════════════════════════════════

/// Metadata attached to every job by the adapter.
final class JobMeta {
  const JobMeta({
    this.timeoutMs = 30000,
    this.retryCount = 0,
    this.maxRetries = 1,
    this.mode = 'sync',
    this.sourceRequestId,
  });

  factory JobMeta.fromJson(Map<String, dynamic> json) => JobMeta(
    timeoutMs: (json['timeout_ms'] as int?) ?? 30000,
    retryCount: (json['retry_count'] as int?) ?? 0,
    maxRetries: (json['max_retries'] as int?) ?? 1,
    mode: (json['mode'] as String?) ?? 'sync',
    sourceRequestId: json['source_request_id'] as String?,
  );

  final int timeoutMs;
  final int retryCount;
  final int maxRetries;
  final String mode;
  final String? sourceRequestId;

  bool get canRetry => retryCount < maxRetries;
  Duration get timeout => Duration(milliseconds: timeoutMs);

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'timeout_ms': timeoutMs,
      'retry_count': retryCount,
      'max_retries': maxRetries,
      'mode': mode,
    };
    if (sourceRequestId != null) map['source_request_id'] = sourceRequestId;
    return map;
  }
}

// ══════════════════════════════════════════════════════════
//  WorkerJob — the job contract
// ══════════════════════════════════════════════════════════

/// Abstract interface for a job passed through the queue.
abstract interface class WorkerJob {
  String get jobId;
  String get tool;
  Map<String, dynamic> get payload;
  AuthContext? get auth;
  JobMeta? get meta;
}

/// Concrete job implementation placed in Redis queue by adapter.
final class WorkerJobImpl implements WorkerJob {
  const WorkerJobImpl({
    required this.jobId,
    required this.tool,
    required this.payload,
    required this.createdAt,
    this.auth,
    this.meta,
  });

  factory WorkerJobImpl.fromJson(Map<String, dynamic> json) {
    final authRaw = json['auth'] as Map<String, dynamic>?;
    final metaRaw = json['meta'] as Map<String, dynamic>?;
    return WorkerJobImpl(
      jobId: json['job_id'] as String,
      tool: json['tool'] as String,
      payload: json['payload'] as Map<String, dynamic>,
      createdAt: json['created_at'] as int,
      auth: authRaw != null ? AuthContext.fromJson(authRaw) : null,
      meta: metaRaw != null ? JobMeta.fromJson(metaRaw) : null,
    );
  }

  @override
  final String jobId;

  @override
  final String tool;

  @override
  final Map<String, dynamic> payload;

  @override
  final AuthContext? auth;

  @override
  final JobMeta? meta;

  final int createdAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'job_id': jobId,
      'tool': tool,
      'payload': payload,
      'created_at': createdAt,
    };
    if (auth != null) map['auth'] = auth!.toJson();
    if (meta != null) map['meta'] = meta!.toJson();
    return map;
  }

  @override
  String toString() => 'WorkerJob(id: $jobId, tool: $tool)';
}

// ══════════════════════════════════════════════════════════
//  WorkerError
// ══════════════════════════════════════════════════════════

/// Normalized error from a worker.
final class WorkerError {
  const WorkerError({
    required this.code,
    required this.message,
    required this.type,
  });

  factory WorkerError.fromJson(Map<String, dynamic> json) => WorkerError(
    code: json['code'] as int,
    message: json['message'] as String,
    type: WorkerErrorType.fromString(json['type'] as String),
  );

  final int code;
  final String message;
  final WorkerErrorType type;

  Map<String, dynamic> toJson() => {
    'code': code,
    'message': message,
    'type': type.value,
  };

  static WorkerError executionFailed(String message) => WorkerError(
    code: -32000,
    message: message,
    type: WorkerErrorType.executionError,
  );

  static WorkerError validationFailed(String message) => WorkerError(
    code: -32602,
    message: message,
    type: WorkerErrorType.validationError,
  );

  static WorkerError timedOut() => WorkerError(
    code: -32001,
    message: 'Worker timeout',
    type: WorkerErrorType.timeout,
  );

  @override
  String toString() => 'WorkerError(code: $code, type: ${type.value})';
}

// ══════════════════════════════════════════════════════════
//  WorkerResult — abstract interface and impl
// ══════════════════════════════════════════════════════════

/// Abstract interface for a job execution result.
abstract interface class WorkerResult {
  String get jobId;
  JobStatus get status;
  Map<String, dynamic>? get result;
  WorkerError? get error;
}

/// Concrete worker result written to Redis result store.
final class WorkerResultImpl implements WorkerResult {
  const WorkerResultImpl({
    required this.jobId,
    required this.status,
    required this.completedAt,
    this.result,
    this.error,
    this.durationMs,
  });

  factory WorkerResultImpl.fromJson(Map<String, dynamic> json) {
    final errorRaw = json['error'] as Map<String, dynamic>?;
    final resultRaw = json['result'] as Map<String, dynamic>?;
    return WorkerResultImpl(
      jobId: json['job_id'] as String,
      status: JobStatus.fromString(json['status'] as String),
      completedAt: json['completed_at'] as int,
      result: resultRaw,
      error: errorRaw != null ? WorkerError.fromJson(errorRaw) : null,
      durationMs: json['duration_ms'] as int?,
    );
  }

  @override
  final String jobId;

  @override
  final JobStatus status;

  @override
  final Map<String, dynamic>? result;

  @override
  final WorkerError? error;

  final int completedAt;
  final int? durationMs;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'job_id': jobId,
      'status': status.value,
      'completed_at': completedAt,
    };
    if (result != null) map['result'] = result;
    if (error != null) map['error'] = error!.toJson();
    if (durationMs != null) map['duration_ms'] = durationMs;
    return map;
  }

  static WorkerResultImpl success({
    required String jobId,
    required Map<String, dynamic> result,
    int? durationMs,
  }) => WorkerResultImpl(
    jobId: jobId,
    status: JobStatus.done,
    completedAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    result: result,
    durationMs: durationMs,
  );

  static WorkerResultImpl failure({
    required String jobId,
    required WorkerError error,
    int? durationMs,
  }) => WorkerResultImpl(
    jobId: jobId,
    status: JobStatus.failed,
    completedAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    error: error,
    durationMs: durationMs,
  );

  static WorkerResultImpl timedOut(String jobId) => WorkerResultImpl(
    jobId: jobId,
    status: JobStatus.timeout,
    completedAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    error: WorkerError.timedOut(),
  );

  @override
  String toString() => 'WorkerResult(id: $jobId, status: ${status.value})';
}

// ══════════════════════════════════════════════════════════
//  WorkerCapabilities
// ══════════════════════════════════════════════════════════

/// Declared capabilities of a worker.
final class WorkerCapabilities {
  const WorkerCapabilities({
    required this.async,
    required this.concurrency,
    this.streaming = false,
  });

  factory WorkerCapabilities.fromJson(Map<String, dynamic> json) =>
      WorkerCapabilities(
        async: json['async'] as bool,
        concurrency: json['concurrency'] as int,
        streaming: (json['streaming'] as bool?) ?? false,
      );

  final bool async;
  final int concurrency;
  final bool streaming;

  Map<String, dynamic> toJson() => {
    'async': async,
    'concurrency': concurrency,
    'streaming': streaming,
  };
}

// ══════════════════════════════════════════════════════════
//  WorkerRegistration
// ══════════════════════════════════════════════════════════

/// Registration payload sent by worker on startup.
final class WorkerRegistration {
  const WorkerRegistration({
    required this.workerId,
    required this.tools,
    required this.capabilities,
    this.meta,
  });

  factory WorkerRegistration.fromJson(Map<String, dynamic> json) {
    final toolsList = json['tools'] as List<dynamic>;
    final metaRaw = json['meta'] as Map<String, dynamic>?;
    return WorkerRegistration(
      workerId: json['worker_id'] as String,
      tools: toolsList
          .map((t) => McpToolImpl.fromJson(t as Map<String, dynamic>))
          .toList(),
      capabilities: WorkerCapabilities.fromJson(
        json['capabilities'] as Map<String, dynamic>,
      ),
      meta: metaRaw,
    );
  }

  final String workerId;
  final List<McpToolImpl> tools;
  final WorkerCapabilities capabilities;
  final Map<String, dynamic>? meta;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'worker_id': workerId,
      'tools': tools.map((t) => t.toJson()).toList(),
      'capabilities': capabilities.toJson(),
    };
    if (meta != null) map['meta'] = meta;
    return map;
  }

  @override
  String toString() =>
      'WorkerRegistration(id: $workerId, tools: ${tools.map((t) => t.name).toList()})';
}

// ══════════════════════════════════════════════════════════
//  WorkerHealth
// ══════════════════════════════════════════════════════════

/// Periodic health report from worker.
final class WorkerHealth {
  const WorkerHealth({
    required this.workerId,
    required this.status,
    required this.timestamp,
    this.activeJobs = 0,
    this.queueDepth = 0,
    this.uptimeSeconds,
  });

  factory WorkerHealth.fromJson(Map<String, dynamic> json) => WorkerHealth(
    workerId: json['worker_id'] as String,
    status: WorkerStatus.fromString(json['status'] as String),
    timestamp: json['timestamp'] as int,
    activeJobs: (json['active_jobs'] as int?) ?? 0,
    queueDepth: (json['queue_depth'] as int?) ?? 0,
    uptimeSeconds: json['uptime_seconds'] as int?,
  );

  final String workerId;
  final WorkerStatus status;
  final int timestamp;
  final int activeJobs;
  final int queueDepth;
  final int? uptimeSeconds;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'worker_id': workerId,
      'status': status.value,
      'timestamp': timestamp,
      'active_jobs': activeJobs,
      'queue_depth': queueDepth,
    };
    if (uptimeSeconds != null) map['uptime_seconds'] = uptimeSeconds;
    return map;
  }

  @override
  String toString() =>
      'WorkerHealth(id: $workerId, status: ${status.value}, active: $activeJobs)';
}
