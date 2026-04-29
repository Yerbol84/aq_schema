// aq_schema/lib/tools/interfaces/i_tool_handler_registry.dart
//
// Порт: регистрация и выполнение Tool handlers.
//
// Потребители:
//   aq_mcp — McpRegistrar регистрирует MCP handlers
//   aq_subject_runtime — RestrictedToolExecutor вызывает execute
//
// Реализует:
//   aq_tool_runtime — ToolRuntime
//
// Инициализация (в приложении):
//   IToolHandlerRegistry.initialize(ToolRuntime(sandboxProvider));

import '../models/tool_contract.dart';
import '../models/tool_input.dart';
import '../models/tool_output.dart';
import 'i_tool_handler.dart';

/// Порт регистрации и выполнения Tool handlers.
abstract interface class IToolHandlerRegistry {
  static IToolHandlerRegistry? _instance;

  static IToolHandlerRegistry get instance {
    assert(_instance != null, 'IToolHandlerRegistry not initialized. '
        'Call IToolHandlerRegistry.initialize() in main().');
    return _instance!;
  }

  static void initialize(IToolHandlerRegistry impl) => _instance = impl;
  static void reset() => _instance = null;

  /// Зарегистрировать handler для tool.
  void registerHandler(String toolName, IToolHandler handler);

  /// Выполнить tool по контракту.
  Future<ToolOutput> execute(ToolContract contract, ToolInput input);
}
