import 'storable.dart';
import 'direct_storable.dart';

final class IndexingPipelineRecord implements DirectStorable {
  static const kCollection = 'indexing_pipelines';

  @override
  final String id;
  final String name;
  final String extractorId;
  final String extractorVersion;
  final String? transformerId;
  final String? transformerVersion;
  final String chunkerId;
  final String chunkerVersion;
  final String embedderId;
  final String embedderVersion;
  final int vectorDim;
  final String metric;
  final String storeId;
  final bool isDefault;
  final DateTime createdAt;

  const IndexingPipelineRecord({
    required this.id,
    required this.name,
    required this.extractorId,
    required this.extractorVersion,
    this.transformerId,
    this.transformerVersion,
    required this.chunkerId,
    required this.chunkerVersion,
    required this.embedderId,
    required this.embedderVersion,
    required this.vectorDim,
    required this.metric,
    required this.storeId,
    this.isDefault = false,
    required this.createdAt,
  });

  @override
  String get collectionName => kCollection;

  @override
  Map<String, dynamic> get indexFields => {
        'name': name,
        'embedderId': embedderId,
        'storeId': storeId,
      };

  @override
  Map<String, dynamic> get jsonSchema => const {
        'type': 'object',
        'properties': {
          'id': {'type': 'string'},
          'name': {'type': 'string'},
          'embedderId': {'type': 'string'},
          'storeId': {'type': 'string'},
        },
        'required': ['id', 'name', 'embedderId', 'storeId'],
      };

  @override
  bool get softDelete => false;

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'extractorId': extractorId,
        'extractorVersion': extractorVersion,
        if (transformerId != null) 'transformerId': transformerId,
        if (transformerVersion != null) 'transformerVersion': transformerVersion,
        'chunkerId': chunkerId,
        'chunkerVersion': chunkerVersion,
        'embedderId': embedderId,
        'embedderVersion': embedderVersion,
        'vectorDim': vectorDim,
        'metric': metric,
        'storeId': storeId,
        'isDefault': isDefault,
        'createdAt': createdAt.toIso8601String(),
      };

  factory IndexingPipelineRecord.fromMap(Map<String, dynamic> m) =>
      IndexingPipelineRecord(
        id: m['id'] as String,
        name: m['name'] as String,
        extractorId: m['extractorId'] as String,
        extractorVersion: m['extractorVersion'] as String,
        transformerId: m['transformerId'] as String?,
        transformerVersion: m['transformerVersion'] as String?,
        chunkerId: m['chunkerId'] as String,
        chunkerVersion: m['chunkerVersion'] as String,
        embedderId: m['embedderId'] as String,
        embedderVersion: m['embedderVersion'] as String,
        vectorDim: m['vectorDim'] as int,
        metric: m['metric'] as String,
        storeId: m['storeId'] as String,
        isDefault: m['isDefault'] as bool? ?? false,
        createdAt: DateTime.parse(m['createdAt'] as String),
      );
}
