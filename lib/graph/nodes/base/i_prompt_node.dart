// Базовый интерфейс для узлов PromptGraph

import 'package:aq_schema/graph/engine/run_context.dart';
import 'package:aq_schema/graph/core/graph_def.dart';

/// Базовый интерфейс для узлов PromptGraph
///
/// PromptGraph - это граф для построения промпта:
/// - Компилирует текст промпта из частей
/// - Подставляет переменные из контекста
/// - Возвращает готовый текст промпта
///
/// Узлы промптов НЕ вызывают LLM, только строят текст
abstract class IPromptNode extends $Node {
  const IPromptNode();
  /// Уникальный ID узла
  String get id;

  /// Тип узла (для сериализации)
  String get nodeType;

  /// Выполнить узел - вернуть часть промпта
  ///
  /// [context] - контекст с переменными для подстановки
  ///
  /// Возвращает строку - часть промпта
  Future<String> execute(RunContext context);

  /// Сериализация в JSON
  Map<String, dynamic> toJson();

  /// Создать копию узла с изменёнными полями
  @override
  IPromptNode copyWith();
}
