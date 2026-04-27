// pkgs/aq_schema/lib/metrics/primitives/i_gauge.dart
//
// Протокол gauge — текущее значение которое может расти и убывать.
//
// ── Семантика ────────────────────────────────────────────────────────────────
//
// Gauge подходит для:
//   - текущее количество активных сущностей (соединения, запуски, воркеры)
//   - размер очереди прямо сейчас
//   - использование памяти / CPU в данный момент
//   - состояние circuit breaker (0=closed, 1=open, 2=half-open)
//
// Gauge НЕ подходит для:
//   - подсчёт событий (→ ICounter)
//   - измерение длительности (→ IHistogram / ITimer)
//
// ── Сценарии использования ───────────────────────────────────────────────────
//
// СЦЕНАРИЙ 1: Активные запуски графа
//
//   final active = metrics.gauge('graph_active_runs');
//
//   // При старте запуска:
//   active.inc();
//
//   // При завершении (успех или ошибка):
//   active.dec();
//
// СЦЕНАРИЙ 2: Размер очереди задач
//
//   final queue = metrics.gauge('worker_queue_size');
//   queue.set(jobQueue.length.toDouble());   // обновляем каждые N секунд
//
// СЦЕНАРИЙ 3: Состояние circuit breaker с атрибутами
//
//   final cb = metrics.gauge('circuit_breaker_state');
//   cb.set(1, attributes: {'service': 'llm_api'});   // open
//   cb.set(0, attributes: {'service': 'llm_api'});   // closed
//
// СЦЕНАРИЙ 4: Активные сессии по типу пользователя
//
//   final sessions = metrics.gauge('auth_active_sessions');
//   sessions.inc(attributes: {'user_type': 'admin'});
//   sessions.dec(attributes: {'user_type': 'admin'});
//
// ── Контракт для реализаций ──────────────────────────────────────────────────
//
// Реализация ДОЛЖНА:
//   - никогда не бросать исключений
//   - быть потокобезопасной
//   - set() устанавливает абсолютное значение (не дельту)
//
// Реализация МОЖЕТ:
//   - хранить последнее значение per-attributes комбинацию
//   - игнорировать атрибуты если бэкенд их не поддерживает

/// Протокол gauge метрики.
///
/// Текущее значение которое может как расти так и убывать.
/// Отражает состояние системы в данный момент времени.
abstract interface class IGauge {
  /// Увеличить gauge на [value] (по умолчанию 1).
  void inc({
    double value = 1,
    Map<String, String> attributes = const {},
  });

  /// Уменьшить gauge на [value] (по умолчанию 1).
  void dec({
    double value = 1,
    Map<String, String> attributes = const {},
  });

  /// Установить gauge в абсолютное значение.
  void set(
    double value, {
    Map<String, String> attributes = const {},
  });
}
