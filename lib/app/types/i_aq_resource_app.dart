// pkgs/aq_schema/lib/app/types/i_aq_resource_app.dart
//
// Тип: защищённый API ресурс-сервер.
//
// ── Семантика ────────────────────────────────────────────────────────────────
//
// IAQResourceApp — серверное приложение которое:
//   - защищает свои эндпоинты через auth (implements IAuthCapable)
//   - собирает метрики (implements IMetricsCapable)
//   - поддерживает middleware pipeline (через IAQServerApp → IMiddlewareCapable)
//
// Примеры: aq_graph_worker, aq_studio_data_service, aq_auth_data_service
//
// ── Что происходит при IAQApp.init(AqResourceServerApp()) ────────────────────
//
//   Сервисы при своей инициализации видят IAQResourceApp и автоматически:
//
//   IMetricsService.init(PrometheusMetricsService())
//     → регистрирует metricsMiddleware (priority: 700)
//
//   IAuthClient.init(JwtResourceClient(secret: ...))
//     → регистрирует authMiddleware (priority: 400)
//     → возвращает IResourceAuthClient (не IUserAuthClient)
//
//   IAQServerApp.start() читает AqMiddlewareRegistry и применяет всё автоматически.
//
// ── Сценарий: main.dart воркера ──────────────────────────────────────────────
//
//   void main() async {
//     // 1. Объявляем тип — сервисы адаптируются автоматически
//     IAQApp.init(AqResourceServerApp(port: 8765));
//
//     // 2. Инициализируем сервисы — они сами регистрируют middleware
//     IMetricsService.init(PrometheusMetricsService(...));
//     IAuthClient.init(JwtResourceClient(secret: env['JWT_SECRET']!));
//
//     // 3. Только бизнес-логика
//     IAQApp.asServer
//       .addRoutes(graphWorkerRoutes)
//       .start();
//   }

import '../capabilities/i_auth_capable.dart';
import '../capabilities/i_metrics_capable.dart';
import 'i_aq_server_app.dart';

/// Тип: защищённый API ресурс-сервер.
///
/// Автоматически получает auth и metrics middleware
/// при инициализации соответствующих сервисов.
abstract interface class IAQResourceApp
    implements IAQServerApp, IAuthCapable, IMetricsCapable {}
