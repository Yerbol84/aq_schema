// pkgs/aq_schema/lib/app/capabilities/i_middleware_capable.dart
//
// Capability: приложение умеет принимать middleware pipeline.
//
// ── Семантика ────────────────────────────────────────────────────────────────
//
// Если IAQApp.instance is IMiddlewareCapable — сервисы при инициализации
// автоматически регистрируют свои middleware через AqMiddlewareRegistry.
//
// Если приложение НЕ реализует IMiddlewareCapable (например Flutter) —
// сервисы пропускают регистрацию middleware.
//
// ── Сценарий: сервис проверяет capability ────────────────────────────────────
//
//   // Внутри IAuthClient.init():
//   static void _autoRegisterMiddleware(AqMiddleware mw) {
//     if (IAQApp.instance is IMiddlewareCapable) {
//       AqMiddlewareRegistry.register(
//         mw,
//         name: 'auth',
//         priority: AqMiddlewarePriority.auth,
//       );
//     }
//     // Если не IMiddlewareCapable — молча пропускаем
//   }

import '../../server/middleware/aq_middleware_registry.dart';

/// Capability: приложение поддерживает middleware pipeline.
///
/// Реализуется серверными приложениями (IAQResourceApp, IAQPublicApp).
/// НЕ реализуется клиентскими приложениями (IAQFlutterApp, IAQCLIApp).
abstract interface class IMiddlewareCapable {
  /// Реестр middleware этого приложения.
  AqMiddlewareRegistry get middlewareRegistry;
}
