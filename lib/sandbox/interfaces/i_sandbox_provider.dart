// aq_schema/lib/sandbox/interfaces/i_sandbox_provider.dart
//
// Провайдер Sandbox — создание и управление.
//
// Принцип Dependency Inversion:
// • aq_schema определяет интерфейс
// • aq_sandbox реализует интерфейс
// • Клиенты зависят от интерфейса

import '../models/sandbox_runtime_type.dart';
import '../models/sandbox_spec.dart';
import 'i_sandbox_handle.dart';
import '../../core/aq_platform_context.dart';

/// Провайдер Sandbox.
abstract interface class ISandboxProvider {
  static ISandboxProvider? _instance;

  static ISandboxProvider get instance =>
      AQPlatformContext.current?.sandboxProvider ??
      _instance ??
      (throw AssertionError('ISandboxProvider not initialized. '
          'Call ISandboxProvider.initialize() or use AQPlatformContext.run().'));

  static void initialize(ISandboxProvider impl) => _instance = impl;
  static void reset() => _instance = null;

  /// Создать Sandbox.
  Future<ISandboxHandle> create(SandboxSpec spec);

  /// Получить существующий Sandbox.
  Future<ISandboxHandle?> get(String sandboxId);

  /// P-03 fix: освободить disposed sandbox из карты (предотвращает memory leak).
  Future<void> release(String sandboxId);

  /// Список доступных runtime типов.
  Future<List<SandboxRuntimeType>> availableRuntimes();
}

