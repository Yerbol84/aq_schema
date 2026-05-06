import 'dart:math';
import 'package:aq_schema/aq_schema.dart';
import 'backend/mock_data_backend.dart';

final class InMemoryVectorRepository implements IVectorRepository {
  final MockDataBackend _backend;
  final String _collection;

  InMemoryVectorRepository({
    required MockDataBackend backend,
    required String collection,
  })  : _backend = backend,
        _collection = collection;

  List<VectorEntry> get _entries => _backend.vectorCollection(_collection);

  double _cosine(List<double> a, List<double> b) {
    if (a.isEmpty || b.isEmpty || a.length != b.length) return 0.0;
    double dot = 0, normA = 0, normB = 0;
    for (var i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }
    final denom = sqrt(normA) * sqrt(normB);
    return denom == 0 ? 0.0 : dot / denom;
  }

  @override
  Future<void> upsert(VectorEntry vectorEntry) async {
    _entries.removeWhere((e) => e.id == vectorEntry.id);
    _entries.add(vectorEntry);
  }

  @override
  Future<void> upsertAll(List<VectorEntry> vectorEntries) async {
    for (final e in vectorEntries) await upsert(e);
  }

  @override
  Future<void> delete(String id) async =>
      _entries.removeWhere((e) => e.id == id);

  @override
  Future<void> deleteWhere(VaultQuery vaultQuery) async {}

  @override
  Future<List<VectorSearchResult>> search(
    List<double> queryVector, {
    required String tenantId,
    int limit = 10,
    double scoreThreshold = 0.0,
    VaultQuery? filter,
    String? sparseQuery,
    double alpha = 1.0,
  }) async {
    final results = _entries
        .map((e) => VectorSearchResult(id: e.id, score: _cosine(queryVector, e.vector), payload: e.payload))
        .where((r) => r.score >= scoreThreshold)
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));
    return results.take(limit).toList();
  }

  @override
  Future<VectorEntry?> getById(String id) async =>
      _entries.where((e) => e.id == id).firstOrNull;

  @override
  Future<List<VectorEntry>> getAll({VaultQuery? filter}) async => List.of(_entries);

  @override
  Future<PageResult<VectorEntry>> getPage(VaultQuery vaultQuery) async {
    final offset = vaultQuery.offset ?? 0;
    final limit = vaultQuery.limit ?? _entries.length;
    return PageResult(
        items: _entries.skip(offset).take(limit).toList(),
        total: _entries.length,
        offset: offset,
        limit: limit);
  }

  @override
  Future<int> count({VaultQuery? filter}) async => _entries.length;
}
