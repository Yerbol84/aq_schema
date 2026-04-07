# AQ Package Architecture — Принципы построения экосистемы пакетов

**Версия:** 1.0
**Статус:** ОБЯЗАТЕЛЬНО к соблюдению при создании новых пакетов

---

## Философия: Центральная схема + Тонкий клиент

AQ экосистема построена на принципе **"единого источника истины"** — все домены, интерфейсы и схемы данных определяются в центральном пакете `aq_schema`. Остальные пакеты зависят **только** от него и **никогда** друг от друга.

### Ключевые постулаты

1. **aq_schema — единственный источник истины**
   - Все доменные модели (WorkflowGraph, InstructionGraph, AqStudioProject и т.д.)
   - Все интерфейсы (IHand, IEngineTransport, VaultStorage и т.д.)
   - Все схемы данных (Storable интерфейсы: DirectStorable, VersionedStorable, LoggedStorable)
   - Все валидаторы и типы ошибок

2. **Пакеты не зависят друг от друга**
   - `aq_graph_engine` НЕ знает о `aq_worker`
   - `dart_vault` НЕ знает о `aq_security`
   - `aq_mcp_core` НЕ знает о `aq_queue`
   - Все взаимодействие идёт через интерфейсы из `aq_schema`

3. **Клиент максимально тонкий**
   - Клиентское приложение НЕ пишет ни строчки бизнес-логики
   - Клиент просто подключает пакет и получает готовый сервис
   - Вся логика реализована на уровне пакета (и на клиенте, и на сервере)

4. **Пакет = Клиент + Сервер**
   - Каждый пакет содержит две части: клиентскую и серверную
   - Сервер реализует работу, выдаёт результат
   - Клиент (из того же пакета) знает как работать с сервером
   - Благодаря этому: один набор тестов проверяет всё

---

## Структура пакета

Каждый пакет в экосистеме AQ должен следовать единой структуре:

```
my_package/
├── lib/
│   ├── my_package.dart              # Главный экспорт (ТОЛЬКО клиентская часть)
│   ├── client/                      # Клиентская часть (экспортируется)
│   │   ├── my_service_client.dart   # Клиент сервиса
│   │   └── my_repository.dart       # Репозиторий (если это дата-слой)
│   ├── server/                      # Серверная часть (НЕ экспортируется в main)
│   │   ├── my_service_server.dart   # Серверная реализация
│   │   └── storage/                 # Storage реализации (ТОЛЬКО на сервере)
│   ├── shared/                      # Общие утилиты (если нужны)
│   │   └── my_protocol.dart         # Протокол взаимодействия
│   └── server.dart                  # Отдельный экспорт для серверной части
├── test/
│   ├── integration/                 # Интеграционные тесты (клиент + сервер)
│   └── unit/                        # Юнит-тесты
└── pubspec.yaml
```

### Правила экспорта

**КРИТИЧЕСКИ ВАЖНО:**

1. **Главный файл пакета (`lib/my_package.dart`)** экспортирует **ТОЛЬКО клиентскую часть**:
   ```dart
   // lib/my_package.dart
   library my_package;

   export 'client/my_service_client.dart';
   export 'client/my_repository.dart';
   // НЕ экспортируем server/ и storage/
   ```

2. **Серверная часть** экспортируется через **отдельный файл** (`lib/server.dart`):
   ```dart
   // lib/server.dart
   library my_package.server;

   export 'server/my_service_server.dart';
   export 'server/storage/my_storage.dart';
   ```

3. **Storage реализации живут ТОЛЬКО на сервере**:
   - Клиент получает только Repository
   - Storage остаётся на сервере и не передаётся клиенту

---

## Пример: Пакет дата-слоя (dart_vault)

### Что видит клиент

```dart
// В клиентском приложении
import 'package:dart_vault/dart_vault.dart';

// Клиент делает handshake и получает готовый репозиторий
await Vault.connect('http://localhost:8765');

final workflows = Vault.instance.versioned<WorkflowGraph>(
  collection: WorkflowGraph.kCollection,
  fromMap: WorkflowGraph.fromMap,
);

// Всё! Клиент не знает о PostgreSQL, Supabase, или способах хранения
await workflows.createEntity(myWorkflow);
```

### Что происходит на сервере

```dart
// В серверном приложении
import 'package:dart_vault/server.dart'; // Отдельный импорт!

// Сервер регистрирует домены из aq_schema
final registry = VaultRegistry(
  storageFactory: (tenantId) => PostgresVaultStorage(pool: pg, tenantId: tenantId),
  deployer: PostgresSchemaDeployer(pool: pg),
);

registry
  ..register(DomainRegistration(
      collection: WorkflowGraph.kCollection,
      mode: StorageMode.versioned,
      fromMap: WorkflowGraph.fromMap,
      indexes: [VaultIndex(name: 'idx_name', field: 'name')],
  ))
  ..register(DomainRegistration(
      collection: InstructionGraph.kCollection,
      mode: StorageMode.versioned,
      fromMap: InstructionGraph.fromMap,
  ));

await registry.deploy(); // Создаёт таблицы если нужно
```

### Handshake протокол

1. **Клиент подключается**: `Vault.connect('http://localhost:8765')`
2. **Сервер отвечает** списком доступных коллекций:
   ```json
   {
     "serverVersion": "0.3.0",
     "tenantId": "user-123",
     "collections": [
       {"name": "workflows", "mode": "versioned", "schemaVersion": "1.0.0"},
       {"name": "instructions", "mode": "versioned", "schemaVersion": "1.0.0"}
     ],
     "capabilities": ["direct", "versioned", "logged", "artifact", "vector"],
     "compatible": true
   }
   ```
3. **Клиент получает полный репозиторий** — готов к работе!

---

## Пример: Пакет авторизации (aq_security)

### Что видит клиент

```dart
import 'package:aq_security/aq_security.dart';

// Инициализация
await AQSecurityClient.init(
  'http://localhost:8080',
  jwtSecret: 'secret',
);

// Использование
final result = await AQSecurityClient.instance.signIn(
  email: 'user@example.com',
  password: 'password',
);

if (result.success) {
  print('Token: ${result.token}');
}
```

### Что происходит на сервере

```dart
import 'package:aq_security/server.dart'; // Отдельный импорт!

// Сервер регистрирует провайдеры из aq_schema
final authService = AQSecurityServer(
  storage: PostgresSecurityStorage(pool: pg),
  jwtSecret: 'secret',
);

// Обработка запросов
router.post('/auth/signin', (Request req) async {
  final body = await req.readAsString();
  final result = await authService.signIn(jsonDecode(body));
  return Response.ok(jsonEncode(result.toMap()));
});
```

---

## Пример: Пакет графового движка (aq_graph_engine)

### Что видит клиент

```dart
import 'package:aq_graph_engine/aq_graph_engine.dart';

// Клиент получает транспорт (локальный или удалённый)
final transport = LocalEngineTransport(
  tools: toolRegistry,
  runRepo: runRepository,
  graphRepo: graphRepository,
);

// Запуск графа
final stream = transport.run(GraphRunRequest(
  runId: 'run-123',
  blueprintId: 'workflow-456',
  context: {'projectId': 'proj-789'},
));

await for (final event in stream) {
  print('Event: ${event.type}');
}
```

### Что происходит на сервере (worker)

```dart
import 'package:aq_graph_engine/server.dart'; // Отдельный импорт!

// Worker регистрирует hands из aq_schema
final worker = GraphWorker(
  transport: RemoteEngineTransport(endpoint: 'http://localhost:8765'),
  handsRegistry: WorkerHandsRegistry()
    ..register('llm_request', LlmRequestHand())
    ..register('file_write', FileWriteHand()),
);

await worker.start();
```

---

## Регистрация доменов: Строго из aq_schema

**ПРАВИЛО:** Все домены, которые регистрируются в пакетах, должны быть определены в `aq_schema`.

### Где определяются домены

```
aq_schema/
├── lib/
│   ├── graph/
│   │   └── graphs/
│   │       ├── workflow_graph.dart      # WorkflowGraph implements VersionedStorable
│   │       ├── instruction_graph.dart   # InstructionGraph implements VersionedStorable
│   │       └── prompt_graph.dart        # PromptGraph implements VersionedStorable
│   ├── studio_project/
│   │   └── aq_studio_project.dart       # AqStudioProject implements DirectStorable
│   └── data_layer/
│       └── storable/
│           ├── storable.dart            # Базовый интерфейс
│           ├── direct_storable.dart     # Простое хранение
│           ├── versioned_storable.dart  # С версионированием
│           └── logged_storable.dart     # С аудитом
```

### Как регистрировать

```dart
// В серверном приложении (server_apps/aq_studio_data_service)
import 'package:aq_schema/aq_schema.dart';
import 'package:dart_vault/server.dart';

registry
  // Все модели строго из aq_schema!
  ..register(DomainRegistration(
      collection: WorkflowGraph.kCollection,      // из aq_schema
      mode: StorageMode.versioned,
      fromMap: WorkflowGraph.fromMap,             // из aq_schema
  ))
  ..register(DomainRegistration(
      collection: AqStudioProject.kCollection,    // из aq_schema
      mode: StorageMode.direct,
      fromMap: AqStudioProject.fromMap,           // из aq_schema
  ));
```

---

## Тестирование: Один пакет = Один набор тестов

Благодаря тому, что клиент и сервер в одном пакете, тесты проверяют всё сразу:

```dart
// test/integration/vault_integration_test.dart
import 'package:dart_vault/dart_vault.dart';
import 'package:dart_vault/server.dart';
import 'package:aq_schema/aq_schema.dart';

void main() {
  test('Client-Server integration', () async {
    // Запускаем сервер
    final registry = VaultRegistry(
      storageFactory: (tid) => InMemoryVaultStorage(),
    );
    registry.register(DomainRegistration(
      collection: 'test_docs',
      mode: StorageMode.versioned,
      fromMap: TestDoc.fromMap,
    ));

    // Подключаем клиента
    await Vault.connect('http://localhost:8765');

    // Тестируем
    final repo = Vault.instance.versioned<TestDoc>(
      collection: 'test_docs',
      fromMap: TestDoc.fromMap,
    );

    final node = await repo.createEntity(TestDoc(id: '1', title: 'Test'));
    expect(node.status, VersionStatus.draft);
  });
}
```

---

## Преимущества архитектуры

### 1. Нулевая дублирование кода
- Домены определены один раз в `aq_schema`
- Не нужно отдельно описывать для сервера и клиента
- Не нужны прослойки и адаптеры

### 2. Автоматическая синхронизация
- Изменил модель в `aq_schema` → обновил версию пакета
- Клиент и сервер автоматически получают изменения
- Handshake проверяет совместимость версий

### 3. Простота разработки
- Клиент не пишет логику — просто использует пакет
- Сервер регистрирует домены — всё остальное автоматически
- Один набор тестов проверяет всё

### 4. Изоляция и модульность
- Пакеты не зависят друг от друга
- Можно заменить реализацию без изменения интерфейса
- Легко добавлять новые пакеты

### 5. Безопасность
- Storage живёт только на сервере
- Клиент не знает о способах хранения
- Все операции идут через контролируемый API

---

## Чек-лист создания нового пакета

При создании нового пакета в экосистеме AQ, следуй этому чек-листу:

- [ ] **Определить домены в aq_schema**
  - [ ] Создать модели с интерфейсами (DirectStorable/VersionedStorable/LoggedStorable)
  - [ ] Добавить `kCollection` константу
  - [ ] Добавить `fromMap` и `toMap` методы
  - [ ] Экспортировать из `aq_schema.dart`

- [ ] **Создать структуру пакета**
  - [ ] `lib/client/` — клиентская часть
  - [ ] `lib/server/` — серверная часть
  - [ ] `lib/my_package.dart` — экспорт клиента
  - [ ] `lib/server.dart` — экспорт сервера

- [ ] **Реализовать клиента**
  - [ ] Handshake с сервером
  - [ ] Получение сервиса/репозитория
  - [ ] Простой API для использования

- [ ] **Реализовать сервер**
  - [ ] Регистрация доменов из aq_schema
  - [ ] Storage реализация (только на сервере!)
  - [ ] Обработка запросов

- [ ] **Написать тесты**
  - [ ] Интеграционные тесты (клиент + сервер)
  - [ ] Юнит-тесты для логики
  - [ ] Проверка handshake

- [ ] **Документация**
  - [ ] README с примерами использования
  - [ ] Описание API
  - [ ] Примеры для клиента и сервера

---

## Заключение

Эта архитектура позволяет строить масштабируемую экосистему пакетов, где:
- Клиент максимально прост
- Сервер легко расширяется
- Всё тестируется автоматически
- Нет дублирования кода
- Изменения синхронизируются автоматически

**Следуй этим принципам при создании любого нового пакета в AQ экосистеме!**
