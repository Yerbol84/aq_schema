import 'package:aq_schema/aq_schema.dart';

/// Единое in-memory состояние data layer для тестов.
///
/// Все моки репозиториев используют один экземпляр этого класса.
/// Изменение через один репозиторий видно через другой.
///
/// ```dart
/// final backend = MockDataBackend.empty();
/// MockDataLayer.register(backend);
///
/// // Предзагрузить данные:
/// final backend = MockDataBackend.withData(
///   collection: WorkflowGraph.kCollection,
///   entities: [graph1, graph2],
/// );
/// ```
final class MockDataBackend {
  MockDataBackend._();

  // ── Документы (Direct / Versioned / Logged) ────────────────────────────────
  // collection → id → data
  final Map<String, Map<String, Map<String, dynamic>>> store = {};

  // Versioned nodes: collection__nodes → nodeId → VersionNode.toMap()
  // Versioned meta:  collection__meta  → entityId → meta map

  // ── Артефакты ──────────────────────────────────────────────────────────────
  // collection → id → bytes
  final Map<String, Map<String, List<int>>> artifactBytes = {};

  // ── Векторы ────────────────────────────────────────────────────────────────
  // collection → list of VectorEntry
  final Map<String, List<VectorEntry>> vectors = {};

  // ── Сценарии ───────────────────────────────────────────────────────────────

  /// Пустое состояние.
  factory MockDataBackend.empty() => MockDataBackend._();

  /// Предзагрузить сущности в коллекцию.
  factory MockDataBackend.withData({
    required String collection,
    required List<Storable> entities,
  }) {
    final b = MockDataBackend._();
    b.store[collection] = {
      for (final e in entities) e.id: e.toMap(),
    };
    return b;
  }

  // ── Вспомогательные методы ─────────────────────────────────────────────────

  Map<String, Map<String, dynamic>> collectionStore(String collection) =>
      store.putIfAbsent(collection, () => {});

  List<VectorEntry> vectorCollection(String collection) =>
      vectors.putIfAbsent(collection, () => []);

  Map<String, List<int>> artifactCollection(String collection) =>
      artifactBytes.putIfAbsent(collection, () => {});
}
