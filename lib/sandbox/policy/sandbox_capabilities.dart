/// Реестр известных ключей capability.
///
/// Строки-токены. Не enum — чтобы можно было расширять
/// не изменяя базовых файлов.
///
/// Добавление новой capability:
///   1. Добавить константу здесь
///   2. Добавить в list all
///   3. Добавить в нужные пресеты SandboxPolicy
///   4. Реализовать ISandboxCapable в нужных Hands
abstract final class SandboxCapabilities {
  // ── Файловая система ─────────────────────────────────────────────────
  static const String fsRead = 'fs.read';
  static const String fsWrite = 'fs.write';

  // ── Сеть ─────────────────────────────────────────────────────────────
  static const String network = 'network';

  // ── Модели ───────────────────────────────────────────────────────────
  static const String llm = 'llm';

  // ── MCP инструменты ──────────────────────────────────────────────────
  static const String mcp = 'mcp';

  // ── Выполнение кода ──────────────────────────────────────────────────
  static const String process = 'process';

  // ── Системные операции (builder, CRUD blueprints) ────────────────────
  static const String system = 'system';

  /// Все стандартные ключи. Используется в пресетах SandboxPolicy.
  static const List<String> all = [
    fsRead,
    fsWrite,
    network,
    llm,
    mcp,
    process,
    system,
  ];
}
