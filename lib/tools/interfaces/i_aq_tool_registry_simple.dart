// aq_schema/lib/tools/interfaces/i_aq_tool_registry_simple.dart

import '../models/tool_contract.dart';
import '../models/tool_record.dart';
import '../models/tool_ref.dart';

/// Упрощённый реестр инструментов.
/// Инициализация: IAQToolRegistrySimple.initialize(ToolRegistryClient());
abstract interface class IAQToolRegistrySimple {
  static IAQToolRegistrySimple? _instance;

  static IAQToolRegistrySimple get instance {
    assert(_instance != null, 'IAQToolRegistrySimple not initialized. '
        'Call IAQToolRegistrySimple.initialize() in main().');
    return _instance!;
  }

  static void initialize(IAQToolRegistrySimple impl) => _instance = impl;
  static void reset() => _instance = null;

  Future<void> register(ToolRecord record);
  Future<ToolContract> resolve(ToolRef ref);
  Future<List<ToolRecord>> list({String? namespace});
}
