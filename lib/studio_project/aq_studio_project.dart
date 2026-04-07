import 'package:aq_schema/aq_schema.dart';

/// AQ Studio project — top-level container.
/// DirectStorable: plain CRUD, no versioning needed.
class AqStudioProject implements DirectStorable, Sharable, Versionable {
  static const kCollection = 'projects';
  static const kSchemaVersion = '1.0.0';
  static const kJsonSchema = {
    'type': 'object',
    'properties': {
      'id': {'type': 'string', 'format': 'uuid'},
      'tenantId': {'type': 'string'},
      'ownerId': {'type': 'string'},
      'name': {'type': 'string'},
      'path': {'type': 'string'},
      'projectType': {'type': 'string'},
      'lastOpened': {'type': 'string', 'format': 'date-time'},
    },
    'required': ['id', 'tenantId', 'ownerId', 'name', 'projectType'],
  };

  @override
  final String id;

  @override
  final String tenantId;

  @override
  final String ownerId;

  @override
  String get collectionName => kCollection;

  @override
  String get schemaVersion => kSchemaVersion;

  @override
  List<Object> get migrations => const [];

  @override
  Map<String, dynamic> get jsonSchema => kJsonSchema;

  @override
  String get defaultSharingPolicy => 'private';

  final String name;
  final String path;
  final String projectType;
  final DateTime lastOpened;

  const AqStudioProject({
    required this.id,
    required this.tenantId,
    required this.ownerId,
    required this.name,
    required this.path,
    required this.projectType,
    required this.lastOpened,
  });

  factory AqStudioProject.create({
    required String id,
    required String tenantId,
    required String ownerId,
    required String name,
    required String projectType,
  }) =>
      AqStudioProject(
        id: id,
        tenantId: tenantId,
        ownerId: ownerId,
        name: name,
        path: '',
        projectType: projectType,
        lastOpened: DateTime.now(),
      );

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'tenantId': tenantId,
        'ownerId': ownerId,
        'name': name,
        'path': path,
        'projectType': projectType,
        'lastOpened': lastOpened.toIso8601String(),
      };

  @override
  Map<String, dynamic> get indexFields => {
        'projectType': projectType,
        'lastOpened': lastOpened.toIso8601String(),
      };

  static AqStudioProject fromMap(Map<String, dynamic> m) => AqStudioProject(
        id: m['id'] as String,
        tenantId: m['tenantId'] as String? ?? 'system',
        ownerId: m['ownerId'] as String? ?? '',
        name: m['name'] as String? ?? '',
        path: m['path'] as String? ?? '',
        projectType: m['projectType'] as String? ?? 'coder',
        lastOpened:
            DateTime.tryParse(m['lastOpened'] as String? ?? '') ?? DateTime.now(),
      );

  AqStudioProject copyWith({
    String? name,
    String? path,
    String? projectType,
    DateTime? lastOpened,
  }) =>
      AqStudioProject(
        id: id,
        tenantId: tenantId,
        ownerId: ownerId,
        name: name ?? this.name,
        path: path ?? this.path,
        projectType: projectType ?? this.projectType,
        lastOpened: lastOpened ?? this.lastOpened,
      );
}
