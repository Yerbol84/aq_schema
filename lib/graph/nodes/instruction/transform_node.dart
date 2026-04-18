// Transform Node - преобразование данных

import 'package:aq_schema/graph/nodes/base/i_instruction_node.dart';
import 'package:aq_schema/graph/engine/run_context.dart';

/// Узел для преобразования данных
///
/// Применяет трансформацию к данным из переменной
class TransformNode implements IInstructionNode {
  @override
  final String id;

  @override
  final String nodeType = 'transform';

  /// Переменная с исходными данными
  final String inputVar;

  /// Тип трансформации (extract, format, parse, concat, split)
  final String transformType;

  /// Параметры трансформации
  final Map<String, dynamic> params;

  /// Переменная для сохранения результата
  final String outputVar;

  const TransformNode({
    required this.id,
    required this.inputVar,
    required this.transformType,
    this.params = const {},
    required this.outputVar,
  });

  @override
  Future<dynamic> execute(
    RunContext context,
  ) async {
    // Получить исходные данные
    final input = context.getVar(inputVar);
    if (input == null) {
      throw Exception('TransformNode: variable $inputVar not found');
    }

    // Применить трансформацию
    final result = _applyTransform(input, transformType, params, context);

    // Сохранить результат
    context.setVar(outputVar, result);

    context.log(
      'Transform "$transformType" applied to $inputVar',
      branch: context.currentBranch,
    );

    return result;
  }

  dynamic _applyTransform(
    dynamic input,
    String type,
    Map<String, dynamic> params,
    RunContext context,
  ) {
    switch (type) {
      case 'extract':
        // Извлечь часть строки по regex
        final pattern = params['pattern'] as String?;
        if (pattern == null) {
          throw Exception('TransformNode: extract requires "pattern" param');
        }
        final regex = RegExp(pattern);
        final match = regex.firstMatch(input.toString());
        return match?.group(params['group'] as int? ?? 0) ?? '';

      case 'format':
        // Форматировать строку с подстановкой переменных
        final template = params['template'] as String?;
        if (template == null) {
          throw Exception('TransformNode: format requires "template" param');
        }
        return _substituteVariables(template, context);

      case 'parse':
        // Парсить JSON
        if (params['type'] == 'json') {
          // В реальности здесь будет json.decode
          return input.toString();
        }
        return input;

      case 'concat':
        // Объединить с другими переменными
        final parts = params['parts'] as List<dynamic>? ?? [];
        final buffer = StringBuffer(input.toString());
        for (final part in parts) {
          if (part is String && part.startsWith('{{')) {
            final varName = part.replaceAll(RegExp(r'[{}]'), '');
            final value = context.getVar(varName);
            if (value != null) {
              buffer.write(value.toString());
            }
          } else {
            buffer.write(part.toString());
          }
        }
        return buffer.toString();

      case 'split':
        // Разделить строку
        final separator = params['separator'] as String? ?? ',';
        return input.toString().split(separator);

      case 'trim':
        return input.toString().trim();

      case 'toLowerCase':
        return input.toString().toLowerCase();

      case 'toUpperCase':
        return input.toString().toUpperCase();

      default:
        throw Exception('TransformNode: unknown transform type "$type"');
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
          'input_var': inputVar,
          'transform_type': transformType,
          'params': params,
          'output_var': outputVar,
        },
      };

  factory TransformNode.fromJson(Map<String, dynamic> json) {
    final config = json['config'] as Map<String, dynamic>? ?? {};
    return TransformNode(
      id: json['id'] as String,
      inputVar: config['input_var'] as String? ?? '',
      transformType: config['transform_type'] as String? ?? 'format',
      params: config['params'] as Map<String, dynamic>? ?? {},
      outputVar: config['output_var'] as String? ?? 'transform_result',
    );
  }

  @override
  IInstructionNode copyWith({
    String? id,
    String? inputVar,
    String? transformType,
    Map<String, dynamic>? params,
    String? outputVar,
  }) {
    return TransformNode(
      id: id ?? this.id,
      inputVar: inputVar ?? this.inputVar,
      transformType: transformType ?? this.transformType,
      params: params ?? this.params,
      outputVar: outputVar ?? this.outputVar,
    );
  }
}
