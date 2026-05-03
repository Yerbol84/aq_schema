// aq_schema/lib/subject/interfaces/i_subject_session_repository.dart
//
// Порт персистентности активных Subject-сессий (P-03).
// При старте сервиса — найти orphaned сессии и очистить их ресурсы.
//
// Не путать с ISessionRepository из security (auth-сессии пользователей).

import '../../core/aq_platform_context.dart';

/// Запись об активной Subject-сессии.
final class SubjectSessionEntry {
  final String sessionId;
  final String subjectId;
  final String sandboxId;
  final DateTime startedAt;
  final bool isAbandoned;

  const SubjectSessionEntry({
    required this.sessionId,
    required this.subjectId,
    required this.sandboxId,
    required this.startedAt,
    this.isAbandoned = false,
  });

  SubjectSessionEntry copyWith({bool? isAbandoned}) => SubjectSessionEntry(
        sessionId: sessionId,
        subjectId: subjectId,
        sandboxId: sandboxId,
        startedAt: startedAt,
        isAbandoned: isAbandoned ?? this.isAbandoned,
      );
}

/// Репозиторий активных Subject-сессий (агентов).
///
/// Инициализация: ISubjectSessionRepository.initialize(InMemorySubjectSessionRepository());
abstract interface class ISubjectSessionRepository {
  static ISubjectSessionRepository? _instance;

  static ISubjectSessionRepository get instance =>
      AQPlatformContext.current?.subjectSessionRepository ??
      _instance ??
      (throw AssertionError('ISubjectSessionRepository not initialized.'));

  static void initialize(ISubjectSessionRepository impl) => _instance = impl;
  static void reset() => _instance = null;

  Future<void> save(SubjectSessionEntry entry);
  Future<List<SubjectSessionEntry>> findActive();
  Future<void> markAbandoned(String sessionId);
  Future<void> delete(String sessionId);
}
