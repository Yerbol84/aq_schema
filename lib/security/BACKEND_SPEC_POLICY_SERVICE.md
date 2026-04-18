# IPolicyService - Управление политиками доступа

**Файл:** `lib/security/interfaces/i_policy_service.dart`

## Назначение

Подсервис для управления ABAC/PBAC (Attribute-Based / Policy-Based Access Control):
- Создание, изменение, удаление политик
- Оценка политик на основе контекста
- Тестирование политик
- Приоритизация политик

## Отличие от RBAC

| RBAC | PBAC |
|------|------|
| Статические роли | Динамические условия |
| "У пользователя есть роль Admin" | "Пользователь может редактировать, если он владелец И время 9-18" |
| Простая проверка | Сложная оценка контекста |

## Модели

### AqPolicy

```dart
final class AqPolicy {
  final String id;
  final String name;
  final String? description;
  final String tenantId;
  final List<PolicyStatement> statements;  // Список правил
  final bool isActive;
  final int priority;      // Больше = выше приоритет
  final int createdAt;
  final String createdBy;
}
```

### PolicyStatement

```dart
final class PolicyStatement {
  final PolicyEffect effect;              // allow или deny
  final List<PolicyCondition> conditions; // Условия
  final PolicyLogic logic;                // and, or, not
}
```

### PolicyCondition

```dart
final class PolicyCondition {
  final PolicyConditionType type;    // time_range, ip_address, user_attribute, etc.
  final PolicyOperator operator;     // equals, contains, greater_than, etc.
  final dynamic value;               // Значение для сравнения
  final String? field;               // Поле для user_attribute, resource_attribute
}
```

### Enums

```dart
enum PolicyEffect { allow, deny }

enum PolicyConditionType {
  timeRange,           // Временной диапазон
  ipAddress,           // IP адрес
  userAttribute,       // Атрибут пользователя
  resourceAttribute,   // Атрибут ресурса
  scope,               // Scope requirement
  role,                // Role requirement
  custom,              // Кастомное условие
}

enum PolicyOperator {
  equals,              // ==
  notEquals,           // !=
  contains,            // string.contains()
  notContains,         // !string.contains()
  greaterThan,         // >
  lessThan,            // <
  inList,              // value in [...]
  notInList,           // value not in [...]
  matches,             // regex match
}

enum PolicyLogic { and, or, not }
```

---

## Методы

### 1. getPolicies

```dart
Future<List<AqPolicy>> getPolicies({bool includeInactive = false});
```

**Что нужно от backend:**

1. **Запрос:**
   - Получить все политики для текущего тенанта
   - Если `includeInactive = false` → только активные
   - Сортировать по приоритету (DESC), затем по имени

2. **SQL пример:**
   ```sql
   SELECT * FROM rbac_policies 
   WHERE tenantId = $currentTenantId
   AND (isActive = true OR $includeInactive = true)
   ORDER BY priority DESC, name ASC
   ```

3. **Кэширование:**
   - Политики меняются редко → кэшировать на 5-10 минут
   - Инвалидировать при создании/изменении/удалении

**Возврат:** Список политик

**Исключения:** Нет

---

### 2. getPolicy

```dart
Future<AqPolicy?> getPolicy(String policyId);
```

**Что нужно от backend:**

1. **Запрос:**
   - Найти политику по ID
   - Проверить, что принадлежит текущему тенанту

**Возврат:** 
- `AqPolicy` если найдена
- `null` если не найдена или нет доступа

**Исключения:** Нет

---

### 3. createPolicy

```dart
Future<AqPolicy> createPolicy({
  required String name,
  String? description,
  required List<PolicyStatement> statements,
  bool isActive = true,
  int priority = 0,
});
```

**Что нужно от backend:**

1. **Валидация:**
   - `name` не пустой, 3-100 символов
   - `name` уникален в рамках тенанта
   - `statements` не пустой список
   - Каждый statement валиден (есть conditions, effect, logic)

2. **Бизнес-логика:**
   - Генерировать уникальный ID
   - Установить `tenantId = currentTenantId`
   - Установить `createdAt = now`
   - Установить `createdBy = currentUser.id`

3. **Права доступа:**
   - Требуется permission: `policies:create`
   - Или роль: `admin`

4. **Аудит:**
   ```dart
   await audit.logAudit(
     action: AuditActionType.create,
     entityType: AuditEntityType.policy,
     entityId: policy.id,
     entityName: policy.name,
     userId: currentUser.id,
     userEmail: currentUser.email,
     tenantId: currentTenantId,
     changes: {'statements': statements.length},
   );
   ```

**Возврат:** Созданная политика

**Исключения:**
- `SecurityException('Permission denied')` - нет прав
- `SecurityException('Policy name already exists')` - имя занято
- `SecurityException('Invalid policy statement')` - неверный statement

---

### 4. updatePolicy

```dart
Future<AqPolicy> updatePolicy({
  required String policyId,
  String? name,
  String? description,
  List<PolicyStatement>? statements,
  bool? isActive,
  int? priority,
});
```

**Что нужно от backend:**

1. **Валидация:**
   - Политика существует
   - Политика принадлежит текущему тенанту
   - Если `name` меняется → проверить уникальность

2. **Бизнес-логика:**
   - Обновить только переданные поля (partial update)
   - Сохранить старые значения для аудита

3. **Права доступа:**
   - Требуется permission: `policies:update`
   - Или роль: `admin`

4. **Аудит:**
   ```dart
   await audit.logAudit(
     action: AuditActionType.update,
     entityType: AuditEntityType.policy,
     entityId: policyId,
     entityName: policy.name,
     userId: currentUser.id,
     userEmail: currentUser.email,
     tenantId: currentTenantId,
     changes: {
       'name': {'old': oldName, 'new': newName},
       'priority': {'old': oldPriority, 'new': newPriority},
     },
   );
   ```

**Возврат:** Обновлённая политика

**Исключения:**
- `SecurityException('Permission denied')` - нет прав
- `SecurityException('Policy not found')` - политика не найдена
- `SecurityException('Policy name already exists')` - имя занято

---

### 5. deletePolicy

```dart
Future<void> deletePolicy(String policyId);
```

**Что нужно от backend:**

1. **Валидация:**
   - Политика существует
   - Политика принадлежит текущему тенанту

2. **Бизнес-логика:**
   - Удалить политику из БД (hard delete или soft delete через `isActive = false`)

3. **Права доступа:**
   - Требуется permission: `policies:delete`
   - Или роль: `admin`

4. **Аудит:**
   ```dart
   await audit.logAudit(
     action: AuditActionType.delete,
     entityType: AuditEntityType.policy,
     entityId: policyId,
     entityName: policy.name,
     userId: currentUser.id,
     userEmail: currentUser.email,
     tenantId: currentTenantId,
   );
   ```

**Возврат:** void

**Исключения:**
- `SecurityException('Permission denied')` - нет прав
- `SecurityException('Policy not found')` - политика не найдена

---

### 6. evaluatePolicy (КРИТИЧНО!)

```dart
Future<PolicyEvaluationResult> evaluatePolicy(PolicyContext context);
```

**Это самый важный метод!** Он оценивает все политики и принимает решение: разрешить или запретить доступ.

#### PolicyContext

```dart
final class PolicyContext {
  final String userId;
  final String resource;
  final String action;
  final String? ipAddress;
  final DateTime timestamp;
  final Map<String, dynamic> userAttributes;
  final Map<String, dynamic> resourceAttributes;
  final List<String> userRoles;
  final List<String> userScopes;
}
```

#### PolicyEvaluationResult

```dart
final class PolicyEvaluationResult {
  final bool allowed;
  final String? reason;
  final List<String> matchedPolicies;
  final int evaluationTimeMs;
}
```

**Что нужно от backend:**

### Алгоритм оценки политик (КРИТИЧНО!)

```
1. Получить все активные политики для тенанта (отсортированные по priority DESC)

2. Для каждой политики:
   a. Оценить все conditions в каждом statement
   b. Применить logic (and/or/not) к результатам conditions
   c. Если statement совпал → запомнить effect (allow/deny)

3. Применить правило приоритета:
   - Если есть хотя бы один DENY → DENY (deny wins)
   - Если есть хотя бы один ALLOW и нет DENY → ALLOW
   - Если нет совпадений → DENY (default deny)

4. Вернуть результат с причиной и списком сработавших политик
```

### Оценка условий (PolicyCondition)

**timeRange:**
```dart
// value: {"start": "09:00", "end": "18:00"}
final now = context.timestamp;
final hour = now.hour;
final minute = now.minute;
final currentTime = hour * 60 + minute;

final start = parseTime(value['start']); // 09:00 → 540
final end = parseTime(value['end']);     // 18:00 → 1080

if (operator == PolicyOperator.equals) {
  return currentTime >= start && currentTime <= end;
}
```

**ipAddress:**
```dart
// value: "192.168.1.0/24" или ["192.168.1.1", "10.0.0.1"]
if (operator == PolicyOperator.equals) {
  return context.ipAddress == value;
}
if (operator == PolicyOperator.inList) {
  return (value as List).contains(context.ipAddress);
}
if (operator == PolicyOperator.matches) {
  // CIDR match: 192.168.1.0/24
  return ipInCidr(context.ipAddress, value);
}
```

**userAttribute:**
```dart
// field: "department", value: "engineering", operator: equals
final userValue = context.userAttributes[field];
if (operator == PolicyOperator.equals) {
  return userValue == value;
}
if (operator == PolicyOperator.contains) {
  return userValue.toString().contains(value);
}
```

**resourceAttribute:**
```dart
// field: "ownerId", value: context.userId, operator: equals
final resourceValue = context.resourceAttributes[field];
if (operator == PolicyOperator.equals) {
  return resourceValue == value;
}
```

**role:**
```dart
// value: "admin" или ["admin", "moderator"]
if (operator == PolicyOperator.equals) {
  return context.userRoles.contains(value);
}
if (operator == PolicyOperator.inList) {
  return context.userRoles.any((r) => (value as List).contains(r));
}
```

**scope:**
```dart
// value: "projects:write"
if (operator == PolicyOperator.equals) {
  return context.userScopes.contains(value);
}
```

### Применение logic

```dart
// PolicyLogic.and
bool evaluateAnd(List<PolicyCondition> conditions) {
  return conditions.every((c) => evaluateCondition(c, context));
}

// PolicyLogic.or
bool evaluateOr(List<PolicyCondition> conditions) {
  return conditions.any((c) => evaluateCondition(c, context));
}

// PolicyLogic.not
bool evaluateNot(List<PolicyCondition> conditions) {
  return !conditions.every((c) => evaluateCondition(c, context));
}
```

### Пример полной оценки

```dart
Future<PolicyEvaluationResult> evaluatePolicy(PolicyContext context) async {
  final startTime = DateTime.now();
  final policies = await getPolicies(); // Только активные
  
  bool hasAllow = false;
  bool hasDeny = false;
  final matchedPolicies = <String>[];
  String? reason;
  
  for (final policy in policies) {
    for (final statement in policy.statements) {
      bool statementMatches = false;
      
      // Оценить условия с учётом logic
      switch (statement.logic) {
        case PolicyLogic.and:
          statementMatches = statement.conditions.every(
            (c) => evaluateCondition(c, context)
          );
          break;
        case PolicyLogic.or:
          statementMatches = statement.conditions.any(
            (c) => evaluateCondition(c, context)
          );
          break;
        case PolicyLogic.not:
          statementMatches = !statement.conditions.every(
            (c) => evaluateCondition(c, context)
          );
          break;
      }
      
      if (statementMatches) {
        matchedPolicies.add(policy.id);
        
        if (statement.effect == PolicyEffect.deny) {
          hasDeny = true;
          reason = 'Denied by policy: ${policy.name}';
          break; // Deny wins, можно прекратить
        } else {
          hasAllow = true;
          reason = 'Allowed by policy: ${policy.name}';
        }
      }
    }
    
    if (hasDeny) break; // Deny wins
  }
  
  final allowed = !hasDeny && hasAllow;
  final evaluationTime = DateTime.now().difference(startTime).inMilliseconds;
  
  return PolicyEvaluationResult(
    allowed: allowed,
    reason: reason ?? 'No matching policies (default deny)',
    matchedPolicies: matchedPolicies,
    evaluationTimeMs: evaluationTime,
  );
}
```

**Возврат:** Результат оценки

**Исключения:** Нет (всегда возвращает результат)

---

### 7. testPolicy

```dart
Future<PolicyEvaluationResult> testPolicy({
  required String userId,
  required String resource,
  required String action,
  Map<String, dynamic>? additionalContext,
});
```

**Что нужно от backend:**

1. **Назначение:**
   - Тестовый метод для проверки политик
   - Используется в UI для отладки политик

2. **Бизнес-логика:**
   - Загрузить данные пользователя
   - Построить PolicyContext
   - Вызвать evaluatePolicy()

3. **Права доступа:**
   - Требуется permission: `policies:test`
   - Или роль: `admin`

**Возврат:** Результат оценки

**Исключения:**
- `SecurityException('Permission denied')` - нет прав
- `SecurityException('User not found')` - пользователь не найден

---

## Примеры политик

### Пример 1: Доступ только в рабочее время

```json
{
  "name": "Working Hours Only",
  "statements": [
    {
      "effect": "allow",
      "logic": "and",
      "conditions": [
        {
          "type": "time_range",
          "operator": "equals",
          "value": {"start": "09:00", "end": "18:00"}
        }
      ]
    }
  ]
}
```

### Пример 2: Владелец может редактировать

```json
{
  "name": "Owner Can Edit",
  "statements": [
    {
      "effect": "allow",
      "logic": "and",
      "conditions": [
        {
          "type": "resource_attribute",
          "field": "ownerId",
          "operator": "equals",
          "value": "${userId}"
        },
        {
          "type": "user_attribute",
          "field": "emailVerified",
          "operator": "equals",
          "value": true
        }
      ]
    }
  ]
}
```

### Пример 3: Запрет доступа из определённых IP

```json
{
  "name": "Block Suspicious IPs",
  "priority": 100,
  "statements": [
    {
      "effect": "deny",
      "logic": "or",
      "conditions": [
        {
          "type": "ip_address",
          "operator": "in_list",
          "value": ["192.168.1.100", "10.0.0.50"]
        }
      ]
    }
  ]
}
```

---

## Требования к производительности

1. **evaluatePolicy** - КРИТИЧНО! Должен выполняться < 100ms
   - Это вызывается на КАЖДОМ запросе к защищённым ресурсам
   - Оптимизация: кэшировать политики в памяти
   - Оптимизация: прекращать оценку при первом DENY

2. **getPolicies** - должен выполняться < 50ms (с кэшем < 5ms)

3. **createPolicy/updatePolicy** - должны выполняться < 200ms

## Кэширование

```dart
// Кэш политик в памяти (обновляется каждые 5 минут)
final policiesCache = <String, List<AqPolicy>>{};

Future<List<AqPolicy>> getPolicies() async {
  final cacheKey = 'policies:$currentTenantId';
  
  if (policiesCache.containsKey(cacheKey)) {
    final cached = policiesCache[cacheKey]!;
    if (cached.timestamp.difference(DateTime.now()).inMinutes < 5) {
      return cached.policies;
    }
  }
  
  final policies = await db.query(...);
  policiesCache[cacheKey] = CachedPolicies(policies, DateTime.now());
  return policies;
}
```

## Индексы БД

```sql
CREATE INDEX idx_rbac_policies_tenant ON rbac_policies(tenantId);
CREATE INDEX idx_rbac_policies_active ON rbac_policies(isActive);
CREATE INDEX idx_rbac_policies_priority ON rbac_policies(priority DESC);
```
