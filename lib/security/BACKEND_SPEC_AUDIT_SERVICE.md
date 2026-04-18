# IAuditService - Аудит и логирование

**Файл:** `lib/security/interfaces/i_audit_service.dart`

## Назначение

Подсервис для аудита и логирования всех действий в системе безопасности:
- Логирование попыток доступа (успешных и неуспешных)
- Аудит изменений (создание, изменение, удаление сущностей)
- Получение логов с фильтрацией
- Статистика по доступу
- Очистка старых логов

## Модели

### AqAccessLog

```dart
final class AqAccessLog {
  final String id;
  final String userId;
  final String userEmail;
  final String tenantId;
  final String resource;        // "projects/123", "users/456"
  final String action;          // "read", "write", "delete"
  final bool allowed;           // true = разрешено, false = запрещено
  final int timestamp;          // Unix timestamp (seconds)
  final String? reason;         // Причина (особенно важна для denied)
  final String? ipAddress;
  final String? userAgent;
  final Map<String, dynamic>? metadata;
}
```

### AqAuditTrail

```dart
final class AqAuditTrail {
  final String id;
  final AuditActionType action;      // create, update, delete, assign, revoke
  final AuditEntityType entityType;  // role, policy, user, etc.
  final String entityId;
  final String entityName;           // Для удобства отображения
  final String userId;
  final String userEmail;
  final String tenantId;
  final int timestamp;
  final Map<String, dynamic>? changes;  // {"old": {...}, "new": {...}}
  final String? reason;
  final String? ipAddress;
  final Map<String, dynamic>? metadata;
}
```

### Enums

```dart
enum AuditActionType {
  create,
  update,
  delete,
  assign,
  revoke,
}

enum AuditEntityType {
  role,
  permission,
  policy,
  user,
  apiKey,
  session,
}
```

---

## Методы

### 1. logAccess

```dart
Future<void> logAccess({
  required String userId,
  required String userEmail,
  required String tenantId,
  required String resource,
  required String action,
  required bool allowed,
  String? reason,
  String? ipAddress,
  String? userAgent,
  Map<String, dynamic>? metadata,
});
```

**Что нужно от backend:**

1. **Назначение:**
   - Логировать КАЖДУЮ попытку доступа к защищённым ресурсам
   - Вызывается после проверки прав (RBAC + PBAC)

2. **Бизнес-логика:**
   - Генерировать уникальный ID
   - Установить `timestamp = now`
   - Сохранить в БД асинхронно (не блокировать основной поток)

3. **Асинхронность (КРИТИЧНО!):**
   ```dart
   // НЕ БЛОКИРОВАТЬ основной запрос!
   Future<void> logAccess(...) async {
     // Добавить в очередь
     _logQueue.add(AqAccessLog(...));
     
     // Не ждать сохранения в БД
     return;
   }
   
   // Фоновый worker сохраняет батчами
   void _flushLogQueue() async {
     while (true) {
       await Future.delayed(Duration(seconds: 5));
       
       if (_logQueue.isEmpty) continue;
       
       final batch = _logQueue.take(1000).toList();
       _logQueue.removeRange(0, batch.length);
       
       await db.batchInsert('rbac_access_logs', batch);
     }
   }
   ```

4. **Производительность:**
   - Метод должен выполняться < 5ms (только добавление в очередь)
   - Сохранение в БД батчами по 100-1000 записей каждые 5-10 секунд
   - При shutdown приложения → сохранить все оставшиеся логи

**Возврат:** void (не ждём сохранения)

**Исключения:** Нет (логирование не должно ломать основной flow)

---

### 2. logAudit

```dart
Future<void> logAudit({
  required AuditActionType action,
  required AuditEntityType entityType,
  required String entityId,
  required String entityName,
  required String userId,
  required String userEmail,
  required String tenantId,
  Map<String, dynamic>? changes,
  String? reason,
  String? ipAddress,
  Map<String, dynamic>? metadata,
});
```

**Что нужно от backend:**

1. **Назначение:**
   - Логировать изменения в системе безопасности
   - Вызывается при создании/изменении/удалении ролей, политик, назначений

2. **Бизнес-логика:**
   - Генерировать уникальный ID
   - Установить `timestamp = now`
   - Сохранить в БД асинхронно (аналогично logAccess)

3. **Формат changes:**
   ```json
   {
     "name": {"old": "User", "new": "Admin"},
     "permissions": {
       "old": ["read"],
       "new": ["read", "write"]
     }
   }
   ```

4. **Примеры использования:**
   ```dart
   // При создании роли
   await audit.logAudit(
     action: AuditActionType.create,
     entityType: AuditEntityType.role,
     entityId: role.id,
     entityName: role.name,
     userId: currentUser.id,
     userEmail: currentUser.email,
     tenantId: currentTenantId,
     changes: {'permissions': role.permissions},
   );
   
   // При назначении роли
   await audit.logAudit(
     action: AuditActionType.assign,
     entityType: AuditEntityType.role,
     entityId: roleId,
     entityName: role.name,
     userId: currentUser.id,
     userEmail: currentUser.email,
     tenantId: currentTenantId,
     metadata: {'targetUserId': targetUserId},
   );
   ```

**Возврат:** void

**Исключения:** Нет

---

### 3. getAccessLogs

```dart
Future<List<AqAccessLog>> getAccessLogs(AccessLogFilter filter);
```

#### AccessLogFilter

```dart
final class AccessLogFilter {
  final String? userId;
  final String? tenantId;
  final String? resource;
  final String? action;
  final bool? allowed;
  final int? startTime;
  final int? endTime;
  final int limit;
  final int offset;
}
```

**Что нужно от backend:**

1. **Запрос:**
   - Получить логи с фильтрацией
   - Сортировать по timestamp DESC (новые сначала)
   - Применить pagination (limit + offset)

2. **SQL пример:**
   ```sql
   SELECT * FROM rbac_access_logs
   WHERE 1=1
     AND ($userId IS NULL OR userId = $userId)
     AND ($tenantId IS NULL OR tenantId = $tenantId)
     AND ($resource IS NULL OR resource LIKE '%' || $resource || '%')
     AND ($action IS NULL OR action = $action)
     AND ($allowed IS NULL OR allowed = $allowed)
     AND ($startTime IS NULL OR timestamp >= $startTime)
     AND ($endTime IS NULL OR timestamp <= $endTime)
   ORDER BY timestamp DESC
   LIMIT $limit OFFSET $offset
   ```

3. **Права доступа:**
   - Требуется permission: `audit:read`
   - Или роль: `admin`
   - Обычные пользователи могут видеть только свои логи

4. **Производительность:**
   - Должен выполняться < 200ms
   - Использовать индексы по userId, tenantId, timestamp

**Возврат:** Список логов

**Исключения:**
- `SecurityException('Permission denied')` - нет прав

---

### 4. getAuditTrail

```dart
Future<List<AqAuditTrail>> getAuditTrail(AuditTrailFilter filter);
```

#### AuditTrailFilter

```dart
final class AuditTrailFilter {
  final String? userId;
  final String? tenantId;
  final AuditActionType? action;
  final AuditEntityType? entityType;
  final String? entityId;
  final int? startTime;
  final int? endTime;
  final String? searchQuery;
  final int limit;
  final int offset;
}
```

**Что нужно от backend:**

1. **Запрос:**
   - Получить аудит-трейл с фильтрацией
   - Сортировать по timestamp DESC
   - Применить pagination
   - Поддержать поиск по `searchQuery` (entityName, userEmail, reason)

2. **SQL пример:**
   ```sql
   SELECT * FROM rbac_audit_trail
   WHERE 1=1
     AND ($userId IS NULL OR userId = $userId)
     AND ($tenantId IS NULL OR tenantId = $tenantId)
     AND ($action IS NULL OR action = $action)
     AND ($entityType IS NULL OR entityType = $entityType)
     AND ($entityId IS NULL OR entityId = $entityId)
     AND ($startTime IS NULL OR timestamp >= $startTime)
     AND ($endTime IS NULL OR timestamp <= $endTime)
     AND ($searchQuery IS NULL OR 
          entityName ILIKE '%' || $searchQuery || '%' OR
          userEmail ILIKE '%' || $searchQuery || '%' OR
          reason ILIKE '%' || $searchQuery || '%')
   ORDER BY timestamp DESC
   LIMIT $limit OFFSET $offset
   ```

3. **Права доступа:**
   - Требуется permission: `audit:read`
   - Или роль: `admin`

**Возврат:** Список записей аудита

**Исключения:**
- `SecurityException('Permission denied')` - нет прав

---

### 5. getAccessLogStats

```dart
Future<Map<String, dynamic>> getAccessLogStats({
  String? tenantId,
  required int startTime,
  required int endTime,
});
```

**Что нужно от backend:**

1. **Назначение:**
   - Получить статистику по логам доступа за период
   - Используется для дашбордов и отчётов

2. **Возвращаемая структура:**
   ```json
   {
     "total": 1500,
     "allowed": 1350,
     "denied": 150,
     "byResource": {
       "projects": 800,
       "users": 400,
       "settings": 300
     },
     "byAction": {
       "read": 1000,
       "write": 400,
       "delete": 100
     },
     "topUsers": [
       {"userId": "user1", "email": "user1@example.com", "count": 500},
       {"userId": "user2", "email": "user2@example.com", "count": 300}
     ],
     "deniedReasons": {
       "No permission": 80,
       "Policy denied": 50,
       "Session expired": 20
     }
   }
   ```

3. **SQL пример:**
   ```sql
   -- Total и allowed/denied
   SELECT 
     COUNT(*) as total,
     SUM(CASE WHEN allowed THEN 1 ELSE 0 END) as allowed,
     SUM(CASE WHEN NOT allowed THEN 1 ELSE 0 END) as denied
   FROM rbac_access_logs
   WHERE timestamp BETWEEN $startTime AND $endTime
     AND ($tenantId IS NULL OR tenantId = $tenantId);
   
   -- By resource
   SELECT 
     SPLIT_PART(resource, '/', 1) as resource_type,
     COUNT(*) as count
   FROM rbac_access_logs
   WHERE timestamp BETWEEN $startTime AND $endTime
     AND ($tenantId IS NULL OR tenantId = $tenantId)
   GROUP BY resource_type
   ORDER BY count DESC
   LIMIT 10;
   
   -- Top users
   SELECT userId, userEmail, COUNT(*) as count
   FROM rbac_access_logs
   WHERE timestamp BETWEEN $startTime AND $endTime
     AND ($tenantId IS NULL OR tenantId = $tenantId)
   GROUP BY userId, userEmail
   ORDER BY count DESC
   LIMIT 10;
   ```

4. **Права доступа:**
   - Требуется permission: `audit:stats`
   - Или роль: `admin`

**Возврат:** Статистика в виде Map

**Исключения:**
- `SecurityException('Permission denied')` - нет прав

---

### 6. getAuditTrailStats

```dart
Future<Map<String, dynamic>> getAuditTrailStats({
  String? tenantId,
  required int startTime,
  required int endTime,
});
```

**Что нужно от backend:**

1. **Возвращаемая структура:**
   ```json
   {
     "total": 500,
     "byAction": {
       "create": 200,
       "update": 150,
       "delete": 50,
       "assign": 80,
       "revoke": 20
     },
     "byEntityType": {
       "role": 150,
       "policy": 100,
       "user": 200,
       "apiKey": 50
     },
     "topUsers": [
       {"userId": "admin1", "email": "admin@example.com", "count": 300},
       {"userId": "admin2", "email": "admin2@example.com", "count": 200}
     ]
   }
   ```

2. **Права доступа:**
   - Требуется permission: `audit:stats`
   - Или роль: `admin`

**Возврат:** Статистика в виде Map

**Исключения:**
- `SecurityException('Permission denied')` - нет прав

---

### 7. cleanupAccessLogs

```dart
Future<int> cleanupAccessLogs({required int olderThan});
```

**Что нужно от backend:**

1. **Назначение:**
   - Удалить старые логи доступа
   - Вызывается по расписанию (cron job)

2. **Бизнес-логика:**
   - Удалить все логи с `timestamp < olderThan`
   - Выполнять батчами по 10000 записей (чтобы не блокировать БД)

3. **SQL пример:**
   ```sql
   DELETE FROM rbac_access_logs
   WHERE timestamp < $olderThan
   LIMIT 10000;
   ```

4. **Retention policy (рекомендация):**
   - Access logs: хранить 90 дней
   - Denied access logs: хранить 180 дней (важны для безопасности)
   - Запускать cleanup каждую ночь

5. **Права доступа:**
   - Требуется permission: `audit:cleanup`
   - Или роль: `admin`

**Возврат:** Количество удалённых записей

**Исключения:**
- `SecurityException('Permission denied')` - нет прав

---

### 8. cleanupAuditTrail

```dart
Future<int> cleanupAuditTrail({required int olderThan});
```

**Что нужно от backend:**

1. **Назначение:**
   - Удалить старые записи аудита
   - Вызывается по расписанию

2. **Retention policy (рекомендация):**
   - Audit trail: хранить 365 дней (1 год)
   - Критичные действия (delete, revoke): хранить 730 дней (2 года)

3. **SQL пример:**
   ```sql
   -- Удалить некритичные записи старше 1 года
   DELETE FROM rbac_audit_trail
   WHERE timestamp < $olderThan
     AND action NOT IN ('delete', 'revoke')
   LIMIT 10000;
   
   -- Удалить критичные записи старше 2 лет
   DELETE FROM rbac_audit_trail
   WHERE timestamp < $olderThanCritical
     AND action IN ('delete', 'revoke')
   LIMIT 10000;
   ```

**Возврат:** Количество удалённых записей

**Исключения:**
- `SecurityException('Permission denied')` - нет прав

---

## Требования к производительности

### КРИТИЧНО!

1. **logAccess** - должен выполняться < 5ms
   - Вызывается на КАЖДОМ запросе
   - НЕ блокировать основной поток
   - Использовать очередь + батчинг

2. **logAudit** - должен выполняться < 10ms
   - Вызывается при каждом изменении
   - Использовать очередь + батчинг

3. **getAccessLogs** - должен выполняться < 200ms
   - Использовать индексы
   - Ограничить limit (max 1000)

4. **getAuditTrail** - должен выполняться < 200ms
   - Использовать индексы
   - Ограничить limit (max 1000)

5. **getAccessLogStats** - должен выполняться < 500ms
   - Можно кэшировать на 5-10 минут
   - Использовать агрегированные таблицы для больших объёмов

---

## Архитектура логирования

### Очередь логов (КРИТИЧНО!)

```dart
class AuditService implements IAuditService {
  final _accessLogQueue = Queue<AqAccessLog>();
  final _auditTrailQueue = Queue<AqAuditTrail>();
  
  Timer? _flushTimer;
  
  AuditService() {
    // Запустить фоновый worker
    _flushTimer = Timer.periodic(Duration(seconds: 5), (_) {
      _flushQueues();
    });
  }
  
  @override
  Future<void> logAccess(...) async {
    _accessLogQueue.add(AqAccessLog(...));
    
    // Если очередь большая → сбросить немедленно
    if (_accessLogQueue.length > 1000) {
      unawaited(_flushQueues());
    }
  }
  
  Future<void> _flushQueues() async {
    if (_accessLogQueue.isEmpty && _auditTrailQueue.isEmpty) return;
    
    try {
      // Сохранить access logs батчем
      if (_accessLogQueue.isNotEmpty) {
        final batch = _accessLogQueue.take(1000).toList();
        await db.batchInsert('rbac_access_logs', batch);
        _accessLogQueue.removeRange(0, batch.length);
      }
      
      // Сохранить audit trail батчем
      if (_auditTrailQueue.isNotEmpty) {
        final batch = _auditTrailQueue.take(1000).toList();
        await db.batchInsert('rbac_audit_trail', batch);
        _auditTrailQueue.removeRange(0, batch.length);
      }
    } catch (e) {
      // Логировать ошибку, но не терять данные
      print('Failed to flush audit logs: $e');
    }
  }
  
  Future<void> dispose() async {
    _flushTimer?.cancel();
    await _flushQueues(); // Сохранить оставшиеся логи
  }
}
```

---

## Индексы БД (КРИТИЧНО!)

```sql
-- Access logs
CREATE INDEX idx_rbac_logs_user ON rbac_access_logs(userId);
CREATE INDEX idx_rbac_logs_tenant ON rbac_access_logs(tenantId);
CREATE INDEX idx_rbac_logs_resource ON rbac_access_logs(resource);
CREATE INDEX idx_rbac_logs_timestamp ON rbac_access_logs(timestamp DESC);
CREATE INDEX idx_rbac_logs_allowed ON rbac_access_logs(allowed);

-- Composite index для частых запросов
CREATE INDEX idx_rbac_logs_user_time ON rbac_access_logs(userId, timestamp DESC);
CREATE INDEX idx_rbac_logs_tenant_time ON rbac_access_logs(tenantId, timestamp DESC);

-- Audit trail
CREATE INDEX idx_rbac_audit_user ON rbac_audit_trail(userId);
CREATE INDEX idx_rbac_audit_tenant ON rbac_audit_trail(tenantId);
CREATE INDEX idx_rbac_audit_entity ON rbac_audit_trail(entityId);
CREATE INDEX idx_rbac_audit_timestamp ON rbac_audit_trail(timestamp DESC);
CREATE INDEX idx_rbac_audit_action ON rbac_audit_trail(action);

-- Composite index
CREATE INDEX idx_rbac_audit_tenant_time ON rbac_audit_trail(tenantId, timestamp DESC);
```

---

## Партиционирование (для больших объёмов)

Если логов > 10 миллионов записей, рекомендуется партиционирование по времени:

```sql
-- Партиционирование по месяцам
CREATE TABLE rbac_access_logs (
  id TEXT PRIMARY KEY,
  timestamp INTEGER NOT NULL,
  ...
) PARTITION BY RANGE (timestamp);

CREATE TABLE rbac_access_logs_2026_04 PARTITION OF rbac_access_logs
  FOR VALUES FROM (1711929600) TO (1714521600);

CREATE TABLE rbac_access_logs_2026_05 PARTITION OF rbac_access_logs
  FOR VALUES FROM (1714521600) TO (1717200000);
```

---

## Мониторинг

Backend должен экспортировать метрики:

```
# Размер очереди логов
audit_queue_size{type="access_log"} 150
audit_queue_size{type="audit_trail"} 20

# Скорость логирования (записей/сек)
audit_log_rate{type="access_log"} 50
audit_log_rate{type="audit_trail"} 5

# Время сохранения батча
audit_flush_duration_ms{type="access_log"} 120
audit_flush_duration_ms{type="audit_trail"} 80

# Количество записей в БД
audit_total_records{type="access_log"} 5000000
audit_total_records{type="audit_trail"} 500000
```
