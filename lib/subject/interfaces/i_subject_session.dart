// aq_schema/lib/subject/interfaces/i_subject_session.dart
//
// Интерфейс сессии Subject — выполнение и взаимодействие.
//
// Session — это экземпляр выполнения Subject.
// Один Subject может иметь N параллельных сессий.
//
// Принцип: Session владеет Sandbox.
// Session.dispose() → Sandbox.dispose()

import '../models/subject_input.dart';
import '../models/subject_output.dart';
import 'i_tool_executor.dart';

/// Сессия выполнения Subject.
///
/// Создаётся через IAQSubjectRegistry.createSession().
/// Владеет Sandbox и RunContext.
///
/// ```dart
/// final session = await subjectRegistry.createSession(
///   'user/workspace/my-agent',
///   SessionConfig(...),
/// );
///
/// final result = await session.send(SubjectInput(data: {...}));
/// await session.dispose();
/// ```
abstract interface class ISubjectSession {
  /// Уникальный ID сессии.
  String get sessionId;

  /// ID Subject который выполняется.
  String get subjectId;

  /// ID Sandbox в котором выполняется.
  String get sandboxId;

  /// Tool executor для этой сессии (если Subject использует tools).
  IToolExecutor? get toolExecutor;

  /// Отправить input и получить output.
  ///
  /// Блокирующий вызов — ждёт завершения выполнения.
  Future<SubjectOutput> send(SubjectInput input);

  /// Отправить input и получить streaming output.
  ///
  /// Доступно только если SubjectInterface.supportsStreaming == true.
  /// Иначе бросает [StreamingNotSupportedException].
  Stream<SubjectOutputChunk> sendStream(SubjectInput input);

  /// Поток событий сессии.
  ///
  /// События: started, tool_called, completed, error, etc.
  Stream<SubjectSessionEvent> get events;

  /// Завершить сессию и освободить ресурсы.
  ///
  /// • Останавливает выполнение (если активно)
  /// • Вызывает Sandbox.dispose()
  /// • Сохраняет артефакты (если saveArtifacts == true)
  /// • Записывает audit log
  Future<SubjectSessionResult> dispose({bool saveArtifacts = true});
}

/// Чанк streaming output.
final class SubjectOutputChunk {
  final String? text;
  final Map<String, dynamic>? data;
  final bool isDone;

  const SubjectOutputChunk({this.text, this.data, this.isDone = false});
  const SubjectOutputChunk.done() : text = null, data = null, isDone = true;
}

/// Событие сессии.
sealed class SubjectSessionEvent {
  final DateTime timestamp;
  const SubjectSessionEvent(this.timestamp);
}

final class SessionStartedEvent extends SubjectSessionEvent {
  const SessionStartedEvent(super.timestamp);
}

final class ToolCalledEvent extends SubjectSessionEvent {
  final String toolName;
  final Map<String, dynamic> args;
  const ToolCalledEvent(super.timestamp, this.toolName, this.args);
}

final class SessionCompletedEvent extends SubjectSessionEvent {
  final SubjectOutput output;
  const SessionCompletedEvent(super.timestamp, this.output);
}

final class SessionErrorEvent extends SubjectSessionEvent {
  final String error;
  const SessionErrorEvent(super.timestamp, this.error);
}

/// Агент запросил доступ к tool которого у него нет.
/// Слушатель может вызвать RestrictedToolExecutor.grantTool() в ответ.
final class ToolAccessRequestedEvent extends SubjectSessionEvent {
  final String toolName;
  final String agentId;
  const ToolAccessRequestedEvent(super.timestamp, this.toolName, this.agentId);
}

/// Результат завершения сессии.
final class SubjectSessionResult {
  final String sessionId;
  final Duration elapsed;
  final bool success;
  final String? artifactPath; // Путь к сохранённым артефактам

  const SubjectSessionResult({
    required this.sessionId,
    required this.elapsed,
    required this.success,
    this.artifactPath,
  });
}

/// Исключение: streaming не поддерживается.
class StreamingNotSupportedException implements Exception {
  final String subjectId;
  StreamingNotSupportedException(this.subjectId);
  @override
  String toString() => 'Subject $subjectId does not support streaming';
}
