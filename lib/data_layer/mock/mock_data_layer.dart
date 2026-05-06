import 'package:aq_schema/aq_schema.dart';
import 'backend/mock_data_backend.dart';
import 'in_memory_direct_repository.dart';
import 'in_memory_versioned_repository.dart';
import 'in_memory_logged_repository.dart';
import 'in_memory_artifact_repository.dart';
import 'in_memory_vector_repository.dart';
import 'in_memory_knowledge_repository.dart';

/// Mock реализация IDataLayer для тестов.
///
/// Работает без сервера, без PostgreSQL, без dart_vault.
///
/// ```dart
/// // Пустое состояние
/// MockDataLayer.register(MockDataBackend.empty());
///
/// // Предзагруженные данные
/// MockDataLayer.register(MockDataBackend.withData(
///   collection: WorkflowGraph.kCollection,
///   entities: [graph1, graph2],
/// ));
///
/// // Использование
/// final repo = IDataLayer.instance.versioned<WorkflowGraph>(...);
/// final graph = await repo.getCurrent(graphId); // ✅ без сервера
/// ```
final class MockDataLayer implements IDataLayer {
  final MockDataBackend _backend;

  MockDataLayer(this._backend);

  /// Зарегистрировать MockDataLayer как IDataLayer.instance.
  static void register(MockDataBackend backend) {
    if (IDataLayer.isInitialized) {
      IDataLayer.disconnect();
    }
    IDataLayer.register(MockDataLayer(backend));
  }

  @override
  DirectRepository<T> direct<T extends DirectStorable>({
    required String collection,
    required T Function(Map<String, dynamic>) fromMap,
    List<VaultIndex> indexes = const [],
  }) =>
      InMemoryDirectRepository(backend: _backend, collection: collection, fromMap: fromMap);

  @override
  VersionedRepository<T> versioned<T extends VersionedStorable>({
    required String collection,
    required T Function(Map<String, dynamic>) fromMap,
    List<VaultIndex> indexes = const [],
  }) =>
      InMemoryVersionedRepository(backend: _backend, collection: collection, fromMap: fromMap);

  @override
  LoggedRepository<T> logged<T extends LoggedStorable>({
    required String collection,
    required T Function(Map<String, dynamic>) fromMap,
    List<VaultIndex> indexes = const [],
    bool captureFullSnapshot = false,
  }) =>
      InMemoryLoggedRepository(backend: _backend, collection: collection, fromMap: fromMap);

  @override
  IArtifactRepository<T> artifacts<T extends ArtifactEntry>({
    required String collection,
    required T Function(Map<String, dynamic>) fromMap,
  }) =>
      InMemoryArtifactRepository(backend: _backend, collection: collection, fromMap: fromMap);

  @override
  IVectorRepository vectors({required String collection}) =>
      InMemoryVectorRepository(backend: _backend, collection: collection);

  @override
  IKnowledgeRepository<T> knowledge<T extends KnowledgeDocument>({
    required String collection,
    required T Function(Map<String, dynamic>) fromMap,
    required EmbedFn embed,
  }) =>
      InMemoryKnowledgeRepository(backend: _backend, collection: collection, fromMap: fromMap);

  @override
  IBufferedStorage? get buffer => null;

  @override
  String get tenantId => 'mock-tenant';

  @override
  String get endpoint => 'mock://in-memory';

  @override
  String? get serverVersion => '0.0.0-mock';

  @override
  bool get isConnected => true;

  @override
  Future<void> dispose() async {}
}
