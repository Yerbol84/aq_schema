// Condition Node - условное ветвление

import 'package:aq_schema/graph/nodes/base/i_instruction_node.dart';
import 'package:aq_schema/graph/engine/run_context.dart';

/// Узел для условного ветвления
///
/// Вычисляет условие и определяет следующий узел
class ConditionNode implements IInstructionNode {
  @override
  final String id;

  @override
  final String nodeType = 'condition';

  /// Переменная для проверки
  final String checkVar;

  /// Оператор сравнения (==, !=, >, <, >=, <=, contains, isEmpty)
  final String operator;

  /// Значение для сравнения (может содержать {{variables}})
  final dynamic compareValue;

  /// Переменная для сохранения результата (true/false)
  final String outputVar;

  const ConditionNode({
    required this.id,
    required this.checkVar,
    required this.operator,
    this.compareValue,
    required this.outputVar,
  });

  @override
  Future<dynamic> execute(
    RunContext context,
  ) async {
    // Получить значение переменной
    final value = context.getVar(checkVar);

    // Вычислить условие
    final result = _evaluateCondition(value, operator, compareValue, context);

    // Сохранить результат
    context.setVar(outputVar, result);

    context.log(
      'Condition evaluated: $checkVar $operator $compareValue = $result',
      branch: context.currentBranch,
    );

    return result;
  }

  bool _evaluateCondition(
    dynamic value,
    String op,
    dynamic compareValue,
    RunContext context,
  ) {
    // Подставить переменные в compareValue если это строка
    final resolvedCompareValue =
        compareValue is String && compareValue.contains('{{')
            ? _substituteVariables(compareValue, context)
            : compareValue;

    switch (op) {
      case '==':
        return value == resolvedCompareValue;
      case '!=':
        return value != resolvedCompareValue;
      case '>':
        return _compareNumbers(value, resolvedCompareValue, (a, b) => a > b);
      case '<':
        return _compareNumbers(value, resolvedCompareValue, (a, b) => a < b);
      case '>=':
        return _compareNumbers(value, resolvedCompareValue, (a, b) => a >= b);
      case '<=':
        return _compareNumbers(value, resolvedCompareValue, (a, b) => a <= b);
      case 'contains':
        return value.toString().contains(resolvedCompareValue.toString());
      case 'isEmpty':
        return value == null || value.toString().isEmpty;
      case 'isNotEmpty':
        return value != null && value.toString().isNotEmpty;
      default:
        throw Exception('ConditionNode: unknown operator "$op"');
    }
  }

  bool _compareNumbers(
    dynamic a,
    dynamic b,
    bool Function(num, num) compare,
  ) {
    final numA = num.tryParse(a.toString());
    final numB = num.tryParse(b.toString());
    if (numA == null || numB == null) {
      throw Exception(
          'ConditionNode: cannot compare non-numeric values with $operator');
    }
    return compare(numA, numB);
  }

  String _substituteVariables(String template, RunContext context) {
    var result = template;
    final regex = RegExp(r'\{\{(\w+)\}\}');
    for (final match in regex.allMatches(template)) {
      final varName = match.group(1)!;
      final value = context.getVar(varName);
      if (value != null) {
        result = result.replaceAll('{{$varName}}', value.toString());
      }
    }
    return result;
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': nodeType,
        'config': {
          'check_var': checkVar,
          'operator': operator,
          if (compareValue != null) 'compare_value': compareValue,
          'output_var': outputVar,
        },
      };

  factory ConditionNode.fromJson(Map<String, dynamic> json) {
    final config = json['config'] as Map<String, dynamic>? ?? {};
    return ConditionNode(
      id: json['id'] as String,
      checkVar: config['check_var'] as String? ?? '',
      operator: config['operator'] as String? ?? '==',
      compareValue: config['compare_value'],
      outputVar: config['output_var'] as String? ?? 'condition_result',
    );
  }

  @override
  IInstructionNode copyWith({
    String? id,
    String? checkVar,
    String? operator,
    dynamic compareValue,
    String? outputVar,
  }) {
    return ConditionNode(
      id: id ?? this.id,
      checkVar: checkVar ?? this.checkVar,
      operator: operator ?? this.operator,
      compareValue: compareValue ?? this.compareValue,
      outputVar: outputVar ?? this.outputVar,
    );
  }
}
