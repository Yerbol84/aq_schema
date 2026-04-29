// aq_schema/lib/sandbox/models/run_context.dart
//
// Контекст выполнения Tool/Subject.
//
// Содержит только granted capabilities.
// Tool не может сделать то, чего нет в контексте.
//
// Принцип Dependency Inversion:
// • RunContext зависит от интерфейсов (IFsContext, INetContext, etc)
// • Sandbox предоставляет реализации этих интерфейсов
// • Tool использует только интерфейсы

import '../interfaces/i_fs_context.dart';
import '../interfaces/i_net_context.dart';
import '../interfaces/i_proc_context.dart';

/// Контекст выполнения Tool/Subject.
///
/// Содержит только granted capabilities.
/// Nullable поля — capability не granted.
final class RunContext {
  final String runId;
  final String sandboxId;
  final String sessionId;

  // Capability contexts (nullable!)
  final IFsContext? fs; // null если FsReadCap/FsWriteCap не granted
  final INetContext? net; // null если NetOutCap не granted
  final IProcContext? proc; // null если ProcSpawnCap не granted

  // Всегда доступно (через интерфейсы, не прямые зависимости!)
  // TODO: Добавить после создания интерфейсов
  // final IAQVaultClient vault;
  // final IAQToolRuntime tools;

  final Map<String, String> env;

  const RunContext({
    required this.runId,
    required this.sandboxId,
    required this.sessionId,
    this.fs,
    this.net,
    this.proc,
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
