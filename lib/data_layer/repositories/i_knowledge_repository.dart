import 'package:aq_schema/aq_schema.dart';

/// Repository that treats a file and its vector index as ONE entity.
abstract interface class IKnowledgeRepository<T extends KnowledgeDocument> {
  Future<void> save(T knowledgeDocument, List<int> fileBytes, {String? rawText});
  Future<void> reIndex(String documentId, String rawText);
  Future<void> delete(String documentId);

  Future<T?> findById(String documentId);
  Future<List<T>> findAll({VaultQuery? query});
  Future<PageResult<T>> findPage(VaultQuery vaultQuery);
  Future<List<int>?> loadBytes(String documentId);

  Future<List<KnowledgeSearchResult>> search(
    String query, {
    required EmbedFn embed,
    int limit = 10,
    double scoreThreshold = 0.3,
    VaultQuery? filter,
  });

  Stream<List<T>> watchAll({VaultQuery? query});
}
