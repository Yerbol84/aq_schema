/// Базовый интерфейс типизированной команды data layer.
///
/// Команда = мутирующая операция (create, update, delete, publish...).
/// Каждая конкретная команда — отдельный класс с явными полями.
///
/// ## Правило
/// Нет `Map<String, dynamic>` с ключом `'operation'` в транспорте.
/// Тип команды определяется через [commandName] — ключ в диспетчере.
abstract interface class IVaultCommand {
  /// Уникальное имя команды — ключ в [VaultCommandDispatcher].
  /// Совпадает с именем операции в RPC протоколе.
  String get commandName;

  /// Сериализация для HTTP транспорта.
  Map<String, dynamic> toArgs();
}
