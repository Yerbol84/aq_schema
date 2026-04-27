// pkgs/aq_schema/lib/metrics/i_gauge.dart
//
// Протокол gauge метрики.
// Gauge может расти и убывать — отражает текущее состояние (активные запуски и т.д.).

/// Протокол gauge метрики.
///
/// Примеры использования:
///   gauge.inc()     // активный запуск начался
///   gauge.dec()     // активный запуск завершился
///   gauge.set(42)   // установить конкретное значение
abstract interface class IGauge {
  /// Увеличить gauge на [value] (по умолчанию 1).
  void inc([double value = 1]);

  /// Уменьшить gauge на [value] (по умолчанию 1).
  void dec([double value = 1]);

  /// Установить gauge в конкретное значение.
  void set(double value);

  /// Получить экземпляр gauge с конкретными значениями лейблов.
  IGauge labels(List<String> labelValues);
}
