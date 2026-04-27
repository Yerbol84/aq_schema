// pkgs/aq_schema/lib/tools/tool_descriptor.dart
//
// Описание инструмента — используется для передачи LLM схем доступных действий.
// Чистый value-тип — никаких зависимостей кроме Dart primitives.

/// Описание инструмента для передачи в LLM и для интроспекции.
///
/// Движок использует [ToolDescriptor] чтобы сформировать список
/// доступных действий при построении системного промпта.
class ToolDescriptor {
  /// Уникальный идентификатор инструмента.
  /// Используется как ключ при вызове [IToolService.callTool].
  /// Например: 'llm_complete', 'fs_read_file', 'git_commit'.
  final String name;

  /// Человекочитаемое описание что делает инструмент.
  /// Передаётся в LLM как часть системного промпта.
  final String description;

  /// JSON Schema входных параметров инструмента.
  /// Используется LLM для формирования корректных аргументов.
  final Map<String, dynamic> inputSchema;

  const ToolDescriptor({
    required this.name,
    required this.description,
    required this.inputSchema,
  });

  /// Сериализация в Map для передачи в LLM.
  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'input_schema': inputSchema,
      };

  @override
  String toString() => 'ToolDescriptor($name)';
}
