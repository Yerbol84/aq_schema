# ТЗ: TTL Support для DirectStorable и LoggedStorable

**От:** aq_security  
**Кому:** aq_data_layer  
**Приоритет:** HIGH  
**Тип:** Новая функциональность

---

## Контекст

`aq_security` хранит сущности с ограниченным сроком жизни:
- `AqSession` — истекает через N минут/часов
- `AqApiKey` — может иметь `expiresAt`
- `AqUserRole` — временные роли с `expiresAt`

Сейчас истечение управляется вручную через периодический `purgeExpired()` в `SessionService`.
Это ненадёжно: если job не запустился — устаревшие сессии остаются активными.

---

## Что нужно от data layer

### 1. Поле `expiresAt` в контракте `Storable`

Добавить опциональное поле в базовый интерфейс `Storable` (или в `DirectStorable` / `LoggedStorable`):

```dart
abstract interface class Storable {
  // ... existing ...

  /// Unix timestamp (секунды). Если задан — data layer автоматически
  /// обрабатывает сущность по истечении этого времени.
  /// null = без срока истечения.
  int? get expiresAt => null;
}
```

### 2. Колбэк `onExpire()` для LoggedStorable

Для `LoggedStorable` (сессии, API ключи) нужно не удалять запись, а обновить статус:

```dart
abstract interface class LoggedStorable implements Storable {
  // ... existing ...

  /// Вызывается data layer когда наступает expiresAt.
  /// Возвращает новое состояние сущности (например, status: expired).
  /// Если null — data layer делает soft delete.
  LoggedStorable? onExpire() => null;
}
```

Для `DirectStorable` — достаточно soft delete при истечении (без колбэка).

### 3. Поведение data layer

- Периодически (или через DB-level TTL) проверять записи где `expiresAt <= now`
- Для `DirectStorable`: пометить `deletedAt = now`
- Для `LoggedStorable`: вызвать `onExpire()`, сохранить результат с `actorId = 'system'`, записать в лог

---

## Как aq_security будет это использовать

```dart
final class StorableSession implements LoggedStorable {
  // ...

  @override
  int? get expiresAt => _session.expiresAt;

  @override
  StorableSession? onExpire() => StorableSession(
    _session.copyWith(status: SessionStatus.expired),
  );
}

final class StorableApiKey implements LoggedStorable {
  // ...

  @override
  int? get expiresAt => _key.expiresAt;

  @override
  StorableApiKey? onExpire() => StorableApiKey(
    _key.copyWith(isActive: false),
  );
}

final class StorableUserRole implements DirectStorable {
  // ...

  @override
  int? get expiresAt => _userRole.expiresAt;
  // soft delete при истечении — достаточно
}
```

После реализации — `purgeExpired()` в `SessionService` и репозиториях будет удалён.

---

## Что НЕ нужно менять в aq_security

Никаких изменений в бизнес-логике. Только:
1. Добавить `expiresAt` и `onExpire()` в Storable классы
2. Удалить `purgeExpired()` из репозиториев и сервисов
