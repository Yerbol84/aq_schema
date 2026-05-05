# ТЗ: Подтверждение VersionedRepository API для ролей и политик

**От:** aq_security  
**Кому:** aq_data_layer  
**Приоритет:** MEDIUM  
**Тип:** Подтверждение существующего API

---

## Контекст

`aq_security` хранит роли (`AqRole`) и политики (`AqAccessPolicy`) как `DirectStorable`.
При изменении роли/политики старая версия перезаписывается — нет истории, нет rollback.

Для compliance и безопасности нужно версионирование:
- История изменений прав
- Rollback роли после инцидента
- Аудит: кто, когда, что изменил

В `aq_schema` уже есть `VersionedRepository` и `VersionedStorable`. Нужно подтвердить что API покрывает наши use cases.

---

## Use Cases

### UC-1: Создать роль

```dart
// Создать draft
final node = await roleRepo.createEntity(StorableRole(role));

// Опубликовать как v1.0.0
await roleRepo.publishDraft(node.id, increment: IncrementType.major);
```

### UC-2: Обновить права роли

```dart
// Получить текущую версию
final current = await roleRepo.getCurrent(roleId);

// Создать draft с изменениями
final draft = await roleRepo.createDraftFrom(
  current.id,
  StorableRole(updatedRole),
);

// Опубликовать как v1.1.0
await roleRepo.publishDraft(draft.id, increment: IncrementType.minor);
```

### UC-3: Rollback роли

```dart
// Получить старую версию
final oldNode = await roleRepo.getVersionHistory(roleId).then(
  (history) => history.firstWhere((n) => n.version == 'v1.0.0'),
);

// Создать draft из старой версии
final draft = await roleRepo.createDraftFrom(
  oldNode.id,
  await roleRepo.getEntityData(oldNode.id),
);

// Опубликовать как v1.1.1 (patch)
await roleRepo.publishDraft(draft.id, increment: IncrementType.patch);
```

### UC-4: Получить текущую роль для проверки прав

```dart
// AccessControlEngine должен получать CURRENT версию
final current = await roleRepo.getCurrent(roleId);
final roleData = await roleRepo.getEntityData(current.id);
final role = roleData.domain;
```

---

## Вопросы к data layer

1. ✅ / ❌ `VersionedRepository` поддерживает все методы из UC-1..4?
2. ✅ / ❌ `getCurrent(entityId)` возвращает последнюю опубликованную версию?
3. ✅ / ❌ `createDraftFrom(nodeId, data)` копирует метаданные старой версии?
4. ✅ / ❌ `publishDraft(nodeId, increment)` автоматически вычисляет новый semver?
5. 📋 Есть ли миграционный путь `DirectStorable → VersionedStorable` для существующих данных?

---

## Что НЕ нужно менять в aq_security

Если API подтверждён — просто используем `VersionedRepository` вместо `DirectRepository`.

Изменения только в:
- `StorableRole` / `StorablePolicy`: `implements DirectStorable` → `implements VersionedStorable`
- `VaultRoleRepository` / `VaultPolicyRepository`: `DirectRepository<T>` → `VersionedRepository<T>`
- Добавить методы `createRoleDraft`, `publishRoleDraft`, `rollbackRole` в репозитории

Если что-то не работает — это вопрос к data layer, не к aq_security.
