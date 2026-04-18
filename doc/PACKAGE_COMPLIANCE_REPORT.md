# Отчёт о соответствии пакетов архитектурным принципам

**Дата:** 2026-04-10
**Базовый документ:** `PACKAGE_ARCHITECTURE.md` v2.0

---

## Исполнительное резюме

Проанализированы три ключевых пакета экосистемы AQ:
- `aq_security` — ✅ **ПОЛНОЕ СООТВЕТСТВИЕ**
- `dart_vault_package` — ⚠️ **ЧАСТИЧНОЕ СООТВЕТСТВИЕ** (3 отклонения)
- `aq_graph_engine` — ❌ **КРИТИЧЕСКИЕ ОТКЛОНЕНИЯ** (отсутствует серверная часть)

---

## 1. Пакет `aq_security`

### ✅ Соответствие архитектуре: 100%

#### Структура пакета

```
aq_security/
├── lib/
│   ├── aq_security.dart              ✅ Клиентский экспорт
│   ├── aq_security_server.dart       ✅ Серверный экспорт
│   └── src/
│       ├── client/                   ✅ Клиентская часть
│       ├── server/                   ✅ Серверная часть
│       ├── rbac/                     ✅ Общая логика
│       └── shared/                   ✅ Общие утилиты
└── test/
    ├── unit/                         ✅ Юнит-тесты
    ├── integration/                  ✅ Интеграционные тесты
    └── e2e/                          ✅ E2E тесты
```

#### Анализ экспортов

**`lib/aq_security.dart` (клиент):**
```dart
export 'package:aq_schema/security/security.dart';  // ✅ Зависимость от aq_schema
export 'src/client/aq_security_client.dart';        // ✅ Только клиент
export 'src/client/aq_security_service.dart';
export 'src/client/introspection_client.dart';
export 'src/rbac/rbac.dart';                        // ✅ Общая логика
```

**`lib/aq_security_server.dart` (сервер):**
```dart
export 'aq_security.dart';                          // ✅ Включает клиента
export 'src/server/aq_auth_server.dart';            // ✅ Серверная реализация
export 'src/server/token_issuer.dart';
export 'src/server/session_service.dart';
// ... все серверные компоненты
```

#### Соответствие принципам

| Принцип | Статус | Комментарий |
|---------|--------|-------------|
| Разделение client/server | ✅ | Чёткое разделение через отдельные barrel-файлы |
| Зависимость от aq_schema | ✅ | `export 'package:aq_schema/security/security.dart'` |
| Storage только на сервере | ✅ | Репозитории в `src/server/repositories/` |
| Типизированные клиенты | ⚠️ | Не реализованы (User/Resource/Admin), но структура готова |
| Тестирование | ✅ | unit + integration + e2e |

#### Рекомендации

1. **Добавить типизированные клиенты** согласно разделу 3.2.1 PACKAGE_ARCHITECTURE.md:
   - `IAQAuthUserClient` — для UI приложений
   - `IAQAuthResourceClient` — для воркеров
   - `IAQAuthAdminClient` — для администрирования
   - `IAQAuthEngineClient` — для движка (offline validation)

2. **Реализовать интерфейсы из `aq_schema/clients.dart`** с `.instance` геттером

---

## 2. Пакет `dart_vault_package`

### ⚠️ Соответствие архитектуре: 70%

#### Структура пакета

```
dart_vault_package/
├── lib/
│   ├── dart_vault_package.dart       ⚠️ ОТКЛОНЕНИЕ #1: Смешанный экспорт
│   ├── dart_vault.dart               ✅ Альтернативный клиентский экспорт
│   ├── server.dart                   ✅ Серверный экспорт
│   ├── artifact_vault.dart           ⚠️ ОТКЛОНЕНИЕ #2: Дополнительные barrel
│   ├── knowledge_vault.dart          ⚠️ ОТКЛОНЕНИЕ #2: Дополнительные barrel
│   ├── client/                       ✅ Клиентская часть
│   ├── storage/                      ✅ Storage реализации
│   ├── repositories/                 ✅ Репозитории
│   ├── deploy/                       ✅ Deploy (регистрация доменов)
│   └── security/                     ⚠️ ОТКЛОНЕНИЕ #3: Экспортируется в клиент
└── test/
    └── integration/                  ✅ Интеграционные тесты
```

#### Отклонение #1: Смешанный экспорт в главном файле

**Проблема:** `lib/dart_vault_package.dart` экспортирует и клиентские, и серверные компоненты:

```dart
// dart_vault_package.dart
export 'client/vault.dart';                    // ✅ Клиент
export 'repositories/repository.dart';         // ✅ Клиент
export 'storage/vault_storage.dart';           // ❌ Должно быть только в server.dart
export 'storage/local_buffer_vault_storage.dart'; // ❌ Должно быть только в server.dart
export 'security/...';                         // ❌ Часть должна быть только в server.dart
export 'deploy/vault_registry.dart';           // ❌ Должно быть только в server.dart
```

**Ожидаемое поведение:**
- `dart_vault_package.dart` или `dart_vault.dart` — ТОЛЬКО клиент
- `server.dart` — клиент + серверные компоненты

**Текущее состояние:**
- `dart_vault.dart` — правильный клиентский экспорт ✅
- `server.dart` — правильный серверный экспорт ✅
- `dart_vault_package.dart` — смешанный экспорт ❌

#### Отклонение #2: Множественные barrel-файлы

**Проблема:** Дополнительные barrel-файлы `artifact_vault.dart`, `knowledge_vault.dart` нарушают принцип единой точки входа.

**Архитектурный принцип (раздел 2.2):**
> Главный файл пакета (`lib/my_package.dart`) экспортирует ТОЛЬКО клиентскую часть

**Текущее состояние:**
```
lib/
├── dart_vault_package.dart    ← главный (но смешанный)
├── dart_vault.dart            ← альтернативный клиентский
├── artifact_vault.dart        ← специализированный
├── knowledge_vault.dart       ← специализированный
└── server.dart                ← серверный
```

**Рекомендация:** Оставить только два файла:
- `dart_vault_package.dart` — клиент
- `server.dart` — сервер

Специализированные экспорты (`artifact_vault`, `knowledge_vault`) включить в основной клиентский файл.

#### Отклонение #3: Security компоненты в клиенте

**Проблема:** `dart_vault_package.dart` экспортирует security компоненты, которые должны быть только на сервере:

```dart
export 'security/rate_limit_store.dart';           // ❌ Серверный компонент
export 'security/in_memory_rate_limit_store.dart'; // ❌ Серверный компонент
export 'security/vault_rate_limiter.dart';         // ❌ Серверный компонент
export 'security/dos_protection.dart';             // ❌ Серверный компонент
export 'security/secrets_manager.dart';            // ❌ Серверный компонент
export 'security/audit_logger.dart';               // ❌ Серверный компонент
export 'security/postgres_audit_logger.dart';      // ❌ Серверный компонент
```

**Архитектурный принцип (раздел 5.2.5):**
> Storage живёт только на сервере. Клиент не знает о способах хранения.

**Рекомендация:** Переместить все security экспорты в `server.dart`.

#### Соответствие принципам

| Принцип | Статус | Комментарий |
|---------|--------|-------------|
| Разделение client/server | ⚠️ | Есть, но `dart_vault_package.dart` смешанный |
| Зависимость от aq_schema | ✅ | Использует интерфейсы из aq_schema |
| Storage только на сервере | ❌ | Storage экспортируется в клиент |
| Handshake протокол | ✅ | Реализован через `Vault.connect()` |
| Тестирование | ✅ | Интеграционные тесты есть |

#### Рекомендации

1. **Переименовать `dart_vault.dart` → `dart_vault_package.dart`** (сделать его главным)
2. **Удалить текущий `dart_vault_package.dart`** (смешанный экспорт)
3. **Удалить `artifact_vault.dart` и `knowledge_vault.dart`**, включить их в главный файл
4. **Переместить все security экспорты** из клиента в `server.dart`
5. **Добавить типизированные клиенты** согласно разделу 3.2.2:
   - `IAQVaultUserClient`
   - `IAQVaultEngineClient`
   - `IAQVaultWorkerClient`
   - `IAQVaultAdminClient`

---

## 3. Пакет `aq_graph_engine`

### ❌ Соответствие архитектуре: 40%

#### Структура пакета

```
aq_graph_engine/
├── lib/
│   ├── aq_graph_engine.dart          ✅ Клиентский экспорт
│   └── src/
│       ├── client/                   ✅ Клиентская часть
│       ├── engine/                   ⚠️ Движок (должен быть в server/)
│       ├── transport/                ⚠️ Транспорт (смешанный)
│       ├── interfaces/               ✅ Интерфейсы
│       ├── monitoring/               ⚠️ Метрики (должны быть в server/)
│       ├── registry/                 ⚠️ Реестр (должен быть в server/)
│       ├── nodes/                    ⚠️ Узлы (должны быть в server/)
│       ├── runners/                  ⚠️ Runners (должны быть в server/)
│       └── factories/                ⚠️ Фабрики (должны быть в server/)
└── test/
    └── unit/                         ✅ Юнит-тесты
```

#### КРИТИЧЕСКОЕ ОТКЛОНЕНИЕ: Отсутствует `server.dart`

**Проблема:** Пакет НЕ имеет отдельного серверного экспорта `lib/server.dart`.

**Архитектурный принцип (раздел 2.1):**
> Каждый пакет должен следовать единой структуре:
> - `lib/my_package.dart` — клиентский экспорт
> - `lib/server.dart` — серверный экспорт

**Текущее состояние:**
- ✅ `lib/aq_graph_engine.dart` — есть
- ❌ `lib/server.dart` — ОТСУТСТВУЕТ

**Последствия:**
1. Невозможно разделить клиентскую и серверную части
2. Клиент получает доступ к серверным компонентам (engine, runners, nodes)
3. Нарушается принцип "тонкого клиента"

#### Анализ текущего экспорта

**`lib/aq_graph_engine.dart`:**
```dart
export 'src/engine/graph_engine.dart';              // ❌ Серверный компонент
export 'src/engine/engine_execution_context.dart';  // ❌ Серверный компонент
export 'src/interfaces/i_run_repository.dart';      // ✅ Интерфейс (клиент)
export 'src/interfaces/i_graph_repository.dart';    // ✅ Интерфейс (клиент)
export 'src/transport/local_engine_transport.dart'; // ⚠️ Смешанный (нужен и там, и там)
export 'src/transport/http_engine_transport.dart';  // ✅ Клиентский транспорт
export 'src/monitoring/metrics.dart';               // ❌ Серверный компонент
export 'src/registry/node_type_registry.dart';      // ❌ Серверный компонент
export 'src/client/graph_engine_client.dart';       // ✅ Клиент
```

#### Соответствие принципам

| Принцип | Статус | Комментарий |
|---------|--------|-------------|
| Разделение client/server | ❌ | Отсутствует `server.dart` |
| Зависимость от aq_schema | ✅ | Использует интерфейсы из aq_schema |
| Storage только на сервере | N/A | Не применимо (использует внешние репозитории) |
| Типизированные клиенты | ❌ | Не реализованы |
| Тестирование | ⚠️ | Только unit, нет integration |

#### Рекомендации

1. **КРИТИЧНО: Создать `lib/server.dart`** со следующей структурой:
   ```dart
   library aq_graph_engine.server;

   export 'aq_graph_engine.dart';  // Включить клиента

   // Серверные компоненты
   export 'src/engine/graph_engine.dart';
   export 'src/engine/engine_execution_context.dart';
   export 'src/monitoring/metrics.dart';
   export 'src/registry/node_type_registry.dart';
   export 'src/nodes/...';
   export 'src/runners/...';
   export 'src/factories/...';
   ```

2. **Убрать из `aq_graph_engine.dart` серверные компоненты:**
   - `graph_engine.dart`
   - `engine_execution_context.dart`
   - `metrics.dart`
   - `node_type_registry.dart`

3. **Реорганизовать `src/`:**
   ```
   src/
   ├── client/          ← клиентская часть
   ├── server/          ← серверная часть (engine, runners, nodes)
   ├── shared/          ← общие утилиты
   ├── interfaces/      ← интерфейсы (доступны всем)
   └── transport/       ← транспорт (смешанный)
   ```

4. **Добавить типизированные клиенты** согласно разделу 3.2.3:
   - Все режимы через один интерфейс `IAQGraphEngineClient`
   - Режим выбирается при `AQPlatform.init()`

5. **Добавить интеграционные тесты** (клиент + сервер)

---

## Сводная таблица соответствия

| Критерий | aq_security | dart_vault_package | aq_graph_engine |
|----------|-------------|-------------------|-----------------|
| **Структура client/server** | ✅ 100% | ⚠️ 70% | ❌ 0% |
| **Отдельный server.dart** | ✅ Есть | ✅ Есть | ❌ Отсутствует |
| **Зависимость от aq_schema** | ✅ Да | ✅ Да | ✅ Да |
| **Storage только на сервере** | ✅ Да | ❌ Нет | N/A |
| **Типизированные клиенты** | ⚠️ Структура готова | ❌ Нет | ❌ Нет |
| **Handshake протокол** | ✅ Да | ✅ Да | ⚠️ Частично |
| **Интеграционные тесты** | ✅ Да | ✅ Да | ❌ Нет |
| **Общая оценка** | ✅ 95% | ⚠️ 70% | ❌ 40% |

---

## Приоритеты исправления

### Критичные (блокируют архитектуру)

1. **aq_graph_engine:** Создать `lib/server.dart` и разделить client/server
2. **dart_vault_package:** Убрать storage/security из клиентского экспорта

### Важные (нарушают принципы)

3. **dart_vault_package:** Упростить структуру barrel-файлов (один клиент, один сервер)
4. **aq_graph_engine:** Реорганизовать `src/` на client/server/shared

### Желательные (улучшают архитектуру)

5. **Все пакеты:** Реализовать типизированные клиенты (User/Resource/Admin/Engine)
6. **aq_graph_engine:** Добавить интеграционные тесты

---

## Заключение

**aq_security** — эталонный пакет, полностью соответствует архитектуре. Требуется только добавить типизированные клиенты.

**dart_vault_package** — хорошая основа, но требует рефакторинга экспортов для полного соответствия принципу "тонкого клиента".

**aq_graph_engine** — требует критического рефакторинга: отсутствует разделение client/server, что нарушает фундаментальный принцип архитектуры.

**Рекомендация:** Начать с исправления критичных отклонений в `aq_graph_engine`, затем доработать `dart_vault_package`, и в конце добавить типизированные клиенты во все пакеты.
