// Git Commit Node - коммит через Tool

import 'package:aq_schema/graph/nodes/base/automatic_node.dart';
import 'package:aq_schema/graph/nodes/base/i_workflow_node.dart';
import 'package:aq_schema/graph/engine/run_context.dart';

/// Узел для Git коммита
///
/// Выполняет git commit через Tool 'git_commit'
class GitCommitNode extends AutomaticNode {
  @override
  final String id;

  @override
  final String nodeType = 'gitCommit';

  /// Сообщение коммита (может содержать {{variables}})
  final String message;

  /// Переменная с путями файлов для добавления (опционально)
  final String? filesVar;

  GitCommitNode({
    required this.id,
    required this.message,
    this.filesVar,
  });

  @override
  Future<dynamic> execute(
    RunContext context,
  ) async {
    // Подставить переменные в сообщение
    final resolvedMessage = substituteVariables(message, context);

    if (resolvedMessage.trim().isEmpty) {
      throw Exception('GitCommitNode: commit message is empty');
    }

    // ИСПРАВЛЕНИЕ: Валидация сообщения для защиты от command injection
    _validateCommitMessage(resolvedMessage);

    // Получить список файлов если указан
    final params = <String, dynamic>{
      'message': resolvedMessage,
    };

    if (filesVar != null) {
      final files = context.getVar(filesVar!);
      if (files != null) {
        // ИСПРАВЛЕНИЕ: Валидация путей файлов
        if (files is List) {
          for (final file in files) {
            if (file is String) {
              _validateFilePath(file, context);
            }
          }
        }
        params['files'] = files;
      }
    }

    // // Выполнить коммит через AQToolService
    // final result = await tools.callTool(
    //   'git_commit',
    //   params,
    //   context,
    // );

    // context.log(
    //   'Git commit: $resolvedMessage',
    //   branch: context.currentBranch,
    // );

    // return result;
  }

  /// ИСПРАВЛЕНИЕ: Валидация commit message для защиты от command injection
  void _validateCommitMessage(String message) {
    // Проверка на опасные символы для command injection
    final dangerousChars = [';', '|', '&', '`', '\$', '\n', '\r'];
    for (final char in dangerousChars) {
      if (message.contains(char)) {
        throw Exception(
            'GitCommitNode: недопустимый символ "$char" в commit message (command injection)');
      }
    }

    // Проверка на опасные команды в сообщении
    final dangerousPatterns = [
      'rm -rf',
      'dd if=',
      ':(){ :|:& };:', // fork bomb
      'curl',
      'wget',
      'nc ',
      'netcat',
    ];

    final lowerMessage = message.toLowerCase();
    for (final pattern in dangerousPatterns) {
      if (lowerMessage.contains(pattern.toLowerCase())) {
        throw Exception(
            'GitCommitNode: опасная команда "$pattern" в commit message');
      }
    }
  }

  /// Валидация путей файлов
  void _validateFilePath(String path, RunContext context) {
    // Проверка на command injection
    final dangerousChars = [';', '|', '&', '`', '\$'];
    for (final char in dangerousChars) {
      if (path.contains(char)) {
        throw Exception(
            'GitCommitNode: недопустимый символ "$char" в пути файла');
      }
    }

    // Проверка на path traversal
    if (path.contains('..')) {
      throw Exception('GitCommitNode: path traversal запрещён');
    }

    // Проверка что файл внутри projectPath
    final projectPath = context.projectPath;
    if (path.startsWith('/') && !path.startsWith(projectPath)) {
      throw Exception(
          'GitCommitNode: файл вне projectPath ($path не в $projectPath)');
    }
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': nodeType,
        'config': {
          'message': message,
          if (filesVar != null) 'files_var': filesVar,
        },
      };

  factory GitCommitNode.fromJson(Map<String, dynamic> json) {
    final config = json['config'] as Map<String, dynamic>? ?? {};
    return GitCommitNode(
      id: json['id'] as String,
      message: config['message'] as String? ?? '',
      filesVar: config['files_var'] as String?,
    );
  }

  @override
  IWorkflowNode copyWith({
    String? id,
    String? message,
    String? filesVar,
  }) {
    return GitCommitNode(
      id: id ?? this.id,
      message: message ?? this.message,
      filesVar: filesVar ?? this.filesVar,
    );
  }
}
