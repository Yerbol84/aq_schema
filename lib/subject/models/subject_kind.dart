// aq_schema/lib/subject/models/subject_kind.dart
//
// Типы Subject (испытуемых).
//
// Subject Kind определяет КАК система провизионирует Subject:
// • llmEndpoint — LLM API (OpenAI-compatible)
// • gitRepo — GitHub/GitLab репозиторий
// • dockerImage — Docker образ
// • apiEndpoint — HTTP API
// • promptTemplate — Текстовый шаблон
// • script — Inline код
// • mcpServer — MCP-совместимый сервер
// • aqGraph — AQ Graph воркфлоу
// • wasmModule — WASM-компонент
//
// Система расширяема — новые kinds добавляются через плагины.

/// Тип Subject (испытуемого).
///
/// Определяет как система провизионирует и запускает Subject.
/// Каждый kind имеет свой Provisioner и SessionFactory.
enum SubjectKind {
  /// LLM API endpoint (OpenAI-compatible).
  ///
  /// Source: base_url + api_key_ref + model
  /// Interface: HTTP (OpenAI protocol)
  /// Runtime: InMemory (только HTTP вызовы)
  llmEndpoint('llm_endpoint'),

  /// LLM Agent с tool-use capability.
  ///
  /// Source: provider + model + api_key_ref
  /// Interface: MCP (tool orchestration)
  /// Runtime: InMemory + ToolExecutor
  llmAgent('llm_agent'),

  /// GitHub/GitLab репозиторий с кодом.
  ///
  /// Source: repo_url + branch + entrypoint + build_steps
  /// Interface: stdio или HTTP (после сборки)
  /// Runtime: Docker (для изоляции)
  gitRepo('git_repo'),

  /// Docker образ.
  ///
  /// Source: image:tag + command
  /// Interface: stdio или HTTP
  /// Runtime: Docker
  dockerImage('docker_image'),

  /// Внешний HTTP API.
  ///
  /// Source: base_url + auth
  /// Interface: HTTP
  /// Runtime: InMemory (только HTTP вызовы)
  apiEndpoint('api_endpoint'),

  /// Текстовый prompt шаблон.
  ///
  /// Source: inline_text + variable_schema + llm_ref
  /// Interface: LLM (через llm_endpoint)
  /// Runtime: InMemory
  promptTemplate('prompt_template'),

  /// Inline скрипт (Python, JavaScript, etc).
  ///
  /// Source: source_code + language
  /// Interface: stdio
  /// Runtime: Docker или LocalFS
  script('script'),

  /// MCP-совместимый сервер.
  ///
  /// Source: command или URL
  /// Interface: MCP JSON-RPC
  /// Runtime: LocalFS (stdio) или InMemory (HTTP)
  mcpServer('mcp_server'),

  /// AQ Graph воркфлоу.
  ///
  /// Source: blueprintId + versionId
  /// Interface: AQ GraphEngine protocol
  /// Runtime: GraphEngine (специальный)
  aqGraph('aq_graph'),

  /// WebAssembly компонент.
  ///
  /// Source: .wasm файл или URL
  /// Interface: WASM component interface
  /// Runtime: WASM
  wasmModule('wasm_module');

  /// Строковое представление kind (для JSON).
  final String value;

  const SubjectKind(this.value);

  /// Парсинг из строки.
  ///
  /// Бросает [ArgumentError] если kind неизвестен.
  static SubjectKind parse(String value) {
    return SubjectKind.values.firstWhere(
      (kind) => kind.value == value,
      orElse: () => throw ArgumentError('Unknown SubjectKind: $value'),
    );
  }

  @override
  String toString() => value;
}
