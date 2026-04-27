/// Base interface that every model stored in dart_vault must implement.
abstract interface class Storable {
  /// Unique record identifier (UUID recommended).
  String get id;

  /// Name of the storage collection (table/bucket) for this domain.
  /// Must be snake_case. Used by both client (creates repository)
  /// and server (creates table). Same name = same storage.
  ///
  /// Example: 'workflow_graphs', 'projects', 'workflow_runs'
  String get collectionName;

  /// Serialise to Map for storage.
  /// Must return JSON-safe types only: String, num, bool, null, List, Map.
  Map<String, dynamic> toMap();

  /// Values to be written to the index on save.
  /// Key = index name, value = value to index.
  /// Return empty map if no fields need indexing.
  Map<String, dynamic> get indexFields;

  /// JSON Schema describing this domain's structure.
  /// Used by storage backends to auto-create tables/collections.
  ///
  /// Required fields:
  /// - `type`: "object"
  /// - `properties`: map of field name → field schema
  /// - `required`: list of required field names
  ///
  /// Example:
  /// ```dart
  /// static const jsonSchema = {
  ///   'type': 'object',
  ///   'properties': {
  ///     'id': {'type': 'string', 'format': 'uuid'},
  ///     'name': {'type': 'string'},
  ///   },
  ///   'required': ['id', 'name'],
  /// };
  /// ```
  Map<String, dynamic> get jsonSchema;

  /// Controls delete behavior for the ENTIRE ENTITY:
  /// - `true` (default): Soft delete - mark as deleted, keep in DB
  /// - `false`: Hard delete - physically remove from DB
  ///
  /// Both modes log the delete operation to `{collection}_deleted` table.
  ///
  /// ## DirectStorage
  /// - Soft: Mark `deletedAt`, record stays in table
  /// - Hard: Remove from table
  ///
  /// ## VersionedStorage
  /// - Applies to `deleteEntity()` only (deletes ALL versions)
  /// - `deleteVersion()` is ALWAYS soft (state flag), regardless of this setting
  /// - Soft: Mark ALL versions with `deletedAt`
  /// - Hard: Remove ALL versions from table
  ///
  /// ## LoggedStorage
  /// - Applies to main entity record only
  /// - Audit log (`{collection}_log`) is ALWAYS preserved
  /// - Soft: Mark main record `deletedAt`, keep in table
  /// - Hard: Remove main record, log entries stay
  bool get softDelete => true;

  /// 3-level constants system: Domain → Sphere → Key
  static final keys = _StorableKeys._();
}

// ── Level 2: Spheres ──────────────────────────────────────────────────────────

class _StorableKeys {
  _StorableKeys._();

  final dbKeys = _StorableDbKeys._();
  final jsonKeys = _StorableJsonKeys._();
  final transportKeys = _StorableTransportKeys._();
}

// ── Level 3: DB Keys ──────────────────────────────────────────────────────────

class _StorableDbKeys {
  _StorableDbKeys._();

  final String id = 'id';
  final String tenantId = 'tenant_id';
  final String data = 'data';
  final String createdAt = 'created_at';
  final String updatedAt = 'updated_at';
  final String deletedAt = 'deleted_at';
}

// ── Level 3: JSON Keys ────────────────────────────────────────────────────────

class _StorableJsonKeys {
  _StorableJsonKeys._();

  final String id = 'id';
  final String tenantId = 'tenantId';
  final String deletedAt = 'deletedAt';
}

// ── Level 3: Transport Keys ───────────────────────────────────────────────────

class _StorableTransportKeys {
  _StorableTransportKeys._();

  final String collection = 'collection';
  final String operation = 'operation';
  final String tenantId = 'tenantId';
}
