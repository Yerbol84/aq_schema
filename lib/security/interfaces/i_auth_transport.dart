// pkgs/aq_schema/lib/security/interfaces/i_auth_transport.dart
//
// Интерфейс для HTTP транспорта авторизации.
// Реализуется в aq_security, используется в aq_security_ui.

import '../models/aq_user.dart';
import '../models/aq_tenant.dart';
import '../models/aq_session.dart';
import '../models/aq_api_key.dart';
import 'i_security_service.dart';

/// Исключение транспорта безопасности
class SecurityTransportException implements Exception {
  SecurityTransportException(this.message, {this.statusCode, this.details});

  final String message;
  final int? statusCode;
  final Map<String, dynamic>? details;

  @override
  String toString() =>
      'SecurityTransportException: $message (status: $statusCode)';
}

/// Интерфейс для HTTP транспорта авторизации
abstract interface class IAuthTransport {
  /// Базовый URL сервера авторизации
  String get baseUrl;

  // ── Health & Config ───────────────────────────────────────────────────────

  /// Проверка доступности сервера
  Future<Map<String, dynamic>> healthCheck();

  /// Получение публичной конфигурации сервера
  Future<Map<String, dynamic>> getPublicConfig();

  // ── OAuth ─────────────────────────────────────────────────────────────────

  /// Получить URL для Google OAuth
  Future<String> getGoogleAuthUrl({required String redirectUri});

  /// Обменять OAuth code на токены
  Future<AuthResponse> exchangeGoogleCode({
    required String code,
    required String redirectUri,
  });

  /// Получить URL для GitHub OAuth
  Future<String> getGithubAuthUrl({required String redirectUri});

  /// Обменять GitHub code на токены
  Future<AuthResponse> exchangeGithubCode({
    required String code,
    required String redirectUri,
  });

  // ── Email/Password ────────────────────────────────────────────────────────

  /// Авторизация через Email/Password
  Future<AuthResponse> loginWithEmail({
    required String email,
    required String password,
  });

  /// Регистрация нового пользователя
  Future<AuthResponse> register({
    required String email,
    required String password,
    String? displayName,
  });

  /// Запрос сброса пароля
  Future<void> requestPasswordReset(String email);

  /// Сброс пароля с кодом
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });

  /// Смена пароля (требует авторизации)
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String accessToken,
  });

  // ── API Key ───────────────────────────────────────────────────────────────

  /// Авторизация через API Key
  Future<AuthResponse> loginWithApiKey(String apiKey);

  /// Создание API ключа
  Future<AqApiKey> createApiKey({
    required String name,
    required List<String> permissions,
    required String accessToken,
    bool isTest = false,
  });

  /// Ротация API ключа
  Future<AqApiKey> rotateApiKey({
    required String keyId,
    required String accessToken,
  });

  /// Отзыв API ключа
  Future<void> revokeApiKey({
    required String keyId,
    required String accessToken,
  });

  /// Получить список API ключей
  Future<List<AqApiKey>> listApiKeys(String accessToken);

  // ── Tokens ────────────────────────────────────────────────────────────────

  /// Обновление токенов
  Future<AqTokenPair> refreshTokens(String refreshToken);

  /// Валидация токена
  Future<Map<String, dynamic>> validateToken(String accessToken);

  /// Отзыв токена (logout)
  Future<void> revokeToken(String accessToken);

  // ── Sessions ──────────────────────────────────────────────────────────────

  /// Получить список активных сессий
  Future<List<AqSession>> listActiveSessions(String accessToken);

  /// Отозвать сессию
  Future<void> revokeSession({
    required String sessionId,
    required String accessToken,
  });

  /// Отозвать все сессии кроме текущей
  Future<void> revokeAllOtherSessions(String accessToken);

  // ── User & Profile ────────────────────────────────────────────────────────

  /// Получить информацию о текущем пользователе
  Future<AqUser> getCurrentUser(String accessToken);

  /// Обновить профиль
  Future<AqUser> updateProfile({
    required String accessToken,
    String? displayName,
    String? avatarUrl,
  });

  // ── Email Verification ────────────────────────────────────────────────────

  /// Отправить код верификации
  Future<void> sendVerificationCode(String accessToken);

  /// Верифицировать email
  Future<void> verifyEmail({
    required String code,
    required String accessToken,
  });

  // ── Tenants ───────────────────────────────────────────────────────────────

  /// Получить список доступных тенантов
  Future<List<AqTenant>> listTenants(String accessToken);

  /// Переключиться на тенант
  Future<AuthResponse> switchTenant({
    required String tenantId,
    required String accessToken,
  });

  // ── RBAC ──────────────────────────────────────────────────────────────────

  /// Проверить наличие права
  Future<bool> checkPermission({
    required String permission,
    required String accessToken,
  });

  /// Проверить наличие роли
  Future<bool> checkRole({
    required String role,
    required String accessToken,
  });

  /// Получить права текущего пользователя
  Future<List<String>> getUserPermissions(String accessToken);

  /// Получить роли текущего пользователя
  Future<List<String>> getUserRoles(String accessToken);
}

/// Singleton instance getter для IAuthTransport
/// Инициализируется основным пакетом (aq_security) при старте приложения
IAuthTransport get authTransport {
  if (_authTransportInstance == null) {
    throw StateError(
      'AuthTransport not initialized. '
      'Call AQSecurityClient.init() first.',
    );
  }
  return _authTransportInstance!;
}

IAuthTransport? _authTransportInstance;

/// Установка instance (вызывается из aq_security)
void setAuthTransportInstance(IAuthTransport instance) {
  _authTransportInstance = instance;
}
