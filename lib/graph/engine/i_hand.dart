import 'package:aq_schema/aq_schema.dart';

import 'run_context.dart';

abstract class IHand {
  /// Уникальный технический ID (например: 'fs_write_file')
  String get id;

  /// Описание для LLM (что делает этот инструмент)
  String get description;

  /// Схема параметров в формате OpenAI Function Calling.
  /// LLM будет читать это, чтобы понять, какие аргументы передавать.
  Map<String, dynamic> get toolSchema;

  /// Главный метод исполнения.
  /// [args] - Аргументы, переданные из узла графа ИЛИ сгенерированные LLM.
  /// [context] - Наш "Рюкзак" с данными текущего запуска.
  /// Возвращает результат (Map, String, bool и т.д.)
  Future<dynamic> execute(Map<String, dynamic> args, RunContext context);

  /// Флаг, указывающий, является ли инструмент системным (доступным только AI Builder'у).
  /// По умолчанию false - обычные инструменты видны в Tools Lab.
  bool get isSystemTool => false;
}
