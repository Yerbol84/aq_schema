import 'chunk_span.dart';
import 'pipeline_stamp.dart';

/// Typed payload stored in every VectorEntry.
/// Provides tenancy, origin reference, position, and full lineage.
final class VectorPointPayload {
  final String tenantId;
  final String ownerId;
  final String artifactId;
  final String storeId;
  final String modality;
  final ChunkSpan span;
  final String text;
  final PipelineStamp stamp;

  const VectorPointPayload({
    required this.tenantId,
    required this.ownerId,
    required this.artifactId,
    required this.storeId,
    required this.modality,
    required this.span,
    required this.text,
    required this.stamp,
  });

  Map<String, dynamic> toMap() => {
        'tenantId': tenantId,
        'ownerId': ownerId,
        'artifactId': artifactId,
        'storeId': storeId,
        'modality': modality,
        'span': span.toMap(),
        'text': text,
        'stamp': stamp.toMap(),
      };

  factory VectorPointPayload.fromMap(Map<String, dynamic> m) =>
      VectorPointPayload(
        tenantId: m['tenantId'] as String,
        ownerId: m['ownerId'] as String,
        artifactId: m['artifactId'] as String,
        storeId: m['storeId'] as String,
        modality: m['modality'] as String,
        span: ChunkSpan.fromMap(m['span'] as Map<String, dynamic>),
        text: m['text'] as String,
        stamp: PipelineStamp.fromMap(m['stamp'] as Map<String, dynamic>),
      );
}
