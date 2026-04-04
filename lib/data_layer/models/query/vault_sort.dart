/// Sort descriptor for [VaultQuery].
final class VaultSort {
  final String field;
  final bool descending;

  const VaultSort({required this.field, this.descending = false});
}
