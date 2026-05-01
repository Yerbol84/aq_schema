import '../vector/extracted_content.dart';

abstract interface class IContentExtractor {
  String get id;
  String get version;
  Set<String> get supportedContentTypes;

  Future<ExtractedContent> extract(
    List<int> bytes,
    String contentType,
    Map<String, dynamic> meta,
  );
}
