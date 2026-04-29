// aq_schema/lib/tools/interfaces/clients_protocols/i_tool_worker_protocol.dart
//
// Порт для Worker — что видит воркер при работе с инструментами.
//
// Worker использует этот протокол для:
// - прямого вызова инструментов с полным контролем (версия, sandbox)
// - мониторинга состояния circuit breaker
// - streaming вызовов
//
// ## Потребитель
// aq_worker — при выполнении job-ов которые вызывают инструменты напрямую
//
// ## Отличие от IToolEngineProtocol
// Engine: простой вызов по имени, без деталей
// Worker: полный контроль — версия, ref, circuit status, streaming

import '../../../graph/engine/run_context.dart';
import '../../models/tool_contract.dart';
import '../../models/tool_ref.dart';
import '../../models/tool_result.dart';
import '../i_aq_tool_runtime.dart';

/// Протокол инструментов для Worker.
///
/// Воркер работает с инструментами напрямую — с полным контролем над версией
/// и возможностью мониторинга circuit breaker.
///
/// ```dart
/// // В воркере:
/// final result = await IToolWorkerProtocol.instance.call(
///   ToolRef('llm_complete', namespace: 'aq/llm', range: SemVerRange('^2.0.0')),
///   args,
///   context,
/// );
/// ```
abstract interface class IToolWorkerProtocol {
  static IToolWorkerProtocol? _instance;
  static IToolWorkerProtocol get instance {
    assert(_instance != null, 'IToolWorkerProtocol not initialized');
    return _instance!;
  }

  static void initialize(IToolWorkerProtocol impl) => _instance = impl;
  static void reset() => _instance = null;

  /// Вызвать инструмент с явным ToolRef (версия/диапазон).
  ///
  /// Никогда не бросает — ошибки через [ToolResult.failure].
  Future<ToolResult> call(
    ToolRef ref,
    Map<String, dynamic> args,
    RunContext context,
  );

  /// Потоковый вызов.
  Stream<ToolResultChunk> callStream(
    ToolRef ref,
    Map<String, dynamic> args,
    RunContext context,
  );

  /// Получить контракт инструмента (для capability negotiation).
  Future<ToolContract> getContract(ToolRef ref);

  /// Проверить доступность инструмента (с учётом circuit breaker).
  Future<bool> isCallable(ToolRef ref);

  /// Статус circuit breaker — воркер может принять решение о retry.
  Future<CircuitBreakerStatus> getCircuitStatus(ToolRef ref);
}
