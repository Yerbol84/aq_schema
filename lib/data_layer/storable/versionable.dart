import 'storable.dart';

/// Interface for entities that support schema versioning and migrations.
///
/// Entities implementing this interface declare:
/// - Current schema version (semver)
/// - Migration path from previous versions
/// - JSON Schema for automatic table creation
///
/// ## Schema Version
///
/// [schemaVersion] is a semver string (e.g., "1.2.0") that identifies
/// the current structure of this domain model.
///
/// When you change the model (add/remove/rename fields), increment the version:
/// - Patch (1.0.0 → 1.0.1): backward-compatible changes (add nullable field)
/// - Minor (1.0.0 → 1.1.0): new features (add indexed field)
/// - Major (1.0.0 → 2.0.0): breaking changes (rename field, change type)
///
/// ## Migrations
///
/// [migrations] is a list of migration descriptors that transform data
/// from older versions to the current version.
///
/// Example:
/// ```dart
/// static const migrations = [
///   DomainMigration(
///     collection: 'workflows',
///     fromVersion: '1.0.0',
///     toVersion: '2.0.0',
///     description: 'Rename dataJson → graphData',
///     transform: _migrateV1toV2,
///   ),
/// ];
/// ```
///
/// ## JSON Schema
///
/// [jsonSchema] describes the structure of this domain for storage backends.
/// Used by PostgresSchemaDeployer to auto-create tables.
///
/// Required fields:
/// - `type`: "object"
/// - `properties`: map of field name → field schema
/// - `required`: list of required field names
///
/// Field schema:
/// - `type`: "string" | "number" | "boolean" | "array" | "object"
/// - `format`: (optional) "uuid" | "date-time" | "email" | etc.
/// - `items`: (for arrays) schema of array elements
/// - `properties`: (for objects) nested field schemas
///
/// Example:
/// ```dart
/// static const jsonSchema = {
///   'type': 'object',
///   'properties': {
///     'id': {'type': 'string', 'format': 'uuid'},
///     'name': {'type': 'string'},
///     'createdAt': {'type': 'string', 'format': 'date-time'},
///     'tags': {'type': 'array', 'items': {'type': 'string'}},
///   },
///   'required': ['id', 'name'],
/// };
/// ```
abstract interface class Versionable implements Storable {
  /// Current schema version (semver: "1.2.0").
  /// Increment when changing the domain model structure.
  String get schemaVersion;

  /// List of migrations from previous versions.
  /// Applied automatically by SchemaDeployer on startup.
  List<Object> get migrations;

  /// JSON Schema describing this domain's structure.
  /// Used by storage backends to auto-create tables/collections.
  @override
  Map<String, dynamic> get jsonSchema;
}
