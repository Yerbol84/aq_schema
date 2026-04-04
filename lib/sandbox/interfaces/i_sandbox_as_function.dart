// pkgs/aq_schema/lib/sandbox/interfaces/i_sandbox_as_function.dart
//
// РОЛЬ: Изолированная среда для атомарных операций.
//
// БИЗНЕС-СМЫСЛ: Instruction или Prompt — это "функция":
// получает набор входных данных, обрабатывает в изоляции, отдаёт результат.
// Нет долгоживущего состояния. Нет внешних событий по ходу работы.
// Один вход — один выход. Так работает большинство инструкций агента.
//
// ПРИМЕРЫ В ПРОЕКТЕ:
//   InstructionRunSandbox — выполнение одной инструкции
//   PromptRunSandbox      — рендеринг одного промпта
//   TestLabSandbox        — изолированный тест инструкции
//
// КЛЮЧЕВЫЕ СВОЙСТВА:
//   - inputSchema: какие данные принимает (ISandboxSchema для валидации)
//   - outputSchema: какой результат гарантирует
//   - call(input): выполнить, получить результат
//   - Повторный вызов безопасен (нет persistent state)

import 'i_sandbox.dart';
import 'i_sandbox_item.dart';
import 'i_sandbox_schema.dart';

abstract interface class ISandboxAsFunction implements ISandbox {
  ISandboxSchema get inputSchema;
  ISandboxSchema get outputSchema;

  Future<ISandboxItem> call(ISandboxItem input);

  int? get lastCalledAt;
  int? get lastCompletedAt;
}
