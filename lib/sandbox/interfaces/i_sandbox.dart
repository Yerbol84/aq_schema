// pkgs/aq_schema/lib/sandbox/interfaces/i_sandbox.dart
//
// РОЛЬ: Граница изолированной среды.
//
// ISandbox — это контейнер. Он не работает сам —
// он определяет границы в которых работают акторы.
//
// Аналогия с Docker:
//   ISandbox = контейнер (граница, политика, ресурсы)
//   ISandboxActor = процесс внутри контейнера
//   ISandboxContext = файловая система + переменные окружения контейнера
//   ISandboxItem = данные передаваемые в/из контейнера

import 'i_sandbox_event.dart';
import '../policy/sandbox_policy.dart';

abstract interface class ISandbox {
  // ── Идентификация ────────────────────────────────────────────────────
  String get sandboxId;
  String get displayName;

  // ── Политика ─────────────────────────────────────────────────────────
  SandboxPolicy get policy;

  // ── Наблюдаемость ────────────────────────────────────────────────────
  /// Hot broadcast stream. Все события из этого sandbox и его детей.
  Stream<ISandboxEvent> get events;

  // ── Жизненный цикл ───────────────────────────────────────────────────
  Future<void> dispose();
}
