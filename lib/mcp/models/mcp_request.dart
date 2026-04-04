/// MCP JSON-RPC 2.0 request and response models.
library;

import 'package:aq_schema/auth/models/auth_context.dart';

import 'mcp_capabilities.dart';
import 'mcp_error.dart';
import 'mcp_tool.dart';

// ══════════════════════════════════════════════════════════
//  Execution mode
// ══════════════════════════════════════════════════════════

/// AQ EXTENSION: execution mode for tools/call.
enum ExecutionMode {
  sync('sync'),
  async('async');

  const ExecutionMode(this.value);
  final String value;

  static ExecutionMode fromString(String s) =>
      s == 'async' ? ExecutionMode.async : ExecutionMode.sync;
}

// ══════════════════════════════════════════════════════════
//  Content blocks
// ══════════════════════════════════════════════════════════

/// A single content block in a tools/call response.
sealed class McpContentBlock {
  const McpContentBlock();

  factory McpContentBlock.fromJson(Map<String, dynamic> json) {
    return switch (json['type'] as String) {
      'text' => McpTextContent(text: json['text'] as String),
      'image' => McpImageContent(
        data: json['data'] as String,
        mimeType: json['mimeType'] as String,
      ),
      final t => throw FormatException('Unknown content type: $t'),
    };
  }

  Map<String, dynamic> toJson();
}

final class McpTextContent extends McpContentBlock {
  const McpTextContent({required this.text});
  final String text;

  @override
  Map<String, dynamic> toJson() => {'type': 'text', 'text': text};
}

final class McpImageContent extends McpContentBlock {
  const McpImageContent({required this.data, required this.mimeType});
  final String data; // base64
  final String mimeType;

  @override
  Map<String, dynamic> toJson() => {
    'type': 'image',
    'data': data,
    'mimeType': mimeType,
  };
}

// ══════════════════════════════════════════════════════════
//  Requests
// ══════════════════════════════════════════════════════════

/// Generic MCP JSON-RPC request.
sealed class McpRequest {
  const McpRequest({required this.id});

  final Object? id; // String | int | null

  /// Parses raw JSON map into the appropriate [McpRequest] subtype.
  factory McpRequest.fromJson(Map<String, dynamic> json) {
    final method = json['method'] as String?;
    final id = json['id'];
    final params = json['params'] as Map<String, dynamic>? ?? {};

    return switch (method) {
      'initialize' => McpInitializeRequest.fromJson(id, params),
      'tools/list' => McpToolsListRequest(id: id),
      'tools/call' => McpToolsCallRequest.fromJson(id, params),
      _ => McpUnknownRequest(id: id, method: method ?? ''),
    };
  }

  String get method;
}

final class McpInitializeRequest extends McpRequest {
  const McpInitializeRequest({
    required super.id,
    this.protocolVersion,
    this.clientInfo,
  });

  factory McpInitializeRequest.fromJson(
    Object? id,
    Map<String, dynamic> params,
  ) {
    final clientRaw = params['clientInfo'] as Map<String, dynamic>?;
    return McpInitializeRequest(
      id: id,
      protocolVersion: params['protocolVersion'] as String?,
      clientInfo: clientRaw != null ? McpClientInfo.fromJson(clientRaw) : null,
    );
  }

  final String? protocolVersion;
  final McpClientInfo? clientInfo;

  @override
  String get method => 'initialize';
}

final class McpToolsListRequest extends McpRequest {
  const McpToolsListRequest({required super.id});

  @override
  String get method => 'tools/list';
}

final class McpToolsCallRequest extends McpRequest {
  const McpToolsCallRequest({
    required super.id,
    required this.name,
    required this.arguments,
    this.authPayload,
    this.mode = ExecutionMode.sync,
  });

  factory McpToolsCallRequest.fromJson(
    Object? id,
    Map<String, dynamic> params,
  ) {
    final authRaw = params['_aq_auth'] as Map<String, dynamic>?;
    final modeStr = params['_aq_mode'] as String?;
    return McpToolsCallRequest(
      id: id,
      name: params['name'] as String,
      arguments: params['arguments'] as Map<String, dynamic>? ?? {},
      authPayload: authRaw != null ? AuthTokenPayload.fromJson(authRaw) : null,
      mode: modeStr != null
          ? ExecutionMode.fromString(modeStr)
          : ExecutionMode.sync,
    );
  }

  final String name;
  final Map<String, dynamic> arguments;

  /// AQ EXTENSION: optional auth token.
  final AuthTokenPayload? authPayload;

  /// AQ EXTENSION: execution mode.
  final ExecutionMode mode;

  @override
  String get method => 'tools/call';
}

final class McpUnknownRequest extends McpRequest {
  const McpUnknownRequest({required super.id, required this.method});

  @override
  final String method;
}

// ══════════════════════════════════════════════════════════
//  Responses
// ══════════════════════════════════════════════════════════

/// Generic MCP JSON-RPC response (success or error).
sealed class McpResponse {
  const McpResponse({required this.id});
  final Object? id;

  Map<String, dynamic> toJson();
}

/// Successful JSON-RPC response wrapping a result payload.
final class McpSuccessResponse extends McpResponse {
  const McpSuccessResponse({required super.id, required this.result});

  final Map<String, dynamic> result;

  @override
  Map<String, dynamic> toJson() => {
    'jsonrpc': '2.0',
    'id': id,
    'result': result,
  };
}

/// JSON-RPC error response.
final class McpErrorResponse extends McpResponse {
  const McpErrorResponse({required super.id, required this.error});

  final McpError error;

  @override
  Map<String, dynamic> toJson() => {
    'jsonrpc': '2.0',
    'id': id,
    'error': error.toJson(),
  };
}

// ══════════════════════════════════════════════════════════
//  Typed response builders
// ══════════════════════════════════════════════════════════

/// Builds the result map for an initialize response.
final class McpInitializeResult {
  static Map<String, dynamic> build({
    required String protocolVersion,
    required McpCapabilities capabilities,
    required McpServerInfo serverInfo,
  }) => {
    'protocolVersion': protocolVersion,
    'capabilities': capabilities.toJson(),
    'serverInfo': serverInfo.toJson(),
  };
}

/// Builds the result map for a tools/list response.
final class McpToolsListResult {
  static Map<String, dynamic> build(List<McpTool> tools) => {
    'tools': tools.map((t) => t.toJson()).toList(),
  };
}

/// Builds the result map for a tools/call response.
final class McpToolsCallResult {
  static Map<String, dynamic> build({
    required List<McpContentBlock> content,
    bool isError = false,
  }) => {
    'content': content.map((c) => c.toJson()).toList(),
    if (isError) 'isError': true,
  };

  /// Convenience: single text content block (most common case).
  static Map<String, dynamic> text(String text, {bool isError = false}) =>
      build(
        content: [McpTextContent(text: text)],
        isError: isError,
      );

  /// Convenience: job accepted response for async mode.
  static Map<String, dynamic> jobAccepted(String jobId) =>
      text('Job accepted. job_id=$jobId');
}
