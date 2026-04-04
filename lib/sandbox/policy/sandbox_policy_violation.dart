import 'package:meta/meta.dart';

/// Нарушение политики sandbox.
/// Бросается InstructionRunner когда ISandboxCapable Hand
/// требует capability которая не разрешена в activePolicy.
@immutable
final class SandboxPolicyViolation implements Exception {
  const SandboxPolicyViolation({
    required this.sandboxId,
    required this.handId,
    required this.requiredCapability,
  });

  final String sandboxId;
  final String handId;
  final String requiredCapability;

  @override
  String toString() => 'SandboxPolicyViolation: hand "$handId" requires '
      '"$requiredCapability" which is not permitted in sandbox "$sandboxId"';
}
