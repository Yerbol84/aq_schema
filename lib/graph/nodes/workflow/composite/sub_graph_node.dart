// SubGraph Node - выполнение вложенного WorkflowGraph

import 'package:aq_schema/graph/nodes/base/composite_node.dart';
import 'package:aq_schema/graph/nodes/base/i_workflow_node.dart';
import 'package:aq_schema/graph/engine/run_context.dart';

/// Узел для выполнения вложенного WorkflowGraph
///
/// Загружает другой WorkflowGraph и выполняет его как подзадачу
class SubGraphNode extends CompositeNode {
  static int _executionCounter = 0;

  @override
  final String id;

  @override
  final String nodeType = 'subGraph';

  @override
  final String subGraphId;

  @override
  final Map<String, String> inputMapping;

  @override
  final Map<String, String> outputMapping;

  SubGraphNode({
    required this.id,
    required this.subGraphId,
    this.inputMapping = const {},
    this.outputMapping = const {},
  });

  @override
  Future<dynamic> execute(
    RunContext context,
  ) async {
    if (subGraphId.isEmpty) {
      throw Exception('SubGraphNode: subGraphId is required');
    }

    // ИСПРАВЛЕНО: Создать изолированный контекст для подграфа
    // Используем правильные параметры RunContext
    // Добавлен счётчик для уникальности runId
    final executionId = _executionCounter++;
    final subContext = RunContext(
      runId: '${context.runId}_sub_${id}_$executionId',
      projectId: context.projectId,
      projectPath: context.projectPath,
      log: context.log,
      currentBranch: '${context.currentBranch}_sub',
    );

    // Применить input mapping
    applyInputMapping(context, subContext);

    context.log(
      'Starting subgraph: $subGraphId',
      branch: context.currentBranch,
    );

    // Выполнение подграфа будет делать WorkflowRunner
    // Здесь мы только подготавливаем контекст и маппинг
    // Результат выполнения будет в subContext

    // После выполнения применить output mapping
    // (это будет делать Runner после завершения подграфа)

    return subContext;
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': nodeType,
        'config': {
          'sub_graph_id': subGraphId,
          'input_mapping': inputMapping,
          'output_mapping': outputMapping,
        },
      };

  factory SubGraphNode.fromJson(Map<String, dynamic> json) {
    final config = json['config'] as Map<String, dynamic>? ?? {};
    return SubGraphNode(
      id: json['id'] as String,
      subGraphId: config['sub_graph_id'] as String? ?? '',
      inputMapping: (config['input_mapping'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v.toString())) ??
          {},
      outputMapping: (config['output_mapping'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v.toString())) ??
          {},
    );
  }

  @override
  IWorkflowNode copyWith({
    String? id,
    String? subGraphId,
    Map<String, String>? inputMapping,
    Map<String, String>? outputMapping,
  }) {
    return SubGraphNode(
      id: id ?? this.id,
      subGraphId: subGraphId ?? this.subGraphId,
      inputMapping: inputMapping ?? this.inputMapping,
      outputMapping: outputMapping ?? this.outputMapping,
    );
  }
}
