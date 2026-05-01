/// Position of a chunk within its source document.
/// Fields are modality-specific — only chunkIndex is always present.
final class ChunkSpan {
  final int chunkIndex;
  final int? startOffset;   // text: char offset
  final int? endOffset;
  final double? startTime;  // audio/video: seconds
  final double? endTime;
  final int? pageNumber;    // PDF
  final int? frameIndex;    // video

  const ChunkSpan({
    required this.chunkIndex,
    this.startOffset,
    this.endOffset,
    this.startTime,
    this.endTime,
    this.pageNumber,
    this.frameIndex,
  });

  Map<String, dynamic> toMap() => {
        'chunkIndex': chunkIndex,
        if (startOffset != null) 'startOffset': startOffset,
        if (endOffset != null) 'endOffset': endOffset,
        if (startTime != null) 'startTime': startTime,
        if (endTime != null) 'endTime': endTime,
        if (pageNumber != null) 'pageNumber': pageNumber,
        if (frameIndex != null) 'frameIndex': frameIndex,
      };

  factory ChunkSpan.fromMap(Map<String, dynamic> m) => ChunkSpan(
        chunkIndex: m['chunkIndex'] as int,
        startOffset: m['startOffset'] as int?,
        endOffset: m['endOffset'] as int?,
        startTime: (m['startTime'] as num?)?.toDouble(),
        endTime: (m['endTime'] as num?)?.toDouble(),
        pageNumber: m['pageNumber'] as int?,
        frameIndex: m['frameIndex'] as int?,
      );
}
