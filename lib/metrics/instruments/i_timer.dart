// pkgs/aq_schema/lib/metrics/instruments/i_timer.dart
//
// Протокол таймера — высокоуровневый инструмент для измерения длительности.
//
// ── Семантика ────────────────────────────────────────────────────────────────
//
// ITimer — это обёртка над IHistogram которая:
//   1. Запускает stopwatch при start()
//   2. Автоматически вычисляет elapsed при stop()
//   3. Записывает результат в IHistogram
//
// Это предпочтительный способ измерять длительность — не нужно вручную
// управлять Stopwatch и конвертировать в секунды.
//
// ── Сценарии использования ───────────────────────────────────────────────────
//
// СЦЕНАРИЙ 1: Измерение длительности выполнения графа
//
//   final runTimer = metrics.timer('graph_run_duration_seconds');
//
//   final handle = runTimer.start(attributes: {
//     'project_id': projectId,
//     'blueprint_id': blueprintId,
//   });
//
//   try {
//     await runner.start();
//     handle.stop();                    // записывает длительность
//   } catch (e) {
//     handle.stop(attributes: {        // можно добавить атрибуты при stop
//       'project_id': projectId,
//       'blueprint_id': blueprintId,
//       'status': 'error',
//     });
//     rethrow;
//   }
//
// СЦЕНАРИЙ 2: Измерение HTTP запроса с try/finally
//
//   final httpTimer = metrics.timer('http_request_duration_seconds');
//   final handle = httpTimer.start();
//   try {
//     return await handler(request);
//   } finally {
//     handle.stop(attributes: {
//       'method': request.method,
//       'status': response.statusCode.toString(),
//     });
//   }
//
// СЦЕНАРИЙ 3: Через scoped helper (если реализация поддерживает)
//
//   final result = await metrics.timer('db_query_seconds').measure(
//     () => db.query(sql),
//     attributes: {'table': 'projects'},
//   );
//
// ── Контракт для реализаций ──────────────────────────────────────────────────
//
// Реализация ДОЛЖНА:
//   - start() запускать stopwatch немедленно
//   - stop() записывать elapsed в секундах (дробное число)
//   - stop() вызванный повторно — игнорировать (idempotent)
//   - никогда не бросать исключений
//
// Реализация МОЖЕТ:
//   - merge атрибуты из start() и stop() (stop() переопределяет конфликты)
//   - поддерживать measure() как convenience метод

/// Хэндл активного замера — возвращается из [ITimer.start].
/// Вызови [stop] когда операция завершена.
abstract interface class ITimerHandle {
  /// Остановить таймер и записать длительность.
  ///
  /// [attributes] — дополнительные атрибуты (мержатся с атрибутами из start).
  ///                Удобно когда статус операции известен только при завершении.
  void stop({Map<String, String> attributes = const {}});
}

/// Протокол таймера — инструмент для измерения длительности операций.
///
/// Предпочтительный способ измерять время вместо прямого использования IHistogram.
abstract interface class ITimer {
  /// Начать замер.
  ///
  /// [attributes] — атрибуты известные на старте операции.
  ///                Можно дополнить при [ITimerHandle.stop].
  ITimerHandle start({Map<String, String> attributes = const {}});

  /// Удобный метод: выполнить [operation] и автоматически записать длительность.
  Future<T> measure<T>(
    Future<T> Function() operation, {
    Map<String, String> attributes = const {},
  });
}
