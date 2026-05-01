import '../storage/vector_storage.dart';

abstract interface class IReranker {
  String get id;

  Future<List<VectorSearchResult>> rerank(
    String query,
    List<VectorSearchResult> candidates,
  );
}
