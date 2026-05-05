// LLM Query Node - запрос к LLM

import 'package:aq_schema/graph/nodes/base/i_instruction_node.dart';
import 'package:aq_schema/graph/engine/run_context.dart';
import 'package:aq_schema/tools.dart';
import 'package:aq_schema/tools.dart';

/// Узел для запроса к LLM
///
/// Компилирует промпт и вызывает LLM
class LlmQueryNode extends IInstructionNode {
  @override
  final String id;

  @override
  final String nodeType = 'llmQuery';

  /// ID PromptGraph для компиляции промпта
  final String? promptBlueprintId;

  /// Прямой текст промпта (если не используется PromptGraph)
  final String? directPrompt;

  /// Переменная для сохранения результата
  final String outputVar;

  /// Название модели (опционально)
  final String? modelName;

  const LlmQueryNode({
    required this.id,
    this.promptBlueprintId,
    this.directPrompt,
    required this.outputVar,
    this.modelName,
  });

  @override
  Future<dynamic> execute(RunContext context) async {
    final String prompt;
    if (promptBlueprintId != null && promptBlueprintId!.isNotEmpty) {
      final compiled = context.getVar('_compiled_prompt_$id');
      if (compiled == null) {
        throw Exception('LlmQueryNode: compiled prompt not found in context');
      }
      prompt = compiled.toString();
    } else if (directPrompt != null && directPrompt!.isNotEmpty) {
      prompt = _substituteVariables(directPrompt!, context);
    } else {
      throw Exception(
          'LlmQueryNode: either promptBlueprintId or directPrompt is required');
    }

    final result = await IToolEngineProtocol.instance.callTool(
      'llm_ask',
      {
        'prompt': prompt,
        if (modelName != null) 'model_name': modelName,
      },
      context,
    );

    final output = result.success ? result.output : null;
    context.setVar(outputVar, output);
    context.log(
      'LLM query executed (${output?.toString().length ?? 0} chars)',
      branch: context.currentBranch,
    );
    return output;
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
          if (promptBlueprintId != null)
            'prompt_blueprint_id': promptBlueprintId,
          if (directPrompt != null) 'direct_prompt': directPrompt,
          'output_var': outputVar,
          if (modelName != null) 'model_name': modelName,
        },
      };

  factory LlmQueryNode.fromJson(Map<String, dynamic> json) {
    final config = json['config'] as Map<String, dynamic>? ?? {};
    return LlmQueryNode(
      id: json['id'] as String,
      promptBlueprintId: config['prompt_blueprint_id'] as String?,
      directPrompt: config['direct_prompt'] as String?,
      outputVar: config['output_var'] as String? ?? 'llm_result',
      modelName: config['model_name'] as String?,
    );
  }

  @override
  IInstructionNode copyWith({
    String? id,
    String? promptBlueprintId,
    String? directPrompt,
    String? outputVar,
    String? modelName,
  }) {
    return LlmQueryNode(
      id: id ?? this.id,
      promptBlueprintId: promptBlueprintId ?? this.promptBlueprintId,
      directPrompt: directPrompt ?? this.directPrompt,
      outputVar: outputVar ?? this.outputVar,
      modelName: modelName ?? this.modelName,
    );
  }
}
