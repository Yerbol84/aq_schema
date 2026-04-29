// aq_schema/lib/tools/interfaces/clients_protocols/i_tool_engine_protocol.dart
//
// Порт для Graph Engine — что видит движок при работе с инструментами.
//
// Graph Engine использует инструменты через этот протокол.
// Движок не знает о Registry, Runtime, circuit breaker, sandbox.
// Он знает только: есть ли инструмент, вызвать его, получить результат.
//
// ## Потребитель
// aq_graph_engine — при выполнении ToolCallNode
//
// ## Реализация
// aq_tool_runtime — реализует этот протокол поверх IAQToolRuntime + IAQToolRegistry

import '../../../graph/engine/run_context.dart';
import '../../models/tool_ref.dart';
import '../../models/tool_result.dart';
import '../i_aq_tool_registry.dart';

/// Протокол инструментов для Graph Engine.
///
/// Минимальный интерфейс — только то что нужно движку.
/// Движок не знает о версионировании, circuit breaker, sandbox.
///
/// ```dart
/// // В ToolCallNode:
/// final result = await IToolEngineProtocol.instance.callTool(
///   'llm_complete',
///   {'prompt': prompt},
///   context,
/// );
/// ```
abstract interface class IToolEngineProtocol {
  static IToolEngineProtocol? _instance;
  static IToolEngineProtocol get instance {
    assert(_instance != null, 'IToolEngineProtocol not initialized');
    return _instance!;
  }

  static void initialize(IToolEngineProtocol impl) => _instance = impl;
  static void reset() => _instance = null;

  /// Вызвать инструмент по имени.
  ///
  /// Движок передаёт имя без версии — runtime резолвит актуальную.
  /// Никогда не бросает — ошибки через [ToolResult.failure].
  Future<ToolResult> callTool(
    String name,
    Map<String, dynamic> args,
    RunContext context, {
    String? namespace,
  });

  /// Потоковый вызов для streaming инструментов (LLM и т.д.).
  Stream<ToolResultChunk> callToolStream(
    String name,
    Map<String, dynamic> args,
    RunContext context, {
    String? namespace,
  });

  /// Проверить что инструмент зарегистрирован и доступен.
  ///
  /// Используется движком для валидации графа перед запуском.
  Future<bool> hasTool(String name, {String? namespace});

  /// Список доступных инструментов с их описаниями.
  ///
  /// Используется для формирования LLM tool-use schema.
  Future<List<ToolEngineDescriptor>> getAvailableTools({String? namespace});

  /// Поток событий lifecycle — движок может реагировать на деактивацию.
  Stream<ToolLifecycleEvent> get lifecycleEvents;
}

/// Описание инструмента для Graph Engine (упрощённое, без capabilities).
///
/// Движок передаёт это в LLM для формирования tool-use schema.
final class ToolEngineDescriptor {
  final String name;
  final String? namespace;
  final String description;
  final Map<String, dynamic> inputSchema;
  final Map<String, dynamic> outputSchema;
  final bool isDeprecated;

  const ToolEngineDescriptor({
    required this.name,
    required this.description,
    required this.inputSchema,
    this.namespace,
    this.outputSchema = const {},
    this.isDeprecated = false,
  });

  /// Полный идентификатор для LLM: "aq/llm/llm_complete"
  String get fullName =>
      namespace != null ? '$namespace/$name' : name;

  /// Сериализация для LLM tool-use schema.
  Map<String, dynamic> toLlmSchema() => {
        'name': fullName,
        'description': description,
        'input_schema': inputSchema,
      };

  /// Создать из ToolRef (для обратной совместимости с IToolService).
  factory ToolEngineDescriptor.fromRef(
    ToolRef ref,
    String description,
    Map<String, dynamic> inputSchema,
  ) =>
      ToolEngineDescriptor(
        name: ref.name,
        namespace: ref.namespace,
        description: description,
        inputSchema: inputSchema,
      );
}
