import 'dart:async';
import 'package:aq_schema/aq_schema.dart';
import 'backend/mock_data_backend.dart';

final class InMemoryLoggedRepository<T extends LoggedStorable>
    implements LoggedRepository<T> {
  final MockDataBackend _backend;
  final String _collection;
  final T Function(Map<String, dynamic>) _fromMap;
  final _entityController = StreamController<List<T>>.broadcast();
  final _logController = StreamController<List<LogEntry>>.broadcast();

  InMemoryLoggedRepository({
    required MockDataBackend backend,
    required String collection,
    required T Function(Map<String, dynamic>) fromMap,
  })  : _backend = backend,
        _collection = collection,
        _fromMap = fromMap;

  String get _logCol => '${_collection}__log';

  Map<String, Map<String, dynamic>> get _store =>
      _backend.collectionStore(_collection);
  Map<String, Map<String, dynamic>> get _log =>
      _backend.collectionStore(_logCol);

  int _seq = 0;
  String _id() => '${DateTime.now().microsecondsSinceEpoch}-${_seq++}';

  void _notifyEntities() =>
      _entityController.add(_store.values.map(_fromMap).toList());

  void _writeLog(String entityId, String actorId, LogOperation operation,
      Map<String, dynamic> data) {
    final entryId = _id();
    _log[entryId] = LogEntry(
      entryId: entryId,
      entityId: entityId,
      collectionId: _collection,
      changedBy: actorId,
      changedAt: DateTime.now(),
      operation: operation,
      snapshot: data,
    ).toMap();
    _logController.add(_log.values.map(LogEntry.fromMap).toList());
  }

  @override
  Future<void> save(T entity, {required String actorId}) async {
    final existing = _store[entity.id];
    _store[entity.id] = entity.toMap();
    _writeLog(entity.id, actorId,
        existing == null ? LogOperation.created : LogOperation.updated,
        entity.toMap());
    _notifyEntities();
  }

  @override
  Future<void> delete(String entityId, {required String actorId}) async {
    final data = _store[entityId];
    if (data == null) return;
    final entity = _fromMap(data);
    if (entity.softDelete) {
      _store[entityId] = {...data, 'deletedAt': DateTime.now().toIso8601String()};
    } else {
      _store.remove(entityId);
    }
    _writeLog(entityId, actorId, LogOperation.deleted, data);
    _notifyEntities();
  }

  @override
  Future<void> restore(String entityId, {required String actorId}) async {
    final data = _store[entityId];
    if (data == null) return;
    _store[entityId] = {...data, 'deletedAt': null};
    _writeLog(entityId, actorId, LogOperation.updated, _store[entityId]!);
    _notifyEntities();
  }

  @override
  Future<T?> findById(String id) async {
    final data = _store[id];
    if (data == null || data['deletedAt'] != null) return null;
    return _fromMap(data);
  }

  @override
  Future<List<T>> findAll({VaultQuery? query}) async =>
      _store.values.where((m) => m['deletedAt'] == null).map(_fromMap).toList();

  @override
  Future<List<T>> findAllIncludingDeleted({VaultQuery? query}) async =>
      _store.values.map(_fromMap).toList();

  @override
  Future<bool> exists(String id) async =>
      _store.containsKey(id) && _store[id]!['deletedAt'] == null;

  @override
  Future<int> count({VaultQuery? query}) async =>
      _store.values.where((m) => m['deletedAt'] == null).length;

  @override
  Future<PageResult<T>> findPage(VaultQuery query) async {
    final all = _store.values
        .where((m) => m['deletedAt'] == null)
        .map(_fromMap)
        .toList();
    final offset = query.offset ?? 0;
    final limit = query.limit ?? all.length;
    return PageResult(
        items: all.skip(offset).take(limit).toList(),
        total: all.length,
        offset: offset,
        limit: limit);
  }

  @override
  Future<List<LogEntry>> getHistory(String entityId) async {
    return _log.values
        .map(LogEntry.fromMap)
        .where((e) => e.entityId == entityId)
        .toList()
      ..sort((a, b) => a.changedAt.compareTo(b.changedAt));
  }

  @override
  Future<List<LogEntry>> queryHistory(String entityId, VaultQuery query) =>
      getHistory(entityId);

  @override
  Future<PageResult<LogEntry>> getHistoryPage(
      String entityId, VaultQuery query) async {
    final all = await getHistory(entityId);
    final offset = query.offset ?? 0;
    final limit = query.limit ?? all.length;
    return PageResult(
        items: all.skip(offset).take(limit).toList(),
        total: all.length,
        offset: offset,
        limit: limit);
  }

  @override
  Future<T?> getStateAt(String entityId, DateTime moment) async {
    final entries = (await getHistory(entityId))
        .where((e) => e.changedAt.isBefore(moment))
        .toList();
    if (entries.isEmpty) return null;
    final snap = entries.last.snapshot;
    return snap == null ? null : _fromMap(snap);
  }

  @override
  Future<LogEntry?> getLastEntry(String entityId) async {
    final history = await getHistory(entityId);
    return history.isEmpty ? null : history.last;
  }

  @override
  Future<List<LogEntry>> getCollectionLog({DateTime? from, DateTime? to}) async {
    return _log.values.map(LogEntry.fromMap).where((e) {
      if (from != null && e.changedAt.isBefore(from)) return false;
      if (to != null && e.changedAt.isAfter(to)) return false;
      return true;
    }).toList();
  }

  @override
  Future<void> rollbackTo(String entityId, String entryId,
      {required String actorId}) async {
    final entry = LogEntry.fromMap(_log[entryId]!);
    if (entry.snapshot == null) return;
    final entity = _fromMap(entry.snapshot!);
    await save(entity, actorId: actorId);
  }

  @override
  Future<void> registerIndex(VaultIndex index) async {}

  @override
  Stream<List<LogEntry>> watchHistory(String entityId) =>
      _logController.stream.map(
          (entries) => entries.where((e) => e.entityId == entityId).toList());

  @override
  Stream<List<T>> watchAll({VaultQuery? query}) => _entityController.stream;
}
