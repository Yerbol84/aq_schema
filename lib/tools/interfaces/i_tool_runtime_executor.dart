// aq_schema/lib/tools/interfaces/i_tool_runtime_executor.dart
//
// Порт выполнения Tool по контракту.
// Инициализация: IToolRuntimeExecutor.initialize(ToolRuntime(sandboxProvider));

import '../models/tool_contract.dart';
import '../models/tool_input.dart';
import '../models/tool_output.dart';

/// Выполнение Tool по контракту.
abstract interface class IToolRuntimeExecutor {
  static IToolRuntimeExecutor? _instance;

  static IToolRuntimeExecutor get instance {
    assert(_instance != null, 'IToolRuntimeExecutor not initialized. '
        'Call IToolRuntimeExecutor.initialize() in main().');
    return _instance!;
  }

  static void initialize(IToolRuntimeExecutor impl) => _instance = impl;
  static void reset() => _instance = null;

  Future<ToolOutput> execute(ToolContract contract, ToolInput input);
}
