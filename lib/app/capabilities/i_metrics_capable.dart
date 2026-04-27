// pkgs/aq_schema/lib/app/capabilities/i_metrics_capable.dart
//
// Capability: приложение поддерживает сбор метрик.
//
// ── Сценарий ─────────────────────────────────────────────────────────────────
//
//   // Внутри IMetricsService.init():
//   static void _autoRegisterMiddleware(IMetricsService service) {
//     if (IAQApp.instance is IMiddlewareCapable &&
//         IAQApp.instance is IMetricsCapable) {
//       AqMiddlewareRegistry.register(
//         _buildMetricsMiddleware(service),
//         name: 'metrics',
//         priority: AqMiddlewarePriority.metrics,
//       );
//     }
//   }

/// Capability: приложение поддерживает сбор метрик.
///
/// Маркерный интерфейс — реализация не требует дополнительных методов.
/// Сервисы проверяют его наличие чтобы решить регистрировать ли
/// metrics middleware автоматически.
abstract interface class IMetricsCapable {}
