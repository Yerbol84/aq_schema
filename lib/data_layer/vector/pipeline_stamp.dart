/// Full data lineage record written into every VectorPoint payload.
/// Allows filtering compatible chunks and reproducing/migrating the pipeline.
final class PipelineStamp {
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
  final DateTime indexedAt;

  const PipelineStamp({
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
    required this.indexedAt,
  });

  Map<String, dynamic> toMap() => {
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
        'indexedAt': indexedAt.toIso8601String(),
      };

  factory PipelineStamp.fromMap(Map<String, dynamic> m) => PipelineStamp(
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
        indexedAt: DateTime.parse(m['indexedAt'] as String),
      );
}
