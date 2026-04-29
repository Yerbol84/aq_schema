// aq_schema/lib/subject/models/subject_metadata.dart
//
// Метаданные Subject — идентификация и описание.
//
// Содержит информацию О Subject, но не КАК его запускать (это в SubjectSpec).

/// Метаданные Subject.
///
/// Идентификация, версия, описание, флаги.
final class SubjectMetadata {
  static final _SubjectMetadataKeys _keys = _SubjectMetadataKeys._();
  static _SubjectMetadataKeys get keys => _keys;

  /// Имя Subject (уникально в namespace).
  ///
  /// Формат: kebab-case, только [a-z0-9-]
  /// Примеры: "my-agent", "code-analyzer", "llm-orchestrator"
  final String name;

  /// Namespace (workspace или user).
  ///
  /// Формат: "user/{userId}" или "workspace/{workspaceId}"
  /// Примеры: "user/john", "workspace/team-backend"
  final String namespace;

  /// Версия Subject (semver).
  ///
  /// Формат: "major.minor.patch"
  /// Примеры: "1.0.0", "2.1.3"
  final String version;

  /// Человекочитаемое описание.
  final String? description;

  /// Метки для категоризации.
  ///
  /// Примеры: {"team": "backend", "env": "production"}
  final Map<String, String> labels;

  /// Флаг: доступен ли Subject как Tool.
  ///
  /// Если true — автоматически создаётся ToolRecord при регистрации.
  /// Другие Subjects могут использовать этот Subject как Tool.
  final bool exposeAsTool;

  const SubjectMetadata({
    required this.name,
    required this.namespace,
    required this.version,
    this.description,
    this.labels = const {},
    this.exposeAsTool = false,
  });

  /// Полный идентификатор: "{namespace}/{name}".
  ///
  /// Используется как id в SubjectRecord (без версии).
  String get fullId => '$namespace/$name';

  Map<String, dynamic> toJson() => {
        SubjectMetadata.keys.name: name,
        SubjectMetadata.keys.namespace: namespace,
        SubjectMetadata.keys.version: version,
        if (description != null) SubjectMetadata.keys.description: description,
        if (labels.isNotEmpty) SubjectMetadata.keys.labels: labels,
        SubjectMetadata.keys.exposeAsTool: exposeAsTool,
      };

  factory SubjectMetadata.fromJson(Map<String, dynamic> json) =>
      SubjectMetadata(
        name: json[SubjectMetadata.keys.name] as String,
        namespace: json[SubjectMetadata.keys.namespace] as String,
        version: json[SubjectMetadata.keys.version] as String,
        description: json[SubjectMetadata.keys.description] as String?,
        labels: json[SubjectMetadata.keys.labels] != null
            ? Map<String, String>.from(
                json[SubjectMetadata.keys.labels] as Map)
            : const {},
        exposeAsTool:
            json[SubjectMetadata.keys.exposeAsTool] as bool? ?? false,
      );

  @override
  String toString() => 'SubjectMetadata($fullId@$version)';
}

class _SubjectMetadataKeys {
  _SubjectMetadataKeys._();

  final String name = 'name';
  final String namespace = 'namespace';
  final String version = 'version';
  final String description = 'description';
  final String labels = 'labels';
  final String exposeAsTool = 'expose_as_tool';

  List<String> get all =>
      [name, namespace, version, description, labels, exposeAsTool];
  Set<String> get required => {name, namespace, version};
}
