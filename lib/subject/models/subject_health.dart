// aq_schema/lib/subject/models/subject_health.dart
//
// P-14: Health status для субъектов.

/// Статус здоровья Subject.
enum SubjectHealthStatus {
  /// Статус неизвестен (не проверялся).
  unknown,

  /// Субъект готов к работе.
  healthy,

  /// Субъект недоступен или не отвечает.
  unhealthy,

  /// Субъект в процессе провизионирования.
  provisioning,
}
