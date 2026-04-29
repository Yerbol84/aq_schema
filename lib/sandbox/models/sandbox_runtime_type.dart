// aq_schema/lib/sandbox/models/sandbox_runtime_type.dart

/// Тип Sandbox runtime.
enum SandboxRuntimeType {
  /// Только RAM, нет FS/proc. Для LLM/HTTP инструментов.
  inMemory('in_memory'),

  /// Изолированная папка на хосте. Для файловых операций.
  localFs('local_fs'),

  /// Docker контейнер. Полная изоляция.
  docker('docker'),

  /// MicroVM (Firecracker). Максимальная изоляция.
  vm('vm'),

  /// WebAssembly runtime. Для edge/browser.
  wasm('wasm');

  final String value;
  const SandboxRuntimeType(this.value);

  static SandboxRuntimeType parse(String value) {
    return SandboxRuntimeType.values.firstWhere(
      (t) => t.value == value,
      orElse: () => throw ArgumentError('Unknown SandboxRuntimeType: $value'),
    );
  }

  @override
  String toString() => value;
}
