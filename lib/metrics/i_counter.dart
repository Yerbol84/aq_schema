// pkgs/aq_schema/lib/metrics/i_counter.dart
//
// Протокол счётчика метрик.
// Счётчик только растёт — сбрасывается только при рестарте процесса.

/// Протокол счётчика метрик.
///
/// Примеры использования:
///   counter.inc()                          // +1
///   counter.labels(['projectId']).inc()    // +1 с лейблами
abstract interface class ICounter {
  /// Увеличить счётчик на [value] (по умолчанию 1).
  void inc([double value = 1]);

  /// Получить экземпляр счётчика с конкретными значениями лейблов.
  /// Порядок значений соответствует [labelNames] переданным при создании.
  ICounter labels(List<String> labelValues);
}
