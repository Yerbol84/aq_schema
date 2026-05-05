// aq_schema/lib/subject/interfaces/i_subject_executor.dart
//
// P-10: Extensible executor registry для SubjectKind.
//
// Заменяет switch(kind) в SubjectSession на registry lookup.
// Новый kind = зарегистрировать ISubjectExecutor в точке сборки.

import '../models/subject_descriptor.dart';
import '../models/subject_input.dart';
import '../models/subject_output.dart';
import '../models/subject_kind.dart';
import '../../sandbox/models/run_context.dart';
import '../../sandbox/interfaces/i_sandbox_handle.dart';
import 'i_subject_session.dart';
import 'i_tool_executor.dart';
import '../../core/aq_platform_context.dart';

/// Исполнитель для конкретного SubjectKind.
abstract interface class ISubjectExecutor {
  /// Выполнить Subject и вернуть результат.
  Future<SubjectOutput> execute(
    SubjectDescriptor descriptor,
    SubjectInput input,
    RunContext context,
    ISandboxHandle sandbox,
    IToolExecutor? toolExecutor, {
    void Function(SubjectSessionEvent)? onEvent,
  });
}

/// Реестр исполнителей по SubjectKind.
///
/// Инициализация: ISubjectExecutorRegistry.initialize(SubjectExecutorRegistry());
abstract interface class ISubjectExecutorRegistry {
  static ISubjectExecutorRegistry? _instance;

  static ISubjectExecutorRegistry get instance =>
      AQPlatformContext.current?.subjectExecutorRegistry ??
      _instance ??
      (throw AssertionError('ISubjectExecutorRegistry not initialized.'));

  static void initialize(ISubjectExecutorRegistry impl) => _instance = impl;
  static void reset() => _instance = null;

  /// Зарегистрировать executor для kind.
  void register(SubjectKind kind, ISubjectExecutor executor);

  /// Найти executor для kind. Null если не зарегистрирован.
  ISubjectExecutor? find(SubjectKind kind);
}
