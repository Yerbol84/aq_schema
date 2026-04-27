// pkgs/aq_schema/lib/server/routing/aq_route.dart
//
// Описание маршрута — метод + путь + handler + опциональные middleware.
//
// ── Сценарии использования ───────────────────────────────────────────────────
//
// СЦЕНАРИЙ 1: Простые маршруты через фабрики
//
//   AqRoute.get('/health', healthHandler)
//   AqRoute.post('/runs', startRunHandler)
//   AqRoute.get('/runs/:id', getRunHandler)
//   AqRoute.delete('/runs/:id', cancelRunHandler)
//
// СЦЕНАРИЙ 2: Маршрут с route-level middleware (применяется только к этому маршруту)
//
//   AqRoute.post(
//     '/admin/users',
//     createUserHandler,
//     middleware: [requireAdminMiddleware],
//   )
//
// СЦЕНАРИЙ 3: Группировка маршрутов
//
//   final runsRoutes = [
//     AqRoute.get('/runs', listRunsHandler),
//     AqRoute.post('/runs', startRunHandler),
//     AqRoute.get('/runs/:id', getRunHandler),
//     AqRoute.post('/runs/:id/resume', resumeRunHandler),
//     AqRoute.delete('/runs/:id', cancelRunHandler),
//   ];
//
//   IAQServerApp.instance.addRoutes(runsRoutes);

import 'aq_handler.dart';
import '../transport/aq_request.dart';

/// Описание HTTP маршрута.
class AqRoute {
  /// HTTP метод.
  final AqHttpMethod method;

  /// Шаблон пути. Поддерживает параметры: '/runs/:id', '/users/:userId/projects/:projectId'
  final String path;

  /// Обработчик запроса.
  final AqHandler handler;

  /// Middleware применяемые только к этому маршруту (после глобальных).
  final List<AqMiddleware> middleware;

  const AqRoute({
    required this.method,
    required this.path,
    required this.handler,
    this.middleware = const [],
  });

  // ── Фабрики ───────────────────────────────────────────────────────────────

  factory AqRoute.get(
    String path,
    AqHandler handler, {
    List<AqMiddleware> middleware = const [],
  }) =>
      AqRoute(
        method: AqHttpMethod.get,
        path: path,
        handler: handler,
        middleware: middleware,
      );

  factory AqRoute.post(
    String path,
    AqHandler handler, {
    List<AqMiddleware> middleware = const [],
  }) =>
      AqRoute(
        method: AqHttpMethod.post,
        path: path,
        handler: handler,
        middleware: middleware,
      );

  factory AqRoute.put(
    String path,
    AqHandler handler, {
    List<AqMiddleware> middleware = const [],
  }) =>
      AqRoute(
        method: AqHttpMethod.put,
        path: path,
        handler: handler,
        middleware: middleware,
      );

  factory AqRoute.patch(
    String path,
    AqHandler handler, {
    List<AqMiddleware> middleware = const [],
  }) =>
      AqRoute(
        method: AqHttpMethod.patch,
        path: path,
        handler: handler,
        middleware: middleware,
      );

  factory AqRoute.delete(
    String path,
    AqHandler handler, {
    List<AqMiddleware> middleware = const [],
  }) =>
      AqRoute(
        method: AqHttpMethod.delete,
        path: path,
        handler: handler,
        middleware: middleware,
      );

  @override
  String toString() => 'AqRoute(${method.name.toUpperCase()} $path)';
}
