// pkgs/aq_schema/lib/sandbox/interfaces/i_sandbox_actor.dart
//
// РОЛЬ: Исполнитель внутри sandbox.
//
// WorkflowRunner, InstructionRunner, PromptRunner — все акторы.
// Актор получает ISandboxContext от sandbox и производит работу.
//
// Аналогия: если ISandboxContext — это рабочий стол,
// то ISandboxActor — это человек за этим столом.
// Он работает с материалами на столе, следует политике и
// записывает что делает в лог.
//
// Почему "Actor" а не "Runner":
//   "Runner" — техническое слово, привязанное к реализации.
//   "Actor" — роль в системе. Runner реализует Actor, а не наоборот.

import 'i_sandbox_context.dart';

abstract interface class ISandboxActor {
  /// Контекст выполнения этого актора.
  /// Предоставляется sandbox при создании актора.
  ISandboxContext get context;

  /// Запустить работу актора.
  Future<void> run();
}
