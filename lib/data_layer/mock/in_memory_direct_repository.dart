import 'dart:async';
import 'package:aq_schema/aq_schema.dart';
import 'backend/mock_data_backend.dart';

final class InMemoryDirectRepository<T extends DirectStorable>
    implements DirectRepository<T> {
  final MockDataBackend _backend;
  final String _collection;
  final T Function(Map<String, dynamic>) _fromMap;
  final _controller = StreamController<List<T>>.broadcast();

  InMemoryDirectRepository({
    required MockDataBackend backend,
    required String collection,
    required T Function(Map<String, dynamic>) fromMap,
  })  : _backend = backend,
        _collection = collection,
        _fromMap = fromMap;

  Map<String, Map<String, dynamic>> get _store =>
      _backend.collectionStore(_collection);

  void _notify() => _controller.add(_all());

  List<T> _all() => _store.values
      .where((m) => m['deletedAt'] == null)
      .map(_fromMap)
      .toList();

  @override
  Future<void> save(T entity) async {
    _store[entity.id] = entity.toMap();
    _notify();
  }

  @override
  Future<void> saveAll(List<T> entities) async {
    for (final e in entities) {
      _store[e.id] = e.toMap();
    }
    _notify();
  }

  @override
  Future<void> delete(String id) async {
    final data = _store[id];
    if (data == null) return;
    final entity = _fromMap(data);
    if (entity.softDelete) {
      _store[id] = {...data, 'deletedAt': DateTime.now().toIso8601String()};
    } else {
      _store.remove(id);
    }
    _notify();
  }

  @override
  Future<void> restore(String id) async {
    final data = _store[id];
    if (data == null) return;
    _store[id] = {...data, 'deletedAt': null};
    _notify();
  }

  @override
  Future<T?> findById(String id) async {
    final data = _store[id];
    if (data == null || data['deletedAt'] != null) return null;
    return _fromMap(data);
  }

  @override
  Future<List<T>> findAll({VaultQuery? query}) async => _all();

  @override
  Future<List<T>> findAllIncludingDeleted({VaultQuery? query}) async =>
      _store.values.map(_fromMap).toList();

  @override
  Future<bool> exists(String id) async =>
      _store.containsKey(id) && _store[id]!['deletedAt'] == null;

  @override
  Future<int> count({VaultQuery? query}) async => _all().length;

  @override
  Future<PageResult<T>> findPage(VaultQuery query) async {
    final all = _all();
    final offset = query.offset ?? 0;
    final limit = query.limit ?? all.length;
    return PageResult(
        items: all.skip(offset).take(limit).toList(),
        total: all.length,
        offset: offset,
        limit: limit);
  }

  @override
  Future<void> registerIndex(VaultIndex index) async {}

  @override
  Stream<List<T>> watchAll({VaultQuery? query}) => _controller.stream;
}
