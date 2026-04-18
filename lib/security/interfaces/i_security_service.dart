// pkgs/aq_schema/lib/security/interfaces/i_security_service.dart
//
// Интерфейс для сервиса безопасности.
// Реализуется в aq_security, используется в aq_security_ui.

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

/// Главный интерфейс сервиса безопасности
///
/// ВАЖНО ДЛЯ BACKEND РАЗРАБОТЧИКА:
///
/// Этот интерфейс является точкой входа для всей системы безопасности.
/// Backend пакет (aq_security) должен:
///
/// 1. Создать класс, реализующий ISecurityService:
///    ```dart
///    class AQSecurityService implements ISecurityService {
///      // Реализация всех методов
///    }
///    ```
///
/// 2. При инициализации приложения вызвать setSecurityServiceInstance:
///    ```dart
///    void main() {
///      final securityService = AQSecurityService(
///        authTransport: ...,
///        sessionStore: ...,
///      );
///
///      // Регистрация singleton instance
///      setSecurityServiceInstance(securityService);
///
///      runApp(MyApp());
///    }
///    ```
///
/// 3. После этого UI пакеты могут получить instance через:
///    ```dart
///    final service = ISecurityService.instance;
///    // или
///    final service = securityService; // глобальный геттер
///    ```
///
/// АРХИТЕКТУРА:
/// - ISecurityService - главный интерфейс (точка входа)
/// - IRoleManagementService - подсервис управления ролями (RBAC)
/// - IPolicyService - подсервис управления политиками (ABAC/PBAC)
/// - IAuditService - подсервис аудита и логирования
///
/// Все подсервисы доступны через геттеры главного интерфейса.
abstract interface class ISecurityService {
  /// Singleton instance геттер
  ///
  /// Используется UI пакетами для получения сервиса безопасности.
  /// Выбрасывает StateError если instance не инициализирован.
  ///
  /// Пример использования:
  /// ```dart
  /// final service = ISecurityService.instance;
  /// final roles = await service.roleManagement.getRoles();
  /// ```
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

  // ── Подсервисы ─────────────────────────────────────────────────────────────

  /// Сервис управления ролями (RBAC)
  /// Используется для работы с ролями, назначениями и правами доступа
  IRoleManagementService get roleManagement;

  /// Сервис управления политиками (ABAC/PBAC)
  /// Используется для работы с политиками доступа и их оценкой
  IPolicyService get policies;

  /// Сервис аудита и логирования
  /// Используется для записи и получения логов доступа и аудит-трейла
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

  // ── Проверка прав ─────────────────────────────────────────────────────────

  /// Проверка наличия права
  Future<bool> hasPermission(String permission);

  /// Проверка наличия роли
  Future<bool> hasRole(String role);

  /// Проверка нескольких прав (requireAll: true = все, false = хотя бы одно)
  Future<bool> hasPermissions(List<String> permissions, {bool requireAll = true});

  /// Проверка нескольких ролей
  Future<bool> hasRoles(List<String> roles, {bool requireAll = true});

  /// Получить список разрешённых действий для конкретного ресурса
  ///
  /// **Назначение:**
  /// Этот метод определяет, какие действия (permissions) текущий пользователь
  /// может выполнить над конкретным ресурсом, учитывая как RBAC (роли),
  /// так и PBAC (политики с контекстом).
  ///
  /// **Философия платформы:**
  /// В AQ Studio права доступа определяются двумя механизмами:
  /// 1. RBAC (Role-Based Access Control) - статические роли с permissions
  /// 2. PBAC (Policy-Based Access Control) - динамические политики с условиями
  ///
  /// Этот метод объединяет оба механизма, предоставляя единую точку входа
  /// для проверки прав на ресурс. Это соответствует принципу "чистой архитектуры":
  /// UI не должен знать о деталях реализации проверки прав.
  ///
  /// **Параметры:**
  /// - [resourceId] - Идентификатор ресурса в формате "type/id"
  ///   Примеры: "project/123", "workflow/456", "user/789"
  ///
  /// - [actions] - Список действий для проверки (опционально)
  ///   По умолчанию: ['read', 'write', 'delete', 'admin']
  ///   Можно передать кастомный список: ['execute', 'publish', 'share']
  ///
  /// **Возвращает:**
  /// Список разрешённых permissions в формате "resource_type:action"
  /// Примеры: ["project:read", "project:write"]
  ///
  /// **Алгоритм реализации (рекомендация для backend):**
  ///
  /// ```dart
  /// Future<List<String>> getResourcePermissions(
  ///   String resourceId, {
  ///   List<String>? actions,
  /// }) async {
  ///   // 1. Проверить авторизацию
  ///   final user = currentUser;
  ///   if (user == null) return [];
  ///
  ///   // 2. Извлечь тип ресурса из resourceId
  ///   final resourceType = resourceId.split('/').first; // "project/123" -> "project"
  ///
  ///   // 3. Определить список действий для проверки
  ///   final checkActions = actions ?? ['read', 'write', 'delete', 'admin'];
  ///
  ///   // 4. Проверить каждое действие
  ///   final allowed = <String>[];
  ///   for (final action in checkActions) {
  ///     final permission = '$resourceType:$action';
  ///
  ///     // 4.1. Проверка через RBAC (быстрая проверка по ролям)
  ///     final hasRbacPermission = await hasPermission(permission);
  ///     if (!hasRbacPermission) continue; // Нет права в ролях -> skip
  ///
  ///     // 4.2. Проверка через PBAC (политики с контекстом)
  ///     // Политики могут ограничить доступ даже если есть роль
  ///     // Например: "можно редактировать только свои проекты"
  ///     final context = PolicyContext(
  ///       userId: user.id,
  ///       resource: resourceId,
  ///       action: action,
  ///       ipAddress: currentIpAddress,
  ///       timestamp: DateTime.now(),
  ///       userAttributes: {
  ///         'email': user.email,
  ///         'userType': user.userType.value,
  ///       },
  ///       resourceAttributes: await _getResourceAttributes(resourceId),
  ///       userRoles: (await roleManagement.getUserRoles(user.id))
  ///           .map((r) => r.name)
  ///           .toList(),
  ///       userScopes: currentClaims?.scopes ?? [],
  ///     );
  ///
  ///     final policyResult = await policies.evaluatePolicy(context);
  ///     if (policyResult.allowed) {
  ///       allowed.add(permission);
  ///
  ///       // Логировать проверку (опционально, для аудита)
  ///       await audit.logAccess(
  ///         userId: user.id,
  ///         userEmail: user.email,
  ///         tenantId: currentTenant!.id,
  ///         resource: resourceId,
  ///         action: action,
  ///         allowed: true,
  ///         reason: 'Permission check via getResourcePermissions',
  ///       );
  ///     }
  ///   }
  ///
  ///   return allowed;
  /// }
  ///
  /// // Вспомогательный метод для получения атрибутов ресурса
  /// Future<Map<String, dynamic>> _getResourceAttributes(String resourceId) async {
  ///   // Загрузить ресурс из БД и извлечь атрибуты
  ///   // Например, для проекта: ownerId, visibility, status
  ///   final parts = resourceId.split('/');
  ///   final type = parts[0];
  ///   final id = parts.length > 1 ? parts[1] : null;
  ///
  ///   switch (type) {
  ///     case 'project':
  ///       final project = await projectRepository.get(id!);
  ///       return {
  ///         'ownerId': project.ownerId,
  ///         'visibility': project.visibility,
  ///         'status': project.status,
  ///       };
  ///     case 'workflow':
  ///       final workflow = await workflowRepository.get(id!);
  ///       return {
  ///         'ownerId': workflow.ownerId,
  ///         'projectId': workflow.projectId,
  ///       };
  ///     default:
  ///       return {};
  ///   }
  /// }
  /// ```
  ///
  /// **Почему такая реализация?**
  ///
  /// 1. **Производительность:**
  ///    - Сначала проверяем RBAC (быстро, по кэшу ролей)
  ///    - Только если есть право в роли -> проверяем политики
  ///    - Избегаем лишних вызовов evaluatePolicy
  ///
  /// 2. **Безопасность:**
  ///    - Политики могут ограничить доступ даже при наличии роли
  ///    - Учитывается контекст: время, IP, атрибуты ресурса
  ///    - Принцип "deny wins" соблюдается
  ///
  /// 3. **Чистая архитектура:**
  ///    - UI вызывает один метод, не зная о RBAC/PBAC
  ///    - Backend инкапсулирует логику проверки
  ///    - Легко добавить новые механизмы проверки (ABAC, etc.)
  ///
  /// 4. **Аудит:**
  ///    - Каждая проверка логируется
  ///    - Можно отследить кто и когда проверял права
  ///    - Compliance требования выполняются
  ///
  /// **Кэширование (рекомендация):**
  ///
  /// Результат можно кэшировать на короткое время (30-60 секунд):
  /// ```dart
  /// final cacheKey = 'resource_permissions:${user.id}:$resourceId';
  /// final cached = await cache.get(cacheKey);
  /// if (cached != null) return cached;
  ///
  /// final result = await _computePermissions(...);
  /// await cache.set(cacheKey, result, ttl: Duration(seconds: 30));
  /// return result;
  /// ```
  ///
  /// **Использование в UI:**
  ///
  /// ```dart
  /// // В провайдере
  /// final resourcePermissionsProvider = FutureProvider.family<List<String>, String>(
  ///   (ref, resourceId) async {
  ///     final service = ref.watch(securityServiceProvider);
  ///     return await service.getResourcePermissions(resourceId);
  ///   },
  /// );
  ///
  /// // В виджете
  /// final permissions = ref.watch(resourcePermissionsProvider('project/123'));
  /// permissions.when(
  ///   data: (perms) {
  ///     final canRead = perms.contains('project:read');
  ///     final canWrite = perms.contains('project:write');
  ///     // Показать UI в зависимости от прав
  ///   },
  /// );
  /// ```
  ///
  /// **Требования к производительности:**
  /// - Должен выполняться < 200ms без кэша
  /// - Должен выполняться < 10ms с кэшем
  /// - Не должен блокировать UI
  ///
  /// **Аудит:**
  /// - Логировать только разрешённые проверки (allowed: true)
  /// - Или логировать все проверки для compliance
  /// - Решение зависит от требований безопасности
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

/// Установка singleton instance (вызывается из backend пакета)
///
/// ВАЖНО ДЛЯ BACKEND РАЗРАБОТЧИКА:
/// Этот метод должен быть вызван при инициализации приложения,
/// до того как UI начнёт использовать сервис безопасности.
///
/// Пример:
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///
///   // Создание и инициализация сервиса
///   final securityService = AQSecurityService(
///     authTransport: HttpAuthTransport(baseUrl: 'http://localhost:8080'),
///     sessionStore: SecureSessionStore(),
///   );
///
///   // Регистрация singleton instance
///   setSecurityServiceInstance(securityService);
///
///   runApp(MyApp());
/// }
/// ```
void setSecurityServiceInstance(ISecurityService instance) {
  ISecurityService._instance = instance;
}

/// Глобальный геттер для ISecurityService (для удобства)
///
/// Альтернативный способ получения instance:
/// ```dart
/// final service = securityService;
/// // вместо
/// final service = ISecurityService.instance;
/// ```
///
/// Выбрасывает StateError если instance не инициализирован.
ISecurityService get securityService => ISecurityService.instance;
