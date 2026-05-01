import '../vector/content_chunk.dart';
import '../vector/extracted_content.dart';

abstract interface class IChunker {
  String get id;
  String get version;

  List<ContentChunk> chunk(ExtractedContent content);
}
