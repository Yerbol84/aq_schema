// aq_schema/lib/subject/interfaces/i_subject_session_factory.dart
//
// Порт: создание сессий Subject.
// Принимает IToolExecutor? — правильный уровень абстракции.
// Не знает о RestrictedToolExecutor, allowedTools — это детали реализации.

import '../../sandbox/interfaces/i_sandbox_handle.dart';
import '../../sandbox/models/run_context.dart';
import '../models/subject_descriptor.dart';
import 'i_subject_session.dart';
import 'i_tool_executor.dart';

/// Порт создания сессий Subject.
abstract interface class ISubjectSessionFactory {
  static ISubjectSessionFactory? _instance;

  static ISubjectSessionFactory get instance {
    assert(_instance != null, 'ISubjectSessionFactory not initialized. '
        'Call ISubjectSessionFactory.initialize() in main().');
    return _instance!;
  }

  static void initialize(ISubjectSessionFactory impl) => _instance = impl;
  static void reset() => _instance = null;

  /// Создать сессию для Subject.
  ///
  /// [toolExecutor] — опциональный executor для вызова tools.
  /// Создаётся вызывающим кодом (SubjectRegistryClient) — фабрика не знает
  /// о конкретной реализации (RestrictedToolExecutor).
  ISubjectSession createSession({
    required String sessionId,
    required SubjectDescriptor descriptor,
    required RunContext context,
    required ISandboxHandle sandbox,
    IToolExecutor? toolExecutor,
  });
}
