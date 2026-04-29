// aq_schema/lib/tools/constants/llm_tool_keys.dart
//
// Ключи протокола LLM (OpenAI-compatible API).
// Уровень 2 — используются между пакетами (aq_tool_runtime, aq_subject_runtime).
// Живут в aq_schema потому что это контракт протокола, не деталь реализации.

/// Ключи ToolInput/ToolOutput для LLM tool и agentic loop.
class LlmToolKeys {
  LlmToolKeys._();

  // ── ToolInput ──────────────────────────────────────────────────────────────
  static const String messages = 'messages';
  static const String tools    = 'tools';
  static const String model    = 'model';
  static const String baseUrl  = 'base_url';
  static const String apiKey   = 'api_key';

  // ── ToolOutput.data ────────────────────────────────────────────────────────
  static const String content   = 'content';
  static const String toolCalls = 'tool_calls';

  // ── tool_call объект ───────────────────────────────────────────────────────
  static const String id         = 'id';
  static const String name       = 'name';
  static const String arguments  = 'arguments';
  static const String toolCallId = 'tool_call_id';

  // ── OpenAI request ────────────────────────────────────────────────────────
  static const String stream  = 'stream';
  static const String function = 'function';
  static const String type    = 'type';
  static const String role    = 'role';
  static const String choices = 'choices';
  static const String message = 'message';
  static const String delta   = 'delta';

  // ── Role values ───────────────────────────────────────────────────────────
  static const String roleUser      = 'user';
  static const String roleAssistant = 'assistant';
  static const String roleTool      = 'tool';

  // ── Type values ───────────────────────────────────────────────────────────
  static const String typeFunction = 'function';

  // ── Fallback values ───────────────────────────────────────────────────────
  static const String fallbackOk = 'ok';
}
