// File Upload Node - загрузка файла пользователем

import 'package:aq_schema/graph/nodes/base/interactive_node.dart';
import 'package:aq_schema/graph/nodes/base/i_workflow_node.dart';
import 'package:aq_schema/graph/engine/run_context.dart';

/// Узел для загрузки файла пользователем
///
/// Приостанавливает выполнение и ждет загрузки файла через UI
class FileUploadNode extends InteractiveNode {
  @override
  final String id;

  @override
  final String nodeType = 'fileUpload';

  /// Заголовок формы загрузки
  final String title;

  /// Описание какой файл нужен
  final String message;

  /// Переменная для сохранения пути к файлу
  final String outputVar;

  /// Допустимые расширения файлов (например: ['.txt', '.md'])
  final List<String> allowedExtensions;

  FileUploadNode({
    required this.id,
    required this.title,
    required this.message,
    required this.outputVar,
    this.allowedExtensions = const [],
  });

  @override
  Future<dynamic> execute(
    RunContext context,
  ) async {
    // Проверить, есть ли уже загруженный файл (resume после suspend)
    if (hasUserResponse(context, outputVar)) {
      final filePath = context.getVar(outputVar);
      context.log(
        'File uploaded: $filePath',
        branch: context.currentBranch,
      );
      return filePath;
    }

    // Нет файла - приостановить выполнение
    throwSuspendException(id, 'Waiting for file upload: $title');
  }

  @override
  Map<String, dynamic> getUiConfig() => {
        'title': title,
        'message': message,
        'type': 'file_upload',
        'output_var': outputVar,
        'allowed_extensions': allowedExtensions,
      };

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': nodeType,
        'config': {
          'title': title,
          'message': message,
          'output_var': outputVar,
          'allowed_extensions': allowedExtensions,
        },
      };

  factory FileUploadNode.fromJson(Map<String, dynamic> json) {
    final config = json['config'] as Map<String, dynamic>? ?? {};
    return FileUploadNode(
      id: json['id'] as String,
      title: config['title'] as String? ?? '',
      message: config['message'] as String? ?? '',
      outputVar: config['output_var'] as String? ?? 'uploaded_file',
      allowedExtensions: (config['allowed_extensions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  @override
  IWorkflowNode copyWith({
    String? id,
    String? title,
    String? message,
    String? outputVar,
    List<String>? allowedExtensions,
  }) {
    return FileUploadNode(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      outputVar: outputVar ?? this.outputVar,
      allowedExtensions: allowedExtensions ?? this.allowedExtensions,
    );
  }
}
