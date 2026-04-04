// pkgs/aq_schema/lib/sandbox/interfaces/i_sandbox_context.dart
//
// РОЛЬ: Среда выполнения актора внутри sandbox.
//
// RunContext — это ISandboxContext.
// Он хранит: переменные состояния (state), логи, ветку выполнения,
// ссылку на sandbox-границу и активную политику.
//
// Аналогия: если ISandbox — это комната (граница),
// то ISandboxContext — это рабочий стол внутри неё:
// на нём лежат все инструменты и материалы текущей работы.

import 'i_sandbox.dart';
import '../policy/sandbox_policy.dart';

abstract interface class ISandboxContext {
  // ── Привязка к sandbox ──────────────────────────────────────────────

  /// Sandbox в котором выполняется этот контекст.
  /// Через него — политика, события, иерархия.
  ISandbox get sandbox;

  /// Активная политика. Если sandbox.is ISandboxAsEnvironment →
  /// берёт effectivePolicy (пересечение с родителем).
  /// Иначе → sandbox.policy напрямую.
  SandboxPolicy get activePolicy;

  // ── Состояние выполнения ────────────────────────────────────────────

  /// Переменные текущего выполнения (runtime state).
  /// Заполняется по ходу выполнения шагов агента.
  /// Ключи — имена переменных, значения — любые Dart-объекты.
  Map<String, dynamic> get state;

  /// Читать переменную по имени. Поддерживает dot-notation: 'result.field'.
  dynamic getVar(String name);

  /// Записать переменную.
  void setVar(String key, dynamic value);

  // ── Идентификация ────────────────────────────────────────────────────

  /// ID этого запуска (runId). Совпадает с sandboxId sandbox-а.
  String get runId;

  /// ID проекта в котором выполняется этот контекст.
  String get projectId;

  /// Путь к файлам проекта на диске.
  String get projectPath;

  // ── Ветвление ────────────────────────────────────────────────────────

  /// Текущая ветка выполнения (по умолчанию 'main').
  /// Используется при параллельных ветках workflow.
  String get currentBranch;

  /// Создать клон контекста для новой ветки.
  /// Состояние копируется, sandbox и политика — те же.
  ISandboxContext cloneForBranch(String branchName);

  // ── Логирование ──────────────────────────────────────────────────────

  /// Записать событие в лог. Форвардится в sandbox.events.
  void log(
    String message, {
    required String type,
    required int depth,
    required String branch,
    String? details,
  });
}
