// Co-Creation Chat Node - интерактивный чат с пользователем

import 'package:aq_schema/graph/nodes/base/interactive_node.dart';
import 'package:aq_schema/graph/nodes/base/i_workflow_node.dart';
import 'package:aq_schema/graph/engine/run_context.dart';

/// Узел для интерактивного чата с пользователем
///
/// Позволяет вести диалог с пользователем в процессе выполнения
class CoCreationChatNode extends InteractiveNode {
  @override
  final String id;

  @override
  final String nodeType = 'coCreationChat';

  /// Заголовок чата
  final String title;

  /// Начальное сообщение от системы
  final String initialMessage;

  /// Переменная для сохранения истории чата
  final String chatHistoryVar;

  /// Переменная для сохранения последнего ответа пользователя
  final String outputVar;

  CoCreationChatNode({
    required this.id,
    required this.title,
    required this.initialMessage,
    required this.chatHistoryVar,
    required this.outputVar,
  });

  @override
  Future<dynamic> execute(
    RunContext context,
  ) async {
    // Проверить, есть ли уже ответ пользователя (resume после suspend)
    if (hasUserResponse(context, outputVar)) {
      final userMessage = context.getVar(outputVar);

      // Добавить в историю чата
      final existingHistory =
          context.getVar(chatHistoryVar) as List<dynamic>? ?? [];
      final history = List<Map<String, dynamic>>.from(
        existingHistory.map((e) => Map<String, dynamic>.from(e as Map)),
      );
      history.add({'role': 'user', 'content': userMessage});
      context.setVar(chatHistoryVar, history);

      context.log(
        'Chat message received from user',
        branch: context.currentBranch,
      );
      return userMessage;
    }

    // Инициализировать историю чата если её нет
    if (context.getVar(chatHistoryVar) == null) {
      context.setVar(chatHistoryVar, [
        {'role': 'system', 'content': initialMessage}
      ]);
    }

    // Нет ответа - приостановить выполнение
    throwSuspendException(id, 'Waiting for user message in chat: $title');
  }

  @override
  Map<String, dynamic> getUiConfig() => {
        'title': title,
        'message': initialMessage,
        'type': 'chat',
        'chat_history_var': chatHistoryVar,
        'output_var': outputVar,
      };

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': nodeType,
        'config': {
          'title': title,
          'initial_message': initialMessage,
          'chat_history_var': chatHistoryVar,
          'output_var': outputVar,
        },
      };

  factory CoCreationChatNode.fromJson(Map<String, dynamic> json) {
    final config = json['config'] as Map<String, dynamic>? ?? {};
    return CoCreationChatNode(
      id: json['id'] as String,
      title: config['title'] as String? ?? '',
      initialMessage: config['initial_message'] as String? ?? '',
      chatHistoryVar: config['chat_history_var'] as String? ?? 'chat_history',
      outputVar: config['output_var'] as String? ?? 'user_message',
    );
  }

  @override
  IWorkflowNode copyWith({
    String? id,
    String? title,
    String? initialMessage,
    String? chatHistoryVar,
    String? outputVar,
  }) {
    return CoCreationChatNode(
      id: id ?? this.id,
      title: title ?? this.title,
      initialMessage: initialMessage ?? this.initialMessage,
      chatHistoryVar: chatHistoryVar ?? this.chatHistoryVar,
      outputVar: outputVar ?? this.outputVar,
    );
  }
}
