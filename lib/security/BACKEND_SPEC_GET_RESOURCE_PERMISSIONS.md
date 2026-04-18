# getResourcePermissions - Документация для Backend

**Дата:** 2026-04-13  
**Метод:** `ISecurityService.getResourcePermissions`

## Назначение

Определить список разрешённых действий (permissions) для конкретного ресурса, учитывая как RBAC (роли), так и PBAC (политики с контекстом).

## Сигнатура

```dart
Future<List<String>> getResourcePermissions(
  String resourceId, {
  List<String>? actions,
});
```

## Параметры

### resourceId (обязательный)
Идентификатор ресурса в формате `"type/id"`

**Примеры:**
- `"project/123"` - проект с ID 123
- `"workflow/456"` - workflow с ID 456
- `"user/789"` - пользователь с ID 789
- `"blueprint/abc"` - blueprint с ID abc

### actions (опциональный)
Список действий для проверки

**По умолчанию:** `['read', 'write', 'delete', 'admin']`

**Примеры кастомных списков:**
- `['execute', 'publish', 'share']` - для workflows
- `['view', 'edit', 'manage']` - для проектов
- `['read', 'update']` - минимальный набор

## Возвращаемое значение

Список разрешённых permissions в формате `"resource_type:action"`

**Примеры:**
- `["project:read", "project:write"]` - может читать и писать
- `["workflow:execute", "workflow:publish"]` - может выполнять и публиковать
- `[]` - нет прав (пустой список)

## Алгоритм реализации

### Шаг 1: Проверка авторизации

```dart
final user = currentUser;
if (user == null) return [];
```

### Шаг 2: Извлечение типа ресурса

```dart
final resourceType = resourceId.split('/').first;
// "project/123" -> "project"
// "workflow/456" -> "workflow"
```

### Шаг 3: Определение действий для проверки

```dart
final checkActions = actions ?? ['read', 'write', 'delete', 'admin'];
```

### Шаг 4: Проверка каждого действия

```dart
final allowed = <String>[];

for (final action in checkActions) {
  final permission = '$resourceType:$action';
  
  // 4.1. RBAC проверка (быстрая)
  final hasRbacPermission = await hasPermission(permission);
  if (!hasRbacPermission) {
    continue; // Нет права в ролях -> skip
  }
  
  // 4.2. PBAC проверка (с контекстом)
  final context = PolicyContext(
    userId: user.id,
    resource: resourceId,
    action: action,
    ipAddress: currentIpAddress,
    timestamp: DateTime.now(),
    userAttributes: {
      'email': user.email,
      'userType': user.userType.value,
    },
    resourceAttributes: await _getResourceAttributes(resourceId),
    userRoles: (await roleManagement.getUserRoles(user.id))
        .map((r) => r.name)
        .toList(),
    userScopes: currentClaims?.scopes ?? [],
  );
  
  final policyResult = await policies.evaluatePolicy(context);
  if (policyResult.allowed) {
    allowed.add(permission);
  }
}

return allowed;
```

### Вспомогательный метод: _getResourceAttributes

```dart
Future<Map<String, dynamic>> _getResourceAttributes(String resourceId) async {
  final parts = resourceId.split('/');
  final type = parts[0];
  final id = parts.length > 1 ? parts[1] : null;
  
  if (id == null) return {};
  
  switch (type) {
    case 'project':
      final project = await projectRepository.get(id);
      return {
        'ownerId': project.ownerId,
        'visibility': project.visibility,
        'status': project.status,
      };
      
    case 'workflow':
      final workflow = await workflowRepository.get(id);
      return {
        'ownerId': workflow.ownerId,
        'projectId': workflow.projectId,
        'status': workflow.status,
      };
      
    case 'blueprint':
      final blueprint = await blueprintRepository.get(id);
      return {
        'ownerId': blueprint.ownerId,
        'isPublic': blueprint.isPublic,
      };
      
    default:
      return {};
  }
}
```

## Почему такая реализация?

### 1. Производительность

**Оптимизация:**
- Сначала проверяем RBAC (быстро, по кэшу ролей)
- Только если есть право в роли → проверяем политики
- Избегаем лишних вызовов `evaluatePolicy`

**Пример:**
```
Пользователь проверяет права на project/123
Действия: [read, write, delete, admin]

1. read: RBAC ✅ -> PBAC ✅ -> allowed
2. write: RBAC ✅ -> PBAC ✅ -> allowed
3. delete: RBAC ❌ -> skip PBAC -> denied
4. admin: RBAC ❌ -> skip PBAC -> denied

Результат: ["project:read", "project:write"]
Сэкономлено: 2 вызова evaluatePolicy
```

### 2. Безопасность

**Принцип "deny wins":**
- Политики могут ограничить доступ даже при наличии роли
- Учитывается контекст: время, IP, атрибуты ресурса
- Пример: "Можно редактировать только свои проекты"

**Пример политики:**
```json
{
  "name": "Owner Can Edit",
  "statements": [{
    "effect": "allow",
    "logic": "and",
    "conditions": [
      {
        "type": "resource_attribute",
        "field": "ownerId",
        "operator": "equals",
        "value": "${userId}"
      }
    ]
  }]
}
```

### 3. Чистая архитектура

**Инкапсуляция:**
- UI вызывает один метод, не зная о RBAC/PBAC
- Backend инкапсулирует логику проверки
- Легко добавить новые механизмы (ABAC, etc.)

**До:**
```dart
// UI должен знать о RBAC и PBAC
final roles = await service.roleManagement.getUserRoles(userId);
final hasRole = roles.any((r) => r.permissions.contains('project:write'));
if (hasRole) {
  final context = PolicyContext(...);
  final result = await service.policies.evaluatePolicy(context);
  if (result.allowed) {
    // Показать кнопку "Редактировать"
  }
}
```

**После:**
```dart
// UI просто спрашивает: "Что можно делать?"
final permissions = await service.getResourcePermissions('project/123');
if (permissions.contains('project:write')) {
  // Показать кнопку "Редактировать"
}
```

### 4. Аудит

**Логирование (опционально):**
```dart
if (policyResult.allowed) {
  allowed.add(permission);
  
  // Логировать проверку для compliance
  await audit.logAccess(
    userId: user.id,
    userEmail: user.email,
    tenantId: currentTenant!.id,
    resource: resourceId,
    action: action,
    allowed: true,
    reason: 'Permission check via getResourcePermissions',
  );
}
```

## Кэширование

### Рекомендация

Кэшировать результат на **30-60 секунд**:

```dart
Future<List<String>> getResourcePermissions(
  String resourceId, {
  List<String>? actions,
}) async {
  final user = currentUser;
  if (user == null) return [];
  
  // Ключ кэша
  final cacheKey = 'resource_permissions:${user.id}:$resourceId';
  
  // Проверить кэш
  final cached = await cache.get<List<String>>(cacheKey);
  if (cached != null) return cached;
  
  // Вычислить
  final result = await _computePermissions(resourceId, actions);
  
  // Сохранить в кэш
  await cache.set(cacheKey, result, ttl: Duration(seconds: 30));
  
  return result;
}
```

### Инвалидация кэша

Кэш нужно инвалидировать при:
- Изменении ролей пользователя
- Изменении политик
- Изменении атрибутов ресурса (например, смена владельца)

```dart
// При назначении роли
await roleManagement.assignRole(userId: userId, roleId: roleId);
await cache.delete('resource_permissions:$userId:*'); // Wildcard delete

// При изменении ресурса
await projectRepository.update(projectId, ownerId: newOwnerId);
await cache.delete('resource_permissions:*:project/$projectId'); // Wildcard delete
```

## Требования к производительности

| Сценарий | Требование | Почему |
|----------|-----------|--------|
| **Без кэша** | < 200ms | UI не должен тормозить |
| **С кэшем** | < 10ms | Мгновенный отклик |
| **Параллельные запросы** | 100+ RPS | Много пользователей одновременно |

## Использование в UI

### Provider

```dart
final resourcePermissionsProvider = FutureProvider.family<List<String>, String>(
  (ref, resourceId) async {
    final service = ref.watch(securityServiceProvider);
    return await service.getResourcePermissions(resourceId);
  },
);
```

### Виджет

```dart
class ProjectActionsWidget extends ConsumerWidget {
  final String projectId;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissions = ref.watch(
      resourcePermissionsProvider('project/$projectId')
    );
    
    return permissions.when(
      data: (perms) {
        return Row(
          children: [
            if (perms.contains('project:read'))
              IconButton(
                icon: Icon(Icons.visibility),
                onPressed: () => _viewProject(),
              ),
            if (perms.contains('project:write'))
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () => _editProject(),
              ),
            if (perms.contains('project:delete'))
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => _deleteProject(),
              ),
          ],
        );
      },
      loading: () => CircularProgressIndicator(),
      error: (e, s) => Text('Error: $e'),
    );
  }
}
```

## Примеры использования

### Пример 1: Проверка прав на проект

```dart
final permissions = await service.getResourcePermissions('project/123');

// Результат: ["project:read", "project:write"]

if (permissions.contains('project:read')) {
  print('Можно читать проект');
}

if (permissions.contains('project:write')) {
  print('Можно редактировать проект');
}

if (permissions.contains('project:delete')) {
  print('Можно удалить проект');
} else {
  print('Нельзя удалить проект');
}
```

### Пример 2: Кастомные действия

```dart
final permissions = await service.getResourcePermissions(
  'workflow/456',
  actions: ['execute', 'publish', 'share'],
);

// Результат: ["workflow:execute", "workflow:publish"]

if (permissions.contains('workflow:execute')) {
  // Показать кнопку "Запустить"
}

if (permissions.contains('workflow:publish')) {
  // Показать кнопку "Опубликовать"
}

if (!permissions.contains('workflow:share')) {
  // Скрыть кнопку "Поделиться"
}
```

### Пример 3: Динамическое меню

```dart
final permissions = await service.getResourcePermissions('blueprint/abc');

final menuItems = <MenuItem>[];

if (permissions.contains('blueprint:read')) {
  menuItems.add(MenuItem(icon: Icons.visibility, label: 'Просмотр'));
}

if (permissions.contains('blueprint:write')) {
  menuItems.add(MenuItem(icon: Icons.edit, label: 'Редактировать'));
}

if (permissions.contains('blueprint:delete')) {
  menuItems.add(MenuItem(icon: Icons.delete, label: 'Удалить'));
}

return PopupMenuButton(items: menuItems);
```

## Тестирование

### Unit тест

```dart
test('getResourcePermissions returns allowed permissions', () async {
  // Arrange
  final service = MockSecurityService();
  
  // Act
  final permissions = await service.getResourcePermissions('project/123');
  
  // Assert
  expect(permissions, contains('project:read'));
  expect(permissions, contains('project:write'));
  expect(permissions, isNot(contains('project:delete')));
});
```

### Integration тест

```dart
test('getResourcePermissions respects policies', () async {
  // Arrange: Пользователь имеет роль с project:write
  // Но политика разрешает редактировать только свои проекты
  
  final service = AQSecurityService(...);
  await service.loginWithEmail(email: 'user@example.com', password: 'pass');
  
  // Act: Проверить права на чужой проект
  final permissions = await service.getResourcePermissions('project/999');
  
  // Assert: Нет права на редактирование (политика запретила)
  expect(permissions, contains('project:read'));
  expect(permissions, isNot(contains('project:write')));
});
```

## Исключения

Метод **НЕ выбрасывает исключения**. Всегда возвращает список (может быть пустым).

**Причины:**
- Отсутствие прав - это нормальная ситуация, а не ошибка
- UI должен корректно обрабатывать пустой список
- Упрощает использование в виджетах

## Мониторинг

### Метрики

```
# Количество вызовов
security_resource_permissions_total{resource_type="project"} 1500

# Время выполнения
security_resource_permissions_duration_ms{cached="true"} 5
security_resource_permissions_duration_ms{cached="false"} 150

# Cache hit rate
security_resource_permissions_cache_hit_rate 0.85
```

### Алерты

```yaml
# Медленные запросы
- alert: SlowResourcePermissionCheck
  expr: security_resource_permissions_duration_ms{cached="false"} > 500
  for: 5m
  annotations:
    summary: "Проверка прав на ресурс выполняется медленно"

# Низкий cache hit rate
- alert: LowCacheHitRate
  expr: security_resource_permissions_cache_hit_rate < 0.7
  for: 10m
  annotations:
    summary: "Низкий процент попаданий в кэш прав на ресурсы"
```

---

**Документация готова для передачи в backend!**
