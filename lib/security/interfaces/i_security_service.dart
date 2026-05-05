// pkgs/aq_schema/lib/security/interfaces/i_security_service.dart
//
// Главный порт слоя безопасности.
// Реализация: aq_security/lib/src/client/aq_security_service.dart

import 'dart:async';
import '../models/aq_user.dart';
import '../models/aq_tenant.dart';
import '../models/aq_session.dart';
import '../models/aq_token_claims.dart';
import '../models/aq_api_key.dart';
import '../models/credentials.dart';
import 'i_role_management_service.dart';
import 'i_policy_service.dart';
import 'i_audit_service.dart';

/// Состояние безопасности
sealed class SecurityState {
  const SecurityState();
}

final class SecurityStateUnauthenticated extends SecurityState {
  const SecurityStateUnauthenticated();
}

final class SecurityStateAuthenticated extends SecurityState {
  const SecurityStateAuthenticated({
    required this.user,
    required this.tenant,
    required this.session,
    required this.claims,
  });

  final AqUser user;
  final AqTenant tenant;
  final AqSession session;
  final AqTokenClaims claims;
}

final class SecurityStateLoading extends SecurityState {
  const SecurityStateLoading();
}

final class SecurityStateError extends SecurityState {
  const SecurityStateError(this.message);
  final String message;
}

/// Пара токенов (access + refresh)
///
/// DEPRECATED: Используйте TokenPair из aq_token_claims.dart
/// Этот алиас оставлен для обратной совместимости.
typedef AqTokenPair = TokenPair;

/// Ответ на авторизацию
final class AuthResponse {
  const AuthResponse({
    required this.user,
    required this.tenant,
    required this.session,
    required this.tokens,
  });

  final AqUser user;
  final AqTenant tenant;
  final AqSession session;
  final TokenPair tokens;

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        user: AqUser.fromJson(json['user'] as Map<String, dynamic>),
        tenant: AqTenant.fromJson(json['tenant'] as Map<String, dynamic>),
        session: AqSession.fromJson(json['session'] as Map<String, dynamic>),
        tokens: TokenPair.fromJson(json['tokens'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'user': user.toJson(),
        'tenant': tenant.toJson(),
        'session': session.toJson(),
        'tokens': tokens.toJson(),
      };
}

/// # ISecurityService — точка входа в систему безопасности
///
/// Фасад над всеми операциями безопасности: аутентификация, проверка прав,
/// управление сессиями и API ключами.
///
/// ---
///
/// ## 🖥️ Flutter / Web приложение
///
/// Типичный сценарий: пользователь логинится, UI адаптируется под его права.
///
/// ```dart
/// // main.dart — инициализация один раз
/// final service = await AQSecurityClient.init('https://auth.example.com');
///
/// // Логин
/// final response = await service.loginWithEmail(
///   email: 'alice@example.com',
///   password: 'secret',
/// );
///
/// // Реактивное состояние — слушать изменения
/// service.stream.listen((state) {
///   if (state is SecurityStateAuthenticated) {
///     // Обновить UI
///   }
/// });
///
/// // Проверить право перед показом кнопки (локально, из токена)
/// // ⚠️ Только для UI — не для защиты данных. Сервер проверяет независимо.
/// if (await service.hasPermission('projects:write')) {
///   showEditButton();
/// }
///
/// // Получить что можно делать с конкретным ресурсом
/// final perms = await service.getResourcePermissions('project/123');
/// // → ['project:read', 'project:write']
/// ```
///
/// ---
///
/// ## ⚙️ Worker / Dart CLI
///
/// Типичный сценарий: сервис логинится через API Key, выполняет задачи.
///
/// ```dart
/// // Инициализация с jwtSecret для локальной валидации токенов (без сети)
/// final service = await AQSecurityClient.init(
///   Platform.environment['AUTH_ENDPOINT']!,
///   jwtSecret: Platform.environment['JWT_SECRET']!,
/// );
///
/// // Логин через API Key
/// await service.loginWithApiKey(Platform.environment['API_KEY']!);
///
/// // Проверить право (локально, без HTTP запроса)
/// if (await service.hasPermission('graphs:execute')) {
///   await runGraph();
/// }
/// ```
///
/// ---
///
/// ## 🔧 Backend сервис (другой сервис платформы)
///
/// Типичный сценарий: сервис проверяет токен входящего запроса.
///
/// ```dart
/// // Инициализация с jwtSecret — валидация токенов локально
/// final service = await AQSecurityClient.init(
///   authEndpoint,
///   jwtSecret: jwtSecret,
/// );
///
/// // Валидация входящего токена из HTTP заголовка
/// final isValid = await service.validateToken(request.headers['authorization']!);
///
/// // Получить claims из токена (без сети)
/// final claims = service.currentClaims;
/// final userId = claims?.sub;
/// final tenantId = claims?.tid;
/// ```
///
/// ---
///
/// ## 🔑 Подсервисы (admin операции)
///
/// Доступны через геттеры. Используются только в admin UI или backend сервисах
/// с соответствующими правами.
///
/// ```dart
/// // Управление ролями — только для admin
/// final roles = await service.roleManagement.getRoles();
///
/// // Управление политиками — только для admin
/// final policies = await service.policies.getPolicies();
///
/// // Аудит — только для admin/compliance
/// final logs = await service.audit.getAccessLogs(userId: userId);
/// ```
abstract interface class ISecurityService {
  /// Singleton — доступен после инициализации через AQSecurityClient.init().
  static ISecurityService get instance {
    if (_instance == null) {
      throw StateError(
        'ISecurityService not initialized. '
        'Backend package must call setSecurityServiceInstance() '
        'before using the service.',
      );
    }
    return _instance!;
  }

  /// Скрытое поле для хранения singleton instance
  static ISecurityService? _instance;

  /// Observable stream состояния безопасности
  Stream<SecurityState> get stream;

  /// Текущее состояние
  SecurityState get state;

  /// Текущий пользователь (null если не авторизован)
  AqUser? get currentUser;

  /// Текущий тенант (null если не авторизован)
  AqTenant? get currentTenant;

  /// Текущие claims (null если не авторизован)
  AqTokenClaims? get currentClaims;

  /// Флаг авторизации
  bool get isAuthenticated;

  /// Текущий access token (может триггерить silent refresh)
  Future<String?> get accessToken;

  // ── Подсервисы (admin операции) ───────────────────────────────────────────

  /// Управление ролями и назначениями. Только для admin UI.
  IRoleManagementService get roleManagement;

  /// Управление политиками доступа. Только для admin UI.
  IPolicyService get policies;

  /// Аудит и логи доступа. Только для admin/compliance.
  IAuditService get audit;

  // ── Методы авторизации ────────────────────────────────────────────────────

  /// Авторизация через Google OAuth
  Future<AuthResponse> loginWithGoogle({
    required String code,
    required String redirectUri,
  });

  /// Авторизация через Email/Password
  Future<AuthResponse> loginWithEmail({
    required String email,
    required String password,
  });

  /// Авторизация через API Key
  Future<AuthResponse> loginWithApiKey(String apiKey);

  /// Регистрация нового пользователя
  Future<AuthResponse> register({
    required String email,
    required String password,
    String? displayName,
  });

  /// Выход из системы
  Future<void> logout();

  /// Обновление токенов
  Future<AqTokenPair> refreshTokens();

  /// Восстановление сессии из хранилища
  Future<void> restoreSession();

  // ── Проверка прав (локально, из токена) ──────────────────────────────────
  //
  // ⚠️ Эти методы читают claims из JWT токена — быстро, без сети.
  // Используются ТОЛЬКО для адаптации UI (скрыть кнопку, показать раздел).
  // Для защиты данных сервер проверяет права независимо через AccessControlEngine.

  /// Есть ли право в токене текущего пользователя.
  Future<bool> hasPermission(String permission);

  /// Есть ли роль в токене текущего пользователя.
  Future<bool> hasRole(String role);

  /// Все/любое из прав присутствуют в токене.
  Future<bool> hasPermissions(List<String> permissions,
      {bool requireAll = true});

  /// Все/любая из ролей присутствуют в токене.
  Future<bool> hasRoles(List<String> roles, {bool requireAll = true});

  /// Какие действия разрешены на конкретном ресурсе.
  ///
  /// Объединяет RBAC + политики. Результат — список разрешённых permissions.
  ///
  /// ```dart
  /// final perms = await service.getResourcePermissions('project/123');
  /// final canWrite = perms.contains('project:write');
  /// ```
  Future<List<String>> getResourcePermissions(
    String resourceId, {
    List<String>? actions,
  });

  // ── Управление сессиями ───────────────────────────────────────────────────

  /// Получить список активных сессий текущего пользователя
  Future<List<AqSession>> getActiveSessions();

  /// Отозвать сессию по ID
  Future<void> revokeSession(String sessionId);

  /// Отозвать все сессии кроме текущей
  Future<void> revokeAllOtherSessions();

  // ── Управление API ключами ────────────────────────────────────────────────

  /// Получить список API ключей текущего пользователя
  Future<List<AqApiKey>> getApiKeys();

  /// Создать новый API ключ
  Future<AqApiKey> createApiKey({
    required String name,
    required List<String> permissions,
    bool isTest = false,
  });

  /// Ротация API ключа (создание нового, отзыв старого)
  Future<AqApiKey> rotateApiKey(String keyId);

  /// Отозвать API ключ
  Future<void> revokeApiKey(String keyId);

  // ── Управление профилем ───────────────────────────────────────────────────

  /// Обновить профиль пользователя
  Future<AqUser> updateProfile({
    String? displayName,
    String? avatarUrl,
  });

  /// Сменить пароль
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  });

  /// Запросить сброс пароля (отправка кода на email)
  Future<void> requestPasswordReset(String email);

  /// Сбросить пароль с кодом
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });

  // ── Верификация email ─────────────────────────────────────────────────────

  /// Отправить код верификации на email
  Future<void> sendVerificationCode();

  /// Верифицировать email с кодом
  Future<void> verifyEmail(String code);

  // ── Управление тенантами ──────────────────────────────────────────────────

  /// Получить список доступных тенантов
  Future<List<AqTenant>> getAvailableTenants();

  /// Переключиться на другой тенант
  Future<void> switchTenant(String tenantId);

  // ── Утилиты ───────────────────────────────────────────────────────────────

  /// Валидация токена
  Future<bool> validateToken(String token);

  /// Dispose ресурсов
  Future<void> dispose();
}

/// Регистрирует реализацию ISecurityService как singleton.
/// Вызывается один раз при старте приложения из aq_security пакета.
///
/// ```dart
/// // main.dart
/// final service = await AQSecurityClient.init('https://auth.example.com');
/// // AQSecurityClient.init() вызывает setSecurityServiceInstance() внутри
/// ```
void setSecurityServiceInstance(ISecurityService instance) {
  ISecurityService._instance = instance;
}

/// Глобальный геттер — синоним для ISecurityService.instance.
ISecurityService get securityService => ISecurityService.instance;
