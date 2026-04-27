// pkgs/aq_schema/lib/app/capabilities/i_auth_capable.dart
//
// Capability: приложение требует аутентификации входящих запросов.
//
// ── Семантика ────────────────────────────────────────────────────────────────
//
// IAuthCapable — маркер для серверных приложений которые защищают свои
// эндпоинты через auth middleware.
//
// Слой безопасности при инициализации проверяет этот маркер:
//   - IAQResourceApp всегда implements IAuthCapable
//   - IAQPublicApp НЕ implements IAuthCapable (публичные эндпоинты)
//   - IAQFlutterApp НЕ implements IAuthCapable (клиент, не сервер)
//
// ── Сценарий ─────────────────────────────────────────────────────────────────
//
//   // Внутри IAuthClient.init() для ресурс-сервера:
//   static void _autoRegister(AqMiddleware authMw) {
//     final app = IAQApp.instance;
//     if (app is IMiddlewareCapable && app is IAuthCapable) {
//       // Это защищённый ресурс-сервер — регистрируем auth middleware
//       AqMiddlewareRegistry.register(
//         authMw,
//         name: 'auth',
//         priority: AqMiddlewarePriority.auth,
//       );
//     }
//     // Flutter или публичный сервер — пропускаем
//   }

/// Capability: приложение требует аутентификации входящих запросов.
///
/// Маркерный интерфейс. Реализуется защищёнными серверными приложениями.
/// Слой безопасности использует его чтобы автоматически добавить
/// auth middleware в pipeline.
abstract interface class IAuthCapable {}
