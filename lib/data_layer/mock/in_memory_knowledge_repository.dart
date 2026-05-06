import 'dart:async';
import 'package:aq_schema/aq_schema.dart';
import 'backend/mock_data_backend.dart';
import 'in_memory_artifact_repository.dart';
import 'in_memory_vector_repository.dart';

final class InMemoryKnowledgeRepository<T extends KnowledgeDocument>
    implements IKnowledgeRepository<T> {
  final InMemoryArtifactRepository<T> _artifacts;
  final InMemoryVectorRepository _vectors;
  final String _collection;

  InMemoryKnowledgeRepository({
    required MockDataBackend backend,
    required String collection,
    required T Function(Map<String, dynamic>) fromMap,
  })  : _collection = collection,
        _artifacts = InMemoryArtifactRepository(backend: backend, collection: collection, fromMap: fromMap),
        _vectors = InMemoryVectorRepository(backend: backend, collection: '${collection}__vectors');

  @override
  Future<void> save(T knowledgeDocument, List<int> fileBytes, {String? rawText}) async {
    await _artifacts.save(knowledgeDocument, fileBytes);
    if (rawText != null) {
      // Simple chunking for mock: one chunk per 500 chars
      final splitter = FixedSizeSplitter(chunkSize: 500, overlap: 50);
      final chunks = splitter.split(rawText);
      for (final chunk in chunks) {
        // Mock embedding: zero vector of length 4
        await _vectors.upsert(VectorEntry(
          id: '${knowledgeDocument.id}__chunk${chunk.index}',
          vector: List.filled(4, 0.0),
          payload: {'docId': knowledgeDocument.id, 'chunkIndex': chunk.index, 'text': chunk.text},
        ));
      }
    }
  }

  @override
  Future<void> reIndex(String documentId, String rawText) async {
    await _vectors.deleteWhere(VaultQuery());
    final doc = await findById(documentId);
    if (doc == null) return;
    await save(doc, [], rawText: rawText);
  }

  @override
  Future<void> delete(String documentId) async {
    await _artifacts.delete(documentId);
    await _vectors.deleteWhere(VaultQuery());
  }

  @override
  Future<T?> findById(String documentId) => _artifacts.findById(documentId);

  @override
  Future<List<T>> findAll({VaultQuery? query}) => _artifacts.findAll(query: query);

  @override
  Future<PageResult<T>> findPage(VaultQuery vaultQuery) => _artifacts.findPage(vaultQuery);

  @override
  Future<List<int>?> loadBytes(String documentId) => _artifacts.loadBytes(documentId);

  @override
  Future<List<KnowledgeSearchResult>> search(
    String query, {
    required EmbedFn embed,
    int limit = 10,
    double scoreThreshold = 0.3,
    VaultQuery? filter,
  }) async {
    final queryVector = await embed(query);
    final results = await _vectors.search(queryVector, tenantId: '', limit: limit, scoreThreshold: scoreThreshold);
    return results.map((r) => KnowledgeSearchResult(
      documentId: r.payload['docId'] as String? ?? '',
      documentName: r.payload['docId'] as String? ?? '',
      chunkId: r.id,
      chunkIndex: r.payload['chunkIndex'] as int? ?? 0,
      chunkText: r.payload['text'] as String? ?? '',
      score: r.score,
    )).toList();
  }

  @override
  Stream<List<T>> watchAll({VaultQuery? query}) => _artifacts.watchAll(query: query);
}
