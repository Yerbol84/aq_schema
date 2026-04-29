// aq_schema/lib/tools/interfaces/clients_protocols/i_tool_admin_protocol.dart
//
// Порт для Admin — управление реестром и runtime инструментов.
//
// Admin использует этот протокол для:
// - установки/удаления пакетов инструментов
// - мониторинга использования и метрик
// - управления circuit breaker
// - blacklist/unblacklist инструментов
//
// ## Потребитель
// Admin UI / CLI — управление платформой инструментов

import '../../models/tool_package_manifest.dart';
import '../../models/tool_ref.dart';
import '../i_aq_tool_registry.dart';
import '../i_aq_tool_runtime.dart';

/// Протокол инструментов для Admin.
///
/// Объединяет административные операции Registry и Runtime
/// в единый интерфейс для Admin-потребителей.
///
/// ```dart
/// // В admin CLI:
/// await IToolAdminProtocol.instance.install(manifest);
/// await IToolAdminProtocol.instance.resetCircuit(ref);
/// ```
abstract interface class IToolAdminProtocol {
  static IToolAdminProtocol? _instance;
  static IToolAdminProtocol get instance {
    assert(_instance != null, 'IToolAdminProtocol not initialized');
    return _instance!;
  }

  static void initialize(IToolAdminProtocol impl) => _instance = impl;
  static void reset() => _instance = null;

  // ── Registry operations ───────────────────────────────────────────────────

  /// Установить пакет инструментов.
  Future<void> install(ToolPackageManifest manifest);

  /// Активировать инструмент.
  Future<void> activate(ToolRef ref);

  /// Деактивировать инструмент (graceful).
  Future<void> deactivate(
    ToolRef ref, {
    Duration gracePeriod = const Duration(seconds: 30),
  });

  /// Удалить инструмент.
  Future<void> uninstall(ToolRef ref);

  /// Заблокировать инструмент.
  Future<void> blacklist(ToolRef ref, {required String reason});

  /// Снять блокировку.
  Future<void> unblacklist(ToolRef ref);

  /// Статистика использования.
  Future<List<ToolUsageStats>> getUsageStats({
    DateTime? from,
    DateTime? to,
  });

  // ── Runtime operations ────────────────────────────────────────────────────

  /// Сбросить circuit breaker в CLOSED.
  Future<void> resetCircuit(ToolRef ref);

  /// Установить политику circuit breaker.
  Future<void> setCircuitPolicy(ToolRef ref, CircuitBreakerPolicy policy);

  /// Метрики по инструментам.
  Future<List<ToolMetrics>> getMetrics({String? namePattern});

  // ── Lifecycle stream ──────────────────────────────────────────────────────

  /// Поток всех lifecycle событий (для мониторинга).
  Stream<ToolLifecycleEvent> get lifecycleEvents;
}
