# Сценарий использования TD-4: TTL Support

**От:** aq_security

---

## Как будет использоваться

### Сценарий 1: Сессия автоматически истекает

```dart
// StorableSession объявляет expiresAt
final class StorableSession implements LoggedStorable {
  @override
  int? get expiresAt => _session.expiresAt;

  @override
  LoggedStorable? onExpire() => StorableSession(
    _session.copyWith(status: SessionStatus.expired),
  );
}

// Сохраняем сессию — data layer сам обновит статус когда наступит expiresAt
await sessionRepo.save(StorableSession(session), actorId: 'system');

// Через N секунд — data layer вызвал onExpire() и сохранил новое состояние
final loaded = await sessionRepo.findById(session.id);
assert(loaded?.domain.status == SessionStatus.expired);
```

### Сценарий 2: API Key автоматически деактивируется

```dart
final class StorableApiKey implements LoggedStorable {
  @override
  int? get expiresAt => _key.expiresAt;

  @override
  LoggedStorable? onExpire() => StorableApiKey(
    _key.copyWith(isActive: false),
  );
}
```

### Сценарий 3: Временная роль удаляется

```dart
final class StorableUserRole implements DirectStorable {
  @override
  int? get expiresAt => _userRole.expiresAt;
  // onExpire не нужен — soft delete достаточно
}
```

## После реализации

Удаляем из aq_security:
- `purgeExpired()` из `VaultSessionRepository`
- `purgeExpired()` из `VaultApiKeyRepository`
- `startPurgeTimer()` из `SessionService`
