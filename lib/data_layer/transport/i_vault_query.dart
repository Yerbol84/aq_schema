/// Базовый интерфейс типизированного запроса data layer.
///
/// Запрос = read-only операция (get, list, find...).
/// Результат запроса зависит от конкретной реализации.
abstract interface class IVaultQuery {
  /// Уникальное имя запроса — ключ в [VaultCommandDispatcher].
  String get queryName;

  /// Сериализация для HTTP транспорта.
  Map<String, dynamic> toArgs();
}
