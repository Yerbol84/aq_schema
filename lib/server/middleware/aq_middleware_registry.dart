// pkgs/aq_schema/lib/server/middleware/aq_middleware_registry.dart
//
// Реестр middleware — центральное место регистрации для всех слоёв платформы.
//
// ── Назначение ───────────────────────────────────────────────────────────────
//
// AqMiddlewareRegistry позволяет каждому пакету зарегистрировать свой middleware
// при инициализации — без явной передачи в приложение.
//
// Приложение при старте читает реестр и применяет все middleware
// в порядке приоритетов автоматически.
//
// ── Сценарии использования ───────────────────────────────────────────────────
//
// СЦЕНАРИЙ 1: Пакет регистрирует middleware при инициализации
//
//   // Внутри IAuthClient.init():
//   AqMiddlewareRegistry.register(
//     _buildJwtMiddleware(secret),
//     name: 'jwt_auth',
//     priority: AqMiddlewarePriority.auth,
//   );
//
// СЦЕНАРИЙ 2: Пакет метрик регистрирует свой middleware
//
//   // Внутри IMetricsService.init():
//   AqMiddlewareRegistry.register(
//     _buildMetricsMiddleware(metricsService),
//     name: 'metrics',
//     priority: AqMiddlewarePriority.metrics,
//   );
//
// СЦЕНАРИЙ 3: Приложение применяет все middleware автоматически
//
//   // Внутри IAQServerApp.start() — вызывается автоматически:
//   final middlewares = AqMiddlewareRegistry.orderedMiddlewares;
//   // middlewares уже отсортированы по приоритету
//
// СЦЕНАРИЙ 4: Отключить конкретный middleware (для тестов или отладки)
//
//   AqMiddlewareRegistry.disable('jwt_auth');
//
// СЦЕНАРИЙ 5: Приложение добавляет свой middleware
//
//   IAQServerApp.instance.addMiddleware(
//     myCustomMiddleware,
//     priority: AqMiddlewarePriority.userDefined,
//   );
//   // Эквивалентно:
//   AqMiddlewareRegistry.register(
//     myCustomMiddleware,
//     name: 'my_custom',
//     priority: AqMiddlewarePriority.userDefined,
//   );

import '../routing/aq_handler.dart';
import 'aq_middleware_priority.dart';

export 'aq_middleware_priority.dart';

/// Запись в реестре middleware.
class AqMiddlewareEntry {
  /// Уникальное имя для идентификации и отключения.
  final String name;

  /// Middleware функция.
  final AqMiddleware middleware;

  /// Приоритет — определяет порядок в pipeline.
  /// Выше = внешнее (выполняется первым).
  final int priority;

  /// Включён ли middleware.
  bool enabled;

  AqMiddlewareEntry({
    required this.name,
    required this.middleware,
    required this.priority,
    this.enabled = true,
  });

  @override
  String toString() =>
      'AqMiddlewareEntry($name, priority: $priority, enabled: $enabled)';
}

/// Реестр middleware платформы AQ.
///
/// Синглтон — доступен глобально через статические методы.
/// Каждый пакет регистрирует свой middleware при инициализации.
/// Сервер читает реестр при старте и применяет все middleware автоматически.
class AqMiddlewareRegistry {
  AqMiddlewareRegistry._();

  static final List<AqMiddlewareEntry> _entries = [];

  // ── Регистрация ───────────────────────────────────────────────────────────

  /// Зарегистрировать middleware.
  ///
  /// [name] — уникальное имя. Повторная регистрация с тем же именем
  ///          заменяет предыдущую запись.
  /// [priority] — порядок в pipeline (см. [AqMiddlewarePriority]).
  /// [enabled] — можно зарегистрировать отключённым и включить позже.
  static void register(
    AqMiddleware middleware, {
    required String name,
    int priority = AqMiddlewarePriority.userDefined,
    bool enabled = true,
  }) {
    // Заменяем если уже есть с таким именем
    _entries.removeWhere((e) => e.name == name);
    _entries.add(AqMiddlewareEntry(
      name: name,
      middleware: middleware,
      priority: priority,
      enabled: enabled,
    ));
  }

  // ── Управление ────────────────────────────────────────────────────────────

  /// Отключить middleware по имени.
  static void disable(String name) {
    final entry = _find(name);
    if (entry != null) entry.enabled = false;
  }

  /// Включить middleware по имени.
  static void enable(String name) {
    final entry = _find(name);
    if (entry != null) entry.enabled = true;
  }

  /// Удалить middleware по имени.
  static void unregister(String name) {
    _entries.removeWhere((e) => e.name == name);
  }

  // ── Чтение ────────────────────────────────────────────────────────────────

  /// Все включённые middleware отсортированные по приоритету (убывание).
  ///
  /// Первый в списке = самый внешний слой (наивысший приоритет).
  static List<AqMiddleware> get orderedMiddlewares => List.unmodifiable(
        (_entries.where((e) => e.enabled).toList()
              ..sort((a, b) => b.priority.compareTo(a.priority)))
            .map((e) => e.middleware)
            .toList(),
      );

  /// Все записи (включая отключённые) — для отладки и инспекции.
  static List<AqMiddlewareEntry> get allEntries =>
      List.unmodifiable(_entries);

  /// Проверить зарегистрирован ли middleware с данным именем.
  static bool isRegistered(String name) =>
      _entries.any((e) => e.name == name);

  // ── Тесты ─────────────────────────────────────────────────────────────────

  /// Очистить реестр. Используется в тестах для изоляции.
  static void resetForTesting() => _entries.clear();

  // ── Внутренние утилиты ────────────────────────────────────────────────────

  static AqMiddlewareEntry? _find(String name) {
    try {
      return _entries.firstWhere((e) => e.name == name);
    } catch (_) {
      return null;
    }
  }
}
