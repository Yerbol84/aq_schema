// pkgs/aq_schema/lib/server/routing/aq_handler.dart
//
// Типы для обработчиков и middleware — сердце routing системы.
//
// ── Паттерн Onion (Middleware Chain) ─────────────────────────────────────────
//
// Middleware оборачивают handler как слои луковицы.
// Каждый middleware получает следующий handler (next) и может:
//   - выполнить код ДО вызова next (pre-processing)
//   - выполнить код ПОСЛЕ вызова next (post-processing)
//   - прервать цепочку вернув ответ без вызова next
//   - модифицировать контекст перед передачей в next
//   - модифицировать ответ от next
//
//   Request → [MW1] → [MW2] → [MW3] → [Handler]
//                                          ↓
//   Response ← [MW1] ← [MW2] ← [MW3] ←───┘
//
// ── Сценарии использования ───────────────────────────────────────────────────
//
// СЦЕНАРИЙ 1: Простой handler
//
//   AqHandler ping = (ctx) async => AqResponse.ok(body: {'status': 'ok'});
//
// СЦЕНАРИЙ 2: Middleware — логирование
//
//   AqMiddleware loggingMiddleware = (next) => (ctx) async {
//     final start = DateTime.now();
//     log.info('→ ${ctx.request.method.name} ${ctx.request.path}');
//     final response = await next(ctx);
//     final ms = DateTime.now().difference(start).inMilliseconds;
//     log.info('← ${response.statusCode} (${ms}ms)');
//     return response;
//   };
//
// СЦЕНАРИЙ 3: Middleware — CORS
//
//   AqMiddleware corsMiddleware = (next) => (ctx) async {
//     // Preflight
//     if (ctx.request.method == AqHttpMethod.options) {
//       return AqResponse.noContent().withHeaders({
//         'access-control-allow-origin': '*',
//         'access-control-allow-methods': 'GET, POST, PUT, DELETE',
//         'access-control-allow-headers': 'Authorization, Content-Type',
//       });
//     }
//     final response = await next(ctx);
//     return response.withHeader('access-control-allow-origin', '*');
//   };
//
// СЦЕНАРИЙ 4: Middleware — обработка ошибок
//
//   AqMiddleware errorHandlerMiddleware = (next) => (ctx) async {
//     try {
//       return await next(ctx);
//     } on NotFoundException catch (e) {
//       return AqResponse.notFound(error: e.message);
//     } on ValidationException catch (e) {
//       return AqResponse.unprocessable(errors: e.errors);
//     } catch (e, stack) {
//       log.severe('Unhandled error', e, stack);
//       return AqResponse.internalError();
//     }
//   };
//
// СЦЕНАРИЙ 5: Middleware от слоя безопасности
//
//   // Слой безопасности возвращает готовый middleware при инициализации:
//   final authMiddleware = IAuthClient.init(JwtAuthClient(secret: jwtSecret));
//
//   // Регистрируем в сервере:
//   IAQServerApp.instance.addMiddleware(authMiddleware);
//
// ── Порядок применения middleware ────────────────────────────────────────────
//
// Middleware применяются в порядке регистрации.
// Первый зарегистрированный — самый внешний слой (выполняется первым и последним).
//
//   .addMiddleware(errorHandler)   ← выполняется первым/последним
//   .addMiddleware(logging)
//   .addMiddleware(metrics)
//   .addMiddleware(auth)           ← выполняется последним перед handler

import '../transport/aq_request_context.dart';
import '../transport/aq_response.dart';

/// Обработчик запроса — основная единица бизнес-логики.
///
/// Получает контекст запроса, возвращает ответ.
typedef AqHandler = Future<AqResponse> Function(AqRequestContext ctx);

/// Middleware — функция высшего порядка оборачивающая handler.
///
/// Принимает следующий handler в цепочке ([next]),
/// возвращает новый handler который может выполнить код до/после [next].
typedef AqMiddleware = AqHandler Function(AqHandler next);
