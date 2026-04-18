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
}

// ── Level 3: JSON Keys ────────────────────────────────────────────────────────

class _StorableJsonKeys {
  _StorableJsonKeys._();

  final String id = 'id';
  final String tenantId = 'tenantId';
}

// ── Level 3: Transport Keys ───────────────────────────────────────────────────

class _StorableTransportKeys {
  _StorableTransportKeys._();

  final String collection = 'collection';
  final String operation = 'operation';
  final String tenantId = 'tenantId';
}
