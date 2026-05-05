// aq_schema/lib/sandbox/interfaces/i_proc_context.dart

import 'i_disposable.dart';

/// Запуск процессов (ограниченный).
abstract interface class IProcContext implements IDisposable {
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
