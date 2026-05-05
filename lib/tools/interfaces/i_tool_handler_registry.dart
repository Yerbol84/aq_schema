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
//   IToolHandlerRegistry.initialize(ToolRuntime());

import '../models/tool_contract.dart';
import '../models/tool_input.dart';
import '../models/tool_output.dart';
import '../../sandbox/models/run_context.dart';
import '../../core/aq_platform_context.dart';
import 'i_tool_handler.dart';

/// Порт регистрации и выполнения Tool handlers.
abstract interface class IToolHandlerRegistry {
  static IToolHandlerRegistry? _instance;

  static IToolHandlerRegistry get instance =>
      AQPlatformContext.current?.toolHandlerRegistry ??
      _instance ??
      (throw AssertionError('IToolHandlerRegistry not initialized.'));

  static void initialize(IToolHandlerRegistry impl) => _instance = impl;
  static void reset() => _instance = null;

  void registerHandler(String toolName, IToolHandler handler);

  Future<ToolOutput> execute(
    ToolContract contract,
    ToolInput input,
    RunContext sessionContext,
  );
}
