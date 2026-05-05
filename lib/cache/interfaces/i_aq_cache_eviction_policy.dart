import '../models/cache_entry.dart';

/// Стратегия очистки кэша.
///
/// Из коробки: TtlEvictionPolicy (в пакете aq_cache).
/// Передаётся при инициализации кэша — необязательно.
abstract interface class IAQCacheEvictionPolicy {
  /// true = запись должна быть удалена.
  bool shouldEvict(CacheEntry entry);

  /// Интервал между проверками.
  Duration get checkInterval;
}
