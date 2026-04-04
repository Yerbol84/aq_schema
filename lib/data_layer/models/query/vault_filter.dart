import 'vault_operator.dart';

/// A single filter predicate in a [VaultQuery].
final class VaultFilter {
  final String field;
  final VaultOperator operator;
  final dynamic value;

  const VaultFilter(this.field, this.operator, this.value);

  /// Evaluate this filter against a single stored record map.
  bool matches(Map<String, dynamic> record) {
    final fieldValue = record[field];
    return operator.evaluate(fieldValue, value);
  }
}
