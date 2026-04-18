// User Input Node - запрос ввода от пользователя

import 'package:aq_schema/graph/nodes/base/interactive_node.dart';
import 'package:aq_schema/graph/nodes/base/i_workflow_node.dart';
import 'package:aq_schema/graph/engine/run_context.dart';

/// Узел для запроса ввода от пользователя
///
/// Приостанавливает выполнение и ждет ввода через UI
class UserInputNode extends InteractiveNode {
  @override
  final String id;

  @override
  final String nodeType = 'userInput';

  /// Заголовок формы ввода
  final String title;

  /// Описание что нужно ввести
  final String message;

  /// Переменная для сохранения ответа
  final String outputVar;

  /// Тип ввода (text, number, multiline)
  final String inputType;

  UserInputNode({
    required this.id,
    required this.title,
    required this.message,
    required this.outputVar,
    this.inputType = 'text',
  });

  @override
  Future<dynamic> execute(
    RunContext context,
  ) async {
    // Проверить, есть ли уже ответ (resume после suspend)
    if (hasUserResponse(context, outputVar)) {
      final value = context.getVar(outputVar);
      final valueStr = value.toString();
      final preview =
          valueStr.length > 50 ? '${valueStr.substring(0, 50)}...' : valueStr;
      context.log(
        'User input received: $preview',
        branch: context.currentBranch,
      );
      return value;
    }

    // Нет ответа - приостановить выполнение
    throwSuspendException(id, 'Waiting for user input: $title');
  }

  @override
  Map<String, dynamic> getUiConfig() => {
        'title': title,
        'message': message,
        'type': 'text_input',
        'input_type': inputType,
        'output_var': outputVar,
      };

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': nodeType,
        'config': {
          'title': title,
          'message': message,
          'output_var': outputVar,
          'input_type': inputType,
        },
      };

  factory UserInputNode.fromJson(Map<String, dynamic> json) {
    final config = json['config'] as Map<String, dynamic>? ?? {};
    return UserInputNode(
      id: json['id'] as String,
      title: config['title'] as String? ?? '',
      message: config['message'] as String? ?? '',
      outputVar: config['output_var'] as String? ?? 'user_input',
      inputType: config['input_type'] as String? ?? 'text',
    );
  }

  @override
  IWorkflowNode copyWith({
    String? id,
    String? title,
    String? message,
    String? outputVar,
    String? inputType,
  }) {
    return UserInputNode(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      outputVar: outputVar ?? this.outputVar,
      inputType: inputType ?? this.inputType,
    );
  }
}
