// pkgs/aq_schema/lib/graph/engine/run_context.dart

import '../../security/models/api_key_claims.dart';

class RunContext {
  // ── Идентификация ────────────────────────────────────────────────────
  @override
  final String runId;
  @override
  final String projectId;
  @override
  final String projectPath;
  @override
  final String currentBranch;

  // ── Security ─────────────────────────────────────────────────────────
  /// API key claims для контроля доступа
  /// Если null — unrestricted (для локального режима)
  final AQApiKeyClaims? apiKeyClaims;

  // ── Состояние ────────────────────────────────────────────────────────
  @override
  final Map<String, dynamic> state = {};

  // ИСПРАВЛЕНИЕ: Добавлен механизм транзакций для rollback при ошибке
  Map<String, dynamic>? _savepoint;

  // ИСПРАВЛЕНИЕ: Отслеживание временных ресурсов для cleanup
  final List<String> _tempResources = [];

  // ── Логирование (реализация, не часть ISandboxContext) ───────────────
  // Приватное поле — callback передаётся в конструктор как раньше.
  // Публичный метод log() — удовлетворяет вызывающим context.log(...).
  // Существующий код вне класса не меняется.
  final void Function(
    String message, {
    String type,
    int depth,
    required String branch,
    String? details,
  }) _log;

  @override
  void log(
    String message, {
    String type = 'info',
    int depth = 0,
    required String branch,
    String? details,
  }) =>
      _log(message, type: type, depth: depth, branch: branch, details: details);

  // ── Конструктор ──────────────────────────────────────────────────────
  // Параметр называется `log` как раньше — все места создания RunContext
  // работают без изменений.
  RunContext({
    required this.runId,
    required this.projectId,
    required this.projectPath,
    required void Function(
      String, {
      String type,
      int depth,
      required String branch,
      String? details,
    }) log,
    this.currentBranch = 'main',
    this.apiKeyClaims,
  }) : _log = log;

  // ── Методы состояния ─────────────────────────────────────────────────

  /// ИСПРАВЛЕНИЕ: Deep copy для предотвращения memory leak
  /// Проблема: контекст хранил ссылки на объекты, изменение извне меняло контекст
  /// Решение: делаем deep copy при setVar()
  @override
  void setVar(String key, dynamic value) {
    // Deep copy для предотвращения изменения извне
    final copiedValue = _deepCopy(value);
    state[key] = copiedValue;

    // Маскируем секреты в логах
    final maskedValue = _maskSecrets(key, copiedValue);
    _log('Memory updated: [$key] = $maskedValue',
        type: 'system', depth: 0, branch: currentBranch);
  }

  @override
  dynamic getVar(String name) {
    if (!name.contains('.')) {
      final value = state[name];
      // Возвращаем копию, чтобы изменения извне не влияли на контекст
      return _deepCopy(value);
    }
    final parts = name.split('.');
    dynamic current = state[parts[0]];
    for (int i = 1; i < parts.length; i++) {
      if (current is Map) {
        current = current[parts[i]];
      } else {
        return null;
      }
    }
    // Возвращаем копию
    return _deepCopy(current);
  }

  /// Deep copy для предотвращения изменения объектов извне
  dynamic _deepCopy(dynamic value) {
    if (value == null) return null;
    if (value is String || value is num || value is bool) return value;

    if (value is List) {
      return value.map((item) => _deepCopy(item)).toList();
    }

    if (value is Map) {
      return Map<String, dynamic>.from(
          value.map((key, val) => MapEntry(key.toString(), _deepCopy(val))));
    }

    // Для других типов возвращаем как есть (DateTime, etc)
    return value;
  }

  /// Маскирование секретов в логах
  String _maskSecrets(String key, dynamic value) {
    final lowerKey = key.toLowerCase();

    // Список ключей, которые содержат секреты
    final secretKeys = [
      'password',
      'secret',
      'token',
      'key',
      'api_key',
      'jwt',
      'auth',
      'credential',
      'private'
    ];

    // Проверяем содержит ли ключ секретное слово
    final isSecret = secretKeys.any((secret) => lowerKey.contains(secret));

    if (isSecret && value is String && value.isNotEmpty) {
      // Маскируем: показываем первые 4 символа + ***
      if (value.length <= 4) return '***';
      return '${value.substring(0, 4)}***';
    }

    return value.toString();
  }

  // ── ИСПРАВЛЕНИЕ: Транзакционность ─────────────────────────────────────

  /// Создаёт savepoint для возможности rollback
  void createSavepoint() {
    _savepoint = _deepCopy(state) as Map<String, dynamic>;
    _log('Savepoint created', type: 'system', depth: 0, branch: currentBranch);
  }

  /// Откатывает состояние к savepoint
  void rollback() {
    if (_savepoint != null) {
      state.clear();
      state.addAll(_savepoint!);
      _savepoint = null;
      _log('Rolled back to savepoint',
          type: 'system', depth: 0, branch: currentBranch);
    }
  }

  /// Подтверждает изменения и удаляет savepoint
  void commit() {
    _savepoint = null;
    _log('Changes committed', type: 'system', depth: 0, branch: currentBranch);
  }

  // ── ИСПРАВЛЕНИЕ: Resource Management ──────────────────────────────────

  /// Регистрирует временный ресурс для cleanup
  void registerTempResource(String resourcePath) {
    _tempResources.add(resourcePath);
    _log('Temp resource registered: $resourcePath',
        type: 'system', depth: 0, branch: currentBranch);
  }

  /// Освобождает все ресурсы
  Future<void> dispose() async {
    // Cleanup временных ресурсов
    for (final resource in _tempResources) {
      _log('Cleaning up temp resource: $resource',
          type: 'system', depth: 0, branch: currentBranch);
      // TODO: реальное удаление файлов через sandbox
    }
    _tempResources.clear();

    // Очистка состояния
    state.clear();
    _savepoint = null;

    _log('RunContext disposed',
        type: 'system', depth: 0, branch: currentBranch);
  }

  // ── Ветвление ────────────────────────────────────────────────────────
  /// Создать дочерний контекст для новой ветки выполнения.
  ///
  /// Копирует текущее состояние — изменения в дочернем контексте
  /// не влияют на родительский.
  RunContext cloneForBranch(String branchName) {
    final child = RunContext(
      runId: runId,
      projectId: projectId,
      projectPath: projectPath,
      log: _log,
      currentBranch: branchName,
      apiKeyClaims: apiKeyClaims,
    );
    // Копируем состояние
    child.state.addAll(_deepCopy(state) as Map<String, dynamic>);
    return child;
  }

  // ── Сериализация (без изменений) ─────────────────────────────────────
  Map<String, dynamic> toJson() => {
        'runId': runId,
        'projectId': projectId,
        'projectPath': projectPath,
        'state': state,
        'currentBranch': currentBranch,
      };

  factory RunContext.fromJson(
    Map<String, dynamic> json,
    void Function(
      String, {
      String type,
      int depth,
      required String branch,
      String? details,
    }) log,
  ) {
    final ctx = RunContext(
      runId: json['runId'] as String,
      projectId: json['projectId'] as String,
      projectPath: json['projectPath'] as String,
      currentBranch: json['currentBranch'] as String? ?? 'main',
      log: log,
    );
    if (json['state'] != null) {
      ctx.state.addAll(Map<String, dynamic>.from(json['state'] as Map));
    }
    return ctx;
  }
}
