import '../storage/vector_storage.dart';

final class VectorStoreDescriptor {
  final String id;
  final String type; // 'in_memory' | 'pgvector' | 'qdrant'
  final String embedderId;
  final int vectorDim;
  final String metric;
  final bool isDefault;

  const VectorStoreDescriptor({
    required this.id,
    required this.type,
    required this.embedderId,
    required this.vectorDim,
    this.metric = 'cosine',
    this.isDefault = false,
  });
}

abstract interface class IVectorStoreRegistry {
  void register(VectorStoreDescriptor descriptor, VectorStorage storage);
  VectorStorage resolve(String storeId);
  VectorStoreDescriptor descriptor(String storeId);
  List<VectorStoreDescriptor> get all;
  VectorStoreDescriptor? findCompatible(String embedderId, int vectorDim);
}
