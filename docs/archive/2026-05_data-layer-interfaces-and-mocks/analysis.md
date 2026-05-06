# Analysis: Data Layer — архитектурные нарушения + отсутствие моков

## Текущее состояние

### Что есть правильно
- `DirectRepository`, `VersionedRepository`, `LoggedRepository` — интерфейсы в `aq_schema/lib/data_layer/repositories/` ✅
- `DirectStorable`, `VersionedStorable`, `LoggedStorable`, `ArtifactEntry` — в `aq_schema/lib/data_layer/storable/` ✅
- `VaultStorage`, `ArtifactStorage`, `VectorStorage` — низкоуровневые бэкенды в `aq_schema` ✅
- `IDataLayer` — единая точка входа в `aq_schema` ✅
- `MockSecurityBackend` + моки security — реализованы правильно, паттерн есть ✅

### Нарушения

**Нарушение 1: `ArtifactRepository` в `aq_data_layer`**
Файл: `aq_data_layer/lib/repositories/artifact_repository.dart`
Это `abstract interface class` — порт. По правилам порты живут в `aq_schema` и называются с `I`-префиксом. Сейчас живёт в пакете-реализации.

**Нарушение 2: `VectorRepository` в `aq_data_layer`**
Файл: `aq_data_layer/lib/repositories/vector_repository.dart`
То же нарушение.

**Нарушение 3: `KnowledgeRepository` в `aq_data_layer`**
Файл: `aq_data_layer/lib/repositories/knowledge_repository.dart`
То же нарушение. Плюс содержит `KnowledgeDocument`, `KnowledgeSearchResult`, `DocumentChunk`, `TextSplitter` — всё это модели/интерфейсы которые должны быть в `aq_schema`.

**Нарушение 4: `Repository<T>` в `aq_data_layer`**
Файл: `aq_data_layer/lib/repositories/repository.dart`
Базовый интерфейс-дубликат. Контракт уже покрыт `DirectRepository` в `aq_schema`. Подлежит удалению.

**Нарушение 5: `IDataLayer` не покрывает артефакты, векторы, знания**
Файл: `aq_schema/lib/data_layer/i_data_layer.dart`
`IDataLayer` — единственная точка входа для клиента. Но методов `artifacts()`, `vectors()`, `knowledge()` нет. Клиент вынужден использовать `ArtifactVault`, `KnowledgeVault` в обход `IDataLayer`. Моки невозможны без расширения интерфейса.

**Нарушение 6: Моки data layer отсутствуют полностью**
`aq_schema/lib/data_layer/mock/` — не существует.
`aq_schema/lib/data_testing.dart` — не существует.
По правилам `inter_layer_communication_rules.xml` команда реализующая слой обязана поставить моки рядом с портами. Без моков `aq_graph_engine`, `aq_security` не могут тестироваться без реального `dart_vault`.

**Нарушение 7: `VectorEntry` не реализует `Storable`**
Файл: `aq_schema/lib/data_layer/storage/vector_storage.dart`
`VectorEntry` — целевая сущность для `IVectorRepository`, но не входит в иерархию `Storable`. Нет единого контракта с остальными сущностями data layer.
Нужен `VectorStorable implements Storable` в `storable/`.

**Нарушение 8: `KnowledgeDocument` живёт в `aq_data_layer`**
Файл: `aq_data_layer/lib/repositories/knowledge_repository.dart`
`KnowledgeDocument implements ArtifactEntry` — целевая сущность, должна быть в `aq_schema/lib/data_layer/storable/`.

## Проблема

Другие пакеты (`aq_graph_engine`, `aq_security`) не могут тестироваться без реального `dart_vault` + PostgreSQL. Нет `InMemoryVersionedRepository` для тестов. Нет `MockDataLayer` как заглушки `IDataLayer.instance`.

## Ограничения

- Работаем только в `aq_schema` (текущий пакет сессии)
- `aq_data_layer` — только чтение для понимания контрактов
- После этой сессии — отдельная сессия `aq_data_layer` для обновления реализаций
