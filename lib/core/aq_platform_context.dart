// aq_schema/lib/core/aq_platform_context.dart
//
// P-01: Zone-local DI контейнер для AQ Platform.
//
// Решает проблему статических синглтонов (P-01):
// один процесс может иметь несколько изолированных контекстов
// (тесты, multi-tenant, параллельные сценарии).
//
// Использование:
// ```dart
// await AQPlatformContext(
//   sandboxProvider: SandboxProvider('playground'),
//   subjectRegistry: SubjectRegistryClient(),
//   toolRegistry: ToolRegistryClient(),
//   toolRuntimeExecutor: ToolRuntime(),
//   subjectSessionFactory: SubjectSessionFactory(),
//   subjectRepository: InMemorySubjectRepository(),
//   toolRepository: InMemoryToolRepository(),
//   subjectSessionRepository: InMemorySubjectSessionRepository(),
// ).run(() async {
//   // Внутри зоны Interface.instance делегирует к этому контексту
//   final registry = IAQSubjectRegistry.instance;
// });
// ```

import 'dart:async';
import '../sandbox/interfaces/i_sandbox_provider.dart';
import '../subject/interfaces/i_aq_subject_registry.dart';
import '../subject/interfaces/i_subject_session_factory.dart';
import '../subject/interfaces/i_subject_repository.dart';
import '../subject/interfaces/i_subject_session_repository.dart';
import '../tools/interfaces/i_aq_tool_registry_simple.dart';
import '../tools/interfaces/i_tool_runtime_executor.dart';
import '../tools/interfaces/i_tool_repository.dart';

/// Zone-local DI контейнер платформы.
final class AQPlatformContext {
  static final Object _zoneKey = Object();

  final ISandboxProvider sandboxProvider;
  final IAQSubjectRegistry subjectRegistry;
  final IAQToolRegistrySimple toolRegistry;
  final IToolRuntimeExecutor toolRuntimeExecutor;
  final ISubjectSessionFactory subjectSessionFactory;
  final ISubjectRepository subjectRepository;
  final IToolRepository toolRepository;
  final ISubjectSessionRepository subjectSessionRepository;

  const AQPlatformContext({
    required this.sandboxProvider,
    required this.subjectRegistry,
    required this.toolRegistry,
    required this.toolRuntimeExecutor,
    required this.subjectSessionFactory,
    required this.subjectRepository,
    required this.toolRepository,
    required this.subjectSessionRepository,
  });

  /// Текущий контекст из zone. Null если не установлен.
  static AQPlatformContext? get current =>
      Zone.current[_zoneKey] as AQPlatformContext?;

  /// Выполнить [body] внутри этого контекста.
  ///
  /// Внутри зоны все `Interface.instance` делегируют к этому контексту.
  Future<T> run<T>(Future<T> Function() body) =>
      runZoned(body, zoneValues: {_zoneKey: this});

  /// Установить как глобальный default (для точки сборки / main.dart).
  ///
  /// Инициализирует все статические синглтоны.
  /// Вызывать один раз в main() перед запуском приложения.
  void registerAsDefault() {
    ISandboxProvider.initialize(sandboxProvider);
    IAQSubjectRegistry.initialize(subjectRegistry);
    IAQToolRegistrySimple.initialize(toolRegistry);
    IToolRuntimeExecutor.initialize(toolRuntimeExecutor);
    ISubjectSessionFactory.initialize(subjectSessionFactory);
    ISubjectRepository.initialize(subjectRepository);
    IToolRepository.initialize(toolRepository);
    ISubjectSessionRepository.initialize(subjectSessionRepository);
  }

  /// Сбросить все статические синглтоны (для тестов).
  static void resetAll() {
    ISandboxProvider.reset();
    IAQSubjectRegistry.reset();
    IAQToolRegistrySimple.reset();
    IToolRuntimeExecutor.reset();
    ISubjectSessionFactory.reset();
    ISubjectRepository.reset();
    IToolRepository.reset();
    ISubjectSessionRepository.reset();
  }
}
