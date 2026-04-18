// Стандартный формат ответа с ошибкой для всех сервисов
// Используется во всех HTTP API для единообразия

/// Structured error response
///
/// Единый формат ошибок для всех сервисов AQ:
/// - graph_engine_server
/// - aq_auth_service
/// - aq_studio_data_service
/// - aq_graph_worker
/// - и т.д.
class ErrorResponse {
  /// Краткое описание ошибки
  final String error;

  /// Детальное сообщение (опционально)
  final String? message;

  /// Код ошибки для программной обработки
  final String? code;

  /// Дополнительные детали (например, validation errors)
  final Map<String, dynamic>? details;

  /// ID запроса для трейсинга
  final String? requestId;

  /// Временная метка
  final DateTime timestamp;

  const ErrorResponse({
    required this.error,
    this.message,
    this.code,
    this.details,
    this.requestId,
    required this.timestamp,
  });

  /// Сериализация в JSON
  Map<String, dynamic> toJson() => {
        'error': error,
        if (message != null) 'message': message,
        if (code != null) 'code': code,
        if (details != null) 'details': details,
        if (requestId != null) 'requestId': requestId,
        'timestamp': timestamp.toIso8601String(),
      };

  /// Десериализация из JSON
  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      error: json['error'] as String,
      message: json['message'] as String?,
      code: json['code'] as String?,
      details: json['details'] as Map<String, dynamic>?,
      requestId: json['requestId'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  @override
  String toString() => 'ErrorResponse(error: $error, code: $code)';
}
