// aq_schema/lib/subject/interfaces/i_quota_service.dart
//
// P-15: Порт quota и rate limiting для Subject Registry.
//
// SubjectRegistryClient.createSession() вызывает checkAndConsume()
// перед созданием sandbox — защита от resource exhaustion.

/// Ресурс для квотирования.
enum QuotaResource {
  /// Активная сессия (Docker контейнер или sandbox).
  concurrentSession,
}

/// Статус квоты namespace.
final class QuotaStatus {
  final String namespace;
  final QuotaResource resource;
  final int used;
  final int limit;

  const QuotaStatus({
    required this.namespace,
    required this.resource,
    required this.used,
    required this.limit,
  });

  bool get isExhausted => used >= limit;
}

/// Исключение при превышении квоты.
class QuotaExceededException implements Exception {
  final String namespace;
  final QuotaResource resource;
  final int limit;

  QuotaExceededException(this.namespace, this.resource, this.limit);

  @override
  String toString() =>
      'QuotaExceededException: $namespace exceeded $resource limit ($limit)';
}

/// Порт quota service.
///
/// Инициализация: IQuotaService.initialize(InMemoryQuotaService());
abstract interface class IQuotaService {
  static IQuotaService? _instance;

  static IQuotaService get instance {
    assert(_instance != null, 'IQuotaService not initialized.');
    return _instance!;
  }

  static void initialize(IQuotaService impl) => _instance = impl;
  static void reset() => _instance = null;
  static bool get isInitialized => _instance != null;

  /// Проверить квоту и потребить единицу ресурса.
  ///
  /// Бросает [QuotaExceededException] если лимит превышен.
  Future<void> checkAndConsume(String namespace, QuotaResource resource);

  /// Освободить единицу ресурса (при dispose сессии).
  Future<void> release(String namespace, QuotaResource resource);

  /// Получить текущий статус квоты.
  Future<QuotaStatus> getStatus(String namespace, QuotaResource resource);
}
