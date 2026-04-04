// pkgs/aq_schema/lib/sandbox/interfaces/i_sandbox_as_environment.dart
//
// РОЛЬ: Изолированная среда как контейнер других сред.
//
// БИЗНЕС-СМЫСЛ: Project — это "среда разработки":
// внутри него запускаются workflows, работает Builder, выполняются
// тесты. Каждый из них — дочерний sandbox. Проект задаёт
// общую политику ("в этом проекте нельзя делать HTTP-запросы")
// и все дочерние получают не больше прав чем родитель.
//
// ПРИМЕРЫ В ПРОЕКТЕ:
//   ProjectSandbox           — проект как контейнер всего
//   DockerEnvironmentSandbox — Docker контейнер (L2+)
//   RemoteEnvironmentSandbox — удалённая машина пользователя
//
// КЛЮЧЕВЫЕ СВОЙСТВА:
//   - children: активные дочерние sandbox-ы
//   - spawnChild(): породить дочерний, НЕ превышающий политику родителя
//   - effectivePolicy: собственная политика ∩ политика родителей
//   - origin: 'managed'|'user'|'remote'
//
// ПРАВИЛО: ISandboxAsFunction, Process, Chat — ЛИСТОВЫЕ.
// Только ISandboxAsEnvironment может содержать другие sandbox-ы.
// Это предотвращает бесконечную вложенность и архитектурный тупик.

import 'i_sandbox.dart';
import '../policy/sandbox_policy.dart';

abstract interface class ISandboxAsEnvironment implements ISandbox {
  List<ISandbox> get children;

  /// Создать дочерний sandbox.
  /// narrowPolicy — сужение родительской политики.
  /// Если narrowPolicy шире родительской → пересечение (дочерний не получит больше).
  T spawnChild<T extends ISandbox>(ISandboxFactory<T> factory);

  ISandbox? getChild(String sandboxId);

  /// Собственная policy ∩ политики всех родителей в цепочке
  SandboxPolicy get effectivePolicy;

  /// 'managed'|'user'|'remote'
  String get origin;
}

abstract interface class ISandboxFactory<T extends ISandbox> {
  T create({
    required ISandboxAsEnvironment parent,
    required SandboxPolicy narrowPolicy,
  });
}
