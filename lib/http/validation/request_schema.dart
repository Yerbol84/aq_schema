// Схема валидации запроса

import 'field_type.dart';
import '../responses/validation_field_error.dart';

/// Схема валидации для HTTP запроса
class RequestSchema {
  final Map<String, FieldType> requiredFields;
  final Map<String, FieldType> optionalFields;
  final Map<String, String? Function(dynamic)> customValidators;

  const RequestSchema({
    this.requiredFields = const {},
    this.optionalFields = const {},
    this.customValidators = const {},
  });

  /// Валидировать body
  List<ValidationFieldError> validate(Map<String, dynamic> body) {
    final errors = <ValidationFieldError>[];

    // Проверяем required fields
    for (final entry in requiredFields.entries) {
      final field = entry.key;
      final type = entry.value;

      if (!body.containsKey(field)) {
        errors.add(ValidationFieldError(
          field: field,
          message: 'Required field missing',
          code: 'REQUIRED_FIELD_MISSING',
        ));
        continue;
      }

      final value = body[field];
      if (!_checkType(value, type)) {
        errors.add(ValidationFieldError(
          field: field,
          message: 'Expected ${type.name}, got ${value.runtimeType}',
          code: 'INVALID_TYPE',
        ));
      }
    }

    // Проверяем optional fields (если присутствуют)
    for (final entry in optionalFields.entries) {
      final field = entry.key;
      final type = entry.value;

      if (body.containsKey(field)) {
        final value = body[field];
        if (value != null && !_checkType(value, type)) {
          errors.add(ValidationFieldError(
            field: field,
            message: 'Expected ${type.name}, got ${value.runtimeType}',
            code: 'INVALID_TYPE',
          ));
        }
      }
    }

    // Кастомные валидаторы
    for (final entry in customValidators.entries) {
      final field = entry.key;
      final validator = entry.value;

      if (body.containsKey(field)) {
        final error = validator(body[field]);
        if (error != null) {
          errors.add(ValidationFieldError(
            field: field,
            message: error,
            code: 'CUSTOM_VALIDATION_FAILED',
          ));
        }
      }
    }

    return errors;
  }

  /// Проверить тип значения
  bool _checkType(dynamic value, FieldType type) {
    switch (type) {
      case FieldType.string:
        return value is String;
      case FieldType.number:
        return value is num;
      case FieldType.boolean:
        return value is bool;
      case FieldType.object:
        return value is Map;
      case FieldType.array:
        return value is List;
    }
  }
}
