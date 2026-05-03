// aq_schema/lib/sandbox/models/run_context.dart
//
// Контекст выполнения Tool/Subject.
//
// Содержит только granted capabilities.
// Tool не может сделать то, чего нет в контексте.

import '../interfaces/i_fs_context.dart';
import '../interfaces/i_net_context.dart';
import '../interfaces/i_proc_context.dart';
import '../models/sandbox_policy.dart';

/// Контекст выполнения Tool/Subject.
///
/// Содержит только granted capabilities.
/// Nullable поля — capability не granted.
final class RunContext {
  final String runId;
  final String sandboxId;
  final String sessionId;

  // S-05: разделённые fs контексты.
  // fsRead  — FsReadCap или FsWriteCap granted
  // fsWrite — только FsWriteCap granted
  final IReadableFsContext? fsRead;
  final IWritableFsContext? fsWrite;

  /// Обратная совместимость: fs → fsWrite (полный доступ).
  IWritableFsContext? get fs => fsWrite;

  final INetContext? net;
  final IProcContext? proc;

  /// Политика sandbox сессии — для chain-of-trust при Subject-as-Tool (S-03).
  final SandboxPolicy? policy;

  final Map<String, String> env;

  const RunContext({
    required this.runId,
    required this.sandboxId,
    required this.sessionId,
    this.fsRead,
    this.fsWrite,
    this.net,
    this.proc,
    this.policy,
    this.env = const {},
  });

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
