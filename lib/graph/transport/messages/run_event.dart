// Событие которое движок отправляет клиенту во время выполнения.
// Клиент подписывается на Stream<GraphRunEvent> и получает обновления в реальном времени.

import 'run_status.dart';

/// Тип события
enum GraphRunEventType {
  /// Строка лога (выполнение шагов, системные сообщения)
  log,

  /// Статус изменился (например: running → suspended)
  statusChanged,

  /// Граф завершил выполнение
  completed,

  /// Произошла ошибка
  error,

  /// Движок ждёт ввода пользователя (см. UserInputRequired)
  userInputRequired,
}

class GraphRunEvent {
  final String runId;
  final GraphRunEventType type;
  final DateTime timestamp;

  /// Текст лога (для type == log)
  final String? message;

  /// Тип лога: 'system', 'node', 'error', 'warning', 'user_action', 'start', 'success'
  final String? logType;

  /// Ветка выполнения (для type == log)
  final String? branch;

  /// Глубина вложенности (для type == log)
  final int depth;

  /// Новый статус (для type == statusChanged)
  final GraphRunStatus? newStatus;

  /// Информация о необходимом вводе (для type == userInputRequired)
  final Map<String, dynamic>? inputRequiredPayload;

  /// Ошибка (для type == error)
  final String? errorMessage;

  GraphRunEvent({
    required this.runId,
    required this.type,
    DateTime? timestamp,
    this.message,
    this.logType,
    this.branch,
    this.depth = 0,
    this.newStatus,
    this.inputRequiredPayload,
    this.errorMessage,
  }) : timestamp = timestamp ?? DateTime.now();

  // ─── Удобные фабричные конструкторы ───────────────────────────────────────

  factory GraphRunEvent.log({
    required String runId,
    required String message,
    required String logType,
    required String branch,
    int depth = 0,
  }) {
    return GraphRunEvent(
      runId: runId,
      type: GraphRunEventType.log,
      message: message,
      logType: logType,
      branch: branch,
      depth: depth,
    );
  }

  factory GraphRunEvent.statusChanged({
    required String runId,
    required GraphRunStatus status,
  }) {
    return GraphRunEvent(
      runId: runId,
      type: GraphRunEventType.statusChanged,
      newStatus: status,
    );
  }

  factory GraphRunEvent.completed({required String runId}) {
    return GraphRunEvent(
      runId: runId,
      type: GraphRunEventType.completed,
      newStatus: GraphRunStatus.completed,
    );
  }

  factory GraphRunEvent.error({
    required String runId,
    required String message,
  }) {
    return GraphRunEvent(
      runId: runId,
      type: GraphRunEventType.error,
      errorMessage: message,
      newStatus: GraphRunStatus.failed,
    );
  }

  factory GraphRunEvent.userInputRequired({
    required String runId,
    required Map<String, dynamic> payload,
  }) {
    return GraphRunEvent(
      runId: runId,
      type: GraphRunEventType.userInputRequired,
      inputRequiredPayload: payload,
      newStatus: GraphRunStatus.suspended,
    );
  }

  Map<String, dynamic> toJson() => {
    'runId': runId,
    'type': type.name,
    'timestamp': timestamp.toIso8601String(),
    if (message != null) 'message': message,
    if (logType != null) 'logType': logType,
    if (branch != null) 'branch': branch,
    'depth': depth,
    if (newStatus != null) 'newStatus': newStatus!.toJson(),
    if (inputRequiredPayload != null)
      'inputRequiredPayload': inputRequiredPayload,
    if (errorMessage != null) 'errorMessage': errorMessage,
  };
}
