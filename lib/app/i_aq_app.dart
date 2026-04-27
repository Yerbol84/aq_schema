// pkgs/aq_schema/lib/app/i_aq_app.dart
//
// Корневой синглтон платформы AQ — точка входа для всех сервисов.
//
// ── Центральная идея ─────────────────────────────────────────────────────────
//
// IAQApp.instance — это "паспорт" приложения.
// Каждый сервис при инициализации смотрит на него и адаптирует своё поведение:
//
//   IAQApp.instance is IAQResourceApp  → серверный ресурс, нужны middleware
//   IAQApp.instance is IAQFlutterApp   → Flutter клиент, middleware не нужны
//   IAQApp.instance is IAuthCapable    → нужна auth защита
//   IAQApp.instance is IMetricsCapable → нужны метрики
//
// ── Жизненный цикл ───────────────────────────────────────────────────────────
//
//   1. IAQApp.init(AqResourceServerApp()) — объявляем тип приложения
//   2. IMetricsService.init(...)          — сервис видит тип, адаптируется
//   3. IAuthClient.init(...)              — сервис видит тип, адаптируется
//   4. IAQApp.asServer.addRoutes(...).start() — запускаем
//
// ── Полные сценарии ───────────────────────────────────────────────────────────
//
// СЦЕНАРИЙ 1: Серверный воркер (aq_graph_worker)
//
//   void main() async {
//     IAQApp.init(AqResourceServerApp(port: 8765));
//     // ↑ implements IAQResourceApp, IAQServerApp,
//     //   IMiddlewareCapable, IAuthCapable, IMetricsCapable
//
//     IMetricsService.init(PrometheusMetricsService(
//       globalAttributes: {'service': 'aq_graph_worker'},
//     ));
//     // ↑ видит IMetricsCapable + IMiddlewareCapable
//     // ↑ автоматически регистрирует metricsMiddleware
//
//     IAuthClient.init(JwtResourceClient(secret: env['JWT_SECRET']!));
//     // ↑ видит IAuthCapable + IMiddlewareCapable
//     // ↑ автоматически регистрирует authMiddleware
//     // ↑ возвращает IResourceAuthClient
//
//     IAQApp.asServer
//       .addRoutes(graphWorkerRoutes)
//       .start();
//     // ↑ start() читает AqMiddlewareRegistry
//     // ↑ применяет все middleware автоматически в порядке приоритетов
//   }
//
// СЦЕНАРИЙ 2: Flutter приложение
//
//   void main() async {
//     IAQApp.init(AqFlutterApp());
//     // ↑ implements IAQFlutterApp, IAQClientApp
//     // ↑ НЕ implements IMiddlewareCapable, IAuthCapable
//
//     IAuthClient.init(FlutterJwtClient(authUrl: 'https://auth.aq.io'));
//     // ↑ видит IAQFlutterApp → возвращает IUserAuthClient
//     // ↑ НЕ регистрирует middleware (нет IMiddlewareCapable)
//
//     runApp(MyApp());
//   }
//
// СЦЕНАРИЙ 3: Тесты — минимальная инициализация
//
//   setUp(() {
//     IAQApp.init(_TestApp());  // минимальная реализация
//   });
//   tearDown(() => IAQApp.resetForTesting());

import 'types/i_aq_server_app.dart';
import 'types/i_aq_client_app.dart';
import 'types/i_aq_resource_app.dart';

export 'types/i_aq_server_app.dart';
export 'types/i_aq_resource_app.dart';
export 'types/i_aq_client_app.dart';
export 'capabilities/i_middleware_capable.dart';
export 'capabilities/i_metrics_capable.dart';
export 'capabilities/i_auth_capable.dart';

/// Корневой синглтон платформы AQ.
///
/// Инициализируется один раз в main() — до инициализации любых сервисов.
/// Сервисы читают [instance] чтобы адаптировать своё поведение к типу приложения.
abstract interface class IAQApp {
  // ── Синглтон ────────────────────────────────────────────────────────────────

  static IAQApp? _instance;

  /// Текущий экземпляр приложения.
  ///
  /// Бросает [StateError] если [init] не был вызван.
  static IAQApp get instance {
    if (_instance == null) {
      throw StateError(
        'IAQApp not initialized. '
        'Call IAQApp.init(...) as the very first line in main().',
      );
    }
    return _instance!;
  }

  /// Инициализировать приложение.
  ///
  /// Вызывать ПЕРВЫМ в main() — до инициализации любых сервисов.
  static void init(IAQApp app) => _instance = app;

  /// Сбросить. Используется в тестах.
  static void resetForTesting() => _instance = null;

  /// true если приложение инициализировано.
  static bool get isInitialized => _instance != null;

  // ── Удобные геттеры с приведением типа ──────────────────────────────────────

  /// Получить приложение как серверное.
  ///
  /// Бросает [StateError] если приложение не является серверным.
  static IAQServerApp get asServer {
    final app = instance;
    if (app is IAQServerApp) return app as IAQServerApp;
    throw StateError(
      'IAQApp.instance is not a server app. '
      'Expected IAQServerApp, got ${app.runtimeType}.',
    );
  }

  /// Получить приложение как ресурс-сервер.
  static IAQResourceApp get asResource {
    final app = instance;
    if (app is IAQResourceApp) return app as IAQResourceApp;
    throw StateError(
      'IAQApp.instance is not a resource app. '
      'Expected IAQResourceApp, got ${app.runtimeType}.',
    );
  }

  /// Получить приложение как Flutter клиент.
  static IAQFlutterApp get asFlutter {
    final app = instance;
    if (app is IAQFlutterApp) return app as IAQFlutterApp;
    throw StateError(
      'IAQApp.instance is not a Flutter app. '
      'Expected IAQFlutterApp, got ${app.runtimeType}.',
    );
  }

  // ── Базовые свойства ────────────────────────────────────────────────────────

  /// Имя приложения (для логов и метрик).
  String get appName;

  /// Окружение: 'development', 'staging', 'production'.
  String get environment;

  /// true если production окружение.
  bool get isProduction => environment == 'production';
}
