/// MCP error codes — JSON-RPC standard + AQ extensions.
///
/// Standard JSON-RPC codes: -32700 .. -32600
/// AQ extension codes:       -32000 .. -32004
library;

/// Error codes used in MCP protocol responses.
abstract final class McpErrorCode {
  // ── JSON-RPC Standard ──────────────────────────────────
  /// Invalid JSON received by server.
  static const int parseError = -32700;

  /// JSON sent is not a valid Request object.
  static const int invalidRequest = -32600;

  /// Method does not exist or is not available.
  static const int methodNotFound = -32601;

  /// Invalid method parameters.
  static const int invalidParams = -32602;

  /// Internal JSON-RPC error.
  static const int internalError = -32603;

  // ── AQ Extensions ─────────────────────────────────────
  /// Worker execution failed (generic).
  static const int workerExecutionFailed = -32000;

  /// Worker did not respond within timeout.
  static const int workerTimeout = -32001;

  /// No worker available for requested tool.
  static const int workerNotAvailable = -32002;

  /// Tool requires authentication but none provided.
  static const int authRequired = -32003;

  /// Provided auth token is invalid or expired.
  static const int authInvalid = -32004;

  /// Human-readable label for a given error code.
  static String label(int code) => switch (code) {
        parseError => 'Parse error',
        invalidRequest => 'Invalid Request',
        methodNotFound => 'Method not found',
        invalidParams => 'Invalid params',
        internalError => 'Internal error',
        workerExecutionFailed => 'Worker execution failed',
        workerTimeout => 'Worker timeout',
        workerNotAvailable => 'Worker not available',
        authRequired => 'Authentication required',
        authInvalid => 'Authentication invalid',
        _ => 'Unknown error',
      };
}

/// Represents a JSON-RPC 2.0 error object embedded in an error response.
final class McpError {
  const McpError({
    required this.code,
    required this.message,
    this.data,
  });

  /// Constructs from a decoded JSON map.
  factory McpError.fromJson(Map<String, dynamic> json) {
    return McpError(
      code: json['code'] as int,
      message: json['message'] as String,
      data: json['data'],
    );
  }

  /// JSON-RPC error code. See [McpErrorCode].
  final int code;

  /// Human-readable error message.
  final String message;

  /// Optional additional error context (any JSON value).
  final Object? data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'code': code,
      'message': message,
    };
    if (data != null) map['data'] = data;
    return map;
  }

  // ── Convenience constructors ───────────────────────────

  static McpError parseError([String? detail]) => McpError(
        code: McpErrorCode.parseError,
        message: McpErrorCode.label(McpErrorCode.parseError),
        data: detail,
      );

  static McpError invalidRequest([String? detail]) => McpError(
        code: McpErrorCode.invalidRequest,
        message: McpErrorCode.label(McpErrorCode.invalidRequest),
        data: detail,
      );

  static McpError methodNotFound(String method) => McpError(
        code: McpErrorCode.methodNotFound,
        message: McpErrorCode.label(McpErrorCode.methodNotFound),
        data: 'Method not found: $method',
      );

  static McpError invalidParams([String? detail]) => McpError(
        code: McpErrorCode.invalidParams,
        message: McpErrorCode.label(McpErrorCode.invalidParams),
        data: detail,
      );

  static McpError internalError([String? detail]) => McpError(
        code: McpErrorCode.internalError,
        message: McpErrorCode.label(McpErrorCode.internalError),
        data: detail,
      );

  static McpError workerTimeout(String jobId) => McpError(
        code: McpErrorCode.workerTimeout,
        message: McpErrorCode.label(McpErrorCode.workerTimeout),
        data: 'job_id: $jobId',
      );

  static McpError workerNotAvailable(String tool) => McpError(
        code: McpErrorCode.workerNotAvailable,
        message: McpErrorCode.label(McpErrorCode.workerNotAvailable),
        data: 'No worker available for tool: $tool',
      );

  static McpError authRequired() => McpError(
        code: McpErrorCode.authRequired,
        message: McpErrorCode.label(McpErrorCode.authRequired),
      );

  static McpError authInvalid([String? reason]) => McpError(
        code: McpErrorCode.authInvalid,
        message: McpErrorCode.label(McpErrorCode.authInvalid),
        data: reason,
      );

  @override
  String toString() => 'McpError(code: $code, message: $message)';
}
