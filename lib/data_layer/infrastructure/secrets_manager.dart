// pkgs/aq_schema/lib/data_layer/infrastructure/secrets_manager.dart
//
// Интерфейс для Secrets Management.
// Реализация должна быть в dart_vault_package.

/// Secret value wrapper
final class SecretValue {
  const SecretValue({
    required this.key,
    required this.value,
    required this.version,
    this.metadata = const {},
  });

  final String key;
  final String value;
  final String version;
  final Map<String, dynamic> metadata;

  factory SecretValue.fromJson(Map<String, dynamic> json) => SecretValue(
        key: json['key'] as String,
        value: json['value'] as String,
        version: json['version'] as String,
        metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      );

  Map<String, dynamic> toJson() => {
        'key': key,
        'value': value,
        'version': version,
        'metadata': metadata,
      };
}

/// Secret rotation result
final class SecretRotationResult {
  const SecretRotationResult({
    required this.success,
    required this.oldVersion,
    required this.newVersion,
    this.error,
  });

  final bool success;
  final String oldVersion;
  final String newVersion;
  final String? error;
}

/// Secrets Manager interface
///
/// Реализация должна быть в dart_vault_package и инициализироваться через:
/// ```dart
/// ISecretsManager.initialize(MySecretsManagerImpl());
/// ```
abstract interface class ISecretsManager {
  /// Singleton instance
  /// Должен быть установлен через initialize() при старте приложения
  static ISecretsManager? _instance;

  static ISecretsManager get instance {
    if (_instance == null) {
      throw StateError(
        'ISecretsManager not initialized. '
        'Call ISecretsManager.initialize() first.',
      );
    }
    return _instance!;
  }

  /// Initialize singleton instance
  /// Вызывается dart_vault при инициализации
  static void initialize(ISecretsManager implementation) {
    _instance = implementation;
  }

  /// Reset instance (для тестов)
  static void reset() {
    _instance = null;
  }

  /// Получить secret по ключу
  Future<SecretValue?> getSecret(String key);

  /// Сохранить secret
  Future<void> setSecret({
    required String key,
    required String value,
    Map<String, dynamic>? metadata,
  });

  /// Удалить secret
  Future<void> deleteSecret(String key);

  /// Получить все secrets (только ключи, не значения)
  Future<List<String>> listSecrets();

  /// Rotate secret (создать новую версию)
  Future<SecretRotationResult> rotateSecret({
    required String key,
    required String newValue,
  });

  /// Получить конкретную версию secret
  Future<SecretValue?> getSecretVersion({
    required String key,
    required String version,
  });

  /// Проверить, существует ли secret
  Future<bool> secretExists(String key);

  /// Получить metadata secret без значения
  Future<Map<String, dynamic>?> getSecretMetadata(String key);
}

/// Mock implementation для тестов
final class MockSecretsManager implements ISecretsManager {
  final Map<String, List<SecretValue>> _secrets = {};

  @override
  Future<SecretValue?> getSecret(String key) async {
    final versions = _secrets[key];
    if (versions == null || versions.isEmpty) return null;
    return versions.last; // Latest version
  }

  @override
  Future<void> setSecret({
    required String key,
    required String value,
    Map<String, dynamic>? metadata,
  }) async {
    final version = DateTime.now().millisecondsSinceEpoch.toString();
    final secret = SecretValue(
      key: key,
      value: value,
      version: version,
      metadata: metadata ?? {},
    );

    _secrets.putIfAbsent(key, () => []).add(secret);
  }

  @override
  Future<void> deleteSecret(String key) async {
    _secrets.remove(key);
  }

  @override
  Future<List<String>> listSecrets() async {
    return _secrets.keys.toList();
  }

  @override
  Future<SecretRotationResult> rotateSecret({
    required String key,
    required String newValue,
  }) async {
    final current = await getSecret(key);
    if (current == null) {
      return SecretRotationResult(
        success: false,
        oldVersion: '',
        newVersion: '',
        error: 'Secret not found',
      );
    }

    final newVersion = DateTime.now().millisecondsSinceEpoch.toString();
    await setSecret(key: key, value: newValue);

    return SecretRotationResult(
      success: true,
      oldVersion: current.version,
      newVersion: newVersion,
    );
  }

  @override
  Future<SecretValue?> getSecretVersion({
    required String key,
    required String version,
  }) async {
    final versions = _secrets[key];
    if (versions == null) return null;

    return versions.where((s) => s.version == version).firstOrNull;
  }

  @override
  Future<bool> secretExists(String key) async {
    return _secrets.containsKey(key);
  }

  @override
  Future<Map<String, dynamic>?> getSecretMetadata(String key) async {
    final secret = await getSecret(key);
    return secret?.metadata;
  }

  /// Clear all secrets (для тестов)
  void clear() {
    _secrets.clear();
  }
}
