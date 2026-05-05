// Tool Call Node - вызов инструмента

import 'package:aq_schema/graph/nodes/base/i_instruction_node.dart';
import 'package:aq_schema/graph/engine/run_context.dart';
import 'package:aq_schema/tools.dart';

/// Узел для вызова инструмента (Tool)
///
/// Вызывает любой зарегистрированный Tool с параметрами
class ToolCallNode extends IInstructionNode {
  @override
  final String id;

  @override
  final String nodeType = 'toolCall';

  /// Название инструмента для вызова
  final String toolName;

  /// Параметры для инструмента (могут содержать {{variables}})
  final Map<String, dynamic> params;

  /// Переменная для сохранения результата
  final String outputVar;

  const ToolCallNode({
    required this.id,
    required this.toolName,
    this.params = const {},
    required this.outputVar,
  });

  @override
  Future<dynamic> execute(RunContext context) async {
    if (toolName.isEmpty) {
      throw Exception('ToolCallNode: toolName is required');
    }

    final resolvedParams = _resolveParams(params, context);
    final result = await IToolEngineProtocol.instance.callTool(
      toolName,
      resolvedParams,
      context,
    );

    final output = result.success ? result.output : null;
    context.setVar(outputVar, output);
    context.log('Tool "$toolName" executed', branch: context.currentBranch);
    return output;
  }

  Map<String, dynamic> _resolveParams(
    Map<String, dynamic> params,
    RunContext context,
  ) {
    final resolved = <String, dynamic>{};
    for (final entry in params.entries) {
      final value = entry.value;
      if (value is String && value.contains('{{')) {
        // Подставить переменные
        resolved[entry.key] = _substituteVariables(value, context);
      } else {
        resolved[entry.key] = value;
      }
    }
    return resolved;
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
          'tool_name': toolName,
          'params': params,
          'output_var': outputVar,
        },
      };

  factory ToolCallNode.fromJson(Map<String, dynamic> json) {
    final config = json['config'] as Map<String, dynamic>? ?? {};
    return ToolCallNode(
      id: json['id'] as String,
      toolName: config['tool_name'] as String? ?? '',
      params: config['params'] as Map<String, dynamic>? ?? {},
      outputVar: config['output_var'] as String? ?? 'tool_result',
    );
  }

  @override
  IInstructionNode copyWith({
    String? id,
    String? toolName,
    Map<String, dynamic>? params,
    String? outputVar,
  }) {
    return ToolCallNode(
      id: id ?? this.id,
      toolName: toolName ?? this.toolName,
      params: params ?? this.params,
      outputVar: outputVar ?? this.outputVar,
    );
  }
}
