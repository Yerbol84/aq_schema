// pkgs/aq_schema/lib/app/types/i_aq_client_app.dart
//
// Типы клиентских приложений.
//
// ── Семантика ────────────────────────────────────────────────────────────────
//
// Клиентские приложения НЕ реализуют IMiddlewareCapable —
// сервисы при инициализации не регистрируют серверные middleware.
//
// IAuthClient.init() видит IAQClientApp и возвращает IUserAuthClient
// (login, logout, refreshToken) вместо IResourceAuthClient (middleware).
//
// ── Сценарий: Flutter main.dart ──────────────────────────────────────────────
//
//   void main() async {
//     IAQApp.init(AqFlutterApp());
//
//     // Auth видит IAQFlutterApp → возвращает IUserAuthClient
//     final auth = IAuthClient.init(FlutterJwtClient(
//       authServiceUrl: 'https://auth.aq.io',
//     ));
//     // auth.login(email, password) — пользовательский flow
//     // auth.refreshToken() — обновление токена
//     // НЕТ middleware — Flutter не сервер
//
//     runApp(MyApp());
//   }

/// Базовый тип клиентского приложения.
///
/// НЕ реализует IMiddlewareCapable — серверные middleware не применяются.
abstract interface class IAQClientApp {}

/// Flutter UI приложение.
abstract interface class IAQFlutterApp implements IAQClientApp {}

/// CLI инструмент.
abstract interface class IAQCLIApp implements IAQClientApp {}
