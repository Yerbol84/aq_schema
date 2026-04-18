// Text Block Node - статический текстовый блок

import 'package:aq_schema/graph/nodes/base/i_prompt_node.dart';
import 'package:aq_schema/graph/engine/run_context.dart';

/// Узел для статического текстового блока
///
/// Возвращает текст с подстановкой переменных
class TextBlockNode implements IPromptNode {
  @override
  final String id;

  @override
  final String nodeType = 'textBlock';

  /// Текст блока (может содержать {{variables}})
  final String text;

  const TextBlockNode({
    required this.id,
    required this.text,
  });

  @override
  Future<String> execute(RunContext context) async {
    // Подставить переменные
    final result = _substituteVariables(text, context);

    context.log(
      'Text block compiled (${result.length} chars)',
      branch: context.currentBranch,
    );

    return result;
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
          'text': text,
        },
      };

  factory TextBlockNode.fromJson(Map<String, dynamic> json) {
    final config = json['config'] as Map<String, dynamic>? ?? {};
    return TextBlockNode(
      id: json['id'] as String,
      text: config['text'] as String? ?? '',
    );
  }

  @override
  IPromptNode copyWith({
    String? id,
    String? text,
  }) {
    return TextBlockNode(
      id: id ?? this.id,
      text: text ?? this.text,
    );
  }
}
