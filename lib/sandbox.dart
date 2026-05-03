// aq_schema/lib/sandbox.dart
//
// Sandbox domain — изоляция и ограничения выполнения.
//
// Sandbox — это контекст выполнения который:
// • Enforce capabilities (что разрешено делать)
// • Ограничивает ресурсы (CPU, RAM, disk, time)
// • Audit log (что было сделано)
// • Cleanup после выполнения
//
// Принцип: Subject/Tool не знают о Sandbox.
// Они работают через RunContext. Sandbox предоставляет этот контекст.
//
// Использование:
//   import 'package:aq_schema/sandbox.dart';
//
// Реализация (в aq_sandbox):
//   import 'package:aq_schema/sandbox.dart';
//   class SandboxClient implements ISandboxProvider { ... }

// ── Модели ────────────────────────────────────────────────────────────────────
export 'sandbox/models/sandbox_runtime_type.dart';
export 'sandbox/models/sandbox_policy.dart';
export 'sandbox/models/sandbox_spec.dart';
export 'sandbox/models/sandbox_resource_budget.dart';
export 'sandbox/models/sandbox_network_policy.dart';
export 'sandbox/models/sandbox_disposal_spec.dart';
export 'sandbox/models/run_context.dart';

// ── Интерфейсы ────────────────────────────────────────────────────────────────
export 'sandbox/interfaces/i_fs_context.dart';
export 'sandbox/interfaces/i_net_context.dart';
export 'sandbox/interfaces/i_proc_context.dart';
export 'sandbox/interfaces/i_sandbox_provider.dart';
export 'sandbox/interfaces/i_sandbox_handle.dart';

// ── Capability matching ───────────────────────────────────────────────────────
export 'sandbox/capability_matcher.dart';
