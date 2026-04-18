// Variable Insert Node - вставка переменной

import 'package:aq_schema/graph/nodes/base/i_prompt_node.dart';
import 'package:aq_schema/graph/engine/run_context.dart';

/// Узел для вставки переменной в промпт
///
/// Получает значение переменной из контекста и возвращает как строку
class VariableInsertNode implements IPromptNode {
  @override
  final String id;

  @override
  final String nodeType = 'variableInsert';

  /// Имя переменной для вставки
  final String varName;

  /// Префикс перед значением (опционально)
  final String? prefix;

  /// Суффикс после значения (опционально)
  final String? suffix;

  /// Значение по умолчанию если переменная не найдена
  final String? defaultValue;

  const VariableInsertNode({
    required this.id,
    required this.varName,
    this.prefix,
    this.suffix,
    this.defaultValue,
  });

  @override
  Future<String> execute(RunContext context) async {
    // Получить значение переменной
    final value = context.getVar(varName);
    final valueStr = value?.toString() ?? defaultValue ?? '';

    if (valueStr.isEmpty && defaultValue == null) {
      context.log(
        'Warning: variable $varName not found and no default value',
        branch: context.currentBranch,
      );
    }

    // Собрать результат с prefix/suffix
    final buffer = StringBuffer();
    if (prefix != null && valueStr.isNotEmpty) {
      buffer.write(prefix);
    }
    buffer.write(valueStr);
    if (suffix != null && valueStr.isNotEmpty) {
      buffer.write(suffix);
    }

    final result = buffer.toString();

    context.log(
      'Variable "$varName" inserted (${result.length} chars)',
      branch: context.currentBranch,
    );

    return result;
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': nodeType,
        'config': {
          'var_name': varName,
          if (prefix != null) 'prefix': prefix,
          if (suffix != null) 'suffix': suffix,
          if (defaultValue != null) 'default_value': defaultValue,
        },
      };

  factory VariableInsertNode.fromJson(Map<String, dynamic> json) {
    final config = json['config'] as Map<String, dynamic>? ?? {};
    return VariableInsertNode(
      id: json['id'] as String,
      varName: config['var_name'] as String? ?? '',
      prefix: config['prefix'] as String?,
      suffix: config['suffix'] as String?,
      defaultValue: config['default_value'] as String?,
    );
  }

  @override
  IPromptNode copyWith({
    String? id,
    String? varName,
    String? prefix,
    String? suffix,
    String? defaultValue,
  }) {
    return VariableInsertNode(
      id: id ?? this.id,
      varName: varName ?? this.varName,
      prefix: prefix ?? this.prefix,
      suffix: suffix ?? this.suffix,
      defaultValue: defaultValue ?? this.defaultValue,
    );
  }
}
