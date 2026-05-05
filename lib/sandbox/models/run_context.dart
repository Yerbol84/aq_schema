// aq_schema/lib/sandbox/models/run_context.dart
//
// Контекст выполнения Tool/Subject.
//
// TD-12: RunContext содержит SandboxResources как поле.
// Сигнатуры IToolHandler.execute(input, context) не меняются.
// Handler обращается к ресурсам через context.sandboxResources.fsWrite и т.д.

import '../interfaces/i_fs_context.dart';
import '../interfaces/i_net_context.dart';
import '../interfaces/i_proc_context.dart';
import '../models/sandbox_policy.dart';
import '../models/sandbox_resources.dart';

/// Контекст выполнения Tool/Subject.
///
/// Содержит метаданные сессии + доступ к ресурсам sandbox.
/// Передаётся в каждый IToolHandler.execute() — единственный параметр контекста.
final class RunContext {
  final String runId;
  final String sandboxId;
  final String sessionId;

  /// Политика sandbox сессии — для chain-of-trust при Subject-as-Tool.
  final SandboxPolicy? policy;

  final Map<String, String> env;

  /// Доступ к физическим ресурсам sandbox (fs, net, proc).
  /// Capability-gated: null если capability не выдана.
  final SandboxResources sandboxResources;

  RunContext({
    required this.runId,
    required this.sandboxId,
    required this.sessionId,
    this.policy,
    this.env = const {},
    SandboxResources? sandboxResources,
  }) : sandboxResources = sandboxResources ?? SandboxResources();

  // ── Удобные геттеры (делегируют к resources) ──────────────────────────────

  /// Обратная совместимость.
  IWritableFsContext? get fs => sandboxResources.fsWrite;
  IReadableFsContext? get fsRead => sandboxResources.fsRead;
  IWritableFsContext? get fsWrite => sandboxResources.fsWrite;
  INetContext? get net => sandboxResources.net;
  IProcContext? get proc => sandboxResources.proc;

  /// Минимальный контекст (без capabilities).
  factory RunContext.minimal({
    required String runId,
    required String sandboxId,
    required String sessionId,
  }) =>
      RunContext(
        runId: runId,
        sandboxId: sandboxId,
        sessionId: sessionId,
      );

  @override
  String toString() => 'RunContext($runId, sandbox: $sandboxId)';
}
