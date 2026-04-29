// aq_schema/lib/sandbox/models/sandbox_spec.dart

import 'sandbox_policy.dart';
import 'sandbox_runtime_type.dart';

/// Спецификация создания Sandbox.
final class SandboxSpec {
  final SandboxRuntimeType runtime;
  final SandboxPolicy policy;

  /// Если задан — Sandbox использует этот workDir вместо создания нового.
  /// Используется когда tool должен работать в том же workDir что и агент.
  final String? workDirOverride;

  const SandboxSpec({
    required this.runtime,
    required this.policy,
    this.workDirOverride,
  });
}
