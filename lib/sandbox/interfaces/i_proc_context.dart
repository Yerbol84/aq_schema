// aq_schema/lib/sandbox/interfaces/i_proc_context.dart

/// Запуск процессов (ограниченный).
abstract interface class IProcContext {
  Future<ProcResult> run(
    String binary,
    List<String> args, {
    String? workingSubDir,
    Duration? timeout,
    Map<String, String>? extraEnv,
  });
}

final class ProcResult {
  final int exitCode;
  final String stdout;
  final String stderr;
  const ProcResult(this.exitCode, this.stdout, this.stderr);
}
