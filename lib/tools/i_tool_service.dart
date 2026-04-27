// pkgs/aq_schema/lib/tools/i_tool_service.dart
//
// Протокол-интерфейс для сервиса инструментов.
// Это единственное что нужно знать графовому движку о тулсах.
//
// КОНТРАКТ (этот файл) — живёт в aq_schema.
// РЕАЛИЗАЦИЯ — живёт в aq_tool_service (AQToolServiceImpl implements IToolService).
//
// Движок получает IToolService снаружи (dependency injection)
// и не знает ничего о том как он реализован.

import '../graph/engine/run_context.dart';
import 'tool_call_result.dart';
import 'tool_descriptor.dart';

/// Протокол сервиса инструментов для графового движка.
///
/// Движок использует только этот интерфейс — никаких деталей реализации.
/// Конкретные реализации (AQToolServiceImpl, MockToolService и т.д.)
/// живут в пакете aq_tool_service и реализуют этот интерфейс.
abstract interface class IToolService {
  /// Вызвать инструмент по имени.
  ///
  /// [name] — идентификатор инструмента (например: 'llm_complete', 'fs_read_file')
  /// [args] — аргументы вызова
  /// [context] — контекст текущего выполнения графа
  ///
  /// Никогда не бросает исключение — ошибки возвращаются через [ToolCallResult.failure].
  Future<ToolCallResult> callTool(
    String name,
    Map<String, dynamic> args,
    RunContext context,
  );

  /// Проверить что инструмент зарегистрирован.
  ///
  /// Используется движком для валидации графа перед запуском.
  bool hasTool(String name);

  /// Список доступных инструментов.
  ///
  /// Используется для передачи LLM схем доступных действий
  /// при построении системного промпта.
  List<ToolDescriptor> get availableTools;
}
