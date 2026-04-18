// File Read Node - чтение файла через Tool

import 'package:aq_schema/graph/nodes/base/automatic_node.dart';
import 'package:aq_schema/graph/nodes/base/i_workflow_node.dart';
import 'package:aq_schema/graph/engine/run_context.dart';

/// Узел для чтения файла
///
/// Читает файл через Tool 'fs_read_file'
class FileReadNode extends AutomaticNode {
  @override
  final String id;

  @override
  final String nodeType = 'fileRead';

  /// Путь к файлу (может содержать {{variables}})
  final String filePath;

  /// Переменная для сохранения содержимого
  final String outputVar;

  FileReadNode({
    required this.id,
    required this.filePath,
    required this.outputVar,
  });

  @override
  Future<dynamic> execute(
    RunContext context,
  ) async {
    // Подставить переменные в путь
    final resolvedPath = substituteVariables(filePath, context);

    if (resolvedPath.trim().isEmpty) {
      throw Exception('FileReadNode: file path is empty');
    }

    // ИСПРАВЛЕНИЕ: Валидация пути для защиты от injection и path traversal
    _validateFilePath(resolvedPath, context);

    // Прочитать файл через AQToolService
    // final content = await tools.callTool(
    //   'fs_read_file',
    //   {'file_path': resolvedPath},
    //   context,
    // );

    // // Сохранить результат
    // context.setVar(outputVar, content);
    // context.setVar('current_file_path', resolvedPath);

    // context.log(
    //   'File read: $resolvedPath (${content.toString().length} chars)',
    //   branch: context.currentBranch,
    // );

    // return content;
  }

  /// ИСПРАВЛЕНИЕ: Валидация пути файла
  /// Защита от: path traversal, command injection, доступа к системным файлам
  void _validateFilePath(String path, RunContext context) {
    // 1. Проверка на command injection
    final dangerousChars = [';', '|', '&', '`', '\$', '\n', '\r'];
    for (final char in dangerousChars) {
      if (path.contains(char)) {
        throw Exception(
            'FileReadNode: недопустимый символ "$char" в пути файла (command injection)');
      }
    }

    // 2. Проверка на path traversal
    if (path.contains('..')) {
      throw Exception('FileReadNode: path traversal запрещён (содержит "..")');
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
            'FileReadNode: доступ к системным файлам запрещён ($systemPath)');
      }
    }

    // 4. КРИТИЧНО: Проверка что файл внутри projectPath
    // Это защищает от доступа к файлам чужих проектов
    final projectPath = context.projectPath;

    // Нормализуем пути для сравнения
    final normalizedPath = _normalizePath(path);
    final normalizedProjectPath = _normalizePath(projectPath);

    // Если путь абсолютный - проверяем что он внутри projectPath
    if (_isAbsolutePath(normalizedPath)) {
      if (!normalizedPath.startsWith(normalizedProjectPath)) {
        throw Exception('FileReadNode: доступ запрещён - файл вне projectPath. '
            'Файл: $normalizedPath, Проект: $normalizedProjectPath');
      }
    }
    // Если путь относительный - он будет разрешён относительно projectPath
    // (это безопасно, т.к. мы уже проверили на "..")
  }

  /// Нормализует путь (убирает лишние слеши, приводит к lowercase на Windows)
  String _normalizePath(String path) {
    var normalized = path.replaceAll('\\', '/');
    // На Windows пути case-insensitive
    if (path.contains(':\\')) {
      normalized = normalized.toLowerCase();
    }
    // Убираем trailing slash
    if (normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }
    return normalized;
  }

  /// Проверяет является ли путь абсолютным
  bool _isAbsolutePath(String path) {
    // Unix: начинается с /
    if (path.startsWith('/')) return true;
    // Windows: содержит C:\ или подобное
    if (path.contains(':\\')) return true;
    return false;
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': nodeType,
        'config': {
          'file_path': filePath,
          'output_var': outputVar,
        },
      };

  factory FileReadNode.fromJson(Map<String, dynamic> json) {
    final config = json['config'] as Map<String, dynamic>? ?? {};
    return FileReadNode(
      id: json['id'] as String,
      filePath: config['file_path'] as String? ?? '',
      outputVar: config['output_var'] as String? ?? 'source_code',
    );
  }

  @override
  IWorkflowNode copyWith({
    String? id,
    String? filePath,
    String? outputVar,
  }) {
    return FileReadNode(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      outputVar: outputVar ?? this.outputVar,
    );
  }
}
