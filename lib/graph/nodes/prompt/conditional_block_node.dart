// Conditional Block Node - условный блок текста

import 'package:aq_schema/graph/nodes/base/i_prompt_node.dart';
import 'package:aq_schema/graph/engine/run_context.dart';

/// Узел для условного блока текста
///
/// Возвращает текст только если условие выполнено
class ConditionalBlockNode implements IPromptNode {
  @override
  final String id;

  @override
  final String nodeType = 'conditionalBlock';

  /// Переменная для проверки
  final String checkVar;

  /// Оператор сравнения (==, !=, isEmpty, isNotEmpty, exists)
  final String operator;

  /// Значение для сравнения (опционально)
  final dynamic compareValue;

  /// Текст если условие true (может содержать {{variables}})
  final String textIfTrue;

  /// Текст если условие false (опционально)
  final String? textIfFalse;

  const ConditionalBlockNode({
    required this.id,
    required this.checkVar,
    required this.operator,
    this.compareValue,
    required this.textIfTrue,
    this.textIfFalse,
  });

  @override
  Future<String> execute(RunContext context) async {
    // Получить значение переменной
    final value = context.getVar(checkVar);

    // Вычислить условие
    final condition = _evaluateCondition(value, operator, compareValue);

    // Выбрать текст
    final text = condition ? textIfTrue : (textIfFalse ?? '');

    // Подставить переменные
    final result = _substituteVariables(text, context);

    context.log(
      'Conditional block: $checkVar $operator $compareValue = $condition',
      branch: context.currentBranch,
    );

    return result;
  }

  bool _evaluateCondition(dynamic value, String op, dynamic compareValue) {
    switch (op) {
      case '==':
        return value == compareValue;
      case '!=':
        return value != compareValue;
      case 'isEmpty':
        return value == null || value.toString().isEmpty;
      case 'isNotEmpty':
        return value != null && value.toString().isNotEmpty;
      case 'exists':
        return value != null;
      case 'notExists':
        return value == null;
      default:
        throw Exception('ConditionalBlockNode: unknown operator "$op"');
    }
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
          'text_if_true': textIfTrue,
          if (textIfFalse != null) 'text_if_false': textIfFalse,
        },
      };

  factory ConditionalBlockNode.fromJson(Map<String, dynamic> json) {
    final config = json['config'] as Map<String, dynamic>? ?? {};
    return ConditionalBlockNode(
      id: json['id'] as String,
      checkVar: config['check_var'] as String? ?? '',
      operator: config['operator'] as String? ?? 'exists',
      compareValue: config['compare_value'],
      textIfTrue: config['text_if_true'] as String? ?? '',
      textIfFalse: config['text_if_false'] as String?,
    );
  }

  @override
  IPromptNode copyWith({
    String? id,
    String? checkVar,
    String? operator,
    dynamic compareValue,
    String? textIfTrue,
    String? textIfFalse,
  }) {
    return ConditionalBlockNode(
      id: id ?? this.id,
      checkVar: checkVar ?? this.checkVar,
      operator: operator ?? this.operator,
      compareValue: compareValue ?? this.compareValue,
      textIfTrue: textIfTrue ?? this.textIfTrue,
      textIfFalse: textIfFalse ?? this.textIfFalse,
    );
  }
}
