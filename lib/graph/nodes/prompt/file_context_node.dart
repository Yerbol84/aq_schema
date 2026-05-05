// File Context Node — вставляет содержимое файла в промпт.

import 'package:aq_schema/graph/nodes/base/i_prompt_node.dart';
import 'package:aq_schema/graph/engine/run_context.dart';
import 'package:aq_schema/tools.dart';

/// Читает файл через IToolEngineProtocol и вставляет его содержимое в промпт.
///
/// Конфигурация:
/// - [filePath] — путь к файлу (поддерживает {{variables}})
/// - [prefix] — текст перед содержимым файла (опционально)
/// - [suffix] — текст после содержимого файла (опционально)
class FileContextNode extends IPromptNode {
  @override
  final String id;

  @override
  final String nodeType = 'fileContext';

  final String filePath;
  final String prefix;
  final String suffix;

  const FileContextNode({
    required this.id,
    required this.filePath,
    this.prefix = '',
    this.suffix = '',
  });

  @override
  Future<String> execute(RunContext context) async {
    final resolvedPath = _substitute(filePath, context);

    final result = await IToolEngineProtocol.instance.callTool(
      'fs_read',
      {'path': resolvedPath},
      context,
    );

    if (!result.success) {
      context.log(
        'FileContextNode: failed to read "$resolvedPath": ${result.error}',
        branch: context.currentBranch,
      );
      return '';
    }

    final content = result.output?.toString() ?? '';
    context.log(
      'FileContextNode: read ${content.length} chars from "$resolvedPath"',
      branch: context.currentBranch,
    );

    final parts = [
      if (prefix.isNotEmpty) prefix,
      content,
      if (suffix.isNotEmpty) suffix,
    ];
    return parts.join('\n');
  }

  String _substitute(String template, RunContext context) {
    var result = template;
    final regex = RegExp(r'\{\{(\w+)\}\}');
    for (final match in regex.allMatches(template)) {
      final varName = match.group(1)!;
      final value = context.getVar(varName);
      if (value != null) result = result.replaceAll('{{$varName}}', value.toString());
    }
    return result;
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': nodeType,
        'config': {
          'file_path': filePath,
          if (prefix.isNotEmpty) 'prefix': prefix,
          if (suffix.isNotEmpty) 'suffix': suffix,
        },
      };

  factory FileContextNode.fromJson(Map<String, dynamic> json) {
    final config = json['config'] as Map<String, dynamic>? ?? {};
    return FileContextNode(
      id: json['id'] as String,
      filePath: config['file_path'] as String? ?? '',
      prefix: config['prefix'] as String? ?? '',
      suffix: config['suffix'] as String? ?? '',
    );
  }

  @override
  IPromptNode copyWith({String? id, String? filePath, String? prefix, String? suffix}) =>
      FileContextNode(
        id: id ?? this.id,
        filePath: filePath ?? this.filePath,
        prefix: prefix ?? this.prefix,
        suffix: suffix ?? this.suffix,
      );
}
