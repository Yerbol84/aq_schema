// LLM Action Node - вызов LLM через Tool

import 'package:aq_schema/graph/nodes/base/automatic_node.dart';
import 'package:aq_schema/graph/nodes/base/i_workflow_node.dart';
import 'package:aq_schema/graph/engine/run_context.dart';

/// Узел для вызова LLM
///
/// Загружает PromptGraph, компилирует промпт, вызывает LLM через Tool
class LlmActionNode extends AutomaticNode {
  @override
  final String id;

  @override
  final String nodeType = 'llmAction';

  /// ID PromptGraph для компиляции промпта
  final String? promptBlueprintId;

  /// Переменная для сохранения результата
  final String outputVar;

  /// Название модели (опционально)
  final String? modelName;

  LlmActionNode({
    required this.id,
    this.promptBlueprintId,
    required this.outputVar,
    this.modelName,
  });

  @override
  Future<dynamic> execute(
    RunContext context,
  ) async {
    if (promptBlueprintId == null || promptBlueprintId!.isEmpty) {
      throw Exception('LlmActionNode: promptBlueprintId is required');
    }

    // Промпт будет скомпилирован через PromptRunner в движке
    // Здесь мы просто вызываем Tool с уже скомпилированным промптом
    // который должен быть в контексте
    final compiledPrompt = context.getVar('_compiled_prompt_$id');
    if (compiledPrompt == null) {
      throw Exception('LlmActionNode: compiled prompt not found in context');
    }

    // // Вызвать LLM через AQToolService
    // final result = await tools.callTool('llm_ask', {
    //   'prompt': compiledPrompt,
    //   if (modelName != null) 'model_name': modelName,
    // }, context);

    // // Сохранить результат
    // context.setVar(outputVar, result);

    // context.log(
    //   'LLM generated ${result.toString().length} chars',
    //   branch: context.currentBranch,
    // );

    // return result;
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': nodeType,
        'config': {
          'prompt_blueprint_id': promptBlueprintId,
          'output_var': outputVar,
          if (modelName != null) 'model_name': modelName,
        },
      };

  factory LlmActionNode.fromJson(Map<String, dynamic> json) {
    final config = json['config'] as Map<String, dynamic>? ?? {};
    return LlmActionNode(
      id: json['id'] as String,
      promptBlueprintId: config['prompt_blueprint_id'] as String?,
      outputVar: config['output_var'] as String? ?? 'llm_result',
      modelName: config['model_name'] as String?,
    );
  }

  @override
  IWorkflowNode copyWith({
    String? id,
    String? promptBlueprintId,
    String? outputVar,
    String? modelName,
  }) {
    return LlmActionNode(
      id: id ?? this.id,
      promptBlueprintId: promptBlueprintId ?? this.promptBlueprintId,
      outputVar: outputVar ?? this.outputVar,
      modelName: modelName ?? this.modelName,
    );
  }
}
