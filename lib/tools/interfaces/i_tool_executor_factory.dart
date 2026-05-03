// aq_schema/lib/tools/interfaces/i_tool_executor_factory.dart
//
// Порт: создание IToolExecutor для Subject.
//
// Потребители:
//   aq_subject_registry — SubjectRegistryClient.createSession()
//
// Реализует:
//   aq_subject_runtime — RestrictedToolExecutorFactory
//
// Инициализация:
//   IToolExecutorFactory.initialize(RestrictedToolExecutorFactory());

import '../models/tool_ref.dart';
import '../../subject/interfaces/i_tool_executor.dart';
import '../../sandbox/models/run_context.dart';

/// Порт создания IToolExecutor для Subject.
abstract interface class IToolExecutorFactory {
  static IToolExecutorFactory? _instance;

  static IToolExecutorFactory get instance {
    assert(_instance != null, 'IToolExecutorFactory not initialized. '
        'Call IToolExecutorFactory.initialize() in main().');
    return _instance!;
  }

  static void initialize(IToolExecutorFactory impl) => _instance = impl;
  static void reset() => _instance = null;

  /// Создать executor с whitelist разрешённых tools.
  ///
  /// [sessionContext] — контекст сессии агента. Передаётся в каждый tool call
  /// чтобы tools работали в sandbox сессии (S-02 fix).
  IToolExecutor create(
    List<ToolRef> allowedTools,
    String subjectId,
    RunContext sessionContext,
  );
}
