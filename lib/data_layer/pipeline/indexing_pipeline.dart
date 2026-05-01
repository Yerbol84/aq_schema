import '../vector/pipeline_stamp.dart';
import 'i_chunker.dart';
import 'i_content_extractor.dart';
import 'i_embeddings_client.dart';
import 'i_modality_transformer.dart';
import 'i_reranker.dart';

final class IndexingPipeline {
  final String id;
  final String storeId;
  final IContentExtractor extractor;
  final IModalityTransformer? transformer;
  final IChunker chunker;
  final IEmbeddingsClient embedder;
  final IReranker reranker;

  const IndexingPipeline({
    required this.id,
    required this.storeId,
    required this.extractor,
    required this.chunker,
    required this.embedder,
    required this.reranker,
    this.transformer,
  });

  PipelineStamp buildStamp() => PipelineStamp(
        extractorId: extractor.id,
        extractorVersion: extractor.version,
        transformerId: transformer?.id,
        transformerVersion: transformer?.version,
        chunkerId: chunker.id,
        chunkerVersion: chunker.version,
        embedderId: embedder.id,
        embedderVersion: embedder.version,
        vectorDim: embedder.dimensions,
        metric: embedder.defaultMetric,
        indexedAt: DateTime.now().toUtc(),
      );
}
