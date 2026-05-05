import 'i_aq_cacheable.dart';
import 'i_aq_cache_storage.dart';
import 'i_aq_cache_eviction_policy.dart';
import 'i_aq_cache_validator.dart';
import '../models/cache_config.dart';

/// Универсальный мультитонный кэш платформы AQ.
///
/// Каждый кэш — именованный экземпляр. Один пакет может иметь
/// несколько кэшей с разными настройками:
///
/// ```dart
/// IAQCache.instance('security.tokens')
/// IAQCache.instance('security.permissions')
/// IAQCache.instance('vault.users')
/// ```
///
/// Инициализация в точке сборки приложения:
/// ```dart
/// IAQCache.register('security.tokens', AQCacheImpl(
///   storage: InMemoryCacheStorage(),
///   config: CacheConfig(defaultTtl: Duration(minutes: 15)),
/// ));
/// ```
///
/// Tunnel-запрос (fetch):
/// ```dart
/// final user = await IAQCache.instance('vault.users')
///   .fetch(() => repo.getById('user:123'));
/// ```
abstract interface class IAQCache {
  // ── Мультитон ──────────────────────────────────────────────

  static final Map<String, IAQCache> _instances = {};

  /// Получить именованный экземпляр кэша.
  /// Бросает [StateError] если кэш не зарегистрирован.
  static IAQCache instance(String name) {
    final cache = _instances[name];
    assert(cache != null,
        'IAQCache "$name" not registered. Call IAQCache.register() first.');
    return cache!;
  }

  /// Зарегистрировать именованный кэш.
  static void register(String name, IAQCache cache) {
    _instances[name] = cache;
  }

  /// Удалить именованный кэш.
  static void unregister(String name) => _instances.remove(name);

  /// Сбросить все экземпляры. Используется в тестах.
  static void resetAll() => _instances.clear();

  /// Проверить зарегистрирован ли кэш.
  static bool isRegistered(String name) => _instances.containsKey(name);

  // ── Контракт ───────────────────────────────────────────────

  /// Получить запись из кэша по ключу.
  /// Возвращает null если запись отсутствует или просрочена
  /// (и валидатор не продлил её жизнь).
  Future<T?> get<T extends IAQCacheable>(String key);

  /// Положить значение в кэш.
  /// TTL берётся из value.cacheTtl ?? config.defaultTtl.
  Future<void> put(IAQCacheable value);

  /// Удалить запись из кэша.
  Future<void> evict(String key);

  /// Очистить весь кэш.
  Future<void> clear();

  /// Tunnel-запрос: кэш → валидатор → handler.
  ///
  /// Логика:
  /// 1. Есть свежая запись → возвращаем немедленно, handler не вызывается
  /// 2. Запись просрочена + validator.isValid() == true →
  ///    обновляем TTL, возвращаем без handler (freeze-режим)
  /// 3. Запись просрочена + validator.isValid() == false → вызываем handler
  /// 4. Записи нет → вызываем handler
  /// 5. handler вернул результат → кэшируем и возвращаем
  ///
  /// Ключ для поиска в кэше берётся из результата handler (result.cacheKey).
  /// Если кэш пуст — handler вызывается, ключ берётся из его результата.
  Future<T?> fetch<T extends IAQCacheable>(
    String key,
    Future<T?> Function() handler,
  );

  // ── Конфигурация (read-only) ───────────────────────────────

  CacheConfig get config;
  IAQCacheStorage get storage;
  IAQCacheEvictionPolicy? get evictionPolicy;
  IAQCacheValidator? get validator;
}
