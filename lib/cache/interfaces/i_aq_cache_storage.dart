import '../models/cache_entry.dart';

/// Хранилище кэша. Экранировано от механики кэша.
///
/// Из коробки: InMemoryCacheStorage (в пакете aq_cache).
/// Клиент может реализовать свой: Redis, SQLite, Hive, etc.
abstract interface class IAQCacheStorage {
  Future<CacheEntry?> get(String key);
  Future<void> set(String key, CacheEntry entry);
  Future<void> delete(String key);
  Future<void> clear();
  Future<List<String>> keys();

  /// true = хранилище само управляет истечением записей (Redis EXPIRE, Hive TTL и т.д.)
  /// false = AQCacheImpl запустит eviction timer.
  bool get supportsNativeTtl => false;
}
