// aq_schema/lib/tools/interfaces/i_aq_tool_registry_simple.dart

import '../models/tool_contract.dart';
import '../models/tool_record.dart';
import '../models/tool_ref.dart';
import '../../core/aq_platform_context.dart';

/// Упрощённый реестр инструментов.
abstract interface class IAQToolRegistrySimple {
  static IAQToolRegistrySimple? _instance;

  static IAQToolRegistrySimple get instance =>
      AQPlatformContext.current?.toolRegistry ??
      _instance ??
      (throw AssertionError('IAQToolRegistrySimple not initialized.'));

  static void initialize(IAQToolRegistrySimple impl) => _instance = impl;
  static void reset() => _instance = null;

  Future<void> register(ToolRecord record);
  Future<ToolContract> resolve(ToolRef ref);
  Future<List<ToolRecord>> list({String? namespace});
}
