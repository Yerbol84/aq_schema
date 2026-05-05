// aq_schema/lib/subject/interfaces/i_llm_response_adapter.dart
//
// P-13: Адаптер нормализации ответов LLM провайдеров.
//
// Разные провайдеры возвращают tool_calls в разных форматах.
// Адаптер нормализует raw response → LlmNormalizedResponse.
//
// LlmAgentSource указывает адаптер через поле adapterType.
// LlmAgentExecutor использует адаптер вместо прямого парсинга.

/// Нормализованный tool call из ответа LLM.
final class LlmNormalizedToolCall {
  final String id;
  final String name;
  final Map<String, dynamic> arguments;

  const LlmNormalizedToolCall({
    required this.id,
    required this.name,
    required this.arguments,
  });
}

/// Нормализованный ответ LLM.
final class LlmNormalizedResponse {
  /// Текстовый контент ответа (может быть пустым при tool calls).
  final String content;

  /// Tool calls (пустой список если нет).
  final List<LlmNormalizedToolCall> toolCalls;

  const LlmNormalizedResponse({
    required this.content,
    required this.toolCalls,
  });

  bool get hasToolCalls => toolCalls.isNotEmpty;
}

/// Адаптер нормализации ответа LLM провайдера.
///
/// Реализации:
/// - OpenAiResponseAdapter — OpenAI / OpenAI-compatible format
/// - (будущие) AnthropicResponseAdapter, GeminiResponseAdapter
abstract interface class ILlmResponseAdapter {
  /// Нормализовать raw ответ из ToolOutput.data в LlmNormalizedResponse.
  LlmNormalizedResponse normalize(Map<String, dynamic> data);
}
