// aq_schema/lib/tools/interfaces/i_tool_handler.dart

import '../models/tool_input.dart';
import '../models/tool_output.dart';
import '../../sandbox/models/run_context.dart';

/// Интерфейс для обработчика Tool.
/// Выполняется в изолированном Sandbox.
abstract interface class IToolHandler {
  /// Выполнить Tool в заданном контексте.
  Future<ToolOutput> execute(ToolInput input, RunContext context);
}
