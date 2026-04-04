/// The type of operation recorded in a [LogEntry].
enum LogOperation {
  created,
  updated,
  deleted,
  rollback;

  static LogOperation fromString(String s) => LogOperation.values.firstWhere(
        (v) => v.name == s,
        orElse: () => LogOperation.updated,
      );
}
