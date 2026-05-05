// aq_schema/lib/subject/interfaces/i_subject_tool_pool_manager.dart
//
// TD-10: Порт для управления lifecycle пулов Subject-as-Tool сессий.
//
// Позволяет aq_subject_runtime освобождать пулы из aq_tool_runtime
// без прямой зависимости между пакетами.

abstract interface class ISubjectToolPoolManager {
  static ISubjectToolPoolManager? _instance;

  static bool get isInitialized => _instance != null;

  static ISubjectToolPoolManager get instance {
    assert(_instance != null, 'ISubjectToolPoolManager not initialized.');
    return _instance!;
  }

  static void initialize(ISubjectToolPoolManager impl) => _instance = impl;
  static void reset() => _instance = null;

  /// Зарегистрировать что сессия [parentSessionId] вызвала subject [subjectId] как tool.
  void trackUsage(String parentSessionId, String subjectId);

  /// Освободить все пулы subjectId вызванных из сессии [parentSessionId].
  Future<void> releaseForSession(String parentSessionId);

  /// Освободить пул сессий для конкретного subjectId.
  Future<void> releasePool(String subjectId);

  /// Освободить все пулы (при shutdown).
  Future<void> releaseAll();
}
