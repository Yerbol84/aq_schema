// pkgs/aq_schema/lib/security/interfaces/i_session_store.dart
//
// Интерфейс для локального хранения сессий.
// Реализуется в aq_security, используется в aq_security_ui.

import 'i_security_service.dart';

/// Сохранённые данные сессии
final class StoredSession {
  const StoredSession({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.userId,
    required this.tenantId,
  });

  final String accessToken;
  final String refreshToken;
  final int expiresAt; // Unix timestamp в секундах
  final String userId;
  final String tenantId;

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'expiresAt': expiresAt,
        'userId': userId,
        'tenantId': tenantId,
      };

  factory StoredSession.fromJson(Map<String, dynamic> json) => StoredSession(
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
        expiresAt: json['expiresAt'] as int,
        userId: json['userId'] as String,
        tenantId: json['tenantId'] as String,
      );
}

/// Интерфейс для локального хранения сессий
abstract interface class ISessionStore {
  // ── Tokens ────────────────────────────────────────────────────────────────

  /// Сохранить токены в хранилище
  Future<void> saveTokens(AqTokenPair tokens, {
    required String userId,
    required String tenantId,
    required int expiresAt,
  });

  /// Получить сохранённые токены
  StoredSession? getStoredTokens();

  /// Очистить токены из хранилища
  Future<void> clearTokens();

  /// Проверить, истекли ли токены (с буфером в 60 секунд)
  bool areTokensExpired();

  // ── User Data ─────────────────────────────────────────────────────────────

  /// Сохранить данные пользователя
  Future<void> saveUserData(Map<String, dynamic> userData);

  /// Получить сохранённые данные пользователя
  Map<String, dynamic>? getUserData();

  /// Очистить данные пользователя
  Future<void> clearUserData();

  // ── Preferences ───────────────────────────────────────────────────────────

  /// Сохранить настройку
  Future<void> setPreference(String key, dynamic value);

  /// Получить настройку
  dynamic getPreference(String key);

  /// Удалить настройку
  Future<void> removePreference(String key);

  /// Очистить все настройки
  Future<void> clearPreferences();

  // ── Session State ─────────────────────────────────────────────────────────

  /// Сохранить последний активный тенант
  Future<void> saveLastTenant(String tenantId);

  /// Получить последний активный тенант
  String? getLastTenant();

  /// Сохранить флаг "запомнить меня"
  Future<void> setRememberMe(bool remember);

  /// Получить флаг "запомнить меня"
  bool getRememberMe();

  // ── Security ──────────────────────────────────────────────────────────────

  /// Сохранить fingerprint устройства
  Future<void> saveDeviceFingerprint(String fingerprint);

  /// Получить fingerprint устройства
  String? getDeviceFingerprint();

  /// Сохранить timestamp последней активности
  Future<void> updateLastActivity();

  /// Получить timestamp последней активности
  int? getLastActivity();

  // ── Cleanup ───────────────────────────────────────────────────────────────

  /// Полная очистка всех данных
  Future<void> clearAll();

  /// Проверка, есть ли сохранённая сессия
  bool hasStoredSession();
}

/// Singleton instance getter для ISessionStore
/// Инициализируется основным пакетом (aq_security) при старте приложения
ISessionStore get sessionStore {
  if (_sessionStoreInstance == null) {
    throw StateError(
      'SessionStore not initialized. '
      'Call AQSecurityClient.init() first.',
    );
  }
  return _sessionStoreInstance!;
}

ISessionStore? _sessionStoreInstance;

/// Установка instance (вызывается из aq_security)
void setSessionStoreInstance(ISessionStore instance) {
  _sessionStoreInstance = instance;
}
