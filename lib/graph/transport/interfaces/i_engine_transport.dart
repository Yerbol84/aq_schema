// Интерфейс транспорта между клиентом и движком.
//
// Локальная реализация (desktop): вызывает движок напрямую в том же процессе.
// Удалённая реализация (web service): отправляет HTTP запросы к серверу.
// В обоих случаях клиент работает одинаково — через этот интерфейс.

import '../messages/run_request.dart';
import '../messages/run_event.dart';
import '../messages/user_input_response.dart';

abstract class IEngineTransport {
  /// Запустить граф.
  /// Возвращает Stream событий — клиент слушает его и обновляет UI.
  Stream<GraphRunEvent> run(GraphRunRequest request);

  /// Отправить ответ пользователя когда граф ждёт ввода.
  Future<void> respondToInput(UserInputResponse response);

  /// Отменить выполнение.
  Future<void> cancel(String runId);

  /// Проверить доступность движка (для удалённого транспорта — health check).
  Future<bool> isAvailable();

  /// Освободить ресурсы.
  void dispose();
}
