// pkgs/aq_schema/lib/metrics/i_histogram.dart
//
// Протокол гистограммы метрик.
// Гистограмма распределяет наблюдения по бакетам — для измерения длительности.

/// Протокол гистограммы метрик.
///
/// Примеры использования:
///   histogram.observe(1.5)                        // 1.5 секунды
///   histogram.labels(['nodeType']).observe(0.3)   // с лейблами
abstract interface class IHistogram {
  /// Записать наблюдение [value] (обычно в секундах).
  void observe(double value);

  /// Получить экземпляр гистограммы с конкретными значениями лейблов.
  IHistogram labels(List<String> labelValues);
}
