import 'storable.dart';
import 'logged_storable.dart';

enum AnnotationActorType {
  user('user'),
  llm('llm');

  const AnnotationActorType(this.value);
  final String value;

  static AnnotationActorType fromString(String s) =>
      AnnotationActorType.values.firstWhere((e) => e.value == s,
          orElse: () => AnnotationActorType.user);
}

enum AnnotationType {
  highlight('highlight'),   // выделение текста/области
  comment('comment'),       // комментарий
  label('label'),           // тег/метка
  vectorRef('vector_ref');  // ссылка на векторный чанк (LLM)

  const AnnotationType(this.value);
  final String value;

  static AnnotationType fromString(String s) =>
      AnnotationType.values.firstWhere((e) => e.value == s,
          orElse: () => AnnotationType.highlight);
}

/// Position within a document.
final class AnnotationRange {
  const AnnotationRange({
    this.page,
    required this.startOffset,
    required this.endOffset,
    this.xpath,
  });

  final int? page;          // для PDF
  final int startOffset;    // символьный offset
  final int endOffset;
  final String? xpath;      // для HTML/XML

  Map<String, dynamic> toMap() => {
        'startOffset': startOffset,
        'endOffset': endOffset,
        if (page != null) 'page': page,
        if (xpath != null) 'xpath': xpath,
      };

  factory AnnotationRange.fromMap(Map<String, dynamic> m) => AnnotationRange(
        startOffset: m['startOffset'] as int,
        endOffset: m['endOffset'] as int,
        page: m['page'] as int?,
        xpath: m['xpath'] as String?,
      );
}

/// Annotation on a document — user highlight, comment, or LLM-generated mark.
///
/// Stored as [LoggedStorable] — every change is audited and reversible.
/// This allows "undo LLM annotations" or "see annotation history".
final class DocumentAnnotation implements LoggedStorable {
  const DocumentAnnotation({
    required this.id,
    required this.tenantId,
    required this.ownerId,
    required this.artifactId,
    required this.actorType,
    required this.actorId,
    required this.type,
    required this.range,
    required this.createdAt,
    this.content,
    this.meta = const {},
    this.deletedAt,
  });

  @override
  final String id;
  final String tenantId;
  final String ownerId;
  final String artifactId;          // ссылка на StoredArtifact
  final AnnotationActorType actorType;
  final String actorId;             // userId или llm-model-id
  final AnnotationType type;
  final AnnotationRange range;
  final String? content;            // текст комментария
  final Map<String, dynamic> meta;  // для LLM: chunkId, score, query
  final DateTime createdAt;
  final DateTime? deletedAt;

  @override
  String get collectionName => kCollection;

  @override
  Set<String> get trackedFields => const {'content', 'meta', 'deletedAt'};

  @override
  Map<String, dynamic> get indexFields => {
        'artifactId': artifactId,
        'actorType': actorType.value,
        'type': type.value,
        'tenantId': tenantId,
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
        'artifactId': artifactId,
        'actorType': actorType.value,
        'actorId': actorId,
        'type': type.value,
        'range': range.toMap(),
        'createdAt': createdAt.toIso8601String(),
        if (content != null) 'content': content,
        if (meta.isNotEmpty) 'meta': meta,
        if (deletedAt != null) 'deletedAt': deletedAt!.toIso8601String(),
      };

  factory DocumentAnnotation.fromMap(Map<String, dynamic> m) =>
      DocumentAnnotation(
        id: m['id'] as String,
        tenantId: m['tenantId'] as String,
        ownerId: m['ownerId'] as String,
        artifactId: m['artifactId'] as String,
        actorType: AnnotationActorType.fromString(m['actorType'] as String),
        actorId: m['actorId'] as String,
        type: AnnotationType.fromString(m['type'] as String),
        range: AnnotationRange.fromMap(m['range'] as Map<String, dynamic>),
        createdAt: DateTime.parse(m['createdAt'] as String),
        content: m['content'] as String?,
        meta: m['meta'] as Map<String, dynamic>? ?? const {},
        deletedAt: m['deletedAt'] != null
            ? DateTime.parse(m['deletedAt'] as String)
            : null,
      );

  static const kCollection = 'document_annotations';

  static const kJsonSchema = {
    'type': 'object',
    'properties': {
      'id': {'type': 'string'},
      'tenantId': {'type': 'string'},
      'ownerId': {'type': 'string'},
      'artifactId': {'type': 'string'},
      'actorType': {'type': 'string'},
      'actorId': {'type': 'string'},
      'type': {'type': 'string'},
      'range': {'type': 'object'},
      'createdAt': {'type': 'string'},
    },
    'required': ['id', 'tenantId', 'ownerId', 'artifactId', 'actorType', 'actorId', 'type', 'range'],
  };
}
