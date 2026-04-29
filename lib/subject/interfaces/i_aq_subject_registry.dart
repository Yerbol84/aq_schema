// aq_schema/lib/subject/interfaces/i_aq_subject_registry.dart
//
// Интерфейс реестра Subject — регистрация, провизионирование, создание сессий.
//
// Принцип Dependency Inversion:
// • aq_schema определяет интерфейс
// • aq_subject_registry реализует интерфейс
// • Клиенты зависят от интерфейса, не от реализации

import '../../sandbox/models/sandbox_policy.dart';
import '../models/subject_descriptor.dart';
import '../models/subject_record.dart';
import 'i_subject_session.dart';

/// Реестр Subject — регистрация и управление.
///
/// Singleton через static instance (dependency injection).
///
/// ```dart
/// // Инициализация (в main)
/// IAQSubjectRegistry.initialize(SubjectRegistryClient(...));
///
/// // Использование
/// final registry = IAQSubjectRegistry.instance;
/// await registry.register(descriptor);
/// ```
abstract interface class IAQSubjectRegistry {
  static IAQSubjectRegistry? _instance;

  static IAQSubjectRegistry get instance {
    assert(_instance != null, 'IAQSubjectRegistry not initialized');
    return _instance!;
  }

  static void initialize(IAQSubjectRegistry impl) => _instance = impl;
  static void reset() => _instance = null;

  /// Зарегистрировать Subject.
  ///
  /// Выполняет:
  /// • Валидацию descriptor
  /// • Проверку графа зависимостей (циклы, глубина)
  /// • Сохранение SubjectRecord (VersionedStorable)
  /// • Создание ToolRecord (если exposeAsTool == true)
  ///
  /// Бросает:
  /// • [CyclicDependencyException] если цикл
  /// • [MaxDepthExceededException] если глубина > 3
  /// • [SubjectValidationException] если descriptor невалиден
  Future<SubjectRecord> register(SubjectDescriptor descriptor);

  /// Получить Subject по ID.
  ///
  /// Возвращает последнюю версию.
  Future<SubjectRecord?> get(String subjectId);

  /// Получить конкретную версию Subject.
  Future<SubjectRecord?> getVersion(String subjectId, String version);

  /// Список всех Subject.
  Future<List<SubjectRecord>> listAll({
    String? namespace,
    bool includeDeprecated = false,
  });

  /// Провизионировать Subject.
  ///
  /// Подготовка к выполнению:
  /// • Клонирование репо (для gitRepo)
  /// • Сборка образа (для dockerImage)
  /// • Валидация endpoint (для llmEndpoint)
  ///
  /// Результат сохраняется как артефакт.
  /// Повторный вызов использует кеш.
  Future<void> provision(String subjectId);

  /// Создать сессию выполнения.
  ///
  /// Создаёт:
  /// • Sandbox через ISandboxProvider
  /// • RunContext с granted capabilities
  /// • ISubjectSession для взаимодействия
  ///
  /// Session владеет Sandbox — dispose сессии освобождает Sandbox.
  Future<ISubjectSession> createSession(
    String subjectId,
    SessionConfig config,
  );

  /// Удалить Subject (все версии).
  Future<void> delete(String subjectId);
}

/// Конфигурация сессии.
final class SessionConfig {
  final SandboxPolicy? sandboxPolicy;
  final Map<String, dynamic> inputs;
  final Map<String, String> envOverrides;
  final Duration? timeout;

  const SessionConfig({
    this.sandboxPolicy,
    this.inputs = const {},
    this.envOverrides = const {},
    this.timeout,
  });
}

/// Исключение валидации Subject.
class SubjectValidationException implements Exception {
  final String message;
  final Object? cause;

  SubjectValidationException(this.message, {this.cause});

  @override
  String toString() => 'SubjectValidationException: $message'
      '${cause != null ? ' (cause: $cause)' : ''}';
}
