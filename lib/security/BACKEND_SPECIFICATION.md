# Спецификация для Backend разработчика

**Дата:** 2026-04-13  
**Пакет:** aq_schema  
**Версия:** 1.0

## Оглавление

1. [Общая архитектура](#общая-архитектура)
2. [ISecurityService - главный интерфейс](#isecurityservice)
3. [IRoleManagementService - управление ролями](#irolemanagementservice)
4. [IPolicyService - управление политиками](#ipolicyservice)
5. [IAuditService - аудит и логирование](#iauditservice)
6. [Модели данных](#модели-данных)
7. [Требования к производительности](#требования-к-производительности)
8. [Безопасность](#безопасность)

---

## Общая архитектура

### Принцип работы

Система безопасности построена на архитектуре **Ports & Adapters** (Hexagonal Architecture):

- **Порты (Interfaces)**: Определены в `aq_schema/lib/security/interfaces/`
- **Адаптеры (Implementations)**: Реализуются в пакете `aq_security` (backend)
- **Модели**: Определены в `aq_schema/lib/security/models/`

### Точка входа

```dart
// Главный интерфейс - точка входа в систему безопасности
abstract interface class ISecurityService {
  // Singleton instance
  static ISecurityService get instance;
  
  // Подсервисы
  IRoleManagementService get roleManagement;
  IPolicyService get policies;
  IAuditService get audit;
  
  // Основные методы авторизации
  Future<AuthResponse> loginWithEmail({...});
  Future<AuthResponse> loginWithGoogle({...});
  Future<void> logout();
  // ... и другие
}
```

### Инициализация (КРИТИЧНО!)

Backend ОБЯЗАН предоставить реализацию и зарегистрировать её как singleton:

```dart
void main() async {
  // 1. Создать реализацию
  final securityService = AQSecurityService(
    authTransport: HttpAuthTransport(baseUrl: 'http://localhost:8080'),
    sessionStore: SecureSessionStore(),
    // Инициализировать подсервисы
    roleManagement: RoleManagementService(...),
    policies: PolicyService(...),
    audit: AuditService(...),
  );

  // 2. Зарегистрировать singleton
  setSecurityServiceInstance(securityService);

  // 3. Теперь UI может использовать ISecurityService.instance
  runApp(MyApp());
}
```

### Разделение ответственности

| Подсервис | Ответственность |
|-----------|-----------------|
| **IRoleManagementService** | RBAC - роли, права, назначения |
| **IPolicyService** | ABAC/PBAC - политики доступа на основе контекста |
| **IAuditService** | Логирование доступа и изменений |

---

## ISecurityService

**Файл:** `lib/security/interfaces/i_security_service.dart`

### Назначение

Главный интерфейс системы безопасности. Отвечает за:
- Аутентификацию пользователей
- Управление сессиями
- Управление API ключами
- Проверку прав доступа
- Управление профилем пользователя

### Состояние (State)

```dart
Stream<SecurityState> get stream;
SecurityState get state;
```

**Что нужно от backend:**

Система работает на основе состояний. Backend должен эмитить изменения состояния через Stream:

```dart
sealed class SecurityState {
  const SecurityState();
}

// Пользователь не авторизован
final class SecurityStateUnauthenticated extends SecurityState {
  const SecurityStateUnauthenticated();
}

// Пользователь авторизован
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
```

**Бизнес-логика:**
1. При успешной авторизации → эмитить `SecurityStateAuthenticated`
2. При logout → эмитить `SecurityStateUnauthenticated`
3. При истечении токена → эмитить `SecurityStateUnauthenticated`
4. При смене тенанта → эмитить новый `SecurityStateAuthenticated` с новым tenant

### Геттеры текущего состояния

```dart
AqUser? get currentUser;
AqTenant? get currentTenant;
AqTokenClaims? get currentClaims;
bool get isAuthenticated;
Future<String?> get accessToken;
```

**Что нужно от backend:**

Эти геттеры должны возвращать данные из текущего `state`:
- `currentUser` - null если не авторизован
- `currentTenant` - null если не авторизован
- `currentClaims` - null если не авторизован
- `isAuthenticated` - true если state is SecurityStateAuthenticated
- `accessToken` - JWT токен или null

---

## Методы авторизации

### loginWithEmail

```dart
Future<AuthResponse> loginWithEmail({
  required String email,
  required String password,
});
```

**Что нужно от backend:**

1. **Валидация:**
   - Email должен быть валидным (формат email)
   - Password не пустой
   - Проверить существование пользователя
   - Проверить правильность пароля (bcrypt/argon2)

2. **Бизнес-логика:**
   - Если пользователь неактивен (`isActive = false`) → выбросить `SecurityException('User is inactive')`
   - Если email не верифицирован и требуется верификация → выбросить `SecurityException('Email not verified')`
   - Создать новую сессию (`AqSession`)
   - Сгенерировать JWT токены (access + refresh)
   - Записать в audit log: `action: login, success: true`

3. **Возврат:**
   ```dart
   return AuthResponse(
     user: user,
     tenant: tenant,
     session: session,
     tokens: AqTokenPair(
       accessToken: 'jwt_access_token',
       refreshToken: 'jwt_refresh_token',
     ),
   );
   ```

4. **Аудит:**
   - Логировать КАЖДУЮ попытку входа (успешную и неуспешную)
   - Сохранять IP адрес, User-Agent
   - При неуспешной попытке сохранять причину (wrong password, user not found, etc.)

**Исключения:**
- `SecurityException('Invalid credentials')` - неверный email/password
- `SecurityException('User is inactive')` - пользователь деактивирован
- `SecurityException('Email not verified')` - email не подтверждён
- `SecurityException('Too many attempts')` - превышен лимит попыток входа

### loginWithGoogle

```dart
Future<AuthResponse> loginWithGoogle({
  required String code,
  required String redirectUri,
});
```

**Что нужно от backend:**

1. **OAuth2 Flow:**
   - Обменять `code` на Google access token
   - Получить профиль пользователя из Google API
   - Извлечь: email, displayName, avatarUrl, providerUserId (Google ID)

2. **Бизнес-логика:**
   - Найти пользователя по `providerUserId` и `authProvider = google`
   - Если не найден → создать нового пользователя:
     ```dart
     AqUser(
       id: generateId(),
       email: googleEmail,
       displayName: googleName,
       avatarUrl: googleAvatar,
       authProvider: AuthProvider.google,
       providerUserId: googleId,
       userType: UserType.developer, // по умолчанию
       tenantId: defaultTenantId,
       isActive: true,
       emailVerified: true, // Google уже верифицировал
       createdAt: now,
     )
     ```
   - Создать сессию
   - Сгенерировать токены
   - Записать в audit log

3. **Tenant assignment:**
   - Если новый пользователь → создать личный tenant или назначить в default tenant
   - Если существующий → использовать его текущий tenant

**Исключения:**
- `SecurityException('Invalid OAuth code')` - неверный code
- `SecurityException('Google API error')` - ошибка при обращении к Google

### loginWithApiKey

```dart
Future<AuthResponse> loginWithApiKey(String apiKey);
```

**Что нужно от backend:**

1. **Валидация:**
   - Извлечь prefix из ключа (первые 8 символов)
   - Найти ключ в БД по hash (SHA-256 от полного ключа)
   - Проверить `isActive = true`
   - Проверить `expiresAt` (если установлен)

2. **Бизнес-логика:**
   - Обновить `lastUsedAt = now`
   - Загрузить пользователя по `userId`
   - Создать сессию с `authProvider = apiKey`
   - Сгенерировать токены с ограниченными правами (только permissions из API ключа)

3. **Токены:**
   - Access token должен содержать только те permissions, которые есть у API ключа
   - Refresh token НЕ выдавать (API ключи не обновляются)

**Исключения:**
- `SecurityException('Invalid API key')` - ключ не найден
- `SecurityException('API key expired')` - ключ истёк
- `SecurityException('API key inactive')` - ключ деактивирован

---

Продолжение следует в следующих файлах...
