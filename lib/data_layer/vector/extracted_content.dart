/// Result of extracting content from a file.
/// In-memory only — never stored in DB.
final class ExtractedContent {
  final String artifactId;
  final String tenantId;
  final String ownerId;
  final String modality; // 'text' | 'image' | 'audio' | 'video'
  final String text;
  final Map<String, dynamic> meta;

  const ExtractedContent({
    required this.artifactId,
    required this.tenantId,
    required this.ownerId,
    required this.modality,
    required this.text,
    this.meta = const {},
  });
}
