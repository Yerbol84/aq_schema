// Возможные статусы выполнения графа

enum GraphRunStatus {
  /// Запрос принят, ещё не запущен
  queued,

  /// Выполняется прямо сейчас
  running,

  /// Приостановлен — ждёт ввода от пользователя
  suspended,

  /// Успешно завершён
  completed,

  /// Завершён с ошибкой
  failed,

  /// Отменён пользователем
  cancelled;

  String toJson() => name;
  static GraphRunStatus fromJson(String s) => values.byName(s);

  bool get isTerminal =>
      this == completed || this == failed || this == cancelled;
}
