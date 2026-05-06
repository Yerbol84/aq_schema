# Plan: Data Layer — архитектурные нарушения + моки

## Шаги

### Шаг 1: VectorStorable (нарушение 7)
Создать `aq_schema/lib/data_layer/storable/vector_storable.dart`
```dart
abstract interface class VectorStorable implements Storable {
  List<double> get vector;
  Map<String, dynamic> get payload;
}
```

### Шаг 2: KnowledgeDocument (нарушение 8)
Перенести из `aq_data_layer` в `aq_schema/lib/data_layer/storable/knowledge_document.dart`
Содержит: `KnowledgeDocument`, `KnowledgeSearchResult`, `DocumentChunk`, `TextSplitter`, `FixedSizeSplitter`, `EmbedFn`

### Шаг 3: IArtifactRepository (нарушение 1)
Создать `aq_schema/lib/data_layer/repositories/i_artifact_repository.dart`
Контракт из `aq_data_layer/lib/repositories/artifact_repository.dart`, переименовать в `IArtifactRepository<T extends ArtifactEntry>`

### Шаг 4: IVectorRepository (нарушение 2)
Создать `aq_schema/lib/data_layer/repositories/i_vector_repository.dart`
Контракт из `aq_data_layer/lib/repositories/vector_repository.dart`, переименовать в `IVectorRepository`

### Шаг 5: IKnowledgeRepository (нарушение 3)
Создать `aq_schema/lib/data_layer/repositories/i_knowledge_repository.dart`
Контракт из `aq_data_layer/lib/repositories/knowledge_repository.dart`, переименовать в `IKnowledgeRepository<T extends KnowledgeDocument>`

### Шаг 6: Расширить IDataLayer (нарушение 5)
Добавить в `aq_schema/lib/data_layer/i_data_layer.dart`:
```dart
IArtifactRepository<T> artifacts<T extends ArtifactEntry>({
  required String collection,
  required T Function(Map<String, dynamic>) fromMap,
});

IVectorRepository vectors({required String collection});

IKnowledgeRepository<T> knowledge<T extends KnowledgeDocument>({
  required String collection,
  required T Function(Map<String, dynamic>) fromMap,
  required EmbedFn embed,
});
```

### Шаг 7: MockDataBackend + MockDataLayer + 6 репозиториев (нарушение 6)

Структура:
```
aq_schema/lib/data_layer/mock/
├── backend/
│   ├── mock_data_backend.dart
│   └── mock_data_seed.dart
├── mock_data_layer.dart
├── in_memory_direct_repository.dart
├── in_memory_versioned_repository.dart
├── in_memory_logged_repository.dart
├── in_memory_artifact_repository.dart
├── in_memory_vector_repository.dart
├── in_memory_knowledge_repository.dart
└── mock.dart
```

`MockDataBackend` — единое хранилище:
- `Map<String, Map<String, Map<String, dynamic>>> store` — документы (collection → id → data)
- `Map<String, Map<String, List<int>>> artifacts` — байты (collection → id → bytes)
- `Map<String, List<VectorEntry>> vectors` — векторы (collection → entries)

Factory-сценарии: `empty()`, `withData(collection, entities)`

`MockDataLayer implements IDataLayer` — создаёт репозитории из backend, регистрируется через `IDataLayer.register(mockDataLayer)`

### Шаг 8: data_testing.dart barrel
```dart
export 'data_layer/mock/mock.dart';
```

### Шаг 9: dart analyze — 0 errors

### Шаг 10: report.md

## Критерии готовности (Definition of Done)
- `dart analyze aq_schema` → 0 errors, 0 warnings
- Все 8 нарушений устранены
- `import 'package:aq_schema/data_testing.dart'` даёт доступ ко всем мокам
- `MockDataLayer.register(MockDataBackend.empty())` → `IDataLayer.instance` работает без сервера
- `MockDataBackend.withData(collection, [entity])` → репозиторий возвращает предзагруженные данные
