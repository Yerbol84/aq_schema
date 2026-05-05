// aq_schema/lib/sandbox/models/sandbox_resources.dart
//
// P-05: Явный владелец живых ресурсов sandbox.
//
// RunContext — value object (метаданные, передаётся по значению).
// SandboxResources — lifecycle object (живые ресурсы, явный dispose).

import '../interfaces/i_fs_context.dart';
import '../interfaces/i_net_context.dart';
import '../interfaces/i_proc_context.dart';
import '../interfaces/i_disposable.dart';

/// Живые ресурсы sandbox сессии.
///
/// Создаётся вместе с [RunContext] через [ISandboxHandle.createContext].
/// Владеет fs/net/proc контекстами — закрывает их при [dispose].
final class SandboxResources {
  final IReadableFsContext? fsRead;
  final IWritableFsContext? fsWrite;
  final INetContext? net;
  final IProcContext? proc;

  final List<IDisposable> _tracked;
  bool _disposed = false;

  SandboxResources({
    this.fsRead,
    this.fsWrite,
    this.net,
    this.proc,
  }) : _tracked = [
          if (fsWrite != null) fsWrite,
          // fsRead может совпадать с fsWrite — не регистрируем дважды
          if (fsRead != null && fsRead != fsWrite) fsRead,
          if (net != null) net,
          if (proc != null) proc,
        ];

  /// Освободить все ресурсы в обратном порядке регистрации.
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    for (final disposable in _tracked.reversed) {
      if (!disposable.isDisposed) await disposable.dispose();
    }
  }

  bool get isDisposed => _disposed;
}
