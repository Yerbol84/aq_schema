// Стандартные коды ошибок для всех сервисов AQ

/// Стандартные коды ошибок
///
/// Используются во всех сервисах для единообразной обработки ошибок
class ErrorCodes {
  // Authentication & Authorization
  static const String authRequired = 'AUTH_REQUIRED';
  static const String authFailed = 'AUTH_FAILED';
  static const String insufficientPermissions = 'INSUFFICIENT_PERMISSIONS';
  static const String tokenExpired = 'TOKEN_EXPIRED';
  static const String tokenInvalid = 'TOKEN_INVALID';

  // Validation
  static const String validationError = 'VALIDATION_ERROR';
  static const String requiredFieldMissing = 'REQUIRED_FIELD_MISSING';
  static const String invalidType = 'INVALID_TYPE';
  static const String invalidFormat = 'INVALID_FORMAT';
  static const String invalidContentType = 'INVALID_CONTENT_TYPE';
  static const String invalidJson = 'INVALID_JSON';
  static const String missingBody = 'MISSING_BODY';

  // Resources
  static const String notFound = 'NOT_FOUND';
  static const String alreadyExists = 'ALREADY_EXISTS';
  static const String conflict = 'CONFLICT';

  // Rate Limiting
  static const String rateLimitExceeded = 'RATE_LIMIT_EXCEEDED';
  static const String tooManyRequests = 'TOO_MANY_REQUESTS';

  // Server Errors
  static const String internalError = 'INTERNAL_ERROR';
  static const String serviceUnavailable = 'SERVICE_UNAVAILABLE';
  static const String timeout = 'TIMEOUT';
  static const String badGateway = 'BAD_GATEWAY';

  // Business Logic
  static const String operationFailed = 'OPERATION_FAILED';
  static const String invalidState = 'INVALID_STATE';
  static const String preconditionFailed = 'PRECONDITION_FAILED';

  ErrorCodes._(); // Приватный конструктор - только константы
}
