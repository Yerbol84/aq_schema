// pkgs/aq_schema/lib/sandbox/interfaces/i_sandbox_as_process.dart
//
// РОЛЬ: Изолированная среда для долгоживущих процессов.
//
// БИЗНЕС-СМЫСЛ: Workflow — это "процесс":
// он запускается, живёт долго, проходит через множество узлов,
// накапливает состояние, может быть приостановлен и возобновлён,
// реагирует на внешние события (cancel, pause) и генерирует события
// (step_completed, waiting_for_input). В конце — итоговый результат.
//
// ПРИМЕРЫ В ПРОЕКТЕ:
//   WorkflowRunSandbox  — полный запуск workflow
//   AgentTaskSandbox    — долгоживущая задача агента
//
// КЛЮЧЕВЫЕ СВОЙСТВА:
//   - status: жизненный цикл ('preparing'|'active'|'suspended'|'completed'|'failed')
//   - currentState: текущее состояние (ISandboxItem — типизированный снапшот)
//   - send(event): принять внешнее событие (pause, cancel, inject data)
//   - result: итог (null пока не завершён)
//
// В ОТЛИЧИЕ ОТ FUNCTION:
//   - Живёт долго (минуты, часы)
//   - Имеет observable состояние по ходу работы
//   - Может быть приостановлен и возобновлён
//   - Двусторонний обмен событиями

import 'i_sandbox.dart';
import 'i_sandbox_item.dart';
import 'i_sandbox_event.dart';

abstract interface class ISandboxAsProcess implements ISandbox {
  ISandboxItem get initialState;
  ISandboxItem get currentState;

  /// 'preparing'|'active'|'suspended'|'completed'|'failed'|'disposed'
  String get status;

  Future<void> send(ISandboxEvent event);

  ISandboxItem? get result;
  int? get completedAt;
}

abstract final class SandboxProcessStatus {
  static const String preparing = 'preparing';
  static const String active = 'active';
  static const String suspended = 'suspended';
  static const String completed = 'completed';
  static const String failed = 'failed';
  static const String disposed = 'disposed';

  static bool isTerminal(String s) =>
      s == completed || s == failed || s == disposed;
}
