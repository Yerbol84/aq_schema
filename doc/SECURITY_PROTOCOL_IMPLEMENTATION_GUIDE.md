# Security Protocol Implementation Guide

Руководство для разработчиков, реализующих `IVaultSecurityProtocol` в пакете `aq_security`.

## Обзор

`IVaultSecurityProtocol` — это интерфейс между data layer (dart_vault) и security service (aq_security).

**Ключевые принципы:**

1. **Dependency Inversion**: Data layer зависит от интерфейса, а не от реализации
2. **Декларативность**: Data layer спрашивает "Можно?", получает типобезопасный ответ
3. **Универсальность**: Protocol не знает о бизнес-доменах (проекты, графы, воркфлоу)
4. **Опциональность**: Если protocol не инициализирован, всё разрешено

## Архитектура

```
┌─────────────────────────────────────────────────────────────┐
│ dart_vault (Data Layer)                                     │
│ - PostgresVaultStorage                                      │
│ - SupabaseVaultStorage                                      │
│ - Не знает о JWT, ролях, политиках                         │
└────────────────┬────────────────────────────────────────────┘
                 │ depends on (interface)
                 ▼
┌─────────────────────────────────────────────────────────────┐
│ IVaultSecurityProtocol (aq_schema)                          │
│ - Интерфейс с методами canRead, canWrite, etc.             │
│ - Типобезопасные решения (sealed classes)                  │
│ - Singleton pattern                                         │
└────────────────┬────────────────────────────────────────────┘
                 │ implemented by
                 ▼
┌─────────────────────────────────────────────────────────────┐
│ AqVaultSecurityProtocol (aq_security)                       │
│ - Реализация protocol                                       │
│ - Использует ISecurityService                              │
│ - JWT validation, RBAC, ABAC, RLS                          │
└─────────────────────────────────────────────────────────────┘
```

## Что ожидает интерфейс

### 1. Извлечение контекста

```dart
Future<AqTokenClaims?> extractClaims(Map<String, String> headers);
```

**Задача:** Извлечь claims из HTTP headers (JWT, API key, session cookie).

**Ожидания:**
- Если токен валиден → вернуть `AqTokenClaims`
- Если токена нет → вернуть `null` (анонимный запрос)
- Если токен невалиден → вернуть `null` или выбросить исключение

**Пример реализации:**

```dart
@override
Future<AqTokenClaims?> extractClaims(Map<String, String> headers) async {
  // 1. Извлечь токен из headers
  final authHeader = headers['Authorization'] ?? headers['authorization'];
  if (authHeader == null) return null;

  final token = authHeader.startsWith('Bearer ')
      ? authHeader.substring(7)
      : authHeader;

  // 2. Валидировать JWT
  try {
    final jwt = JWT.verify(token, SecretKey(_jwtSecret));
    
    // 3. Извлечь claims
    return AqTokenClaims(
      sub: jwt.subject!,
      email: jwt.payload['email'] as String,
      tenantId: jwt.payload['tenant_id'] as String,
      roles: List<String>.from(jwt.payload['roles'] ?? []),
      scopes: List<String>.from(jwt.payload['scopes'] ?? []),
      iat: jwt.issuedAt!.millisecondsSinceEpoch ~/ 1000,
      exp: jwt.expiresAt!.millisecondsSinceEpoch ~/ 1000,
    );
  } catch (e) {
    // Токен невалиден
    return null;
  }
}
```

**Важно:**
- Кешируйте результат валидации JWT (по токену)
- TTL кеша = время до истечения токена
- Не валидируйте токен на каждый запрос

### 2. Проверка прав доступа

```dart
Future<AccessDecision> canRead({
  required AqTokenClaims? claims,
  required String collection,
  String? entityId,
});
```

**Задача:** Определить, может ли пользователь читать из коллекции.

**Возможные решения:**

1. **AccessAllowed** — пользователь может читать всё
2. **AccessDenied** — пользователь не может читать
3. **AccessRestricted** — пользователь может читать только указанные ID (RLS)

**Пример реализации:**

```dart
@override
Future<AccessDecision> canRead({
  required AqTokenClaims? claims,
  required String collection,
  String? entityId,
}) async {
  // 1. Анонимный доступ
  if (claims == null) {
    // Проверить, разрешён ли анонимный доступ к коллекции
    final policy = await _policyService.getCollectionPolicy(collection);
    if (policy.allowAnonymousRead) {
      return const AccessAllowed();
    }
    return const AccessDenied('Authentication required');
  }

  // 2. Админ может всё
  if (claims.roles.contains('admin')) {
    return const AccessAllowed();
  }

  // 3. Проверить scope
  if (!_hasScope(claims, collection, 'read')) {
    return const AccessDenied('No read permission for $collection');
  }

  // 4. Применить RLS (Row Level Security)
  if (entityId != null) {
    // Проверка конкретной сущности
    final hasAccess = await _rlsService.canAccessEntity(
      userId: claims.sub,
      tenantId: claims.tenantId,
      collection: collection,
      entityId: entityId,
    );
    
    return hasAccess
        ? const AccessAllowed()
        : const AccessDenied('No access to entity $entityId');
  }

  // 5. Получить список доступных ID для пользователя
  final allowedIds = await _rlsService.getAllowedIds(
    userId: claims.sub,
    tenantId: claims.tenantId,
    collection: collection,
  );

  if (allowedIds.isEmpty) {
    return const AccessDenied('No accessible entities');
  }

  // Если пользователь может читать все сущности в tenant
  if (allowedIds.contains('*')) {
    return const AccessAllowed();
  }

  // Ограниченный доступ
  return AccessRestricted(
    allowedIds: allowedIds,
    reason: 'User can only access own entities',
  );
}
```

**Важно:**
- Кешируйте RLS решения (по userId + collection)
- Инвалидируйте кеш при изменении прав
- Для списков используйте `AccessRestricted` с `allowedIds`

### 3. Проверка прав на запись

```dart
Future<AccessDecision> canWrite({
  required AqTokenClaims? claims,
  required String collection,
  String? entityId,
  required Map<String, dynamic> data,
});
```

**Задача:** Определить, может ли пользователь писать в коллекцию.

**Особенности:**
- `entityId == null` → создание новой сущности
- `entityId != null` → обновление существующей
- `data` → данные для записи (для валидации и ABAC)

**Пример реализации:**

```dart
@override
Future<AccessDecision> canWrite({
  required AqTokenClaims? claims,
  required String collection,
  String? entityId,
  required Map<String, dynamic> data,
}) async {
  // 1. Аутентификация обязательна для записи
  if (claims == null) {
    return const AccessDenied('Authentication required');
  }

  // 2. Проверить scope
  if (!_hasScope(claims, collection, 'write')) {
    return const AccessDenied('No write permission for $collection');
  }

  // 3. Создание новой сущности
  if (entityId == null) {
    // Проверить квоты
    final quota = await _quotaService.checkQuota(
      userId: claims.sub,
      tenantId: claims.tenantId,
      collection: collection,
    );
    
    if (!quota.allowed) {
      return AccessDenied('Quota exceeded: ${quota.reason}');
    }

    return const AccessAllowed();
  }

  // 4. Обновление существующей сущности
  final hasAccess = await _rlsService.canModifyEntity(
    userId: claims.sub,
    tenantId: claims.tenantId,
    collection: collection,
    entityId: entityId,
  );

  if (!hasAccess) {
    return const AccessDenied('No access to entity $entityId');
  }

  // 5. ABAC: проверить атрибуты данных
  final abacDecision = await _abacService.evaluate(
    claims: claims,
    action: 'write',
    resource: collection,
    data: data,
  );

  return abacDecision ? const AccessAllowed() : const AccessDenied('ABAC policy denied');
}
```

### 4. Rate Limiting

```dart
Future<RateLimitDecision> checkRateLimit({
  required AqTokenClaims? claims,
  required String operation,
  String? ip,
});
```

**Задача:** Проверить, не превышен ли лимит запросов.

**Пример реализации:**

```dart
@override
Future<RateLimitDecision> checkRateLimit({
  required AqTokenClaims? claims,
  required String operation,
  String? ip,
}) async {
  // 1. Определить ключ для rate limiting
  final key = claims != null
      ? 'user:${claims.sub}:$operation'
      : 'ip:$ip:$operation';

  // 2. Получить лимит для пользователя/IP
  final limit = await _rateLimitService.getLimit(
    userId: claims?.sub,
    operation: operation,
  );

  // 3. Проверить текущее количество запросов
  final current = await _rateLimitStore.increment(key);

  if (current > limit.max) {
    // Лимит превышен
    final resetAt = await _rateLimitStore.getResetTime(key);
    final retryAfter = resetAt.difference(DateTime.now()).inSeconds;

    return RateLimitExceeded(
      retryAfterSeconds: retryAfter,
      limit: limit.max,
    );
  }

  // Лимит не превышен
  return RateLimitOk(
    remaining: limit.max - current,
    limit: limit.max,
  );
}
```

**Важно:**
- Используйте Redis или in-memory store для счётчиков
- Реализуйте sliding window или token bucket
- Разные лимиты для разных операций (read > write > delete)

### 5. Валидация данных

```dart
Future<ValidationDecision> validateData({
  required String collection,
  required Map<String, dynamic> data,
});
```

**Задача:** Валидировать входные данные перед сохранением.

**Проверки:**
- SQL injection
- XSS
- Размер данных
- Формат полей
- Бизнес-правила

**Пример реализации:**

```dart
@override
Future<ValidationDecision> validateData({
  required String collection,
  required Map<String, dynamic> data,
}) async {
  final errors = <ValidationError>[];

  // 1. Получить схему коллекции
  final schema = await _schemaService.getSchema(collection);

  // 2. Проверить обязательные поля
  for (final field in schema.requiredFields) {
    if (!data.containsKey(field)) {
      errors.add(ValidationError(
        field: field,
        message: 'Field "$field" is required',
        code: 'REQUIRED',
      ));
    }
  }

  // 3. Проверить типы полей
  for (final entry in data.entries) {
    final fieldSchema = schema.fields[entry.key];
    if (fieldSchema == null) continue;

    if (!_isValidType(entry.value, fieldSchema.type)) {
      errors.add(ValidationError(
        field: entry.key,
        message: 'Invalid type for field "${entry.key}"',
        code: 'INVALID_TYPE',
      ));
    }
  }

  // 4. SQL injection detection
  for (final entry in data.entries) {
    if (entry.value is String) {
      final value = entry.value as String;
      if (_containsSqlInjection(value)) {
        errors.add(ValidationError(
          field: entry.key,
          message: 'Potential SQL injection detected',
          code: 'SQL_INJECTION',
        ));
      }
    }
  }

  // 5. XSS detection
  for (final entry in data.entries) {
    if (entry.value is String) {
      final value = entry.value as String;
      if (_containsXss(value)) {
        errors.add(ValidationError(
          field: entry.key,
          message: 'Potential XSS detected',
          code: 'XSS',
        ));
      }
    }
  }

  // 6. Размер данных
  final size = _calculateSize(data);
  if (size > schema.maxSize) {
    errors.add(ValidationError(
      field: '__size',
      message: 'Data size exceeds limit',
      code: 'SIZE_EXCEEDED',
    ));
  }

  return errors.isEmpty
      ? const ValidationOk()
      : ValidationFailed(errors);
}
```

### 6. Шифрование чувствительных полей

```dart
Future<Map<String, dynamic>> encryptSensitiveFields({
  required AqTokenClaims? claims,
  required String collection,
  required Map<String, dynamic> data,
});
```

**Задача:** Зашифровать чувствительные поля перед сохранением в БД.

**Пример реализации:**

```dart
@override
Future<Map<String, dynamic>> encryptSensitiveFields({
  required AqTokenClaims? claims,
  required String collection,
  required Map<String, dynamic> data,
}) async {
  // 1. Получить список чувствительных полей для коллекции
  final sensitiveFields = await _schemaService.getSensitiveFields(collection);
  if (sensitiveFields.isEmpty) return data;

  // 2. Клонировать данные
  final encrypted = Map<String, dynamic>.from(data);

  // 3. Зашифровать каждое чувствительное поле
  for (final field in sensitiveFields) {
    if (!encrypted.containsKey(field)) continue;

    final value = encrypted[field];
    if (value == null) continue;

    // Получить ключ шифрования для tenant
    final key = await _keyService.getEncryptionKey(
      tenantId: claims?.tenantId ?? 'system',
    );

    // Зашифровать
    final encryptedValue = await _encryptionService.encrypt(
      value.toString(),
      key: key,
    );

    encrypted[field] = encryptedValue;
  }

  return encrypted;
}
```

**Важно:**
- Используйте AES-256-GCM для шифрования
- Храните ключи в AWS Secrets Manager / Vault
- Ротируйте ключи регулярно
- Не шифруйте индексируемые поля

### 7. Аудит операций

```dart
Future<void> logOperation({
  required AqTokenClaims? claims,
  required String operation,
  required String collection,
  String? entityId,
  required bool success,
  String? errorMessage,
});
```

**Задача:** Записать событие аудита для compliance.

**Пример реализации:**

```dart
@override
Future<void> logOperation({
  required AqTokenClaims? claims,
  required String operation,
  required String collection,
  String? entityId,
  required bool success,
  String? errorMessage,
}) async {
  final event = AuditEvent(
    id: _uuid.v4(),
    timestamp: DateTime.now(),
    userId: claims?.sub ?? 'anonymous',
    tenantId: claims?.tenantId ?? 'system',
    operation: operation,
    collection: collection,
    entityId: entityId,
    success: success,
    errorMessage: errorMessage,
    ip: _currentRequest?.ip,
    userAgent: _currentRequest?.headers['User-Agent'],
  );

  // Записать в audit log (async, не блокирует операцию)
  await _auditLogger.log(event);
}
```

## Интеграция с ISecurityService

`IVaultSecurityProtocol` — это адаптер между dart_vault и `ISecurityService`.

**Пример:**

```dart
final class AqVaultSecurityProtocol implements IVaultSecurityProtocol {
  AqVaultSecurityProtocol({
    required ISecurityService securityService,
  }) : _securityService = securityService;

  final ISecurityService _securityService;

  @override
  Future<AqTokenClaims?> extractClaims(Map<String, String> headers) async {
    // Делегировать ISecurityService
    return await _securityService.validateToken(
      headers['Authorization']?.substring(7), // Remove "Bearer "
    );
  }

  @override
  Future<AccessDecision> canRead({
    required AqTokenClaims? claims,
    required String collection,
    String? entityId,
  }) async {
    // Делегировать ISecurityService
    final hasPermission = await _securityService.checkPermission(
      userId: claims?.sub,
      action: 'read',
      resource: collection,
      resourceId: entityId,
    );

    if (hasPermission) {
      return const AccessAllowed();
    }

    // Проверить RLS
    final allowedIds = await _securityService.getAllowedResourceIds(
      userId: claims?.sub ?? 'anonymous',
      resource: collection,
    );

    if (allowedIds.isEmpty) {
      return const AccessDenied('No read permission');
    }

    return AccessRestricted(allowedIds: allowedIds);
  }

  // ... остальные методы
}
```

## Производительность

### Кеширование

**Что кешировать:**
1. JWT validation результаты (TTL = token expiration)
2. RLS решения (TTL = 5 минут, инвалидация при изменении прав)
3. Схемы коллекций (TTL = 1 час)
4. Encryption keys (TTL = 24 часа)

**Пример:**

```dart
final _claimsCache = <String, AqTokenClaims>{};

@override
Future<AqTokenClaims?> extractClaims(Map<String, String> headers) async {
  final token = _extractToken(headers);
  if (token == null) return null;

  // Проверить кеш
  if (_claimsCache.containsKey(token)) {
    final cached = _claimsCache[token]!;
    // Проверить expiration
    if (cached.exp * 1000 > DateTime.now().millisecondsSinceEpoch) {
      return cached;
    }
    _claimsCache.remove(token);
  }

  // Валидировать и закешировать
  final claims = await _validateJwt(token);
  if (claims != null) {
    _claimsCache[token] = claims;
  }

  return claims;
}
```

### Batch операции

Для списков сущностей делайте batch проверки:

```dart
Future<Map<String, AccessDecision>> canReadBatch({
  required AqTokenClaims? claims,
  required String collection,
  required List<String> entityIds,
}) async {
  // Одним запросом получить все RLS решения
  final allowedIds = await _rlsService.getAllowedIds(
    userId: claims?.sub ?? 'anonymous',
    tenantId: claims?.tenantId ?? 'system',
    collection: collection,
  );

  // Построить Map решений
  return {
    for (final id in entityIds)
      id: allowedIds.contains(id) || allowedIds.contains('*')
          ? const AccessAllowed()
          : const AccessDenied('No access'),
  };
}
```

## Тестирование

### Unit тесты

```dart
void main() {
  late AqVaultSecurityProtocol protocol;
  late MockSecurityService mockSecurityService;

  setUp(() {
    mockSecurityService = MockSecurityService();
    protocol = AqVaultSecurityProtocol(
      securityService: mockSecurityService,
    );
  });

  group('extractClaims', () {
    test('returns claims for valid token', () async {
      when(mockSecurityService.validateToken(any))
          .thenAnswer((_) async => testAdminClaims);

      final claims = await protocol.extractClaims({
        'Authorization': 'Bearer valid-token',
      });

      expect(claims, isNotNull);
      expect(claims!.sub, 'admin-user-id');
    });

    test('returns null for invalid token', () async {
      when(mockSecurityService.validateToken(any))
          .thenAnswer((_) async => null);

      final claims = await protocol.extractClaims({
        'Authorization': 'Bearer invalid-token',
      });

      expect(claims, isNull);
    });
  });

  group('canRead', () {
    test('admin can read everything', () async {
      final decision = await protocol.canRead(
        claims: testAdminClaims,
        collection: 'projects',
      );

      expect(decision, isA<AccessAllowed>());
    });

    test('user with RLS gets restricted access', () async {
      when(mockSecurityService.getAllowedResourceIds(any, any))
          .thenAnswer((_) async => ['project-1', 'project-2']);

      final decision = await protocol.canRead(
        claims: testUserClaims,
        collection: 'projects',
      );

      expect(decision, isA<AccessRestricted>());
      expect((decision as AccessRestricted).allowedIds, ['project-1', 'project-2']);
    });
  });
}
```

### Integration тесты

```dart
void main() {
  late PostgresVaultStorage storage;
  late AqVaultSecurityProtocol protocol;

  setUpAll(() async {
    final pool = await Pool.connect(...);
    protocol = AqVaultSecurityProtocol(
      securityService: RealSecurityService(),
    );
    IVaultSecurityProtocol.initialize(protocol);

    storage = PostgresVaultStorage(
      pool: pool,
      tenantId: 'test-tenant',
    );
  });

  test('admin can read all projects', () async {
    storage.headers = {'Authorization': 'Bearer ${TestTokens.admin}'};

    final projects = await storage.list('projects');
    expect(projects, isNotEmpty);
  });

  test('user can only read own projects', () async {
    storage.headers = {'Authorization': 'Bearer ${TestTokens.user}'};

    final projects = await storage.list('projects');
    // Должны вернуться только проекты пользователя
    expect(projects.every((p) => p['owner_id'] == 'user-id'), isTrue);
  });

  test('blocked user cannot read', () async {
    storage.headers = {'Authorization': 'Bearer ${TestTokens.blocked}'};

    expect(
      () => storage.list('projects'),
      throwsA(isA<SecurityException>()),
    );
  });
}
```

## Чеклист реализации

- [ ] Реализовать `extractClaims` с JWT validation
- [ ] Реализовать `canRead` с RLS поддержкой
- [ ] Реализовать `canWrite` с ABAC
- [ ] Реализовать `canDelete` (только для владельцев/админов)
- [ ] Реализовать `canPublish` (для versioned entities)
- [ ] Реализовать `canGrant` (для управления правами)
- [ ] Реализовать `checkRateLimit` с Redis/in-memory store
- [ ] Реализовать `validateData` с SQL injection/XSS detection
- [ ] Реализовать `encryptSensitiveFields` с AES-256-GCM
- [ ] Реализовать `decryptSensitiveFields`
- [ ] Реализовать `logOperation` с audit logger
- [ ] Добавить кеширование для JWT validation
- [ ] Добавить кеширование для RLS решений
- [ ] Добавить batch операции для списков
- [ ] Написать unit тесты (coverage > 90%)
- [ ] Написать integration тесты с реальной БД
- [ ] Добавить метрики (latency, cache hit rate)
- [ ] Добавить логирование (debug, info, error)
- [ ] Документировать производительность
- [ ] Провести security audit

## Примеры использования

См. файлы в `pkgs/aq_schema/lib/security/interfaces/clients_protocols/`:
- `noop_vault_security_protocol.dart` — NoOp реализация (всё разрешено)
- `mocks/mock_vault_security_protocol.dart` — Mock для тестов
- `mocks/test_tokens.dart` — Захардкоженные токены для тестов

## Вопросы?

Если что-то непонятно, смотрите:
1. Интерфейс: `pkgs/aq_schema/lib/security/interfaces/clients_protocols/i_data_layer_as_clietn_secure_protocol.dart`
2. Mock реализацию: `pkgs/aq_schema/lib/security/interfaces/clients_protocols/mocks/mock_vault_security_protocol.dart`
3. Использование в dart_vault: `pkgs/dart_vault_package/lib/storage/postgres/postgres_vault_storage.dart`
