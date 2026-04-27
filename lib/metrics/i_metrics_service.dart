// pkgs/aq_schema/lib/metrics/i_metrics_service.dart
//
// Протокол-фасад сервиса метрик — единственная точка входа.
//
// ── Архитектура ──────────────────────────────────────────────────────────────
//
//   Уровень 1 — примитивы:   ICounter, IGauge, IHistogram, ISummary
//   Уровень 2 — инструменты: ITimer (обёртка над IHistogram)
//   Уровень 3 — сервис:      IMetricsService (фабрика + синглтон)
//
// ── Синглтон ─────────────────────────────────────────────────────────────────
//
// Клиент всегда работает только через IMetricsService.instance.
// Паттерн аналогичен Vault.instance в data layer.
//
//   До init()  → instance = NoopMetricsService (безопасно, ничего не падает)
//   После init() → instance = реальная реализация
//
// ── Схема зависимостей ───────────────────────────────────────────────────────
//
//   aq_schema
//     └── IMetricsService (протокол + синглтон + NoopMetricsService)
//
//   aq_metrics
//     └── PrometheusMetricsService implements IMetricsService
//
//   aq_graph_engine, aq_auth_service, etc.
//     └── используют только IMetricsService.instance — не знают про Prometheus
//
// ── Сценарий: инициализация в main() ─────────────────────────────────────────
//
//   import 'package:aq_metrics/aq_metrics.dart';
//
//   void main() async {
//     IMetricsService.init(PrometheusMetricsService(
//       globalAttributes: {'service': 'aq_graph_worker', 'env': 'prod'},
//     ));
//     await PrometheusHttpExporter.start(port: 9090);
//     await GraphWorker().start();
//   }
//
// ── Сценарий: использование в любом классе ───────────────────────────────────
//
//   class AuthService {
//     // Инициализируем инструменты один раз при создании объекта
//     final _logins  = IMetricsService.instance.counter('auth_logins_total');
//     final _latency = IMetricsService.instance.timer('auth_login_duration_seconds');
//
//     Future<AuthResult> login(String user, String pass) async {
//       final t = _latency.start();
//       try {
//         final result = await _doLogin(user, pass);
//         _logins.inc(attributes: {'status': 'ok'});
//         t.stop(attributes: {'status': 'ok'});
//         return result;
//       } catch (e) {
//         _logins.inc(attributes: {'status': 'error'});
//         t.stop(attributes: {'status': 'error'});
//         rethrow;
//       }
//     }
//   }
//
// ── Сценарий: тесты ───────────────────────────────────────────────────────────
//
//   setUp(() => IMetricsService.init(NoopMetricsService.instance));
//   tearDown(() => IMetricsService.resetForTesting());
//
// ── Контракт для реализаций ──────────────────────────────────────────────────
//
// Реализация ДОЛЖНА:
//   - возвращать один и тот же экземпляр для одного и того же name (идемпотентность)
//   - никогда не бросать исключений из фабричных методов
//   - быть потокобезопасной
//
// Реализация МОЖЕТ:
//   - добавлять глобальные атрибуты ко всем метрикам (service=auth, env=prod)
//   - игнорировать buckets/quantiles если бэкенд их не поддерживает

import 'primitives/i_counter.dart';
import 'primitives/i_gauge.dart';
import 'primitives/i_histogram.dart';
import 'primitives/i_summary.dart';
import 'instruments/i_timer.dart';
import 'noop_metrics_service.dart';

export 'primitives/i_counter.dart';
export 'primitives/i_gauge.dart';
export 'primitives/i_histogram.dart';
export 'primitives/i_summary.dart';
export 'instruments/i_timer.dart';

/// Протокол фабрики метрических инструментов.
///
/// Содержит синглтон [instance] — клиент никогда не работает с реализацией напрямую.
abstract interface class IMetricsService {
  // ── Синглтон ────────────────────────────────────────────────────────────────

  static IMetricsService _instance = NoopMetricsService.instance;

  /// Текущий экземпляр сервиса метрик.
  ///
  /// До [init] — [NoopMetricsService] (все вызовы игнорируются, ничего не падает).
  /// После [init] — реальная реализация.
  static IMetricsService get instance => _instance;

  /// Инициализировать с конкретной реализацией.
  ///
  /// Вызывать один раз в main() до старта сервисов.
  /// Повторный вызов заменяет предыдущую реализацию.
  static void init(IMetricsService service) => _instance = service;

  /// Сбросить в [NoopMetricsService]. Используется в тестах для изоляции.
  static void resetForTesting() => _instance = NoopMetricsService.instance;

  /// true если инициализирован реальный сервис (не noop).
  static bool get isInitialized => _instance is! NoopMetricsService;

  // ── Фабричные методы ────────────────────────────────────────────────────────

  /// Создать или получить счётчик.
  ///
  /// Конвенция имени: '<namespace>_<metric>_total'
  /// Примеры: 'graph_runs_total', 'auth_login_attempts_total'
  ICounter counter(String name);

  /// Создать или получить gauge.
  ///
  /// Конвенция имени: '<namespace>_<metric>'
  /// Примеры: 'graph_active_runs', 'worker_queue_size', 'auth_active_sessions'
  IGauge gauge(String name);

  /// Создать или получить гистограмму.
  ///
  /// [buckets] — границы бакетов в единицах метрики.
  ///             Для секунд: [0.005, 0.01, 0.05, 0.1, 0.5, 1, 2, 5, 10, 30]
  ///             Для байт:   [100, 1000, 10000, 100000, 1000000]
  IHistogram histogram(
    String name, {
    List<double> buckets = const [0.005, 0.01, 0.05, 0.1, 0.5, 1, 2, 5, 10, 30],
  });

  /// Создать или получить summary (перцентили на стороне клиента).
  ///
  /// Предпочитай [histogram] если нужна агрегация по нескольким инстансам.
  /// Используй [summary] когда нужны точные перцентили на одном инстансе.
  ISummary summary(
    String name, {
    List<double> quantiles = const [0.5, 0.9, 0.95, 0.99],
  });

  /// Создать или получить таймер — предпочтительный способ измерять длительность.
  ///
  /// Конвенция имени: '<namespace>_<operation>_duration_seconds'
  /// Примеры: 'graph_run_duration_seconds', 'auth_token_validation_duration_seconds'
  ITimer timer(
    String name, {
    List<double> buckets = const [0.005, 0.01, 0.05, 0.1, 0.5, 1, 2, 5, 10, 30],
  });
}
