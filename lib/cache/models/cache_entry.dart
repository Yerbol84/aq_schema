/// Обёртка значения в кэше с метаданными.
final class CacheEntry {
  final String key;
  final Object value;
  final DateTime createdAt;
  DateTime expiresAt;

  CacheEntry({
    required this.key,
    required this.value,
    required this.createdAt,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  CacheEntry copyWithExtendedTtl(Duration ttl) => CacheEntry(
        key: key,
        value: value,
        createdAt: createdAt,
        expiresAt: DateTime.now().add(ttl),
      );
}
