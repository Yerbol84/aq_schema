// aq_schema/lib/subject/interfaces/i_tool_executor.dart

import '../../tools/models/tool_ref.dart';
import '../../tools/models/tool_input.dart';
import '../../tools/models/tool_output.dart';
import '../../tools/models/tool_contract.dart';

/// Интерфейс для безопасного вызова Tools из Subject.
abstract interface class IToolExecutor {
  /// Выполнить tool (с проверкой разрешений).
  Future<ToolOutput> execute(ToolRef ref, ToolInput input);

  /// Список доступных tools (только разрешённые).
  Future<List<ToolContract>> listAvailable();

  /// Выдать доступ к tool в runtime (например, после подтверждения пользователем).
  void grantTool(ToolRef ref);
}

/// Tool не разрешён для этого Subject.
class ToolNotAllowedException implements Exception {
  final ToolRef ref;
  final String subjectId;
  
  ToolNotAllowedException(this.ref, this.subjectId);
  
  @override
  String toString() => 'Tool ${ref.name} not allowed for Subject $subjectId';
}
