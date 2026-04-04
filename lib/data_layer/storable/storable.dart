/// Base interface that every model stored in dart_vault must implement.
abstract interface class Storable {
  /// Unique record identifier (UUID recommended).
  String get id;

  /// Serialise to Map for storage.
  /// Must return JSON-safe types only: String, num, bool, null, List, Map.
  Map<String, dynamic> toMap();

  /// Values to be written to the index on save.
  /// Key = index name, value = value to index.
  /// Return empty map if no fields need indexing.
  Map<String, dynamic> get indexFields;
}
