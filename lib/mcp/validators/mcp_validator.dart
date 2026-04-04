/// MCP protocol validator.
///
/// Validates incoming JSON-RPC messages against MCP rules.
/// Does NOT depend on any external JSON Schema library — uses
/// hand-coded rules matching the JSON Schema files in mcp/schemas/.
library;

import '../models/mcp_error.dart';
import '../models/mcp_tool.dart';

/// Result of a validation operation.
final class ValidationResult {
  const ValidationResult._({
    required this.isValid,
    this.errors = const [],
  });

  const ValidationResult.ok() : this._(isValid: true);

  const ValidationResult.fail(List<String> errors)
      : this._(isValid: false, errors: errors);

  factory ValidationResult.single(String error) =>
      ValidationResult.fail([error]);

  final bool isValid;
  final List<String> errors;

  String get firstError => errors.isNotEmpty ? errors.first : '';

  @override
  String toString() =>
      isValid ? 'ValidationResult.ok' : 'ValidationResult.fail($errors)';
}

/// Validates MCP protocol JSON objects.
abstract final class McpValidator {
  // ── JSON-RPC base ──────────────────────────────────────

  /// Validates that a raw map is a well-formed JSON-RPC 2.0 message.
  static ValidationResult validateJsonRpc(Map<String, dynamic> json) {
    final errors = <String>[];

    if (json['jsonrpc'] != '2.0') {
      errors.add('jsonrpc must be "2.0", got: ${json['jsonrpc']}');
    }

    if (!json.containsKey('method') && !json.containsKey('result') && !json.containsKey('error')) {
      errors.add('message must contain method, result, or error');
    }

    return errors.isEmpty
        ? const ValidationResult.ok()
        : ValidationResult.fail(errors);
  }

  // ── initialize ─────────────────────────────────────────

  /// Validates an initialize request map.
  static ValidationResult validateInitializeRequest(Map<String, dynamic> json) {
    final errors = <String>[];
    final base = validateJsonRpc(json);
    if (!base.isValid) errors.addAll(base.errors);

    if (json['method'] != 'initialize') {
      errors.add('method must be "initialize"');
    }

    return errors.isEmpty
        ? const ValidationResult.ok()
        : ValidationResult.fail(errors);
  }

  // ── tools/call ─────────────────────────────────────────

  /// Validates a tools/call request map.
  static ValidationResult validateToolsCallRequest(Map<String, dynamic> json) {
    final errors = <String>[];
    final base = validateJsonRpc(json);
    if (!base.isValid) errors.addAll(base.errors);

    if (json['method'] != 'tools/call') {
      errors.add('method must be "tools/call"');
    }

    final params = json['params'] as Map<String, dynamic>?;
    if (params == null) {
      errors.add('params is required for tools/call');
    } else {
      if (params['name'] == null || params['name'] is! String) {
        errors.add('params.name is required and must be a string');
      }
      if (params['arguments'] != null && params['arguments'] is! Map) {
        errors.add('params.arguments must be an object if provided');
      }
      final mode = params['_aq_mode'] as String?;
      if (mode != null && mode != 'sync' && mode != 'async') {
        errors.add('params._aq_mode must be "sync" or "async"');
      }
    }

    return errors.isEmpty
        ? const ValidationResult.ok()
        : ValidationResult.fail(errors);
  }

  // ── McpTool ────────────────────────────────────────────

  /// Validates a tool definition map matches the mcp_tool.json schema.
  static ValidationResult validateTool(Map<String, dynamic> json) {
    final errors = <String>[];

    final name = json['name'];
    if (name == null || name is! String || name.isEmpty) {
      errors.add('tool.name is required and must be a non-empty string');
    } else if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(name)) {
      errors.add(
          'tool.name must match ^[a-z][a-z0-9_]*\$ (snake_case, got: $name)');
    } else if (name.length > 64) {
      errors.add('tool.name must be at most 64 characters');
    }

    final desc = json['description'];
    if (desc == null || desc is! String || desc.isEmpty) {
      errors.add('tool.description is required and must be a non-empty string');
    } else if (desc.length > 1024) {
      errors.add('tool.description must be at most 1024 characters');
    }

    final schema = json['inputSchema'];
    if (schema == null || schema is! Map) {
      errors.add('tool.inputSchema is required and must be an object');
    } else if (schema['type'] == null) {
      errors.add('tool.inputSchema.type is required');
    }

    return errors.isEmpty
        ? const ValidationResult.ok()
        : ValidationResult.fail(errors);
  }

  /// Validates a [McpToolImpl] instance.
  static ValidationResult validateMcpTool(McpToolImpl tool) =>
      validateTool(tool.toJson());

  // ── error response ─────────────────────────────────────

  /// Validates an error response map.
  static ValidationResult validateErrorResponse(Map<String, dynamic> json) {
    final errors = <String>[];

    final error = json['error'] as Map<String, dynamic>?;
    if (error == null) {
      errors.add('error field is required in error response');
      return ValidationResult.fail(errors);
    }

    if (error['code'] == null || error['code'] is! int) {
      errors.add('error.code is required and must be an integer');
    }

    if (error['message'] == null || error['message'] is! String) {
      errors.add('error.message is required and must be a string');
    }

    return errors.isEmpty
        ? const ValidationResult.ok()
        : ValidationResult.fail(errors);
  }

  // ── tool arguments ─────────────────────────────────────

  /// Validates [arguments] against a tool's [inputSchema].
  ///
  /// Only validates required fields and basic types — a full
  /// JSON Schema validator is in aq_queue / aq_worker.
  static ValidationResult validateToolArguments({
    required Map<String, dynamic> inputSchema,
    required Map<String, dynamic> arguments,
    required String toolName,
  }) {
    final errors = <String>[];

    final required =
        (inputSchema['required'] as List<dynamic>?)?.cast<String>() ?? [];

    for (final field in required) {
      if (!arguments.containsKey(field) || arguments[field] == null) {
        errors.add('$toolName: required argument "$field" is missing');
      }
    }

    return errors.isEmpty
        ? const ValidationResult.ok()
        : ValidationResult.fail(errors);
  }

  // ── MCP error codes ────────────────────────────────────

  /// Validates error code is a known MCP / JSON-RPC code.
  static bool isKnownErrorCode(int code) => const {
        McpErrorCode.parseError,
        McpErrorCode.invalidRequest,
        McpErrorCode.methodNotFound,
        McpErrorCode.invalidParams,
        McpErrorCode.internalError,
        McpErrorCode.workerExecutionFailed,
        McpErrorCode.workerTimeout,
        McpErrorCode.workerNotAvailable,
        McpErrorCode.authRequired,
        McpErrorCode.authInvalid,
      }.contains(code);
}
