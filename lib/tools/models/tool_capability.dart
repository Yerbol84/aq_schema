// aq_schema/lib/tools/models/tool_capability.dart
//
// Capability-based модель разрешений инструмента.
// Вдохновение: Deno --allow-net, Android permissions, WASM Component Model.
//
// Инструмент декларирует что ему нужно — система решает что предоставить.

/// Базовый тип capability — что инструмент хочет делать.
///
/// sealed — все подтипы известны на этапе компиляции.
/// Используется в [ToolContract.requiredCaps] и [ToolContract.optionalCaps].
sealed class ToolCapability {
  const ToolCapability();
}

/// Исходящий сетевой доступ.
///
/// [hostPattern]: "api.anthropic.com", "*.github.com", "*"
/// [port]: null = любой порт
final class NetOutCap extends ToolCapability {
  final String hostPattern;
  final int? port;

  const NetOutCap(this.hostPattern, {this.port});

  @override
  String toString() =>
      'NET_OUT:$hostPattern${port != null ? ':$port' : ''}';
}

/// Чтение файловой системы.
///
/// [pathPattern]: "/work/**", "/tmp/aq/${runId}/**"
final class FsReadCap extends ToolCapability {
  final String pathPattern;

  const FsReadCap(this.pathPattern);

  @override
  String toString() => 'FS_READ:$pathPattern';
}

/// Запись в файловую систему.
///
/// [pathPattern]: "/work/**", "vault://**"
final class FsWriteCap extends ToolCapability {
  final String pathPattern;

  const FsWriteCap(this.pathPattern);

  @override
  String toString() => 'FS_WRITE:$pathPattern';
}

/// Запуск дочерних процессов.
///
/// [allowedBinaries]: ["python3", "git", "dart"]
/// [allowShell]: false = нельзя /bin/sh (защита от shell injection)
final class ProcSpawnCap extends ToolCapability {
  final List<String> allowedBinaries;
  final bool allowShell;

  const ProcSpawnCap(this.allowedBinaries, {this.allowShell = false});

  @override
  String toString() => 'PROC_SPAWN:${allowedBinaries.join(',')}';
}

/// Доступ к Docker daemon.
///
/// [allowedImages]: whitelist образов, [] = любой
final class DockerCap extends ToolCapability {
  final List<String> allowedImages;

  const DockerCap(this.allowedImages);

  @override
  String toString() => 'DOCKER:${allowedImages.join(',')}';
}

/// Чтение переменных окружения.
///
/// [allowedKeys]: ["API_KEY", "MODEL_NAME"] — явный whitelist
final class EnvReadCap extends ToolCapability {
  final List<String> allowedKeys;

  const EnvReadCap(this.allowedKeys);

  @override
  String toString() => 'ENV_READ:${allowedKeys.join(',')}';
}
