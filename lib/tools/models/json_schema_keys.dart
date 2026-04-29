// aq_schema/lib/tools/models/json_schema_keys.dart
//
// Уровень 2 — константы ключей JSON Schema.
// Используются при объявлении inputSchema/outputSchema в ToolContract.

/// Стандартные ключи JSON Schema.
class JsonSchemaKeys {
  JsonSchemaKeys._();

  // ── Структурные ───────────────────────────────────────────────────────────
  static const String type        = 'type';
  static const String properties  = 'properties';
  static const String required    = 'required';
  static const String description = 'description';
  static const String items       = 'items';
  static const String enumValues  = 'enum';

  // ── Типы ──────────────────────────────────────────────────────────────────
  static const String typeObject  = 'object';
  static const String typeString  = 'string';
  static const String typeArray   = 'array';
  static const String typeBoolean = 'boolean';
  static const String typeInteger = 'integer';
  static const String typeNumber  = 'number';
}
