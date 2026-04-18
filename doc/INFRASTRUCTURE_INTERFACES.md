# Infrastructure Interfaces для dart_vault

**Дата:** 2026-04-10
**Статус:** Интерфейсы созданы, ожидают реализации в dart_vault

---

## 📋 Созданные интерфейсы

### 1. ISecretsManager
**Файл:** `pkgs/aq_schema/lib/data_layer/infrastructure/secrets_manager.dart`

**Назначение:** Управление секретами (JWT secrets, DB credentials, API keys)

**Методы:**
- `getSecret(key)` — получить secret
- `setSecret(key, value, metadata)` — сохранить secret
- `deleteSecret(key)` — удалить secret
- `rotateSecret(key, newValue)` — rotate secret
- `getSecretVersion(key, version)` — получить конкретную версию
- `listSecrets()` — список всех secrets
- `secretExists(key)` — проверка существования

**Singleton pattern:**
```dart
// Инициализация (в dart_vault)
ISecretsManager.initialize(VaultSecretsManagerImpl());

// Использование (в любом пакете)
final secret = await ISecretsManager.instance.getSecret('JWT_SECRET');
```

**Mock реализация:** `MockSecretsManager` (для тестов)

### 2. IBackupService
**Файл:** `pkgs/aq_schema/lib/data_layer/infrastructure/backup_service.dart`

**Назначение:** Backup и восстановление данных

**Методы:**
- `createBackup(collections, description, tags)` — создать backup
- `restoreBackup(backupId, collections, overwrite)` — восстановить
- `listBackups(tags, limit)` — список backups
- `getBackupMetadata(backupId)` — metadata backup
- `deleteBackup(backupId)` — удалить backup
- `applyRetentionPolicy(policy)` — применить retention policy
- `verifyBackup(backupId)` — проверить integrity
- `exportBackup(backupId, path)` — экспорт в файл
- `importBackup(path, description)` — импорт из файла

**Singleton pattern:**
```dart
// Инициализация (в dart_vault)
IBackupService.initialize(VaultBackupServiceImpl());

// Использование
final result = await IBackupService.instance.createBackup(
  collections: ['users', 'projects'],
  description: 'Daily backup',
);
```

**Mock реализация:** `MockBackupService` (для тестов)

### 3. IDatabaseHardening
**Файл:** `pkgs/aq_schema/lib/data_layer/infrastructure/database_hardening.dart`

**Назначение:** Database optimization и hardening

**Методы:**
- `getConnectionPoolStats()` — статистика connection pool
- `configureConnectionPool(min, max, timeout)` — настройка pool
- `listIndexes(table)` — список индексов
- `createIndex(name, table, columns, unique)` — создать индекс
- `dropIndex(name)` — удалить индекс
- `optimizeIndexes()` — оптимизация (VACUUM, ANALYZE)
- `getQueryPerformanceStats(limit, minDuration)` — статистика запросов
- `healthCheck()` — health check БД
- `getDatabaseSize()` — размер БД
- `verifyForeignKeys()` — проверка FK
- `verifyConstraints()` — проверка constraints

**Singleton pattern:**
```dart
// Инициализация (в dart_vault)
IDatabaseHardening.initialize(PostgresHardeningImpl());

// Использование
final stats = await IDatabaseHardening.instance.getConnectionPoolStats();
print('Active connections: ${stats.activeConnections}');
```

**Mock реализация:** `MockDatabaseHardening` (для тестов)

---

## 🎯 Использование в aq_security

Теперь aq_security может использовать эти интерфейсы:

```dart
// В aq_security
import 'package:aq_schema/data.dart';

// Использование secrets для JWT
final jwtSecret = await ISecretsManager.instance.getSecret('JWT_SECRET');

// Backup security данных
await IBackupService.instance.createBackup(
  collections: ['users', 'sessions', 'api_keys'],
  tags: ['security', 'daily'],
);

// Мониторинг БД
final health = await IDatabaseHardening.instance.healthCheck();
if (!health.healthy) {
  // Alert!
}
```

---

## 📦 Задача для dart_vault

**dart_vault должен:**

1. Реализовать три интерфейса:
   - `VaultSecretsManager implements ISecretsManager`
   - `VaultBackupService implements IBackupService`
   - `PostgresHardening implements IDatabaseHardening`

2. При инициализации зарегистрировать singleton:
   ```dart
   // В dart_vault при старте
   void initializeInfrastructure() {
     ISecretsManager.initialize(VaultSecretsManager());
     IBackupService.initialize(VaultBackupService());
     IDatabaseHardening.initialize(PostgresHardening());
   }
   ```

3. Реализации могут использовать:
   - HashiCorp Vault для secrets
   - AWS Secrets Manager для secrets
   - PostgreSQL pg_dump для backups
   - PgBouncer для connection pooling
   - PostgreSQL VACUUM/ANALYZE для optimization

---

## ✅ Преимущества архитектуры

1. **Разделение ответственности:**
   - aq_schema определяет контракты
   - dart_vault реализует
   - aq_security использует через интерфейсы

2. **Тестируемость:**
   - Mock реализации для unit тестов
   - Реальные реализации для integration тестов

3. **Гибкость:**
   - Можно заменить реализацию без изменения потребителей
   - Можно использовать разные backends (Vault, AWS, etc.)

4. **Singleton pattern:**
   - Единая точка доступа
   - Инициализация при старте приложения
   - Нет необходимости передавать зависимости

---

## 🚀 Следующие шаги

1. ✅ Интерфейсы созданы в aq_schema
2. ✅ Mock реализации для тестов
3. ✅ Экспорт через data.dart
4. ⏭️ dart_vault должен реализовать интерфейсы
5. ⏭️ aq_security использует через ISecretsManager.instance

---

**Статус:** Интерфейсы готовы, ожидают реализации в dart_vault! 🎉
