// pkgs/aq_schema/lib/server/middleware/aq_middleware_priority.dart
//
// Стандартные приоритеты middleware платформы AQ.
//
// ── Семантика приоритетов ─────────────────────────────────────────────────────
//
// Чем ВЫШЕ число — тем ВНЕШНЕЕ слой (выполняется первым на входе, последним на выходе).
// Чем НИЖЕ число — тем БЛИЖЕ к handler.
//
// Визуализация onion:
//
//   Request
//     → [1000 errorHandler]
//       → [900 cors]
//         → [800 logging]
//           → [700 metrics]
//             → [600 tracing]
//               → [500 rateLimit]
//                 → [400 auth]
//                   → [300 authorization]
//                     → [100 userDefined]
//                       → [Handler]
//                     ← [100]
//                   ← [300]
//                 ← [400]
//               ← [500]
//             ← [600]
//           ← [700]
//         ← [800]
//       ← [900]
//     ← [1000]
//   Response
//
// ── Использование ────────────────────────────────────────────────────────────
//
//   AqMiddlewareRegistry.register(
//     myAuthMiddleware,
//     name: 'jwt_auth',
//     priority: AqMiddlewarePriority.auth,
//   );

/// Стандартные приоритеты middleware платформы AQ.
abstract final class AqMiddlewarePriority {
  AqMiddlewarePriority._();

  /// Обработка ошибок — самый внешний слой.
  /// Ловит все необработанные исключения из нижних слоёв.
  static const int errorHandler = 1000;

  /// CORS — должен быть снаружи auth чтобы preflight запросы проходили.
  static const int cors = 900;

  /// Логирование запросов и ответов.
  static const int logging = 800;

  /// Метрики — время ответа, статус коды.
  static const int metrics = 700;

  /// Distributed tracing (OpenTelemetry span).
  static const int tracing = 600;

  /// Rate limiting — до auth чтобы защищать от brute force.
  static const int rateLimit = 500;

  /// Аутентификация — проверка токена, установка identity в контекст.
  static const int auth = 400;

  /// Авторизация — проверка прав доступа к конкретному ресурсу.
  static const int authorization = 300;

  /// Пользовательские middleware — зона для кода приложения.
  static const int userDefined = 100;
}
