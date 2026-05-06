import 'dart:async';
import 'package:aq_schema/aq_schema.dart';
import 'backend/mock_data_backend.dart';

final class InMemoryArtifactRepository<T extends ArtifactEntry>
    implements IArtifactRepository<T> {
  final MockDataBackend _backend;
  final String _collection;
  final T Function(Map<String, dynamic>) _fromMap;
  final _controller = StreamController<List<T>>.broadcast();

  InMemoryArtifactRepository({
    required MockDataBackend backend,
    required String collection,
    required T Function(Map<String, dynamic>) fromMap,
  })  : _backend = backend,
        _collection = collection,
        _fromMap = fromMap;

  Map<String, Map<String, dynamic>> get _meta =>
      _backend.collectionStore(_collection);
  Map<String, List<int>> get _bytes =>
      _backend.artifactCollection(_collection);

  @override
  Future<void> save(T entry, List<int> bytes) async {
    _meta[entry.id] = entry.toMap();
    _bytes[entry.id] = bytes;
    _controller.add(await findAll());
  }

  @override
  Future<void> delete(String id) async {
    _meta.remove(id);
    _bytes.remove(id);
    _controller.add(await findAll());
  }

  @override
  Future<List<int>?> loadBytes(String id) async => _bytes[id];

  @override
  Stream<List<int>> streamBytes(String id) async* {
    final bytes = _bytes[id];
    if (bytes != null) yield bytes;
  }

  @override
  Future<T?> findById(String id) async {
    final data = _meta[id];
    return data == null ? null : _fromMap(data);
  }

  @override
  Future<List<T>> findAll({VaultQuery? query}) async =>
      _meta.values.map(_fromMap).toList();

  @override
  Future<PageResult<T>> findPage(VaultQuery query) async {
    final all = _meta.values.map(_fromMap).toList();
    final offset = query.offset ?? 0;
    final limit = query.limit ?? all.length;
    return PageResult(
        items: all.skip(offset).take(limit).toList(),
        total: all.length,
        offset: offset,
        limit: limit);
  }

  @override
  Future<bool> exists(String id) async => _meta.containsKey(id);

  @override
  Stream<List<T>> watchAll({VaultQuery? query}) => _controller.stream;
}
