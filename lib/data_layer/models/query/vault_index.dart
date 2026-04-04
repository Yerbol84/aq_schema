/// Index definition for a collection field.
///
/// Register an index via [DirectRepository.registerIndex] or
/// pass [indexes] to [Vault.direct] / [Vault.versioned] / [Vault.logged].
final class VaultIndex {
  /// Logical name of the index (must be unique within a collection).
  final String name;

  /// The field name this index covers.
  final String field;

  /// Whether index entries must be unique.
  final bool unique;

  const VaultIndex({
    required this.name,
    required this.field,
    this.unique = false,
  });
}
