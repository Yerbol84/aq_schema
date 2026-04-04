import 'dart:convert';
import 'package:aq_schema/validator/aq_validation_result.dart';
import 'package:json_schema/json_schema.dart';

enum AqSchemaType { ui, mcp, workflow }

class AqSchemaValidator {
  static final Map<String, JsonSchema> _cache = {};

  /// Провалидировать данные против схемы.
  static Future<AqValidationResult> validate(
    Map<String, dynamic> data, {
    AqSchemaType type = AqSchemaType.ui,
    String version = '2.0.0',
  }) async {
    final schemaJson = await _loadSchema(type, version);
    final schema = _cache[_cacheKey(type, version)] ??= JsonSchema.create(
      schemaJson,
    );

    final results = schema.validate(data, parseJson: false);
    return AqValidationResult(
      isValid: results.isValid,
      detectedVersion: version,
      errors: results.errors
          .map((e) => AqValidationError(path: e.schemaPath, message: e.message))
          .toList(),
    );
  }

  /// Автоопределение версии из поля 'version' или '$schema'.
  static Future<AqValidationResult> validateAuto(
    Map<String, dynamic> data,
  ) async {
    final version = data['version'] as String? ?? '2.0.0';
    return validate(data, version: version);
  }

  static String _cacheKey(AqSchemaType type, String version) =>
      '${type.name}:$version';

  static Future<Map<String, dynamic>> _loadSchema(
    AqSchemaType type,
    String version,
  ) async {
    // В Dart-пакете — читаем из assets или встроенной строки
    // В тестах — читаем с диска
    throw UnimplementedError('Implement schema loading for your platform');
  }
}
