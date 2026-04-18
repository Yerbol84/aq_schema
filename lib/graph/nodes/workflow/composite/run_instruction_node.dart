// Run Instruction Node - выполнение InstructionGraph

import 'package:aq_schema/graph/nodes/base/composite_node.dart';
import 'package:aq_schema/graph/nodes/base/i_workflow_node.dart';
import 'package:aq_schema/graph/engine/run_context.dart';

/// Узел для выполнения InstructionGraph
///
/// Загружает InstructionGraph и выполняет его как функцию
/// Инструкция работает в изолированном контексте без suspend/resume
class RunInstructionNode extends CompositeNode {
  static int _executionCounter = 0;

  @override
  final String id;

  @override
  final String nodeType = 'runInstruction';

  @override
  final String subGraphId;

  @override
  final Map<String, String> inputMapping;

  @override
  final Map<String, String> outputMapping;

  RunInstructionNode({
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
      throw Exception(
          'RunInstructionNode: subGraphId (instructionId) is required');
    }

    // ИСПРАВЛЕНО: Создать изолированный контекст для инструкции
    // Используем правильные параметры RunContext
    // Добавлен счётчик для уникальности runId
    final executionId = _executionCounter++;
    final instructionContext = RunContext(
      runId: '${context.runId}_instr_${id}_$executionId',
      projectId: context.projectId,
      projectPath: context.projectPath,
      log: context.log,
      currentBranch: '${context.currentBranch}_instr',
    );

    // Применить input mapping
    applyInputMapping(context, instructionContext);

    context.log(
      'Starting instruction: $subGraphId',
      branch: context.currentBranch,
    );

    // Выполнение инструкции будет делать InstructionRunner
    // Инструкция выполняется полностью без пауз
    // Результат выполнения будет в instructionContext

    // После выполнения применить output mapping
    // (это будет делать Runner после завершения инструкции)

    return instructionContext;
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': nodeType,
        'config': {
          'instruction_id': subGraphId,
          'input_mapping': inputMapping,
          'output_mapping': outputMapping,
        },
      };

  factory RunInstructionNode.fromJson(Map<String, dynamic> json) {
    final config = json['config'] as Map<String, dynamic>? ?? {};
    return RunInstructionNode(
      id: json['id'] as String,
      subGraphId: config['instruction_id'] as String? ?? '',
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
    return RunInstructionNode(
      id: id ?? this.id,
      subGraphId: subGraphId ?? this.subGraphId,
      inputMapping: inputMapping ?? this.inputMapping,
      outputMapping: outputMapping ?? this.outputMapping,
    );
  }
}
