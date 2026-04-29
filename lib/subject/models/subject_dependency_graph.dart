// aq_schema/lib/subject/models/subject_dependency_graph.dart
//
// Граф зависимостей Subject → Tools.
//
// Используется для:
// • Детекции циклов
// • Вычисления уровня вложенности
// • Валидации при регистрации
//
// ВОПРОС: Где хранить граф?
// См. doc/IMPLEMENTATION_ISSUES.md #3
//
// Пока: в памяти Registry (теряется при перезапуске, но вычисляется заново).

/// Граф зависимостей Subject → Tools.
///
/// Детектирует циклы и вычисляет уровень вложенности.
final class SubjectDependencyGraph {
  final Map<String, Set<String>> _graph = {};
  final Map<String, int> _levels = {};

  /// Добавить Subject с его зависимостями.
  ///
  /// Бросает [CyclicDependencyException] если создаётся цикл.
  /// Бросает [MaxDepthExceededException] если уровень > maxDepth.
  void addSubject(
    String subjectId,
    Set<String> dependencies, {
    int maxDepth = 3,
  }) {
    // 1. Проверить циклы
    if (_hasCycle(subjectId, dependencies)) {
      throw CyclicDependencyException(subjectId);
    }

    // 2. Вычислить уровень вложенности
    final level = _computeLevel(dependencies);
    if (level > maxDepth) {
      throw MaxDepthExceededException(subjectId, level, maxDepth);
    }

    // 3. Сохранить
    _graph[subjectId] = dependencies;
    _levels[subjectId] = level;
  }

  /// Вычислить уровень вложенности.
  int _computeLevel(Set<String> dependencies) {
    if (dependencies.isEmpty) return 0;

    int maxDepLevel = 0;
    for (final dep in dependencies) {
      // Если зависимость не является зарегистрированным Subject — это базовый Tool (уровень 0)
      final depLevel = _levels[dep];
      if (depLevel == null) continue; // базовый tool — уровень 0, пропускаем

      if (depLevel > maxDepLevel) {
        maxDepLevel = depLevel;
      }
    }

    return maxDepLevel + 1;
  }

  /// Детекция циклов через DFS.
  bool _hasCycle(String subject, Set<String> deps) {
    final visited = <String>{};
    final stack = <String>{};

    bool dfs(String node) {
      if (stack.contains(node)) return true; // Цикл!
      if (visited.contains(node)) return false;

      visited.add(node);
      stack.add(node);

      final nodeDeps = _graph[node] ?? {};
      for (final dep in nodeDeps) {
        if (dfs(dep)) return true;
      }

      stack.remove(node);
      return false;
    }

    // Временно добавить новый Subject
    _graph[subject] = deps;
    final hasCycle = dfs(subject);
    _graph.remove(subject);

    return hasCycle;
  }

  /// Получить уровень вложенности Subject.
  int getLevel(String subjectId) => _levels[subjectId] ?? 0;

  /// Удалить Subject из графа.
  void removeSubject(String subjectId) {
    _graph.remove(subjectId);
    _levels.remove(subjectId);
  }

  /// Очистить весь граф.
  void clear() {
    _graph.clear();
    _levels.clear();
  }
}

// ── Исключения ────────────────────────────────────────────────────────────────

class CyclicDependencyException implements Exception {
  final String subjectId;
  CyclicDependencyException(this.subjectId);
  @override
  String toString() => 'Cyclic dependency detected for Subject: $subjectId';
}

class MaxDepthExceededException implements Exception {
  final String subjectId;
  final int actualDepth;
  final int maxDepth;
  MaxDepthExceededException(this.subjectId, this.actualDepth, this.maxDepth);
  @override
  String toString() =>
      'Subject $subjectId exceeds max depth: $actualDepth > $maxDepth';
}

class DependencyNotFoundException implements Exception {
  final String dependencyId;
  DependencyNotFoundException(this.dependencyId);
  @override
  String toString() => 'Dependency not found: $dependencyId';
}
