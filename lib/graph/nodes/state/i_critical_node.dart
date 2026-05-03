// Критический узел — checkpoint до и после, обработка восстановления.

import 'package:aq_schema/graph/engine/run_context.dart';
import 'i_stateful_node.dart';

/// Критический узел — сбой недопустим.
///
/// Runner делает checkpoint ДО и ПОСЛЕ выполнения.
/// При восстановлении после сбоя вызывается [onRecovery].
///
/// Используй для: платежи, запись в БД, отправка email.
abstract interface class ICriticalNode implements IStatefulNode {
  @override
  NodeStateHint get stateHint => NodeStateHint.critical;

  /// Вызывается при восстановлении после сбоя.
  ///
  /// Узел должен проверить — была ли операция уже выполнена (idempotency).
  /// Если да — вернуть без повторного выполнения.
  Future<void> onRecovery(RunContext context);
}
