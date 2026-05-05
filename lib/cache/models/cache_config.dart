/// Настройки кэша. Применяются если модель не указала своё значение.
final class CacheConfig {
  /// TTL по умолчанию если модель вернула cacheTtl == null.
  final Duration defaultTtl;

  /// Максимальное количество записей. null = без ограничений.
  final int? maxSize;

  /// Отдавать устаревшую запись если handler упал с ошибкой.
  final bool staleOnError;

  const CacheConfig({
    this.defaultTtl = const Duration(minutes: 5),
    this.maxSize,
    this.staleOnError = false,
  });
}
