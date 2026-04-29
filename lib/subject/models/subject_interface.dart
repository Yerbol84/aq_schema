// aq_schema/lib/subject/models/subject_interface.dart
//
// Интерфейс взаимодействия с Subject — как отправлять input и получать output.
//
// Определяет протокол (stdio, http, mcp) и схемы данных (JSON Schema).

import 'subject_protocol.dart';

/// Интерфейс взаимодействия с Subject.
///
/// Определяет:
/// • Протокол (как общаться)
/// • Схемы input/output (что отправлять/получать)
/// • Дополнительные параметры протокола
final class SubjectInterface {
  static final _SubjectInterfaceKeys _keys = _SubjectInterfaceKeys._();
  static _SubjectInterfaceKeys get keys => _keys;

  /// Протокол взаимодействия.
  ///
  /// Базовые значения:
  /// • "stdio" — stdin/stdout
  /// • "http" — HTTP REST API
  /// • "mcp" — MCP JSON-RPC
  /// • "graph_engine" — AQ GraphEngine protocol
  /// • "wasm" — WASM component interface
  /// • "openai_compatible" — OpenAI-compatible HTTP API
  final SubjectProtocol protocol;

  /// JSON Schema входных данных.
  ///
  /// Определяет структуру SubjectInput.data.
  /// Используется для валидации и генерации UI.
  final Map<String, dynamic> inputSchema;

  /// JSON Schema выходных данных.
  ///
  /// Определяет структуру SubjectOutput.data.
  final Map<String, dynamic> outputSchema;

  /// Поддерживает ли streaming output.
  ///
  /// Если true — можно использовать session.sendStream().
  final bool supportsStreaming;

  /// Поддерживает ли tool use (для LLM).
  ///
  /// Если true — Subject может вызывать Tools через context.
  final bool supportsToolUse;

  /// Дополнительные параметры протокола.
  ///
  /// Специфичны для каждого protocol.
  /// Примеры:
  /// • http: {"base_path": "/api/v1", "auth_type": "bearer"}
  /// • mcp: {"transport": "stdio", "command": "npx @mcp/server"}
  final Map<String, dynamic> protocolParams;

  const SubjectInterface({
    required this.protocol,
    required this.inputSchema,
    this.outputSchema = const {},
    this.supportsStreaming = false,
    this.supportsToolUse = false,
    this.protocolParams = const {},
  });

  Map<String, dynamic> toJson() => {
        SubjectInterface.keys.protocol: protocol.value,
        SubjectInterface.keys.inputSchema: inputSchema,
        SubjectInterface.keys.outputSchema: outputSchema,
        SubjectInterface.keys.supportsStreaming: supportsStreaming,
        SubjectInterface.keys.supportsToolUse: supportsToolUse,
        if (protocolParams.isNotEmpty)
          SubjectInterface.keys.protocolParams: protocolParams,
      };

  factory SubjectInterface.fromJson(Map<String, dynamic> json) =>
      SubjectInterface(
        protocol: SubjectProtocol.parse(
            json[SubjectInterface.keys.protocol] as String),
        inputSchema: Map<String, dynamic>.from(
            json[SubjectInterface.keys.inputSchema] as Map),
        outputSchema: json[SubjectInterface.keys.outputSchema] != null
            ? Map<String, dynamic>.from(
                json[SubjectInterface.keys.outputSchema] as Map)
            : const {},
        supportsStreaming:
            json[SubjectInterface.keys.supportsStreaming] as bool? ?? false,
        supportsToolUse:
            json[SubjectInterface.keys.supportsToolUse] as bool? ?? false,
        protocolParams: json[SubjectInterface.keys.protocolParams] != null
            ? Map<String, dynamic>.from(
                json[SubjectInterface.keys.protocolParams] as Map)
            : const {},
      );

  @override
  String toString() => 'SubjectInterface($protocol)';
}

class _SubjectInterfaceKeys {
  _SubjectInterfaceKeys._();

  final String protocol = 'protocol';
  final String inputSchema = 'input_schema';
  final String outputSchema = 'output_schema';
  final String supportsStreaming = 'supports_streaming';
  final String supportsToolUse = 'supports_tool_use';
  final String protocolParams = 'protocol_params';

  List<String> get all => [
        protocol,
        inputSchema,
        outputSchema,
        supportsStreaming,
        supportsToolUse,
        protocolParams
      ];
  Set<String> get required => {protocol, inputSchema};
}
