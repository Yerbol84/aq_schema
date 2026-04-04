// pkgs/aq_schema/lib/sandbox/interfaces/i_sandbox_capable.dart
//
// РОЛЬ: Объявление требований Hand к активной политике.
//
// БИЗНЕС-СМЫСЛ: Каждый Hand знает что ему нужно для работы.
// FsWriteHand не может работать если файловая система закрыта.
// LlmHand не может работать если LLM-вызовы запрещены.
//
// Вместо того чтобы хранить списки флагов (needsFsWrite, needsLlm, ...),
// Hand объявляет ОДИН ключ. InstructionRunner проверяет этот ключ
// в activePolicy перед вызовом execute().
//
// КАК ЭТО РАБОТАЕТ:
//   1. Hand реализует ISandboxCapable и возвращает свой ключ
//   2. InstructionRunner: if (hand is ISandboxCapable)
//   3. policy.permits(hand.requiredCapability) → true/false
//   4. false → emit SandboxPolicyViolationEvent, пропустить шаг
//
// РАСШИРЯЕМОСТЬ:
//   Новая capability = новая константа в SandboxCapabilities +
//   implements ISandboxCapable в нужном Hand.
//   Никаких изменений в SandboxPolicy или ISandboxCapable.

abstract interface class ISandboxCapable {
  /// Ключ capability которую требует этот Hand.
  /// Значения — константы из SandboxCapabilities.
  String get requiredCapability;
}
