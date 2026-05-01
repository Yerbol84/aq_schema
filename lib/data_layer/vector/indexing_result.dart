import 'pipeline_stamp.dart';

/// Result returned by VectorRepository.index() / reindex().
final class IndexingResult {
  final String artifactId;
  final int chunksCreated;
  final Duration elapsed;
  final PipelineStamp stamp;
  final String? error; // null on success

  const IndexingResult({
    required this.artifactId,
    required this.chunksCreated,
    required this.elapsed,
    required this.stamp,
    this.error,
  });

  bool get isSuccess => error == null;
}
