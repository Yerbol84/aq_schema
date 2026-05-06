import 'artifact_entry.dart';

/// A knowledge document — simultaneously a file and a set of vector chunks.
abstract interface class KnowledgeDocument implements ArtifactEntry {
  /// Knowledge base this document belongs to.
  String get knowledgeBaseId;

  /// Whether the vector index is current.
  bool get vectorsUpToDate;

  /// Number of indexed vector chunks.
  int get chunkCount;
}

/// Result of a semantic search across a knowledge base.
final class KnowledgeSearchResult {
  final String documentId;
  final String documentName;
  final String chunkId;
  final int chunkIndex;
  final String chunkText;
  final double score;

  const KnowledgeSearchResult({
    required this.documentId,
    required this.documentName,
    required this.chunkId,
    required this.chunkIndex,
    required this.chunkText,
    required this.score,
  });
}

/// A chunk produced by the splitter, ready for embedding.
final class DocumentChunk {
  final int index;
  final String text;
  const DocumentChunk({required this.index, required this.text});
}

/// Strategy for splitting document text into chunks.
abstract interface class ITextSplitter {
  List<DocumentChunk> split(String text);
}

/// Simple fixed-size splitter (characters, with overlap).
final class FixedSizeSplitter implements ITextSplitter {
  final int chunkSize;
  final int overlap;

  const FixedSizeSplitter({this.chunkSize = 512, this.overlap = 64});

  @override
  List<DocumentChunk> split(String text) {
    if (text.isEmpty) return [];
    final chunks = <DocumentChunk>[];
    var start = 0;
    var index = 0;
    while (start < text.length) {
      final end = (start + chunkSize).clamp(0, text.length);
      chunks.add(DocumentChunk(index: index++, text: text.substring(start, end)));
      start += chunkSize - overlap;
      if (start >= text.length) break;
    }
    return chunks;
  }
}

/// Embed function type — produce a vector for a text chunk.
typedef EmbedFn = Future<List<double>> Function(String text);
