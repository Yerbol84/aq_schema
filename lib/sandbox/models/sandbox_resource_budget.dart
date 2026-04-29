// aq_schema/lib/sandbox/models/sandbox_resource_budget.dart

/// Лимиты ресурсов для Sandbox.
final class SandboxResourceBudget {
  final int? maxMemoryMb;
  final int? maxCpuPercent;
  final Duration? maxExecutionTime;
  final int? maxDiskMb;

  const SandboxResourceBudget({
    this.maxMemoryMb,
    this.maxCpuPercent,
    this.maxExecutionTime,
    this.maxDiskMb,
  });

  factory SandboxResourceBudget.defaults() => const SandboxResourceBudget(
        maxMemoryMb: 512,
        maxCpuPercent: 50,
        maxExecutionTime: Duration(minutes: 10),
        maxDiskMb: 1024,
      );

  factory SandboxResourceBudget.generous() => const SandboxResourceBudget(
        maxMemoryMb: 2048,
        maxCpuPercent: 100,
        maxExecutionTime: Duration(hours: 1),
        maxDiskMb: 4096,
      );
}
