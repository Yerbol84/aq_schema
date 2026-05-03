// Evaluator для условных выражений в WorkflowEdge.
// Живёт в aq_schema — переиспользуется движком, воркером и другими пакетами.

/// Исключение при ошибке вычисления условия
class ConditionEvalException implements Exception {
  final String expression;
  final String message;

  ConditionEvalException(this.expression, this.message);

  @override
  String toString() =>
      'ConditionEvalException: не удалось вычислить "$expression" — $message';
}

/// Evaluator условных выражений на рёбрах графа.
///
/// Поддерживаемые операторы:
/// - Сравнение: ==, !=, >, <, >=, <=
/// - Строковые: contains
/// - Проверки: isEmpty, isNotEmpty, exists, notExists
/// - Составные: &&, ||
///
/// Примеры:
/// - "status == 'success'"
/// - "count > 5"
/// - "errors isEmpty"
/// - "result != null"
/// - "message contains 'error'"
/// - "status == 'done' && count > 0"
class ConditionEvaluator {
  static bool evaluate(String expression, Map<String, dynamic> state) {
    final trimmed = expression.trim();
    if (trimmed.isEmpty) throw ConditionEvalException(expression, 'пустое выражение');

    if (trimmed.contains(' && ')) {
      return trimmed.split(' && ').every((p) => evaluate(p.trim(), state));
    }
    if (trimmed.contains(' || ')) {
      return trimmed.split(' || ').any((p) => evaluate(p.trim(), state));
    }

    if (trimmed.contains(' isEmpty'))    return _unary(trimmed, 'isEmpty',    state, (v) => _isEmpty(v));
    if (trimmed.contains(' isNotEmpty')) return _unary(trimmed, 'isNotEmpty', state, (v) => !_isEmpty(v));
    if (trimmed.contains(' exists'))     return _unary(trimmed, 'exists',     state, (v) => v != null);
    if (trimmed.contains(' notExists'))  return _unary(trimmed, 'notExists',  state, (v) => v == null);

    if (trimmed.contains(' contains ')) return _binary(trimmed, 'contains', state, (l, r) => _contains(l, r));
    if (trimmed.contains(' >= '))        return _binary(trimmed, '>=', state, (l, r) => _compare(l, r) >= 0);
    if (trimmed.contains(' <= '))        return _binary(trimmed, '<=', state, (l, r) => _compare(l, r) <= 0);
    if (trimmed.contains(' > '))         return _binary(trimmed, '>',  state, (l, r) => _compare(l, r) > 0);
    if (trimmed.contains(' < '))         return _binary(trimmed, '<',  state, (l, r) => _compare(l, r) < 0);
    if (trimmed.contains(' == '))        return _binary(trimmed, '==', state, (l, r) => l == r);
    if (trimmed.contains(' != '))        return _binary(trimmed, '!=', state, (l, r) => l != r);

    throw ConditionEvalException(expression, 'неизвестный оператор');
  }

  static bool _unary(String expr, String op, Map<String, dynamic> state, bool Function(dynamic) check) {
    final parts = expr.split(' $op');
    if (parts.length != 2 || parts[1].trim().isNotEmpty) {
      throw ConditionEvalException(expr, 'оператор $op должен быть в конце');
    }
    return check(_resolve(parts[0].trim(), state));
  }

  static bool _binary(String expr, String op, Map<String, dynamic> state, bool Function(dynamic, dynamic) cmp) {
    final parts = expr.split(' $op ');
    if (parts.length != 2) throw ConditionEvalException(expr, 'оператор $op требует две части');
    return cmp(_resolve(parts[0].trim(), state), _literal(parts[1].trim()));
  }

  static dynamic _resolve(String varName, Map<String, dynamic> state) {
    if (!varName.contains('.')) return state[varName];
    dynamic cur = state;
    for (final p in varName.split('.')) {
      cur = cur is Map ? cur[p] : null;
    }
    return cur;
  }

  static dynamic _literal(String s) {
    if (s.startsWith("'") && s.endsWith("'")) return s.substring(1, s.length - 1);
    if (s.startsWith('"') && s.endsWith('"')) return s.substring(1, s.length - 1);
    if (s == 'true') return true;
    if (s == 'false') return false;
    if (s == 'null') return null;
    final n = num.tryParse(s);
    if (n != null) return n;
    throw ConditionEvalException(s, 'не удалось распарсить литерал');
  }

  static int _compare(dynamic l, dynamic r) {
    if (l is num && r is num) return l.compareTo(r);
    if (l is String && r is String) return l.compareTo(r);
    throw ConditionEvalException('$l <=> $r', 'сравнение только для чисел или строк');
  }

  static bool _contains(dynamic l, dynamic r) {
    if (l is String && r is String) return l.contains(r);
    if (l is List) return l.contains(r);
    throw ConditionEvalException('$l contains $r', 'contains только для строк и списков');
  }

  static bool _isEmpty(dynamic v) {
    if (v == null) return true;
    if (v is String) return v.isEmpty;
    if (v is List) return v.isEmpty;
    if (v is Map) return v.isEmpty;
    return false;
  }
}
