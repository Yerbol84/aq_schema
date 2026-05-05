// AutomaticWorkflowNode — универсальный автоматический узел.
// Заменяет LlmActionNode, FileReadNode, FileWriteNode, GitCommitNode.
// Узел не знает что делает инструмент — только вызывает его по имени.

import 'package:aq_schema/graph/nodes/base/automatic_node.dart';
import 'package:aq_schema/graph/nodes/base/i_workflow_node.dart';
import 'package:aq_schema/graph/engine/run_context.dart';
import 'package:aq_schema/tools.dart';

/// Универсальный автоматический узел — вызывает инструмент через IToolEngineProtocol.
///
/// Типизация по поведению в графе (автоматический, без suspend),
/// а не по типу действия.
///
/// Примеры:
/// ```dart
/// // Вместо LlmActionNode:
/// AutomaticWorkflowNode(id: 'n1', toolName: 'llm_ask',
///   params: {'prompt': '{{compiled_prompt}}'}, outputVar: 'result')
///
/// // Вместо FileReadNode:
/// AutomaticWorkflowNode(id: 'n2', toolName: 'fs_read',
///   params: {'path': '{{file_path}}'}, outputVar: 'content')
/// ```
class AutomaticWorkflowNode extends AutomaticNode {
  @override
  final String id;

  @override
  final String nodeType = 'automatic';

  /// Имя инструмента для вызова через IToolEngineProtocol
  final String toolName;

  /// Параметры инструмента (могут содержать {{variables}})
  final Map<String, dynamic> params;

  /// Переменная для сохранения результата в RunContext
  final String outputVar;

  AutomaticWorkflowNode({
    required this.id,
    required this.toolName,
    this.params = const {},
    required this.outputVar,
  });

  @override
  Future<dynamic> execute(RunContext context) async {
    if (toolName.isEmpty) {
      throw Exception('AutomaticWorkflowNode [$id]: toolName is required');
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

  /// Подставляет {{variables}} в строковые значения параметров
  Map<String, dynamic> _resolveParams(
      Map<String, dynamic> raw, RunContext context) {
    return raw.map((key, value) {
      if (value is String) return MapEntry(key, substituteVariables(value, context));
      return MapEntry(key, value);
    });
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': nodeType,
        'toolName': toolName,
        'params': params,
        'outputVar': outputVar,
      };

  factory AutomaticWorkflowNode.fromJson(Map<String, dynamic> json) =>
      AutomaticWorkflowNode(
        id: json['id'] as String,
        toolName: json['toolName'] as String,
        params: (json['params'] as Map?)?.cast<String, dynamic>() ?? const {},
        outputVar: json['outputVar'] as String? ?? 'result',
      );

  @override
  IWorkflowNode copyWith({
    String? id,
    String? toolName,
    Map<String, dynamic>? params,
    String? outputVar,
  }) =>
      AutomaticWorkflowNode(
        id: id ?? this.id,
        toolName: toolName ?? this.toolName,
        params: params ?? this.params,
        outputVar: outputVar ?? this.outputVar,
      );
}
