// pkgs/aq_schema/lib/graph/engine/i_graph_engine_client.dart
//
// Порт-интерфейс для работы с графовым движком из любого клиента.
//
// ── Назначение ───────────────────────────────────────────────────────────────
//
// IGraphEngineClient — единственное что нужно знать Flutter/CLI клиенту
// о графовом движке. Не знает про HTTP, WebSocket, SSE — только контракт.
//
// Реализации:
//   HttpGraphEngineClient  — в aq_graph_engine (через HTTP + SSE/WS)
//   LocalGraphEngineClient — в aq_graph_engine (прямой вызов движка)
//
// ── Синглтон ─────────────────────────────────────────────────────────────────
//
// Паттерн аналогичен IMetricsService.instance.
//
//   IGraphEngineClient.init(HttpGraphEngineClient(baseUrl: '...'));
//   IGraphEngineClient.instance.run(request).listen(...);
//
// ── Сценарии использования ───────────────────────────────────────────────────
//
// СЦЕНАРИЙ 1: Flutter — запустить граф и слушать события
//
//   // main.dart:
//   IGraphEngineClient.init(HttpGraphEngineClient(
//     baseUrl: 'http://localhost:8092',
//   ));
//
//   // В виджете:
//   final stream = IGraphEngineClient.instance.run(GraphRunRequest(
//     runId: Uuid().v4(),
//     blueprintId: 'my-workflow-id',
//     projectId: 'project-1',
//     projectPath: '/projects/my-project',
//   ));
//
//   stream.listen((event) {
//     switch (event.type) {
//       case GraphRunEventType.log:
//         print(event.message);
//       case GraphRunEventType.completed:
//         print('Done!');
//       case GraphRunEventType.userInputRequired:
//         showInputDialog(event.inputRequiredPayload);
//     }
//   });
//
// СЦЕНАРИЙ 2: Resume после ввода пользователя
//
//   await IGraphEngineClient.instance.resume(UserInputResponse(
//     runId: runId,
//     values: {'user_answer': 'yes'},
//   ));
//
// СЦЕНАРИЙ 3: Получить статус запуска
//
//   final run = await IGraphEngineClient.instance.getRun(runId);
//   print(run?['status']); // 'running', 'completed', 'suspended', 'failed'
//
// СЦЕНАРИЙ 4: Отменить запуск
//
//   await IGraphEngineClient.instance.cancel(runId);

import '../transport/messages/run_request.dart';
import '../transport/messages/run_event.dart';
import '../transport/messages/user_input_response.dart';

export '../transport/messages/run_request.dart';
export '../transport/messages/run_event.dart';
export '../transport/messages/user_input_response.dart';

/// Порт-интерфейс для работы с графовым движком.
///
/// Клиент (Flutter, CLI, тест) работает только через этот интерфейс.
/// Реализация (HTTP, local) подключается при инициализации.
abstract interface class IGraphEngineClient {
  // ── Синглтон ────────────────────────────────────────────────────────────────

  static IGraphEngineClient? _instance;

  /// Текущий экземпляр клиента.
  ///
  /// Бросает [StateError] если [init] не был вызван.
  static IGraphEngineClient get instance {
    if (_instance == null) {
      throw StateError(
        'IGraphEngineClient not initialized. '
        'Call IGraphEngineClient.init(...) before using instance.',
      );
    }
    return _instance!;
  }

  /// Инициализировать с конкретной реализацией.
  static void init(IGraphEngineClient client) => _instance = client;

  /// Сбросить. Используется в тестах.
  static void resetForTesting() => _instance = null;

  /// true если клиент инициализирован.
  static bool get isInitialized => _instance != null;

  // ── Основные операции ───────────────────────────────────────────────────────

  /// Запустить граф и получить stream событий.
  ///
  /// Stream завершается когда граф завершён, упал или приостановлен.
  /// При [GraphRunEventType.userInputRequired] — вызвать [resume].
  Stream<GraphRunEvent> run(GraphRunRequest request);

  /// Продолжить приостановленный граф после ввода пользователя.
  Future<void> resume(UserInputResponse response);

  /// Отменить выполнение графа.
  Future<void> cancel(String runId);

  /// Получить данные запуска по ID.
  ///
  /// Возвращает Map с полями: id, status, logsJson, contextJson, suspendedNodeId.
  /// Возвращает null если запуск не найден.
  Future<Map<String, dynamic>?> getRun(String runId);

  /// Проверить доступность движка.
  Future<bool> isAvailable();

  /// Освободить ресурсы.
  void dispose();
}
