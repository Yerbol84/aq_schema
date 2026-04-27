// pkgs/aq_schema/lib/metrics/noop_metrics_service.dart
//
// No-op реализация IMetricsService.
//
// ── Назначение ───────────────────────────────────────────────────────────────
//
// Используется по умолчанию когда реальный сервис метрик не подключён:
//   - локальная разработка
//   - тесты (не нужно мокать метрики)
//   - сервисы где метрики не нужны
//
// Все вызовы молча игнорируются. Нулевые аллокации — все объекты синглтоны.
// Движок работает без метрик без каких-либо изменений в коде.
//
// ── Использование ────────────────────────────────────────────────────────────
//
//   // Явно:
//   final metrics = NoopMetricsService.instance;
//
//   // Неявно (GraphEngine использует его по умолчанию):
//   final engine = GraphEngine(tools: myTools);  // metrics не передан → noop

import 'i_metrics_service.dart';
import 'primitives/i_counter.dart';
import 'primitives/i_gauge.dart';
import 'primitives/i_histogram.dart';
import 'primitives/i_summary.dart';
import 'instruments/i_timer.dart';

/// No-op реализация — ничего не пишет, ничего не хранит.
class NoopMetricsService implements IMetricsService {
  const NoopMetricsService();

  static const NoopMetricsService instance = NoopMetricsService();

  @override
  ICounter counter(String name) => const _NoopCounter();

  @override
  IGauge gauge(String name) => const _NoopGauge();

  @override
  IHistogram histogram(
    String name, {
    List<double> buckets = const [0.005, 0.01, 0.05, 0.1, 0.5, 1, 2, 5, 10, 30],
  }) =>
      const _NoopHistogram();

  @override
  ISummary summary(
    String name, {
    List<double> quantiles = const [0.5, 0.9, 0.95, 0.99],
  }) =>
      const _NoopSummary();

  @override
  ITimer timer(
    String name, {
    List<double> buckets = const [0.005, 0.01, 0.05, 0.1, 0.5, 1, 2, 5, 10, 30],
  }) =>
      const _NoopTimer();
}

// ── No-op примитивы ───────────────────────────────────────────────────────────

class _NoopCounter implements ICounter {
  const _NoopCounter();

  @override
  void inc({double value = 1, Map<String, String> attributes = const {}}) {}
}

class _NoopGauge implements IGauge {
  const _NoopGauge();

  @override
  void inc({double value = 1, Map<String, String> attributes = const {}}) {}

  @override
  void dec({double value = 1, Map<String, String> attributes = const {}}) {}

  @override
  void set(double value, {Map<String, String> attributes = const {}}) {}
}

class _NoopHistogram implements IHistogram {
  const _NoopHistogram();

  @override
  void observe(double value, {Map<String, String> attributes = const {}}) {}
}

class _NoopSummary implements ISummary {
  const _NoopSummary();

  @override
  void observe(double value, {Map<String, String> attributes = const {}}) {}
}

// ── No-op инструменты ─────────────────────────────────────────────────────────

class _NoopTimerHandle implements ITimerHandle {
  const _NoopTimerHandle();

  @override
  void stop({Map<String, String> attributes = const {}}) {}
}

class _NoopTimer implements ITimer {
  const _NoopTimer();

  @override
  ITimerHandle start({Map<String, String> attributes = const {}}) =>
      const _NoopTimerHandle();

  @override
  Future<T> measure<T>(
    Future<T> Function() operation, {
    Map<String, String> attributes = const {},
  }) =>
      operation();
}
