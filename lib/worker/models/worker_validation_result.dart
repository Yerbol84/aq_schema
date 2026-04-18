// pkgs/aq_schema/lib/worker/models/worker_validation_result.dart
//
// Результат валидации worker protocol объектов.
// Используется WorkerValidator для возврата результатов валидации.

/// Результат валидации worker protocol объекта
final class WorkerValidationResult {
  const WorkerValidationResult({
    required this.isValid,
    this.errors = const [],
    this.warnings = const [],
  });

  /// Валидация прошла успешно
  final bool isValid;

  /// Список ошибок валидации
  final List<String> errors;

  /// Список предупреждений (не блокируют валидацию)
  final List<String> warnings;

  /// Фабрика для успешной валидации
  factory WorkerValidationResult.ok() =>
      const WorkerValidationResult(isValid: true);

  /// Фабрика для неуспешной валидации
  factory WorkerValidationResult.fail(List<String> errors) =>
      WorkerValidationResult(
        isValid: false,
        errors: errors,
      );

  /// Фабрика для валидации с предупреждениями
  factory WorkerValidationResult.withWarnings(List<String> warnings) =>
      WorkerValidationResult(
        isValid: true,
        warnings: warnings,
      );

  @override
  String toString() =>
      'WorkerValidationResult(isValid: $isValid, errors: $errors, warnings: $warnings)';
}
