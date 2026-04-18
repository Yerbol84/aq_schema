// File Write Node - запись файла через Tool

import 'package:aq_schema/graph/nodes/base/automatic_node.dart';
import 'package:aq_schema/graph/nodes/base/i_workflow_node.dart';
import 'package:aq_schema/graph/engine/run_context.dart';

/// Узел для записи файла
///
/// Записывает файл через Tool 'fs_write_file'
class FileWriteNode extends AutomaticNode {
  @override
  final String id;

  @override
  final String nodeType = 'fileWrite';

  /// Путь к файлу (может содержать {{variables}})
  final String filePath;

  /// Переменная с содержимым для записи
  final String inputVar;

  FileWriteNode({
    required this.id,
    required this.filePath,
    required this.inputVar,
  });

  @override
  Future<dynamic> execute(
    RunContext context,
  ) async {
    // Подставить переменные в путь
    final resolvedPath = substituteVariables(filePath, context);

    if (resolvedPath.trim().isEmpty) {
      throw Exception('FileWriteNode: file path is empty');
    }

    // ИСПРАВЛЕНИЕ: Валидация пути для защиты от injection и path traversal
    _validateFilePath(resolvedPath, context);

    // Получить содержимое из контекста
    final content = context.getVar(inputVar);
    if (content == null) {
      throw Exception('FileWriteNode: variable $inputVar not found in context');
    }

    // // Записать файл через AQToolService
    // await tools.callTool(
    //   'fs_write_file',
    //   {
    //     'file_path': resolvedPath,
    //     'content': content,
    //   },
    //   context,
    // );

    // context.log(
    //   'File written: $resolvedPath',
    //   branch: context.currentBranch,
    // );

    return null;
  }

  /// ИСПРАВЛЕНИЕ: Валидация пути файла (та же логика что в FileReadNode)
  void _validateFilePath(String path, RunContext context) {
    // 1. Проверка на command injection
    final dangerousChars = [';', '|', '&', '`', '\$', '\n', '\r'];
    for (final char in dangerousChars) {
      if (path.contains(char)) {
        throw Exception(
            'FileWriteNode: недопустимый символ "$char" в пути файла (command injection)');
      }
    }

    // 2. Проверка на path traversal
    if (path.contains('..')) {
      throw Exception('FileWriteNode: path traversal запрещён (содержит "..")');
    }

    // 3. Проверка на доступ к системным файлам
    final systemPaths = [
      '/etc/',
      '/root/',
      '/sys/',
      '/proc/',
      'C:\\Windows\\',
      'C:\\Program Files\\',
    ];

    for (final systemPath in systemPaths) {
      if (path.startsWith(systemPath)) {
        throw Exception(
            'FileWriteNode: доступ к системным файлам запрещён ($systemPath)');
      }
    }

    // 4. КРИТИЧНО: Проверка что файл внутри projectPath
    final projectPath = context.projectPath;
    final normalizedPath = _normalizePath(path);
    final normalizedProjectPath = _normalizePath(projectPath);

    if (_isAbsolutePath(normalizedPath)) {
      if (!normalizedPath.startsWith(normalizedProjectPath)) {
        throw Exception(
            'FileWriteNode: доступ запрещён - файл вне projectPath. '
            'Файл: $normalizedPath, Проект: $normalizedProjectPath');
      }
    }
  }

  String _normalizePath(String path) {
    var normalized = path.replaceAll('\\', '/');
    if (path.contains(':\\')) {
      normalized = normalized.toLowerCase();
    }
    if (normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }
    return normalized;
  }

  bool _isAbsolutePath(String path) {
    if (path.startsWith('/')) return true;
    if (path.contains(':\\')) return true;
    return false;
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': nodeType,
        'config': {
          'file_path': filePath,
          'input_var': inputVar,
        },
      };

  factory FileWriteNode.fromJson(Map<String, dynamic> json) {
    final config = json['config'] as Map<String, dynamic>? ?? {};
    return FileWriteNode(
      id: json['id'] as String,
      filePath: config['file_path'] as String? ?? '',
      inputVar: config['input_var'] as String? ?? 'llm_result',
    );
  }

  @override
  IWorkflowNode copyWith({
    String? id,
    String? filePath,
    String? inputVar,
  }) {
    return FileWriteNode(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      inputVar: inputVar ?? this.inputVar,
    );
  }
}
