import 'storable.dart';
import 'direct_storable.dart';

final class VectorStoreRecord implements DirectStorable {
  static const kCollection = 'vector_stores';

  @override
  final String id;
  final String type; // 'in_memory' | 'pgvector' | 'qdrant'
  final String embedderId;
  final int vectorDim;
  final String metric;
  final Map<String, String> config; // public params only, no secrets
  final bool isActive;
  final DateTime createdAt;

  const VectorStoreRecord({
    required this.id,
    required this.type,
    required this.embedderId,
    required this.vectorDim,
    this.metric = 'cosine',
    this.config = const {},
    this.isActive = true,
    required this.createdAt,
  });

  @override
  String get collectionName => kCollection;

  @override
  Map<String, dynamic> get indexFields => {
        'type': type,
        'embedderId': embedderId,
        'isActive': isActive,
      };

  @override
  Map<String, dynamic> get jsonSchema => const {
        'type': 'object',
        'properties': {
          'id': {'type': 'string'},
          'type': {'type': 'string'},
          'embedderId': {'type': 'string'},
        },
        'required': ['id', 'type', 'embedderId'],
      };

  @override
  bool get softDelete => false;

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type,
        'embedderId': embedderId,
        'vectorDim': vectorDim,
        'metric': metric,
        if (config.isNotEmpty) 'config': config,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
      };

  factory VectorStoreRecord.fromMap(Map<String, dynamic> m) => VectorStoreRecord(
        id: m['id'] as String,
        type: m['type'] as String,
        embedderId: m['embedderId'] as String,
        vectorDim: m['vectorDim'] as int,
        metric: m['metric'] as String? ?? 'cosine',
        config: (m['config'] as Map<String, dynamic>?)
                ?.map((k, v) => MapEntry(k, v as String)) ??
            const {},
        isActive: m['isActive'] as bool? ?? true,
        createdAt: DateTime.parse(m['createdAt'] as String),
      );
}
