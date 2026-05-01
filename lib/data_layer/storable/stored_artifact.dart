import 'storable.dart';
import 'direct_storable.dart';
import 'artifact_entry.dart';

enum IndexingStatus { none, pending, indexing, indexed, failed, stale }

/// Concrete implementation of [ArtifactEntry].
/// Stores file metadata + indexing status in VaultStorage (Direct mode).
final class StoredArtifact implements ArtifactEntry {
  const StoredArtifact({
    required this.id,
    required this.tenantId,
    required this.ownerId,
    required this.storageKey,
    required this.fileName,
    required this.contentType,
    required this.sizeBytes,
    required this.checksum,
    required this.createdAt,
    this.meta = const {},
    this.deletedAt,
    this.indexingStatus = IndexingStatus.none,
    this.indexingError,
    this.indexedStoreId,
    this.chunkCount,
    this.indexedAt,
  });

  @override
  final String id;
  final String tenantId;
  final String ownerId;
  @override
  final String storageKey;
  @override
  final String fileName;
  @override
  final String contentType;
  @override
  final int sizeBytes;
  @override
  final String checksum;
  @override
  final DateTime createdAt;
  @override
  final Map<String, String> meta;
  final DateTime? deletedAt;

  // Indexing state
  final IndexingStatus indexingStatus;
  final String? indexingError;
  final String? indexedStoreId;
  final int? chunkCount;
  final DateTime? indexedAt;

  StoredArtifact copyWith({
    IndexingStatus? indexingStatus,
    String? indexingError,
    String? indexedStoreId,
    int? chunkCount,
    DateTime? indexedAt,
  }) =>
      StoredArtifact(
        id: id,
        tenantId: tenantId,
        ownerId: ownerId,
        storageKey: storageKey,
        fileName: fileName,
        contentType: contentType,
        sizeBytes: sizeBytes,
        checksum: checksum,
        createdAt: createdAt,
        meta: meta,
        deletedAt: deletedAt,
        indexingStatus: indexingStatus ?? this.indexingStatus,
        indexingError: indexingError ?? this.indexingError,
        indexedStoreId: indexedStoreId ?? this.indexedStoreId,
        chunkCount: chunkCount ?? this.chunkCount,
        indexedAt: indexedAt ?? this.indexedAt,
      );

  @override
  String get collectionName => kCollection;

  @override
  Map<String, dynamic> get indexFields => {
        'fileName': fileName,
        'contentType': contentType,
        'ownerId': ownerId,
        'tenantId': tenantId,
        'indexingStatus': indexingStatus.name,
      };

  @override
  Map<String, dynamic> get jsonSchema => kJsonSchema;

  @override
  bool get softDelete => true;

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'tenantId': tenantId,
        'ownerId': ownerId,
        'storageKey': storageKey,
        'fileName': fileName,
        'contentType': contentType,
        'sizeBytes': sizeBytes,
        'checksum': checksum,
        'createdAt': createdAt.toIso8601String(),
        if (deletedAt != null) 'deletedAt': deletedAt!.toIso8601String(),
        if (meta.isNotEmpty) 'meta': meta,
        'indexingStatus': indexingStatus.name,
        if (indexingError != null) 'indexingError': indexingError,
        if (indexedStoreId != null) 'indexedStoreId': indexedStoreId,
        if (chunkCount != null) 'chunkCount': chunkCount,
        if (indexedAt != null) 'indexedAt': indexedAt!.toIso8601String(),
      };

  factory StoredArtifact.fromMap(Map<String, dynamic> m) => StoredArtifact(
        id: m['id'] as String,
        tenantId: m['tenantId'] as String,
        ownerId: m['ownerId'] as String,
        storageKey: m['storageKey'] as String,
        fileName: m['fileName'] as String,
        contentType: m['contentType'] as String,
        sizeBytes: m['sizeBytes'] as int,
        checksum: m['checksum'] as String,
        createdAt: DateTime.parse(m['createdAt'] as String),
        deletedAt: m['deletedAt'] != null
            ? DateTime.parse(m['deletedAt'] as String)
            : null,
        meta: (m['meta'] as Map<String, dynamic>?)
                ?.map((k, v) => MapEntry(k, v as String)) ??
            const {},
        indexingStatus: IndexingStatus.values.byName(
          m['indexingStatus'] as String? ?? 'none',
        ),
        indexingError: m['indexingError'] as String?,
        indexedStoreId: m['indexedStoreId'] as String?,
        chunkCount: m['chunkCount'] as int?,
        indexedAt: m['indexedAt'] != null
            ? DateTime.parse(m['indexedAt'] as String)
            : null,
      );

  static const kCollection = 'artifacts';

  static const kJsonSchema = {
    'type': 'object',
    'properties': {
      'id': {'type': 'string'},
      'tenantId': {'type': 'string'},
      'ownerId': {'type': 'string'},
      'storageKey': {'type': 'string'},
      'fileName': {'type': 'string'},
      'contentType': {'type': 'string'},
      'sizeBytes': {'type': 'integer'},
      'checksum': {'type': 'string'},
      'createdAt': {'type': 'string'},
      'indexingStatus': {'type': 'string'},
    },
    'required': ['id', 'tenantId', 'ownerId', 'storageKey', 'fileName', 'contentType'],
  };
}
