// pkgs/aq_schema/lib/server.dart
//
// Набор: HTTP транспортный слой платформы AQ.
//
// ── Что здесь ────────────────────────────────────────────────────────────────
//
//   Транспорт:
//     AqRequest         — входящий HTTP запрос
//     AqResponse        — исходящий HTTP ответ
//     AqRequestContext  — контекст запроса (request + атрибуты middleware)
//     AqHttpMethod      — enum HTTP методов
//
//   Routing:
//     AqHandler         — typedef: Future<AqResponse> Function(AqRequestContext)
//     AqMiddleware      — typedef: AqHandler Function(AqHandler next)
//     AqRoute           — описание маршрута (метод + путь + handler)
//
//   Middleware:
//     AqMiddlewareRegistry — реестр middleware (регистрация + порядок)
//     AqMiddlewarePriority — стандартные приоритеты (errorHandler, auth, metrics...)
//
// ── НЕ здесь ─────────────────────────────────────────────────────────────────
//
//   IAQServerApp, IAQResourceApp — в package:aq_schema/app.dart
//   Реализация (Shelf) — в package:aq_server_app/aq_server_app.dart
//
// ── Использование ────────────────────────────────────────────────────────────
//
//   import 'package:aq_schema/server.dart';
//
//   AqHandler ping = (ctx) async => AqResponse.ok(body: {'status': 'ok'});
//
//   AqMiddleware logging = (next) => (ctx) async {
//     print('→ ${ctx.request.path}');
//     final res = await next(ctx);
//     print('← ${res.statusCode}');
//     return res;
//   };

// Транспорт
export 'server/transport/aq_request.dart';
export 'server/transport/aq_response.dart';
export 'server/transport/aq_request_context.dart';

// Routing
export 'server/routing/aq_handler.dart';
export 'server/routing/aq_route.dart';

// Middleware
export 'server/middleware/aq_middleware_registry.dart';
export 'server/middleware/aq_middleware_priority.dart';
