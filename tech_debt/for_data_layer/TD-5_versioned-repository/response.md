# Ответ на TD-5: VersionedRepository API для ролей и политик

**Статус:** done  
**Версия aq_schema:** текущая  
**Версия aq_data_layer:** текущая

---

## Ответы на вопросы

**1. Поддерживает ли `VersionedRepository` все методы из сценариев 1-4?**

✅ Да, с уточнением по именованию:

| Метод в запросе | Реальный метод | Статус |
|---|---|---|
| `createEntity(model)` | `createEntity(model)` | ✅ |
| `publishDraft(nodeId, increment: IncrementType.major)` | `publishDraft(nodeId, increment: IncrementType.major)` | ✅ |
| `getCurrent(entityId)` | `getCurrent(entityId)` | ✅ |
| `createDraftFrom(nodeId, model)` | `createDraftFrom(nodeId, model)` | ✅ |
| `getVersionHistory(entityId)` | **`listVersions(entityId)`** | ✅ другое имя |
| `getEntityData(nodeId)` | **`getVersion(nodeId)`** | ✅ другое имя |

**2. `getCurrent(entityId)` возвращает последнюю опубликованную версию?**

✅ Да. Возвращает данные ноды с `isCurrent: true`. Флаг устанавливается при `publishDraft` и может быть переключён через `setCurrentVersion`.

**3. `createDraftFrom(nodeId, data)` копирует метаданные старой версии?**

✅ Да. Новый draft наследует `entityId` и `branch` от родительской ноды. `parentNodeId` сохраняется для трассировки истории.

**4. `publishDraft(nodeId, increment)` автоматически вычисляет новый semver?**

✅ Да. Находит последнюю опубликованную версию через `getLatestPublished`, применяет `IncrementType` (major/minor/patch).

**5. Миграция `DirectStorable → VersionedStorable`?**

Миграция не нужна. `AqRole` и `AqAccessPolicy` — новые данные без существующих записей. Достаточно изменить модель:
```dart
// Было:
class StorableRole implements DirectStorable { ... }

// Стало:
class StorableRole implements VersionedStorable { ... }
```

---

## Как использовать

### UC-1: Создать роль (v1.0.0)
```dart
final node = await roleRepo.createEntity(StorableRole(role));
await roleRepo.publishDraft(node.nodeId, increment: IncrementType.major);
```

### UC-2: Обновить права роли (v1.1.0)
```dart
final current = await roleRepo.getCurrent(roleId);
final draft = await roleRepo.createDraftFrom(current!.id, StorableRole(updatedRole));
await roleRepo.publishDraft(draft.nodeId, increment: IncrementType.minor);
```

### UC-3: Rollback роли
```dart
// getVersionHistory → listVersions
final history = await roleRepo.listVersions(roleId);
final v1Node = history.firstWhere((n) => n.version?.toString() == 'v1.0.0');

// getEntityData → getVersion
final v1Data = await roleRepo.getVersion(v1Node.nodeId);
final draft = await roleRepo.createDraftFrom(v1Node.nodeId, v1Data!);
await roleRepo.publishDraft(draft.nodeId, increment: IncrementType.patch);
```

### UC-4: Текущая версия для AccessControlEngine
```dart
final role = await roleRepo.getCurrent(roleId); // AqRole напрямую
```

---

## Моки для тестов

`InMemoryVersionedRepository` теперь доступен в `aq_schema`:

```dart
import 'package:aq_schema/data_testing.dart';

MockDataLayer.register(MockDataBackend.withData(
  collection: StorableRole.kCollection,
  entities: [StorableRole(adminRole)],
));

final roleRepo = IDataLayer.instance.versioned<StorableRole>(
  collection: StorableRole.kCollection,
  fromMap: StorableRole.fromMap,
);
// Работает без dart_vault и PostgreSQL
```

---

## Ограничения

- `VersionNode.nodeId` — идентификатор ноды (не `node.id`). Используй `node.nodeId` в `publishDraft`, `createDraftFrom`.
- `getCurrent` возвращает `T?` — может быть null если нет опубликованных версий.
