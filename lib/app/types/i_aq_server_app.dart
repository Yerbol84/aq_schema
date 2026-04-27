// pkgs/aq_schema/lib/app/types/i_aq_server_app.dart
//
// Базовый тип серверного приложения.
//
// ── Иерархия ─────────────────────────────────────────────────────────────────
//
//   IAQApp
//     └── IAQServerApp          ← любой HTTP сервер
//           ├── IAQResourceApp  ← защищённый API ресурс
//           └── IAQPublicApp    ← публичный API (без auth)

import '../../server/routing/aq_handler.dart';
import '../../server/routing/aq_route.dart';
import '../../server/middleware/aq_middleware_registry.dart';
import '../capabilities/i_middleware_capable.dart';

/// Базовый тип серверного приложения.
///
/// Реализует [IMiddlewareCapable] — все серверные приложения поддерживают middleware.
abstract interface class IAQServerApp implements IMiddlewareCapable {
  // ── Конфигурация ────────────────────────────────────────────────────────────

  /// Добавить маршрут.
  IAQServerApp addRoute(AqRoute route);

  /// Добавить несколько маршрутов.
  IAQServerApp addRoutes(List<AqRoute> routes);

  /// Добавить middleware вручную (помимо автоматически зарегистрированных).
  ///
  /// Эквивалентно [AqMiddlewareRegistry.register] с [AqMiddlewarePriority.userDefined].
  IAQServerApp addMiddleware(
    AqMiddleware middleware, {
    String? name,
    int priority = AqMiddlewarePriority.userDefined,
  });

  // ── Жизненный цикл ──────────────────────────────────────────────────────────

  /// Запустить сервер.
  ///
  /// Автоматически применяет все middleware из [AqMiddlewareRegistry]
  /// в порядке приоритетов — не нужно добавлять их вручную.
  Future<void> start({
    required int port,
    String host = '0.0.0.0',
  });

  /// Остановить сервер.
  Future<void> stop();

  /// true если сервер запущен.
  bool get isRunning;

  /// Порт на котором запущен сервер.
  int? get port;
}
