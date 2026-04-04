// pkgs/aq_schema/lib/sandbox/policy/sandbox_policy.dart
import 'package:meta/meta.dart';

import 'sandbox_capabilities.dart';

@immutable
final class SandboxPolicy {
  const SandboxPolicy({
    required this.available, // что есть в среде
    required this.allowed, // что разрешено из available
    this.sessionDir,
    this.timeoutMs,
    this.runtimeLevel = 'local',
    this.dryRun = false,
    this.envVars = const {},
  });

  final List<String> available; // infrastructure
  final List<String> allowed; // authorization

  final String? sessionDir; // куда пишутся файлы
  final int? timeoutMs; // лимит времени
  final String runtimeLevel; // 'local'|'process'|'container'|'remote'
  final bool dryRun; // ничего не записывать
  final Map<String, String> envVars;

  // ── Проверка ─────────────────────────────────────────────────────────

  bool permits(String key) =>
      !dryRun && available.contains(key) && allowed.contains(key);

  // ── Пересечение с родителем ───────────────────────────────────────────
  // Дочерний sandbox НИКОГДА не получает больше прав чем родитель.

  SandboxPolicy intersectWith(SandboxPolicy parent) => SandboxPolicy(
        available: available.where(parent.available.contains).toList(),
        allowed: allowed.where(parent.allowed.contains).toList(),
        sessionDir: sessionDir ?? parent.sessionDir,
        timeoutMs: _min(timeoutMs, parent.timeoutMs),
        runtimeLevel: runtimeLevel,
        dryRun: dryRun || parent.dryRun,
        envVars: {...parent.envVars, ...envVars},
      );

  String resolveFilePath(String path) {
    if (sessionDir == null) return path;
    return '$sessionDir${path.split('/').last}';
  }

  // ── Пресеты ───────────────────────────────────────────────────────────

  static const SandboxPolicy unrestricted = SandboxPolicy(
    available: SandboxCapabilities.all,
    allowed: SandboxCapabilities.all,
  );

  static const SandboxPolicy readOnly = SandboxPolicy(
    available: SandboxCapabilities.all,
    allowed: [SandboxCapabilities.fsRead, SandboxCapabilities.llm],
  );

  static SandboxPolicy testLab({required String runId}) => SandboxPolicy(
        available: SandboxCapabilities.all,
        allowed: [
          SandboxCapabilities.fsRead,
          SandboxCapabilities.fsWrite,
          SandboxCapabilities.llm,
        ],
        sessionDir: '/tmp/aq_sandbox/$runId/',
      );

  static const SandboxPolicy forWorkflow = SandboxPolicy(
    available: SandboxCapabilities.all,
    allowed: [
      SandboxCapabilities.fsRead,
      SandboxCapabilities.fsWrite,
      SandboxCapabilities.llm,
      SandboxCapabilities.mcp,
    ],
  );

  static const SandboxPolicy forBuilder = SandboxPolicy(
    available: SandboxCapabilities.all,
    allowed: SandboxCapabilities.all, // Builder доверенный — всё разрешено
  );

  static const SandboxPolicy isolated = SandboxPolicy(
    available: [],
    allowed: [],
    dryRun: true,
  );

  // ── Сериализация ──────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'available': available,
        'allowed': allowed,
        if (sessionDir != null) 'sessionDir': sessionDir,
        if (timeoutMs != null) 'timeoutMs': timeoutMs,
        'runtimeLevel': runtimeLevel,
        'dryRun': dryRun,
      };

  factory SandboxPolicy.fromJson(Map<String, dynamic> j) => SandboxPolicy(
        available: List<String>.from(j['available'] as List? ?? []),
        allowed: List<String>.from(j['allowed'] as List? ?? []),
        sessionDir: j['sessionDir'] as String?,
        timeoutMs: j['timeoutMs'] as int?,
        runtimeLevel: j['runtimeLevel'] as String? ?? 'local',
        dryRun: j['dryRun'] as bool? ?? false,
      );

  static int? _min(int? a, int? b) {
    if (a == null) return b;
    if (b == null) return a;
    return a < b ? a : b;
  }
}
