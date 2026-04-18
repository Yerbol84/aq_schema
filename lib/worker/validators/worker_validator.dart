/// Worker protocol validator.
///
/// Validates worker registration, job, result and health objects
/// against the rules defined in worker/schemas/*.json files.
library;

import 'package:aq_schema/mcp/validators/mcp_validator.dart';

import '../models/worker_models.dart';
import '../models/worker_validation_result.dart';

/// Validates worker protocol JSON objects.
abstract final class WorkerValidator {
  // ── WorkerRegistration ────────────────────────────────

  /// Validates a raw worker registration map.
  static WorkerValidationResult validateRegistration(Map<String, dynamic> json) {
    final errors = <String>[];

    final workerId = json['worker_id'];
    if (workerId == null || workerId is! String || workerId.isEmpty) {
      errors.add('worker_id is required and must be a non-empty string');
    } else if (!RegExp(r'^[a-z][a-z0-9-]*$').hasMatch(workerId)) {
      errors.add(
        'worker_id must match ^[a-z][a-z0-9-]*\$ (kebab-case), got: $workerId',
      );
    } else if (workerId.length > 64) {
      errors.add('worker_id must be at most 64 characters');
    }

    final tools = json['tools'];
    if (tools == null || tools is! List || tools.isEmpty) {
      errors.add('tools is required and must be a non-empty array');
    } else {
      for (var i = 0; i < tools.length; i++) {
        final tool = tools[i];
        if (tool is! Map<String, dynamic>) {
          errors.add('tools[$i] must be an object');
          continue;
        }
        final toolResult = McpValidator.validateTool(tool);
        if (!toolResult.isValid) {
          errors.addAll(toolResult.errors.map((e) => 'tools[$i]: $e'));
        }
      }
    }

    final capabilities = json['capabilities'];
    if (capabilities == null || capabilities is! Map) {
      errors.add('capabilities is required and must be an object');
    } else {
      if (capabilities['async'] == null || capabilities['async'] is! bool) {
        errors.add('capabilities.async is required and must be a boolean');
      }
      final concurrency = capabilities['concurrency'];
      if (concurrency == null || concurrency is! int || concurrency < 1) {
        errors.add(
          'capabilities.concurrency is required and must be an integer >= 1',
        );
      }
    }

    return errors.isEmpty
        ? WorkerValidationResult.ok()
        : WorkerValidationResult.fail(errors);
  }

  /// Validates a [WorkerRegistration] instance.
  static WorkerValidationResult validateWorkerRegistration(WorkerRegistration reg) =>
      validateRegistration(reg.toJson());

  // ── WorkerJob ─────────────────────────────────────────

  /// Validates a raw job map.
  static WorkerValidationResult validateJob(Map<String, dynamic> json) {
    final errors = <String>[];

    final jobId = json['job_id'];
    if (jobId == null || jobId is! String || jobId.isEmpty) {
      errors.add('job_id is required');
    }

    final tool = json['tool'];
    if (tool == null || tool is! String || tool.isEmpty) {
      errors.add('tool is required and must be a string');
    } else if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(tool)) {
      errors.add('tool must match ^[a-z][a-z0-9_]*\$');
    }

    if (json['payload'] == null || json['payload'] is! Map) {
      errors.add('payload is required and must be an object');
    }

    if (json['created_at'] == null || json['created_at'] is! int) {
      errors.add(
        'created_at is required and must be an integer (Unix seconds)',
      );
    }

    final meta = json['meta'] as Map<String, dynamic>?;
    if (meta != null) {
      final mode = meta['mode'] as String?;
      if (mode != null && mode != 'sync' && mode != 'async') {
        errors.add('meta.mode must be "sync" or "async"');
      }
      final timeout = meta['timeout_ms'];
      if (timeout != null && (timeout is! int || timeout < 0)) {
        errors.add('meta.timeout_ms must be a non-negative integer');
      }
    }

    return errors.isEmpty
        ? WorkerValidationResult.ok()
        : WorkerValidationResult.fail(errors);
  }

  /// Validates a [WorkerJobImpl] instance.
  static WorkerValidationResult validateWorkerJob(WorkerJobImpl job) =>
      validateJob(job.toJson());

  // ── WorkerResult ──────────────────────────────────────

  /// Validates a raw result map.
  static WorkerValidationResult validateResult(Map<String, dynamic> json) {
    final errors = <String>[];

    final jobId = json['job_id'];
    if (jobId == null || jobId is! String || jobId.isEmpty) {
      errors.add('job_id is required');
    }

    final status = json['status'] as String?;
    const terminal = {'done', 'failed', 'timeout'};
    if (status == null || !terminal.contains(status)) {
      errors.add('status must be one of: ${terminal.join(', ')}');
    }

    if (json['completed_at'] == null || json['completed_at'] is! int) {
      errors.add('completed_at is required and must be an integer');
    }

    if (status == 'done' && json['result'] == null) {
      errors.add('result is required when status is "done"');
    }

    if ((status == 'failed' || status == 'timeout') && json['error'] == null) {
      errors.add('error is required when status is "failed" or "timeout"');
    }

    if (json['error'] != null) {
      final error = json['error'] as Map<String, dynamic>?;
      if (error == null) {
        errors.add('error must be an object');
      } else {
        if (error['code'] is! int) errors.add('error.code must be an integer');
        if (error['message'] is! String) {
          errors.add('error.message must be a string');
        }
        const validTypes = {
          'execution_error',
          'validation_error',
          'auth_error',
          'timeout',
          'internal',
        };
        if (!validTypes.contains(error['type'])) {
          errors.add('error.type must be one of: ${validTypes.join(', ')}');
        }
      }
    }

    return errors.isEmpty
        ? WorkerValidationResult.ok()
        : WorkerValidationResult.fail(errors);
  }

  /// Validates a [WorkerResultImpl] instance.
  static WorkerValidationResult validateWorkerResult(WorkerResultImpl result) =>
      validateResult(result.toJson());

  // ── WorkerHealth ──────────────────────────────────────

  /// Validates a raw health check map.
  static WorkerValidationResult validateHealth(Map<String, dynamic> json) {
    final errors = <String>[];

    final workerId = json['worker_id'];
    if (workerId == null || workerId is! String || workerId.isEmpty) {
      errors.add('worker_id is required');
    }

    const validStatuses = {'healthy', 'degraded', 'unhealthy'};
    final status = json['status'] as String?;
    if (status == null || !validStatuses.contains(status)) {
      errors.add('status must be one of: ${validStatuses.join(', ')}');
    }

    if (json['timestamp'] == null || json['timestamp'] is! int) {
      errors.add('timestamp is required and must be an integer');
    }

    return errors.isEmpty
        ? WorkerValidationResult.ok()
        : WorkerValidationResult.fail(errors);
  }

  /// Validates a [WorkerHealth] instance.
  static WorkerValidationResult validateWorkerHealth(WorkerHealth health) =>
      validateHealth(health.toJson());
}
