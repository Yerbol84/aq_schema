// aq_schema/lib/tools/interfaces/i_aq_tool_registry.dart
//
// Реестр инструментов — источник истины о том какие инструменты существуют,
// какие их версии доступны, и каков их контракт.
//
// Реестр НЕ исполняет инструменты. Он их знает.
// Исполнение — IAQToolRuntime.
//
// Реализация живёт в пакете aq_tool_registry.

import '../models/tool_contract.dart';
import '../models/tool_package_manifest.dart';
import '../models/tool_ref.dart';

// ── Lifecycle Events ──────────────────────────────────────────────────────────

sealed class ToolLifecycleEvent {
  final ToolRef ref;
  final DateTime timestamp;
  const ToolLifecycleEvent(this.ref, this.timestamp);
}

final class ToolInstalledEvent extends ToolLifecycleEvent {
  const ToolInstalledEvent(super.ref, super.timestamp);
}

final class ToolActivatedEvent extends ToolLifecycleEvent {
  const ToolActivatedEvent(super.ref, super.timestamp);
}

/// Инструмент деактивируется — ждёт завершения активных вызовов.
final class ToolDeactivatingEvent extends ToolLifecycleEvent {
  final int activeCallsCount;
  const ToolDeactivatingEvent(
      super.ref, super.timestamp, this.activeCallsCount);
}

final class ToolDeactivatedEvent extends ToolLifecycleEvent {
  const ToolDeactivatedEvent(super.ref, super.timestamp);
}

final class ToolErrorEvent extends ToolLifecycleEvent {
  final String error;
  const ToolErrorEvent(super.ref, super.timestamp, this.error);
}

// ── Health ────────────────────────────────────────────────────────────────────

enum ToolHealthStatus { healthy, degraded, unavailable, unknown }

// ── IAQToolRegistry ───────────────────────────────────────────────────────────

/// Клиентский интерфейс реестра инструментов.
///
/// Используется движком и воркером для:
/// - резолюции версий по диапазону
/// - получения контракта инструмента
/// - управления lifecycle (install/activate/deactivate)
///
/// ```dart
/// final contract = await IAQToolRegistry.instance.resolve(
///   ToolRef('llm_complete', namespace: 'aq/llm', range: SemVerRange('^2.0.0')),
/// );
/// ```
abstract interface class IAQToolRegistry {
  static IAQToolRegistry? _instance;
  static IAQToolRegistry get instance {
    assert(_instance != null, 'IAQToolRegistry not initialized');
    return _instance!;
  }

  static void initialize(IAQToolRegistry impl) => _instance = impl;
  static void reset() => _instance = null;

  /// Найти лучшую совместимую версию для запрошенного диапазона.
  ///
  /// Бросает [ToolNotFoundException] если инструмент не найден.
  /// Бросает [ToolVersionNotFoundException] если версия не удовлетворяет диапазону.
  Future<ToolContract> resolve(ToolRef ref);

  /// Список всех доступных инструментов.
  Future<List<ToolContract>> listAvailable({
    String? namePattern,
    String? namespace,
    bool includeDeprecated = false,
  });

  /// Установить пакет инструментов (hot-install без перезапуска).
  Future<void> install(ToolPackageManifest manifest);

  /// Активировать установленный инструмент.
  Future<void> activate(ToolRef ref);

  /// Деактивировать без удаления.
  /// Graceful — ждёт завершения активных вызовов до [gracePeriod].
  Future<void> deactivate(
    ToolRef ref, {
    Duration gracePeriod = const Duration(seconds: 30),
  });

  /// Удалить инструмент.
  Future<void> uninstall(ToolRef ref);

  /// Поток событий lifecycle (install, activate, deactivate, error).
  Stream<ToolLifecycleEvent> get lifecycleEvents;

  /// Проверить здоровье конкретного инструмента.
  Future<ToolHealthStatus> checkHealth(ToolRef ref);
}

// ── IAQToolRegistryAdmin ──────────────────────────────────────────────────────

/// Статистика использования инструмента.
final class ToolUsageStats {
  final ToolRef ref;
  final int totalCalls;
  final int failedCalls;
  final Duration avgLatency;
  final DateTime? lastCalledAt;

  const ToolUsageStats({
    required this.ref,
    required this.totalCalls,
    required this.failedCalls,
    required this.avgLatency,
    this.lastCalledAt,
  });
}

/// Административный клиент реестра.
///
/// Управление глобальными настройками, статистикой, blacklist.
/// Используется только Admin-потребителями.
abstract interface class IAQToolRegistryAdmin {
  static IAQToolRegistryAdmin? _instance;
  static IAQToolRegistryAdmin get instance {
    assert(_instance != null, 'IAQToolRegistryAdmin not initialized');
    return _instance!;
  }

  static void initialize(IAQToolRegistryAdmin impl) => _instance = impl;
  static void reset() => _instance = null;

  Future<List<ToolUsageStats>> getUsageStats({
    DateTime? from,
    DateTime? to,
  });

  /// Заблокировать инструмент с указанием причины.
  Future<void> blacklist(ToolRef ref, {required String reason});

  /// Снять блокировку.
  Future<void> unblacklist(ToolRef ref);
}
