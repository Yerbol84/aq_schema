import 'i_sandbox_item.dart';

/// Событие в потоке sandbox.events.
///
/// Реализует ISandboxItem — события это тоже данные.
/// Конкретные реализации создаются в aq_studio:
///   SandboxLogEvent
///   SandboxStateChangeEvent
///   SandboxPolicyViolationEvent
///   SandboxHandEvent
abstract interface class ISandboxEvent implements ISandboxItem {
  /// ID sandbox из которого пришло событие
  String get sandboxId;

  /// Unix timestamp в миллисекундах
  int get timestamp;

  /// Тип события — строка-токен.
  /// Стандартные: 'log' | 'state_change' | 'policy_violation' |
  ///              'hand_started' | 'hand_completed' | 'disposed'
  String get type;

  /// Серьёзность: 'debug' | 'info' | 'warning' | 'error'
  String get severity;
}
