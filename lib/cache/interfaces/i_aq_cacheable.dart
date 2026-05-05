/// Контракт для моделей, которые могут быть закэшированы.
///
/// Модель сама декларирует свои cache-характеристики.
/// Приоритет TTL: модель → CacheConfig.defaultTtl → дефолт 5 минут.
abstract interface class IAQCacheable {
  /// Уникальный ключ этого экземпляра в кэше.
  /// Пример: 'user:abc123', 'permission:userId:projects:read'
  String get cacheKey;

  /// TTL для этого экземпляра. null = использовать настройки кэша.
  Duration? get cacheTtl;

  /// Отдавать устаревшую запись если handler вернул ошибку.
  /// Переопределяет CacheConfig.staleOnError для этой модели.
  bool get cacheStaleOnError;
}
