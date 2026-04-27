// pkgs/aq_schema/lib/metrics.dart
//
// Набор: протокол сервиса метрик.
//
// ── Что здесь ────────────────────────────────────────────────────────────────
//
//   IMetricsService  — фабрика всех инструментов (единственная точка входа)
//   ICounter         — монотонно растущий счётчик событий
//   IGauge           — текущее значение (может расти и убывать)
//   IHistogram       — распределение значений по бакетам
//   ISummary         — точные перцентили на стороне клиента
//   ITimer           — измерение длительности (обёртка над IHistogram)
//   ITimerHandle     — хэндл активного замера
//   NoopMetricsService — no-op реализация по умолчанию
//
// ── Использование ────────────────────────────────────────────────────────────
//
//   import 'package:aq_schema/metrics.dart';
//
//   // В сервисе:
//   class MyService {
//     MyService(IMetricsService metrics) {
//       _requests = metrics.counter('my_requests_total');
//       _duration = metrics.timer('my_operation_duration_seconds');
//     }
//   }
//
//   // Реализация (в aq_metrics_prometheus):
//   class PrometheusMetricsService implements IMetricsService { ... }
//
//   // Реализация (в aq_metrics_otel):
//   class OtelMetricsService implements IMetricsService { ... }

export 'metrics/i_metrics_service.dart';
export 'metrics/noop_metrics_service.dart';
