// aq_schema/lib/tools/interfaces/i_aq_tool_runtime.dart
//
// Runtime инструментов — маршрутизация вызовов к исполнителям.
//
// Runtime знает КАК доставить вызов. Не знает бизнес-семантику инструментов.
// Registry знает ЧТО существует. Runtime знает КАК вызвать.
//
// Реализация живёт в пакете aq_tool_runtime.

import '../../graph/engine/run_context.dart';
import '../models/tool_ref.dart';
import '../models/tool_result.dart';

// ── Circuit Breaker ───────────────────────────────────────────────────────────

enum CircuitBreakerState {
  /// Нормальная работа.
  closed,

  /// Инструмент недоступен — вызовы отклоняются немедленно.
  open,

  /// Пробный вызов после recovery timeout.
  halfOpen,
}

final class CircuitBreakerStatus {
  final ToolRef ref;
  final CircuitBreakerState state;
  final int failureCount;
  final DateTime? openedAt;
  final DateTime? nextRetryAt;

  const CircuitBreakerStatus({
    required this.ref,
    required this.state,
    required this.failureCount,
    this.openedAt,
    this.nextRetryAt,
  });

  bool get isCallable => state != CircuitBreakerState.open;
}

// ── IAQToolRuntime ────────────────────────────────────────────────────────────

/// Runtime инструментов — маршрутизация и исполнение.
///
/// Используется воркером для вызова инструментов.
/// Содержит circuit breaker — при N ошибках переходит в OPEN.
///
/// ```dart
/// final result = await IAQToolRuntime.instance.call(
///   ToolRef('llm_complete', namespace: 'aq/llm'),
///   {'prompt': 'Hello'},
///   context,
/// );
/// ```
abstract interface class IAQToolRuntime {
  static IAQToolRuntime? _instance;
  static IAQToolRuntime get instance {
    assert(_instance != null, 'IAQToolRuntime not initialized');
    return _instance!;
  }

  static void initialize(IAQToolRuntime impl) => _instance = impl;
  static void reset() => _instance = null;

  /// Вызвать инструмент по ссылке.
  ///
  /// Никогда не бросает — ошибки через [ToolResult.failure].
  /// При OPEN circuit — возвращает failure с errorCode 'CIRCUIT_OPEN'.
  Future<ToolResult> call(
    ToolRef ref,
    Map<String, dynamic> args,
    RunContext context,
  );

  /// Потоковый вызов для long-running инструментов.
  Stream<ToolResultChunk> callStream(
    ToolRef ref,
    Map<String, dynamic> args,
    RunContext context,
  );

  /// Проверить что инструмент технически доступен для вызова.
  Future<bool> isCallable(ToolRef ref);

  /// Статус circuit breaker для инструмента.
  Future<CircuitBreakerStatus> getCircuitStatus(ToolRef ref);
}

// ── IAQToolRuntimeAdmin ───────────────────────────────────────────────────────

/// Политика circuit breaker.
final class CircuitBreakerPolicy {
  /// Количество ошибок до перехода в OPEN.
  final int failureThreshold;

  /// Время до попытки восстановления (HALF_OPEN).
  final Duration recoveryTimeout;

  /// Таймаут одного вызова.
  final Duration callTimeout;

  const CircuitBreakerPolicy({
    this.failureThreshold = 5,
    this.recoveryTimeout = const Duration(seconds: 30),
    this.callTimeout = const Duration(seconds: 60),
  });
}

/// Метрики инструмента.
final class ToolMetrics {
  final ToolRef ref;
  final int callsPerMinute;
  final double errorRate;
  final Duration p50Latency;
  final Duration p99Latency;

  const ToolMetrics({
    required this.ref,
    required this.callsPerMinute,
    required this.errorRate,
    required this.p50Latency,
    required this.p99Latency,
  });
}

/// Административный клиент runtime.
///
/// Управление circuit breaker и мониторинг метрик.
abstract interface class IAQToolRuntimeAdmin {
  static IAQToolRuntimeAdmin? _instance;
  static IAQToolRuntimeAdmin get instance {
    assert(_instance != null, 'IAQToolRuntimeAdmin not initialized');
    return _instance!;
  }

  static void initialize(IAQToolRuntimeAdmin impl) => _instance = impl;
  static void reset() => _instance = null;

  /// Сбросить circuit breaker в CLOSED.
  Future<void> resetCircuit(ToolRef ref);

  /// Установить политику circuit breaker для инструмента.
  Future<void> setCircuitPolicy(ToolRef ref, CircuitBreakerPolicy policy);

  /// Метрики по инструментам.
  Future<List<ToolMetrics>> getMetrics({String? namePattern});
}
