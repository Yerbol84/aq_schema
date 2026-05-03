// Базовый интерфейс для узлов InstructionGraph

import 'package:aq_schema/graph/engine/run_context.dart';
import 'package:aq_schema/graph/core/graph_def.dart';

/// Базовый интерфейс для узлов InstructionGraph
///
/// InstructionGraph - это граф-функция, которая:
/// - Выполняется полностью без пауз (нет suspend/resume)
/// - Работает в изолированном контексте
/// - Принимает входные данные через input mapping
/// - Возвращает результат через output mapping
///
/// Узлы инструкций НЕ могут быть интерактивными
abstract class IInstructionNode extends $Node {
  const IInstructionNode();
  /// Уникальный ID узла
  String get id;

  /// Тип узла (для сериализации)
  String get nodeType;

  /// Выполнить узел
  ///
  /// [context] - изолированный контекст инструкции
  /// [tools] - сервис для доступа к LLM, Vault и другим инструментам
  ///
  /// Возвращает результат выполнения узла
  Future<dynamic> execute(
    RunContext context,
  );

  /// Сериализация в JSON
  Map<String, dynamic> toJson();

  /// Создать копию узла с изменёнными полями
  @override
  IInstructionNode copyWith();
}
