import 'i_sandbox.dart';

/// Реестр всех активных sandbox-ов — единственный источник правды для UI.
///
/// Реализует: SandboxRegistryService (в aq_studio, Riverpod provider)
/// Использует: SandboxMonitorWidget — видит ТОЛЬКО этот интерфейс
abstract interface class ISandboxRegistry {
  /// Активные sandbox-ы (не в terminal state)
  List<ISandbox> get activeSandboxes;

  /// Stream изменений — UI строится реактивно
  Stream<List<ISandbox>> get stream;

  /// Зарегистрировать при создании
  void register(ISandbox sandbox);

  /// Снять при dispose
  void unregister(String sandboxId);

  /// Найти по ID (включая children рекурсивно в ISandboxAsEnvironment)
  ISandbox? findById(String sandboxId);
}
