# Report: Data Layer — архитектурные нарушения + моки

## Что сделано

### Исправлены архитектурные нарушения

**Нарушение 7 — VectorStorable:**
Создан `lib/data_layer/storable/vector_storable.dart` — базовый интерфейс для векторных сущностей, реализует `Storable`.

**Нарушение 8 — KnowledgeDocument:**
Создан `lib/data_layer/storable/knowledge_document.dart` — перенесён из `aq_data_layer`. Содержит `KnowledgeDocument`, `KnowledgeSearchResult`, `DocumentChunk`, `ITextSplitter`, `FixedSizeSplitter`, `EmbedFn`.

**Нарушения 1-3 — Интерфейсы репозиториев:**
Созданы в `lib/data_layer/repositories/`:
- `i_artifact_repository.dart` — `IArtifactRepository<T extends ArtifactEntry>`
- `i_vector_repository.dart` — `IVectorRepository`
- `i_knowledge_repository.dart` — `IKnowledgeRepository<T extends KnowledgeDocument>`

**Нарушение 5 — IDataLayer расширен:**
В `lib/data_layer/i_data_layer.dart` добавлены методы:
- `artifacts<T>({collection, fromMap})` → `IArtifactRepository<T>`
- `vectors({collection})` → `IVectorRepository`
- `knowledge<T>({collection, fromMap, embed})` → `IKnowledgeRepository<T>`

**Нарушение 6 — Моки data layer:**
Создана полная mock-инфраструктура в `lib/data_layer/mock/`:
- `MockDataBackend` — единое in-memory хранилище (документы + байты + векторы)
- `MockDataLayer implements IDataLayer` — регистрируется через `MockDataLayer.register(backend)`
- `InMemoryDirectRepository<T>`
- `InMemoryVersionedRepository<T>` — полная реализация с semver, branching
- `InMemoryLoggedRepository<T>` — с audit log, rollback, getHistory
- `InMemoryArtifactRepository<T>`
- `InMemoryVectorRepository` — cosine similarity search
- `InMemoryKnowledgeRepository<T>` — file + vector index как одна сущность

**Barrel:**
- `lib/data_layer/mock/mock.dart`
- `lib/data_testing.dart`

**Barrel aq_schema.dart обновлён** — добавлены экспорты всех новых файлов.

## Результат проверки

```
dart analyze lib/data_layer/ → 0 errors
```

Pre-existing ошибки в `lib/graph/` и `lib/validator/` (отсутствует пакет `json_schema`) не связаны с данной работой.

## Отклонения от плана

**Нарушение 4 (Repository<T>)** — удаление из `aq_data_layer` выполняется в следующей сессии с `aq_data_layer`, так как это изменение в другом пакете.

## Следующие шаги (сессия aq_data_layer)

1. Удалить `lib/repositories/repository.dart`
2. Удалить `lib/repositories/artifact_repository.dart`, `vector_repository.dart`, `knowledge_repository.dart`
3. Обновить реализации: `implements IArtifactRepository`, `IVectorRepository`, `IKnowledgeRepository`
4. Реализовать методы `artifacts()`, `vectors()`, `knowledge()` в `DataLayerImpl`
5. Написать `response.md` для TD-5

## Как использовать моки

```dart
import 'package:aq_schema/data_testing.dart';

// Пустое состояние
MockDataLayer.register(MockDataBackend.empty());

// Предзагруженные данные
MockDataLayer.register(MockDataBackend.withData(
  collection: WorkflowGraph.kCollection,
  entities: [graph1, graph2],
));

// IDataLayer.instance работает без сервера
final repo = IDataLayer.instance.versioned<WorkflowGraph>(
  collection: WorkflowGraph.kCollection,
  fromMap: WorkflowGraph.fromMap,
);
final graph = await repo.getCurrent(graphId); // ✅
```
