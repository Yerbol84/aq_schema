# Сводка: Документация для Backend

**Дата:** 2026-04-13  
**Время:** 11:39 UTC

## ✅ Создано 5 документов

### 1. README_BACKEND.md (главный файл)
- Оглавление всех документов
- Быстрый старт
- Критические требования
- Структура БД
- Чеклист реализации
- Мониторинг и отладка

### 2. BACKEND_SPECIFICATION.md
- Общая архитектура (Ports & Adapters)
- ISecurityService - главный интерфейс
- Singleton pattern
- SecurityState (Unauthenticated / Authenticated)
- Методы авторизации:
  - loginWithEmail (с валидацией, аудитом, исключениями)
  - loginWithGoogle (OAuth2 flow)
  - loginWithApiKey (проверка hash, permissions)

### 3. BACKEND_SPEC_ROLE_MANAGEMENT.md
- IRoleManagementService - 10 методов
- Модели: AqRole, AqUserRole
- RBAC логика
- Проверка прав с wildcards
- Требования к производительности
- Индексы БД

**Методы:**
1. getRoles - получить все роли
2. getRole - получить роль по ID
3. createRole - создать роль
4. updateRole - обновить роль
5. deleteRole - удалить роль
6. assignRole - назначить роль пользователю
7. revokeRole - отозвать роль
8. getUserRoles - получить роли пользователя
9. getUsersByRole - получить пользователей с ролью
10. getAllPermissions - получить все permissions

### 4. BACKEND_SPEC_POLICY_SERVICE.md
- IPolicyService - 7 методов
- Модели: AqPolicy, PolicyStatement, PolicyCondition
- **Алгоритм оценки политик** (КРИТИЧНО!)
- Типы условий: timeRange, ipAddress, userAttribute, resourceAttribute, role, scope
- Операторы: equals, contains, greaterThan, inList, matches
- Логика: and, or, not
- Правило приоритета: deny wins
- Примеры политик

**Методы:**
1. getPolicies - получить все политики
2. getPolicy - получить политику по ID
3. createPolicy - создать политику
4. updatePolicy - обновить политику
5. deletePolicy - удалить политику
6. evaluatePolicy - оценить политики (КРИТИЧНО!)
7. testPolicy - тестировать политику

### 5. BACKEND_SPEC_AUDIT_SERVICE.md
- IAuditService - 8 методов
- Модели: AqAccessLog, AqAuditTrail
- **Архитектура очереди логов** (КРИТИЧНО!)
- Асинхронное логирование
- Батчинг (1000 записей каждые 5 секунд)
- Статистика и отчёты
- Retention policy
- Партиционирование для больших объёмов

**Методы:**
1. logAccess - логировать попытку доступа (< 5ms!)
2. logAudit - логировать изменение (< 10ms!)
3. getAccessLogs - получить логи доступа
4. getAuditTrail - получить аудит-трейл
5. getAccessLogStats - статистика по доступу
6. getAuditTrailStats - статистика по аудиту
7. cleanupAccessLogs - очистка старых логов
8. cleanupAuditTrail - очистка старого аудита

## 📊 Статистика

| Метрика | Значение |
|---------|----------|
| **Документов** | 5 |
| **Интерфейсов** | 4 (ISecurityService + 3 подсервиса) |
| **Методов описано** | 40+ |
| **Примеров кода** | 50+ |
| **SQL примеров** | 20+ |
| **Индексов БД** | 15+ |

## 🎯 Ключевые моменты для backend

### Критические требования

1. **Производительность:**
   - logAccess < 5ms (вызывается на КАЖДОМ запросе)
   - evaluatePolicy < 100ms (вызывается на КАЖДОМ запросе)
   - hasPermission < 50ms (вызывается на КАЖДОМ запросе)

2. **Асинхронное логирование:**
   - Использовать очередь + батчинг
   - НЕ блокировать основной поток
   - Сохранять батчами по 1000 записей

3. **Алгоритм оценки политик:**
   - Deny wins (если есть хотя бы один DENY → DENY)
   - Default deny (нет совпадений → DENY)
   - Приоритизация по priority

4. **Индексы БД:**
   - Без индексов система будет медленной
   - 15+ индексов описаны в документации

### Архитектура

```
ISecurityService (singleton)
    ├── IRoleManagementService (RBAC)
    ├── IPolicyService (ABAC/PBAC)
    └── IAuditService (Logging)
```

### Модели данных

**12 коллекций:**
- 7 security коллекций (users, tenants, profiles, roles, sessions, api_keys)
- 5 RBAC коллекций (roles, user_roles, policies, access_logs, audit_trail)

### Storable обёртки

Все модели имеют Storable обёртки:
- DirectStorable - для простых CRUD
- LoggedStorable - для сущностей с аудитом

## 📁 Расположение файлов

```
pkgs/aq_schema/lib/security/
├── README_BACKEND.md                      # Главный файл (старт здесь!)
├── BACKEND_SPECIFICATION.md               # ISecurityService
├── BACKEND_SPEC_ROLE_MANAGEMENT.md        # IRoleManagementService
├── BACKEND_SPEC_POLICY_SERVICE.md         # IPolicyService
├── BACKEND_SPEC_AUDIT_SERVICE.md          # IAuditService
├── interfaces/
│   ├── i_security_service.dart
│   ├── i_role_management_service.dart
│   ├── i_policy_service.dart
│   └── i_audit_service.dart
├── models/
│   ├── aq_user.dart
│   ├── aq_role.dart
│   ├── aq_policy.dart
│   ├── aq_access_log.dart
│   └── aq_audit_trail.dart
├── mock/
│   ├── mock_security_service.dart
│   ├── mock_role_management_service.dart
│   ├── mock_policy_service.dart
│   └── mock_audit_service.dart
└── storable/
    ├── security_storables.dart
    ├── storable_rbac.dart
    └── security_domains.dart
```

## 🚀 Что дальше?

Backend разработчик должен:

1. **Прочитать README_BACKEND.md** - там быстрый старт
2. **Изучить каждый интерфейс** - детальная документация в 4 файлах
3. **Реализовать все методы** - 40+ методов с примерами
4. **Создать индексы БД** - 15+ индексов описаны
5. **Написать тесты** - mock реализации как reference
6. **Настроить мониторинг** - метрики описаны

## ✅ Готово к передаче в backend!

Вся документация содержит:
- ✅ Бизнес-логику для каждого метода
- ✅ Валидацию входных данных
- ✅ Права доступа (permissions)
- ✅ Аудит (что логировать)
- ✅ Исключения (какие ошибки выбрасывать)
- ✅ SQL примеры
- ✅ Требования к производительности
- ✅ Примеры кода
- ✅ Индексы БД
- ✅ Кэширование
- ✅ Мониторинг

**Документация полная и готова к использованию!**
