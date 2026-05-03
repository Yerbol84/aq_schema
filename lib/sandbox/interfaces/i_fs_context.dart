// aq_schema/lib/sandbox/interfaces/i_fs_context.dart
//
// S-05 fix: разделение Read/Write контекстов файловой системы.
//
// Было: IFsContext с обоими методами — FsReadCap не блокировал write().
// Стало: IReadableFsContext (только чтение) и IWritableFsContext (чтение + запись).
//
// RunContext предоставляет:
//   fsRead  — если выдан FsReadCap или FsWriteCap
//   fsWrite — только если выдан FsWriteCap

/// Контекст файловой системы — только чтение.
///
/// Выдаётся при наличии FsReadCap или FsWriteCap.
abstract interface class IReadableFsContext {
  Future<String> read(String relativePath);
  Future<List<String>> list({String? subDir});
  Future<bool> exists(String relativePath);
}

/// Контекст файловой системы — чтение и запись.
///
/// Выдаётся только при наличии FsWriteCap.
/// Расширяет IReadableFsContext — write implies read.
abstract interface class IWritableFsContext implements IReadableFsContext {
  Future<void> write(String relativePath, String content);
  Future<void> writeBytes(String relativePath, List<int> bytes);
  Future<void> delete(String relativePath);
}

/// Обратная совместимость — IFsContext как псевдоним IWritableFsContext.
///
/// Существующий код использующий IFsContext продолжает работать.
/// Новый код должен использовать IReadableFsContext или IWritableFsContext.
typedef IFsContext = IWritableFsContext;
