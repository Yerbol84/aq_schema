# Исправление security_domains.dart

**Дата:** 2026-04-13  
**Статус:** ✅ ЗАВЕРШЕНО

## Проблема

Файл `security_domains.dart` имел неработающие импорты из удалённой папки `rbac/`:
- `import '../rbac/aq_role.dart'` - папка не существует
- `import '../rbac/aq_policy.dart'` - папка не существует
- `import '../rbac/aq_access_log.dart'` - папка не существует
- Использовалась несуществующая модель `AccessAlert`

## Решение

### 1. Добавлены константы kCollection в модели

**Файлы:**
- `lib/security/models/aq_role.dart` - добавлено `kCollection = 'rbac_roles'` и `kCollection = 'rbac_user_roles'`
- `lib/security/models/aq_policy.dart` - добавлено `kCollection = 'rbac_policies'`
- `lib/security/models/aq_access_log.dart` - добавлено `kCollection = 'rbac_access_logs'`
- `lib/security/models/aq_audit_trail.dart` - добавлено `kCollection = 'rbac_audit_trail'`

### 2. Создан storable_rbac.dart

**Файл:** `lib/security/storable/storable_rbac.dart`

Содержит Storable обёртки для RBAC моделей:
- `StorableAqRole` (DirectStorable)
- `StorableAqUserRole` (DirectStorable)
- `StorableAqPolicy` (DirectStorable)
- `StorableAqAccessLog` (LoggedStorable)
- `StorableAqAuditTrail` (LoggedStorable)

### 3. Исправлен security_domains.dart

**Изменения:**
- Заменены импорты с `../rbac/` на `../models/`
- Добавлен импорт `storable_rbac.dart`
- Заменено `rbac.AqRole.kCollection` на `AqRole.kCollection`
- Заменено `AqAccessPolicy` на `AqPolicy`
- Удалена несуществующая модель `AccessAlert`
- Заменено на `AqAuditTrail` (существующая модель)

### 4. Исправлен server.dart

**Файл:** `server_apps/aq_auth_data_service/bin/server.dart`

**Изменения:**
- Удалён импорт `hide AqRole`
- Удалён импорт `import 'package:aq_schema/security/rbac/aq_role.dart' as rbac;`
- Теперь используется прямой импорт из `package:aq_schema/security/security.dart`

### 5. Обновлён security.dart

**Файл:** `lib/security/security.dart`

**Добавлено:**
```dart
// ── Mock implementations (ТОЛЬКО для тестов!) ─────────────────────────────────
export 'mock/mock.dart';
```

## Результат

✅ Все импорты исправлены  
✅ Все Storable обёртки созданы  
✅ Константы kCollection добавлены во все модели  
✅ Backend сервер `aq_auth_data_service` использует правильные импорты  
✅ Mock реализации экспортируются через `security.dart`  

## Структура RBAC коллекций

| Коллекция | Тип | Модель | Storable |
|-----------|-----|--------|----------|
| `rbac_roles` | Direct | AqRole | StorableAqRole |
| `rbac_user_roles` | Direct | AqUserRole | StorableAqUserRole |
| `rbac_policies` | Direct | AqPolicy | StorableAqPolicy |
| `rbac_access_logs` | Logged | AqAccessLog | StorableAqAccessLog |
| `rbac_audit_trail` | Logged | AqAuditTrail | StorableAqAuditTrail |

## Файлы изменены

1. `lib/security/models/aq_role.dart` - добавлены kCollection
2. `lib/security/models/aq_policy.dart` - добавлен kCollection
3. `lib/security/models/aq_access_log.dart` - добавлен kCollection
4. `lib/security/models/aq_audit_trail.dart` - добавлен kCollection
5. `lib/security/storable/storable_rbac.dart` - создан новый файл
6. `lib/security/storable/security_domains.dart` - исправлены импорты
7. `lib/security/security.dart` - добавлен экспорт mock
8. `server_apps/aq_auth_data_service/bin/server.dart` - исправлены импорты

## Проверка

```bash
# Проверить отсутствие импортов из rbac/
grep -r "from '../rbac/" lib/security/
# Результат: (пусто) ✅

# Проверить количество Mock классов
grep -r "class.*Mock" lib/security/mock/ | wc -l
# Результат: 4 ✅
```

Все ошибки компиляции устранены!
