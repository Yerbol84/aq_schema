/// Comparison operators for [VaultFilter].
enum VaultOperator {
  equals,
  notEquals,
  contains,
  startsWith,
  greaterThan,
  greaterOrEqual,
  lessThan,
  lessOrEqual,
  isNull,
  isNotNull,
  inList,
  notInList;

  /// Evaluate this operator against [fieldValue] and [filterValue].
  bool evaluate(dynamic fieldValue, dynamic filterValue) {
    switch (this) {
      case VaultOperator.equals:
        return _str(fieldValue) == _str(filterValue);
      case VaultOperator.notEquals:
        return _str(fieldValue) != _str(filterValue);
      case VaultOperator.contains:
        return _str(fieldValue).contains(_str(filterValue));
      case VaultOperator.startsWith:
        return _str(fieldValue).startsWith(_str(filterValue));
      case VaultOperator.greaterThan:
        return _cmp(fieldValue, filterValue) > 0;
      case VaultOperator.greaterOrEqual:
        return _cmp(fieldValue, filterValue) >= 0;
      case VaultOperator.lessThan:
        return _cmp(fieldValue, filterValue) < 0;
      case VaultOperator.lessOrEqual:
        return _cmp(fieldValue, filterValue) <= 0;
      case VaultOperator.isNull:
        return fieldValue == null;
      case VaultOperator.isNotNull:
        return fieldValue != null;
      case VaultOperator.inList:
        final list = filterValue as List?;
        return list?.map(_str).contains(_str(fieldValue)) ?? false;
      case VaultOperator.notInList:
        final list = filterValue as List?;
        return !(list?.map(_str).contains(_str(fieldValue)) ?? false);
    }
  }

  String _str(dynamic v) => v?.toString() ?? '';

  int _cmp(dynamic a, dynamic b) {
    if (a is num && b is num) return a.compareTo(b);
    final sa = _str(a);
    final sb = _str(b);
    final na = num.tryParse(sa);
    final nb = num.tryParse(sb);
    if (na != null && nb != null) return na.compareTo(nb);
    return sa.compareTo(sb);
  }

  /// SQL operator string for [SqlQueryTranslator] implementations.
  String get sql {
    switch (this) {
      case VaultOperator.equals:
        return '=';
      case VaultOperator.notEquals:
        return '!=';
      case VaultOperator.contains:
        return 'ILIKE';
      case VaultOperator.startsWith:
        return 'ILIKE';
      case VaultOperator.greaterThan:
        return '>';
      case VaultOperator.greaterOrEqual:
        return '>=';
      case VaultOperator.lessThan:
        return '<';
      case VaultOperator.lessOrEqual:
        return '<=';
      case VaultOperator.isNull:
        return 'IS NULL';
      case VaultOperator.isNotNull:
        return 'IS NOT NULL';
      case VaultOperator.inList:
        return 'IN';
      case VaultOperator.notInList:
        return 'NOT IN';
    }
  }
}
