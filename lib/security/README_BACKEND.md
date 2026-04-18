# Документация для Backend разработчика

**Дата:** 2026-04-13  
**Пакет:** aq_schema  
**Версия:** 1.0

## 📚 Содержание документации

Эта документация описывает все интерфейсы системы безопасности, которые должен реализовать backend разработчик.

### Основные документы

1. **[BACKEND_SPECIFICATION.md](BACKEND_SPECIFICATION.md)**
   - Общая архитектура (Ports & Adapters)
   - ISecurityService - главный интерфейс
   - Методы авторизации (loginWithEmail, loginWithGoogle, loginWithApiKey)
   - Управление сессиями и API ключами
   - Управление профилем пользователя

2. **[BACKEND_SPEC_ROLE_MANAGEMENT.md](BACKEND_SPEC_ROLE_MANAGEMENT.md)**
   - IRoleManagementService - управление RBAC
   - Создание, изменение, удаление ролей
   - Назначение ролей пользователям
   - Проверка прав доступа
   - 10 методов с детальной документацией

3. **[BACKEND_SPEC_POLICY_SERVICE.md](BACKEND_SPEC_POLICY_SERVICE.md)**
   - IPolicyService - управление ABAC/PBAC
   - Создание, изменение, удаление политик
   - **Алгоритм оценки политик** (КРИТИЧНО!)
   - Условия доступа на основе контекста
   - 7 методов с примерами политик

4. **[BACKEND_SPEC_AUDIT_SERVICE.md](BACKEND_SPEC_AUDIT_SERVICE.md)**
   - IAuditService - аудит и логирование
   - Логирование попыток доступа
   - Аудит изменений
   - Статистика и отчёты
   - **Архитектура очереди логов** (КРИТИЧНО!)
   - 8 методов с требованиями к производительности

5. **[BACKEND_SPEC_GET_RESOURCE_PERMISSIONS.md](BACKEND_SPEC_GET_RESOURCE_PERMISSIONS.md)** ⭐ NEW
   - ISecurityService.getResourcePermissions - проверка прав на ресурс
   - Объединение RBAC + PBAC в одном методе
   - Детальный алгоритм реализации
   - Кэширование и оптимизация
   - Примеры использования в UI

---

## 🎯 Быстрый старт

### Шаг 1: Изучить архитектуру

Прочитайте [BACKEND_SPECIFICATION.md](BACKEND_SPECIFICATION.md) - там описана общая архитектура и принцип работы.

**Ключевые концепции:**
- Ports & Adapters (Hexagonal Architecture)
- Singleton pattern для ISecurityService
- Подсервисы (roleManagement, policies, audit)
- SecurityState (Unauthenticated / Authenticated)

### Шаг 2: Реализовать ISecurityService

```dart
class AQSecurityService implements ISecurityService {
  AQSecurityService({
    required this.authTransport,
    required this.sessionStore,
    required IRoleManagementService roleManagement,
    required IPolicyService policies,
    required IAuditService audit,
  }) : _roleManagement = roleManagement,
       _policies = policies,
       _audit = audit;

  final IAuthTransport authTransport;
  final ISessionStore sessionStore;
  final IRoleManagementService _roleManagement;
  final IPolicyService _policies;
  final IAuditService _audit;

  @override
  IRoleManagementService get roleManagement => _roleManagement;

  @override
  IPolicyService get policies => _policies;

  @override
  IAuditService get audit => _audit;

  // Реализовать все методы...
}
```

### Шаг 3: Реализовать подсервисы

1. **RoleManagementService** - см. [BACKEND_SPEC_ROLE_MANAGEMENT.md](BACKEND_SPEC_ROLE_MANAGEMENT.md)
2. **PolicyService** - см. [BACKEND_SPEC_POLICY_SERVICE.md](BACKEND_SPEC_POLICY_SERVICE.md)
3. **AuditService** - см. [BACKEND_SPEC_AUDIT_SERVICE.md](BACKEND_SPEC_AUDIT_SERVICE.md)

### Шаг 4: Зарегистрировать singleton

```dart
void main() async {
  final securityService = AQSecurityService(...);
  setSecurityServiceInstance(securityService);
  
  runApp(MyApp());
}
```

---

## 🔑 Критические требования

### 1. Производительность

| Метод | Требование | Почему критично |
|-------|-----------|-----------------|
| `IAuditService.logAccess` | < 5ms | Вызывается на КАЖДОМ запросе |
| `IPolicyService.evaluatePolicy` | < 100ms | Вызывается на КАЖДОМ запросе |
| `IRoleManagementService.hasPermission` | < 50ms | Вызывается на КАЖДОМ запросе |
| `ISecurityService.loginWithEmail` | < 500ms | UX критично |

### 2. Асинхронное логирование

**КРИТИЧНО!** Логирование НЕ должно блокировать основной поток:

```dart
// ✅ ПРАВИЛЬНО
Future<void> logAccess(...) async {
  _logQueue.add(log);
  return; // Не ждём сохранения в БД
}

// ❌ НЕПРАВИЛЬНО
Future<void> logAccess(...) async {
  await db.insert('logs', log); // Блокирует запрос!
}
```

### 3. Алгоритм оценки политик

**КРИТИЧНО!** Правило приоритета:
1. Если есть хотя бы один **DENY** → **DENY** (deny wins)
2. Если есть хотя бы один **ALLOW** и нет DENY → **ALLOW**
3. Если нет совпадений → **DENY** (default deny)

### 4. Индексы БД

**КРИТИЧНО!** Без индексов система будет медленной:

```sql
-- RBAC
CREATE INDEX idx_rbac_roles_tenant ON rbac_roles(tenantId);
CREATE INDEX idx_rbac_ur_user ON rbac_user_roles(userId);
CREATE INDEX idx_rbac_ur_tenant ON rbac_user_roles(tenantId);

-- Policies
CREATE INDEX idx_rbac_policies_tenant ON rbac_policies(tenantId);
CREATE INDEX idx_rbac_policies_priority ON rbac_policies(priority DESC);

-- Audit
CREATE INDEX idx_rbac_logs_user ON rbac_access_logs(userId);
CREATE INDEX idx_rbac_logs_timestamp ON rbac_access_logs(timestamp DESC);
CREATE INDEX idx_rbac_audit_timestamp ON rbac_audit_trail(timestamp DESC);
```

---

## 📊 Структура БД

### Коллекции (таблицы)

| Коллекция | Тип | Описание |
|-----------|-----|----------|
| `security_users` | Direct | Пользователи |
| `security_tenants` | Direct | Тенанты |
| `security_profiles` | Direct | Профили пользователей |
| `security_roles` | Direct | Базовые роли |
| `security_user_roles` | Direct | Назначения базовых ролей |
| `security_sessions` | Logged | Сессии (с аудитом) |
| `security_api_keys` | Logged | API ключи (с аудитом) |
| `rbac_roles` | Direct | RBAC роли |
| `rbac_user_roles` | Direct | RBAC назначения |
| `rbac_policies` | Direct | PBAC политики |
| `rbac_access_logs` | Logged | Логи доступа |
| `rbac_audit_trail` | Logged | Аудит изменений |

### Регистрация в VaultRegistry

Все коллекции уже зарегистрированы в `AqSecurityDomains.all`:

```dart
// server_apps/aq_auth_data_service/bin/server.dart
for (final domain in AqSecurityDomains.all) {
  registry.register(DomainRegistration(
    collection: domain.collection,
    mode: domain.kind.toStorageMode(),
    fromMap: domain.fromMap,
    jsonSchema: domain.jsonSchema,
    indexes: domain.indexes,
  ));
}
```

---

## 🧪 Тестирование

### Mock реализации

Для тестов UI уже созданы mock реализации:

```dart
import 'package:aq_schema/security/mock/mock.dart';

void main() {
  late MockSecurityService mockService;

  setUp(() {
    mockService = MockSecurityService();
    setSecurityServiceInstance(mockService);
  });

  test('should login successfully', () async {
    final response = await mockService.loginWithEmail(
      email: 'test@example.com',
      password: 'password',
    );
    expect(response.user.email, 'test@example.com');
  });
}
```

### Unit тесты backend

Backend должен покрыть тестами:

1. **RoleManagementService:**
   - Создание/изменение/удаление ролей
   - Назначение/отзыв ролей
   - Проверка прав (hasPermission с wildcards)

2. **PolicyService:**
   - Создание/изменение/удаление политик
   - **Алгоритм оценки политик** (все типы условий)
   - Приоритизация (deny wins)

3. **AuditService:**
   - Логирование (очередь + батчинг)
   - Получение логов с фильтрацией
   - Статистика
   - Cleanup

---

## 🔒 Безопасность

### 1. Хранение паролей

```dart
// ✅ ПРАВИЛЬНО
final hashedPassword = await argon2.hash(password);

// ❌ НЕПРАВИЛЬНО
final hashedPassword = sha256(password); // Слишком быстро для брутфорса
```

### 2. JWT токены

```dart
// Access token
{
  "sub": "user_id",
  "tid": "tenant_id",
  "email": "user@example.com",
  "type": "access",
  "exp": now + 1 hour,
  "scopes": ["read", "write"],
  "roles": ["user"]
}

// Refresh token
{
  "sub": "user_id",
  "tid": "tenant_id",
  "type": "refresh",
  "exp": now + 30 days,
  "jti": "unique_token_id"
}
```

### 3. API ключи

```dart
// Генерация
final key = generateSecureRandom(32); // 256 bits
final prefix = key.substring(0, 8);   // Для поиска
final hash = sha256(key);             // Хранить только hash

// Проверка
final storedKey = await db.findByPrefix(prefix);
if (sha256(providedKey) == storedKey.hash) {
  // Valid
}
```

### 4. Rate limiting

```dart
// Защита от брутфорса
final attempts = await redis.get('login_attempts:$email');
if (attempts > 5) {
  throw SecurityException('Too many attempts. Try again in 15 minutes.');
}
```

---

## 📈 Мониторинг

Backend должен экспортировать метрики:

```
# Авторизация
security_login_total{method="email",status="success"} 1500
security_login_total{method="email",status="failed"} 50
security_login_duration_ms{method="email"} 250

# Проверка прав
security_permission_check_total{result="allowed"} 10000
security_permission_check_total{result="denied"} 500
security_permission_check_duration_ms 45

# Оценка политик
security_policy_evaluation_total{result="allowed"} 5000
security_policy_evaluation_total{result="denied"} 200
security_policy_evaluation_duration_ms 80

# Аудит
security_audit_queue_size{type="access_log"} 150
security_audit_queue_size{type="audit_trail"} 20
security_audit_flush_duration_ms 120
```

---

## 🐛 Отладка

### Логирование

```dart
// Включить debug логи
final logger = Logger('SecurityService');

logger.info('User ${user.email} logged in');
logger.warning('Failed login attempt for ${email}');
logger.error('Policy evaluation failed: $error');
```

### Трейсинг

```dart
// OpenTelemetry spans
final span = tracer.startSpan('security.login');
try {
  final result = await loginWithEmail(...);
  span.setStatus(StatusCode.ok);
  return result;
} catch (e) {
  span.setStatus(StatusCode.error, e.toString());
  rethrow;
} finally {
  span.end();
}
```

---

## 📞 Поддержка

Если возникнут вопросы:

1. **Документация в интерфейсах** - каждый метод содержит детальную документацию
2. **Mock реализации** - можно использовать как reference implementation
3. **Эти документы** - содержат все требования и примеры

---

## ✅ Чеклист реализации

### ISecurityService
- [ ] loginWithEmail
- [ ] loginWithGoogle
- [ ] loginWithApiKey
- [ ] register
- [ ] logout
- [ ] refreshTokens
- [ ] restoreSession
- [ ] hasPermission / hasRole
- [ ] getResourcePermissions (NEW!)
- [ ] Управление сессиями (getActiveSessions, revokeSession)
- [ ] Управление API ключами (getApiKeys, createApiKey, rotateApiKey)
- [ ] Управление профилем (updateProfile, changePassword)
- [ ] Верификация email (sendVerificationCode, verifyEmail)
- [ ] Управление тенантами (getAvailableTenants, switchTenant)

### IRoleManagementService
- [ ] getRoles
- [ ] getRole
- [ ] createRole
- [ ] updateRole
- [ ] deleteRole
- [ ] assignRole
- [ ] revokeRole
- [ ] getUserRoles
- [ ] getUsersByRole
- [ ] getAllPermissions

### IPolicyService
- [ ] getPolicies
- [ ] getPolicy
- [ ] createPolicy
- [ ] updatePolicy
- [ ] deletePolicy
- [ ] evaluatePolicy (КРИТИЧНО!)
- [ ] testPolicy

### IAuditService
- [ ] logAccess (с очередью!)
- [ ] logAudit (с очередью!)
- [ ] getAccessLogs
- [ ] getAuditTrail
- [ ] getAccessLogStats
- [ ] getAuditTrailStats
- [ ] cleanupAccessLogs
- [ ] cleanupAuditTrail

### Инфраструктура
- [ ] Индексы БД созданы
- [ ] Очередь логов реализована
- [ ] Кэширование настроено
- [ ] Метрики экспортируются
- [ ] Unit тесты написаны
- [ ] Integration тесты написаны

---

**Удачи в реализации! 🚀**
