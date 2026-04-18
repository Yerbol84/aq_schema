# IRoleManagementService - Управление ролями

**Файл:** `lib/security/interfaces/i_role_management_service.dart`

## Назначение

Подсервис для управления RBAC (Role-Based Access Control):
- Создание, изменение, удаление ролей
- Назначение ролей пользователям
- Проверка прав доступа
- Управление permissions

## Модели

### AqRole

```dart
final class AqRole {
  final String id;
  final String name;              // Уникальное имя роли
  final String? description;
  final String? tenantId;         // null = platform-level role
  final List<String> permissions; // ['projects:read', 'agents:run']
  final bool isSystem;            // Системные роли нельзя удалить
  final int? createdAt;
}
```

**Важно:**
- `tenantId = null` → роль видна во всех тенантах (platform-level)
- `tenantId = 'xxx'` → роль видна только в этом тенанте
- `isSystem = true` → роль нельзя удалить (admin, user, guest)

### AqUserRole

```dart
final class AqUserRole {
  final String userId;
  final String roleId;
  final String tenantId;
  final String? grantedBy;  // ID пользователя, который назначил роль
  final int grantedAt;
  final int? expiresAt;     // null = бессрочно
}
```

---

## Методы

### 1. getRoles

```dart
Future<List<AqRole>> getRoles({bool includeInactive = false});
```

**Что нужно от backend:**

1. **Запрос:**
   - Получить все роли для текущего тенанта
   - Включить platform-level роли (`tenantId = null`)
   - Если `includeInactive = false` → фильтровать только активные

2. **SQL пример:**
   ```sql
   SELECT * FROM rbac_roles 
   WHERE (tenantId = $currentTenantId OR tenantId IS NULL)
   AND (isActive = true OR $includeInactive = true)
   ORDER BY name ASC
   ```

3. **Кэширование:**
   - Роли меняются редко → можно кэшировать на 5-10 минут
   - Инвалидировать кэш при создании/изменении/удалении роли

**Возврат:** Список ролей, отсортированный по имени

**Исключения:** Нет (пустой список если ролей нет)

---

### 2. getRole

```dart
Future<AqRole?> getRole(String roleId);
```

**Что нужно от backend:**

1. **Запрос:**
   - Найти роль по ID
   - Проверить доступ: роль должна быть либо platform-level, либо принадлежать текущему тенанту

2. **Проверка доступа:**
   ```dart
   if (role.tenantId != null && role.tenantId != currentTenantId) {
     return null; // Нет доступа к роли другого тенанта
   }
   ```

**Возврат:** 
- `AqRole` если найдена и есть доступ
- `null` если не найдена или нет доступа

**Исключения:** Нет

---

### 3. createRole

```dart
Future<AqRole> createRole({
  required String name,
  String? description,
  required List<String> permissions,
  bool isActive = true,
});
```

**Что нужно от backend:**

1. **Валидация:**
   - `name` не пустой, 3-50 символов
   - `name` уникален в рамках тенанта
   - `permissions` не пустой список
   - Каждый permission валиден (формат: `resource:action` или `*`)

2. **Бизнес-логика:**
   - Генерировать уникальный ID
   - Установить `tenantId = currentTenantId`
   - Установить `isSystem = false` (только backend может создавать системные роли)
   - Установить `createdAt = now`

3. **Права доступа:**
   - Требуется permission: `roles:create`
   - Или роль: `admin`

4. **Аудит:**
   ```dart
   await audit.logAudit(
     action: AuditActionType.create,
     entityType: AuditEntityType.role,
     entityId: role.id,
     entityName: role.name,
     userId: currentUser.id,
     userEmail: currentUser.email,
     tenantId: currentTenantId,
     changes: {'permissions': permissions},
   );
   ```

**Возврат:** Созданная роль

**Исключения:**
- `SecurityException('Permission denied')` - нет прав
- `SecurityException('Role name already exists')` - имя занято
- `SecurityException('Invalid permission format')` - неверный формат permission

---

### 4. updateRole

```dart
Future<AqRole> updateRole({
  required String roleId,
  String? name,
  String? description,
  List<String>? permissions,
  bool? isActive,
});
```

**Что нужно от backend:**

1. **Валидация:**
   - Роль существует
   - Роль принадлежит текущему тенанту (или platform-level)
   - Если `isSystem = true` → нельзя изменить `name` и `permissions`
   - Если `name` меняется → проверить уникальность

2. **Бизнес-логика:**
   - Обновить только переданные поля (partial update)
   - Сохранить старые значения для аудита

3. **Права доступа:**
   - Требуется permission: `roles:update`
   - Или роль: `admin`

4. **Аудит:**
   ```dart
   await audit.logAudit(
     action: AuditActionType.update,
     entityType: AuditEntityType.role,
     entityId: roleId,
     entityName: role.name,
     userId: currentUser.id,
     userEmail: currentUser.email,
     tenantId: currentTenantId,
     changes: {
       'name': {'old': oldName, 'new': newName},
       'permissions': {'old': oldPerms, 'new': newPerms},
     },
   );
   ```

**Возврат:** Обновлённая роль

**Исключения:**
- `SecurityException('Permission denied')` - нет прав
- `SecurityException('Role not found')` - роль не найдена
- `SecurityException('Cannot modify system role')` - попытка изменить системную роль
- `SecurityException('Role name already exists')` - имя занято

---

### 5. deleteRole

```dart
Future<void> deleteRole(String roleId);
```

**Что нужно от backend:**

1. **Валидация:**
   - Роль существует
   - Роль принадлежит текущему тенанту
   - `isSystem = false` (системные роли нельзя удалить)
   - Роль не назначена пользователям (проверить `rbac_user_roles`)

2. **Бизнес-логика:**
   - Если роль назначена пользователям → выбросить исключение
   - Удалить роль из БД (hard delete или soft delete через `isActive = false`)

3. **Права доступа:**
   - Требуется permission: `roles:delete`
   - Или роль: `admin`

4. **Аудит:**
   ```dart
   await audit.logAudit(
     action: AuditActionType.delete,
     entityType: AuditEntityType.role,
     entityId: roleId,
     entityName: role.name,
     userId: currentUser.id,
     userEmail: currentUser.email,
     tenantId: currentTenantId,
   );
   ```

**Возврат:** void

**Исключения:**
- `SecurityException('Permission denied')` - нет прав
- `SecurityException('Role not found')` - роль не найдена
- `SecurityException('Cannot delete system role')` - попытка удалить системную роль
- `SecurityException('Role is assigned to users')` - роль используется

---

### 6. assignRole

```dart
Future<void> assignRole({
  required String userId,
  required String roleId,
  int? expiresAt,
});
```

**Что нужно от backend:**

1. **Валидация:**
   - Пользователь существует
   - Роль существует
   - Роль доступна в текущем тенанте
   - Роль ещё не назначена этому пользователю

2. **Бизнес-логика:**
   - Создать запись в `rbac_user_roles`:
     ```dart
     AqUserRole(
       userId: userId,
       roleId: roleId,
       tenantId: currentTenantId,
       grantedBy: currentUser.id,
       grantedAt: now,
       expiresAt: expiresAt,
     )
     ```
   - Если роль уже назначена → обновить `expiresAt` и `grantedBy`

3. **Права доступа:**
   - Требуется permission: `roles:assign`
   - Или роль: `admin`

4. **Аудит:**
   ```dart
   await audit.logAudit(
     action: AuditActionType.assign,
     entityType: AuditEntityType.role,
     entityId: roleId,
     entityName: role.name,
     userId: currentUser.id,
     userEmail: currentUser.email,
     tenantId: currentTenantId,
     metadata: {
       'targetUserId': userId,
       'expiresAt': expiresAt,
     },
   );
   ```

**Возврат:** void

**Исключения:**
- `SecurityException('Permission denied')` - нет прав
- `SecurityException('User not found')` - пользователь не найден
- `SecurityException('Role not found')` - роль не найдена

---

### 7. revokeRole

```dart
Future<void> revokeRole({
  required String userId,
  required String roleId,
});
```

**Что нужно от backend:**

1. **Валидация:**
   - Назначение существует
   - Назначение в текущем тенанте

2. **Бизнес-логика:**
   - Удалить запись из `rbac_user_roles`
   - WHERE userId = $userId AND roleId = $roleId AND tenantId = $currentTenantId

3. **Права доступа:**
   - Требуется permission: `roles:revoke`
   - Или роль: `admin`

4. **Аудит:**
   ```dart
   await audit.logAudit(
     action: AuditActionType.revoke,
     entityType: AuditEntityType.role,
     entityId: roleId,
     entityName: role.name,
     userId: currentUser.id,
     userEmail: currentUser.email,
     tenantId: currentTenantId,
     metadata: {'targetUserId': userId},
   );
   ```

**Возврат:** void

**Исключения:**
- `SecurityException('Permission denied')` - нет прав
- `SecurityException('Assignment not found')` - назначение не найдено

---

### 8. getUserRoles

```dart
Future<List<AqRole>> getUserRoles(String userId);
```

**Что нужно от backend:**

1. **Запрос:**
   - Получить все роли пользователя в текущем тенанте
   - Исключить истёкшие назначения (`expiresAt < now`)
   - JOIN с таблицей ролей для получения полной информации

2. **SQL пример:**
   ```sql
   SELECT r.* FROM rbac_roles r
   JOIN rbac_user_roles ur ON r.id = ur.roleId
   WHERE ur.userId = $userId 
   AND ur.tenantId = $currentTenantId
   AND (ur.expiresAt IS NULL OR ur.expiresAt > $now)
   ORDER BY r.name ASC
   ```

3. **Кэширование:**
   - Роли пользователя меняются редко → кэшировать на 1-5 минут
   - Ключ кэша: `user_roles:{userId}:{tenantId}`

**Возврат:** Список ролей пользователя

**Исключения:** Нет (пустой список если ролей нет)

---

### 9. getUsersByRole

```dart
Future<List<AqUser>> getUsersByRole(String roleId);
```

**Что нужно от backend:**

1. **Запрос:**
   - Получить всех пользователей с этой ролью в текущем тенанте
   - Исключить истёкшие назначения
   - JOIN с таблицей пользователей

2. **SQL пример:**
   ```sql
   SELECT u.* FROM security_users u
   JOIN rbac_user_roles ur ON u.id = ur.userId
   WHERE ur.roleId = $roleId 
   AND ur.tenantId = $currentTenantId
   AND (ur.expiresAt IS NULL OR ur.expiresAt > $now)
   ORDER BY u.email ASC
   ```

**Возврат:** Список пользователей

**Исключения:** Нет (пустой список если пользователей нет)

---

### 10. getAllPermissions

```dart
Future<List<String>> getAllPermissions();
```

**Что нужно от backend:**

1. **Запрос:**
   - Получить уникальный список всех permissions из всех ролей
   - Можно кэшировать агрессивно (меняется очень редко)

2. **SQL пример:**
   ```sql
   SELECT DISTINCT unnest(permissions) as permission
   FROM rbac_roles
   WHERE tenantId = $currentTenantId OR tenantId IS NULL
   ORDER BY permission ASC
   ```

3. **Формат permissions:**
   - `resource:action` - конкретное право (например: `projects:read`)
   - `resource:*` - все действия над ресурсом (например: `projects:*`)
   - `*` - все права (superadmin)

**Возврат:** Список всех permissions

**Исключения:** Нет

---

## Проверка прав (используется в ISecurityService)

Backend должен реализовать логику проверки прав:

```dart
Future<bool> hasPermission(String permission) async {
  final roles = await getUserRoles(currentUser.id);
  
  for (final role in roles) {
    // Проверка wildcard
    if (role.permissions.contains('*')) return true;
    
    // Точное совпадение
    if (role.permissions.contains(permission)) return true;
    
    // Wildcard по ресурсу: projects:* matches projects:read
    final parts = permission.split(':');
    if (parts.length == 2) {
      if (role.permissions.contains('${parts[0]}:*')) return true;
    }
  }
  
  return false;
}
```

---

## Требования к производительности

1. **getRoles** - должен выполняться < 50ms (с кэшем < 5ms)
2. **getUserRoles** - должен выполняться < 100ms (с кэшем < 10ms)
3. **hasPermission** - должен выполняться < 50ms (критично для каждого запроса)
4. **assignRole/revokeRole** - должны выполняться < 200ms

## Индексы БД (КРИТИЧНО!)

```sql
CREATE INDEX idx_rbac_roles_tenant ON rbac_roles(tenantId);
CREATE INDEX idx_rbac_roles_name ON rbac_roles(name);
CREATE INDEX idx_rbac_ur_user ON rbac_user_roles(userId);
CREATE INDEX idx_rbac_ur_role ON rbac_user_roles(roleId);
CREATE INDEX idx_rbac_ur_tenant ON rbac_user_roles(tenantId);
CREATE INDEX idx_rbac_ur_expires ON rbac_user_roles(expiresAt);
```
