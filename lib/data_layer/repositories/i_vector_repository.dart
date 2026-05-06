import 'package:aq_schema/aq_schema.dart';

/// Repository for vector embeddings with ANN search.
abstract interface class IVectorRepository {
  Future<void> upsert(VectorEntry vectorEntry);
  Future<void> upsertAll(List<VectorEntry> vectorEntries);
  Future<void> delete(String id);
  Future<void> deleteWhere(VaultQuery vaultQuery);

  Future<List<VectorSearchResult>> search(
    List<double> queryVector, {
    required String tenantId,
    int limit = 10,
    double scoreThreshold = 0.0,
    VaultQuery? filter,
    String? sparseQuery,
    double alpha = 1.0,
  });

  Future<VectorEntry?> getById(String id);
  Future<List<VectorEntry>> getAll({VaultQuery? filter});
  Future<PageResult<VectorEntry>> getPage(VaultQuery vaultQuery);
  Future<int> count({VaultQuery? filter});
}
