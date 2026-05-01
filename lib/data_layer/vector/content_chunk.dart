import 'chunk_span.dart';

/// A single chunk produced by IChunker. In-memory only.
final class ContentChunk {
  final String artifactId;
  final String text;
  final ChunkSpan span;

  const ContentChunk({
    required this.artifactId,
    required this.text,
    required this.span,
  });
}
