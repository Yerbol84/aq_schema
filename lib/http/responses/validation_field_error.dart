// Ошибка валидации поля
// Используется в ValidationError для описания проблем с конкретными полями

/// Ошибка валидации одного поля
class ValidationFieldError {
  /// Имя поля
  final String field;

  /// Сообщение об ошибке
  final String message;

  /// Код ошибки
  final String code;

  const ValidationFieldError({
    required this.field,
    required this.message,
    required this.code,
  });

  Map<String, dynamic> toJson() => {
        'field': field,
        'message': message,
        'code': code,
      };

  factory ValidationFieldError.fromJson(Map<String, dynamic> json) {
    return ValidationFieldError(
      field: json['field'] as String,
      message: json['message'] as String,
      code: json['code'] as String,
    );
  }
}
