// aq_schema/lib/subject.dart
//
// Subject domain — абстракции для испытуемых (Agents, Workflows, Services).
//
// Subject — это высокоуровневая сущность которая:
// • Декларирует зависимости от Tools
// • Версионируется (VersionedStorable)
// • Может стать Tool (exposeAsTool: true)
// • Выполняется в Sandbox
//
// Использование:
//   import 'package:aq_schema/subject.dart';
//
// Реализация (в aq_subject_registry):
//   import 'package:aq_schema/subject.dart';
//   class SubjectRegistryClient implements IAQSubjectRegistry { ... }

// ── Модели ────────────────────────────────────────────────────────────────────
export 'subject/models/subject_ref.dart';
export 'subject/models/subject_record.dart';
export 'subject/models/subject_descriptor.dart';
export 'subject/models/subject_metadata.dart';
export 'subject/models/subject_spec.dart';
export 'subject/models/subject_kind.dart';
export 'subject/models/subject_protocol.dart';
export 'subject/models/subject_source.dart';
export 'subject/models/subject_interface.dart';
export 'subject/models/subject_runtime.dart';
export 'subject/models/subject_capabilities.dart';
export 'subject/models/subject_input.dart';
export 'subject/models/subject_output.dart';
export 'subject/models/subject_dependency_graph.dart';
export 'subject/models/subject_health.dart';

// ── Интерфейсы ────────────────────────────────────────────────────────────────
export 'subject/interfaces/i_subject_session.dart';
export 'subject/interfaces/i_aq_subject_registry.dart';
export 'subject/interfaces/i_tool_executor.dart';
export 'subject/interfaces/i_subject_session_factory.dart';
export 'subject/interfaces/i_subject_repository.dart';
export 'subject/interfaces/i_subject_session_repository.dart';
export 'subject/interfaces/i_subject_executor.dart';
export 'subject/interfaces/i_llm_response_adapter.dart';
export 'subject/interfaces/i_quota_service.dart';
export 'subject/interfaces/i_subject_tool_pool_manager.dart';
