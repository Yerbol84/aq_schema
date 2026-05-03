// Абстракция хранилища графов.
// Живёт в aq_schema — используется aq_graph_engine и aq_graph_worker.

import 'package:aq_schema/graph/core/graph_def.dart';

abstract class IGraphRepository {
  /// Загрузить граф по ID blueprint.
  /// Возвращает WorkflowGraph, InstructionGraph или PromptGraph.
  /// Возвращает null если граф не найден.
  Future<$Graph?> loadGraph(String blueprintId);
}
