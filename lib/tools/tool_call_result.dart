// pkgs/aq_schema/lib/tools/tool_call_result.dart
//
// Результат вызова инструмента через IToolService.
// Чистый value-тип — никаких зависимостей кроме Dart primitives.

/// Результат вызова инструмента.
///
/// Всегда возвращается из [IToolService.callTool] — никогда не бросается исключение.
/// Ошибки кодируются через [ToolCallResult.failure].
class ToolCallResult {
  /// Успешно ли выполнен инструмент.
  final bool success;

  /// Результат выполнения (при [success] == true).
  /// Тип зависит от конкретного инструмента — может быть String, Map, List и т.д.
  final dynamic output;

  /// Сообщение об ошибке (при [success] == false).
  final String? error;

  /// Машиночитаемый код ошибки (при [success] == false).
  /// Например: 'TOOL_NOT_FOUND', 'TIMEOUT', 'PERMISSION_DENIED'.
  final String? errorCode;

  const ToolCallResult._({
    required this.success,
    this.output,
    this.error,
    this.errorCode,
  });

  /// Успешный результат.
  const ToolCallResult.success({required dynamic output})
      : this._(success: true, output: output);

  /// Результат с ошибкой.
  const ToolCallResult.failure({
    required String error,
    String? errorCode,
  }) : this._(success: false, error: error, errorCode: errorCode);

  /// Удобный геттер для получения output как Map.
  Map<String, dynamic>? get outputAsMap {
    if (output is Map<String, dynamic>) return output as Map<String, dynamic>;
    if (output is Map) {
      return Map<String, dynamic>.from(output as Map);
    }
    return null;
  }

  /// Удобный геттер для получения output как String.
  String? get outputAsString {
    if (output is String) return output as String;
    if (output != null) return output.toString();
    return null;
  }

  @override
  String toString() => success
      ? 'ToolCallResult.success(output: $output)'
      : 'ToolCallResult.failure(error: $error, code: $errorCode)';
}
