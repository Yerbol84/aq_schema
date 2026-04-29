// aq_schema/lib/sandbox/interfaces/i_fs_context.dart
//
// Файловая система (изолированная).
// Все пути относительны к workDir. Выход за пределы невозможен.

/// Файловая система (изолированная).
abstract interface class IFsContext {
  Future<String> read(String relativePath);
  Future<void> write(String relativePath, String content);
  Future<void> writeBytes(String relativePath, List<int> bytes);
  Future<List<String>> list({String? subDir});
  Future<bool> exists(String relativePath);
  Future<void> delete(String relativePath);
}

