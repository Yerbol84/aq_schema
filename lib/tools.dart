// pkgs/aq_schema/lib/tools.dart
//
// Набор: протокол инструментов (tools domain).
//
// Содержит:
// - Модели: ToolRef, ToolContract, ToolCapability, ToolResult
// - Интерфейсы: IAQToolRegistry, IAQToolRuntime
// - Порты для потребителей: IToolEngineProtocol, IToolWorkerProtocol, IToolAdminProtocol
//
// Использование в движке:
//   import 'package:aq_schema/tools.dart';
//   final result = await IToolEngineProtocol.instance.callTool(...);
//
// Реализация (в aq_tool_registry, aq_tool_runtime):
//   import 'package:aq_schema/tools.dart';
//   class ToolRegistryImpl implements IAQToolRegistry { ... }

// ── Старые интерфейсы (обратная совместимость) ────────────────────────────────
export 'tools/i_tool_service.dart';
export 'tools/tool_call_result.dart';
export 'tools/tool_descriptor.dart';

// ── Модели ────────────────────────────────────────────────────────────────────
export 'tools/models/tool_ref.dart';
export 'tools/models/tool_capability.dart';
export 'tools/models/tool_contract.dart';
export 'tools/models/tool_result.dart';
export 'tools/models/tool_package_manifest.dart';
export 'tools/models/tool_input.dart';
export 'tools/models/tool_output.dart';
export 'tools/models/tool_source.dart';
export 'tools/models/tool_input.dart';
export 'tools/models/tool_output.dart';
export 'tools/models/tool_source.dart';
export 'tools/models/json_schema_keys.dart';

// ── Storable модели (для data_layer) ──────────────────────────────────────────
export 'tools/models/tool_record.dart';
export 'tools/models/tool_installation.dart';
export 'tools/models/tool_call_log.dart';

// ── Cross-domain: Subject может стать Tool ────────────────────────────────────
// SubjectRecord экспортируется здесь для использования в ToolRegistry
// при создании Tool-обёрток для Subject (exposeAsTool: true)
export 'subject/models/subject_record.dart' show SubjectRecord;

// ── Интерфейсы реестра и runtime ──────────────────────────────────────────────
export 'tools/interfaces/i_aq_tool_registry.dart';
export 'tools/interfaces/i_aq_tool_registry_simple.dart';
export 'tools/interfaces/i_aq_tool_runtime.dart';
export 'tools/interfaces/i_tool_handler.dart';
export 'tools/interfaces/i_tool_runtime_executor.dart';
export 'tools/interfaces/i_tool_handler_registry.dart';
export 'tools/interfaces/i_tool_executor_factory.dart';
export 'tools/constants/llm_tool_keys.dart';

// ── Порты для потребителей ────────────────────────────────────────────────────
export 'tools/interfaces/clients_protocols/i_tool_engine_protocol.dart';
export 'tools/interfaces/clients_protocols/i_tool_worker_protocol.dart';
export 'tools/interfaces/clients_protocols/i_tool_admin_protocol.dart';
