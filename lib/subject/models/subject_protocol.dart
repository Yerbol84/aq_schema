// aq_schema/lib/subject/models/subject_protocol.dart
//
// Протокол взаимодействия с Subject.
//
// Sealed class — расширяемый + типобезопасный.
// Базовые протоколы встроены, кастомные через CustomProtocol.

/// Протокол взаимодействия с Subject.
///
/// Sealed class для типобезопасности + расширяемости.
sealed class SubjectProtocol {
  const SubjectProtocol();

  /// Строковое представление для JSON.
  String get value;

  /// Парсинг из строки.
  static SubjectProtocol parse(String value) {
    return switch (value) {
      'stdio' => const StdioProtocol(),
      'http' => const HttpProtocol(),
      'mcp' => const McpProtocol(),
      'graph_engine' => const GraphEngineProtocol(),
      'wasm' => const WasmProtocol(),
      'openai_compatible' => const OpenAiCompatibleProtocol(),
      _ => CustomProtocol(value),
    };
  }

  @override
  String toString() => value;
}

/// stdin/stdout протокол.
final class StdioProtocol extends SubjectProtocol {
  const StdioProtocol();
  @override
  String get value => 'stdio';
}

/// HTTP REST API.
final class HttpProtocol extends SubjectProtocol {
  const HttpProtocol();
  @override
  String get value => 'http';
}

/// MCP JSON-RPC.
final class McpProtocol extends SubjectProtocol {
  const McpProtocol();
  @override
  String get value => 'mcp';
}

/// AQ GraphEngine protocol.
final class GraphEngineProtocol extends SubjectProtocol {
  const GraphEngineProtocol();
  @override
  String get value => 'graph_engine';
}

/// WASM component interface.
final class WasmProtocol extends SubjectProtocol {
  const WasmProtocol();
  @override
  String get value => 'wasm';
}

/// OpenAI-compatible HTTP API.
final class OpenAiCompatibleProtocol extends SubjectProtocol {
  const OpenAiCompatibleProtocol();
  @override
  String get value => 'openai_compatible';
}

/// Кастомный протокол (расширяемость).
final class CustomProtocol extends SubjectProtocol {
  @override
  final String value;
  const CustomProtocol(this.value);
}
