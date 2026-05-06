// aq_schema/lib/cache/interfaces/i_aq_cache_manager.dart
//
// Порт менеджера кэша — управляет статистикой обращений и выбором жертвы при eviction.
// Реализация: aq_cache/lib/src/impl/aq_cache_manager.dart
//
// Счётчики живут только в памяти — сбрасываются при рестарте.
// Это намеренно: не нужна персистентность, нет накладных расходов на запись.
//
// Использование:
//   final manager = AQCacheManager();
//   IAQCache.register('security.decisions', AQCacheImpl(
//     storage: InMemoryCacheStorage(),
//     config: CacheConfig(defaultTtl: Duration(minutes: 5), maxSize: 1000),
//     manager: manager,
//   ));

/// Менеджер кэша — in-memory статистика обращений для LFU eviction.
abstract interface class IAQCacheManager {
  /// Зафиксировать обращение к ключу (cache hit).
  void recordHit(String key);

  /// Зафиксировать промах по ключу (cache miss).
  void recordMiss(String key);

  /// Выбрать ключ для вытеснения из переданного списка.
  ///
  /// Стратегия: LFU — ключ с наименьшим количеством обращений.
  /// При равенстве — ключ с наиболее давним последним обращением (LRU tiebreak).
  /// Если [keys] пуст — возвращает null.
  String? selectEvictionCandidate(List<String> keys);

  /// Удалить статистику для ключа (вызывается при evict/clear).
  void forget(String key);

  /// Сбросить всю статистику (для тестов).
  void reset();

  /// Количество обращений к ключу.
  int hitsFor(String key);
}
