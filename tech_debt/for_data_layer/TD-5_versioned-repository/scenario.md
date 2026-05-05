# Сценарий использования TD-5: VersionedRepository для ролей

**От:** aq_security

---

## Как будет использоваться

### Сценарий 1: Создать роль (v1.0.0)

```dart
final node = await roleRepo.createEntity(StorableRole(role));
await roleRepo.publishDraft(node.id, increment: IncrementType.major);
```

### Сценарий 2: Обновить права роли (v1.1.0)

```dart
final current = await roleRepo.getCurrent(roleId);
final draft = await roleRepo.createDraftFrom(current.id, StorableRole(updatedRole));
await roleRepo.publishDraft(draft.id, increment: IncrementType.minor);
```

### Сценарий 3: Rollback роли к предыдущей версии

```dart
final history = await roleRepo.getVersionHistory(roleId);
final v1 = history.firstWhere((n) => n.version == 'v1.0.0');
final draft = await roleRepo.createDraftFrom(v1.id, await roleRepo.getEntityData(v1.id));
await roleRepo.publishDraft(draft.id, increment: IncrementType.patch);
```

### Сценарий 4: AccessControlEngine получает текущую версию

```dart
// В _collectPermissionsRecursive:
final current = await roleRepo.getCurrent(roleId);
final roleData = await roleRepo.getEntityData(current.id);
final role = roleData.domain; // AqRole с актуальными permissions
```

## Вопросы к data layer (ответить в response.md)

1. Поддерживает ли `VersionedRepository` все методы из сценариев 1-4?
2. Как мигрировать существующие `DirectStorable` записи на `VersionedStorable`?
3. Есть ли `InMemoryVersionedRepository` для тестов в `aq_schema/data_layer/mock/`?
