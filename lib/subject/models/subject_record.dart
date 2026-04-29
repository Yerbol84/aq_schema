// aq_schema/lib/subject/models/subject_record.dart
//
// Версионируемая запись Subject в реестре.
// Один Subject (по id) может иметь несколько версий.
//
// ═══════════════════════════════════════════════════════════════════════════════
// ИСПОЛЬЗОВАНИЕ DATA_LAYER
// ═══════════════════════════════════════════════════════════════════════════════
//
// SubjectRecord — это VersionedStorable. Используй versionedRepository<SubjectRecord>().
//
// ── Создать новую версию Subject ──────────────────────────────────────────────
//
// final record = SubjectRecord(
//   id: 'user/workspace/my-agent',     // БЕЗ @version!
//   version: Semver(1, 0, 0),
//   descriptor: descriptor,
//   registeredAt: DateTime.now(),
//   exposeAsTool: true,
//   dependencyLevel: 1,
// );
//
// await dataLayer.versionedRepository<SubjectRecord>().create(record);
//
// ── Получить конкретную версию ────────────────────────────────────────────────
//
// final record = await dataLayer
//     .versionedRepository<SubjectRecord>()
//     .readVersion('user/workspace/my-agent', Semver(1, 0, 0));
//
// ── Получить последнюю версию ─────────────────────────────────────────────────
//
// final record = await dataLayer
//     .versionedRepository<SubjectRecord>()
//     .read('user/workspace/my-agent');
//
// ── Получить все версии Subject ───────────────────────────────────────────────
//
// final versions = await dataLayer
//     .versionedRepository<SubjectRecord>()
//     .listVersions('user/workspace/my-agent');
//
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:aq_schema/aq_schema.dart';

import 'subject_descriptor.dart';

/// Версионируемая запись Subject в реестре.
///
/// Хранится через data_layer.versionedRepository<SubjectRecord>().
final class SubjectRecord implements VersionedStorable {
  static final _SubjectRecordKeys _keys = _SubjectRecordKeys._();
  static _SubjectRecordKeys get keys => _keys;

  @override
  final String id; // "{namespace}/{name}" (БЕЗ версии!)

  @override
  final Semver version;

  final SubjectDescriptor descriptor;
  final DateTime registeredAt;
  final bool isDeprecated;

  /// Флаг: доступен ли Subject как Tool.
  ///
  /// Если true — автоматически создан ToolRecord при регистрации.
  final bool exposeAsTool;

  /// Уровень вложенности зависимостей.
  ///
  /// • 0 — зависит только от базовых Tools (aq/llm/*, aq/fs/*)
  /// • 1 — зависит от Subject уровня 0
  /// • 2 — зависит от Subject уровня 1
  /// • 3 — зависит от Subject уровня 2
  /// • 4+ — ЗАПРЕЩЕНО (MaxDepthExceededException)
  final int dependencyLevel;

  const SubjectRecord({
    required this.id,
    required this.version,
    required this.descriptor,
    required this.registeredAt,
    this.isDeprecated = false,
    this.exposeAsTool = false,
    this.dependencyLevel = 0,
  });

  @override
  String get domain => 'subjects';

  @override
  Map<String, dynamic> toJson() => {
        SubjectRecord.keys.id: id,
        SubjectRecord.keys.version: version.toString(),
        SubjectRecord.keys.descriptor: descriptor.toJson(),
        SubjectRecord.keys.registeredAt: registeredAt.toIso8601String(),
        SubjectRecord.keys.isDeprecated: isDeprecated,
        SubjectRecord.keys.exposeAsTool: exposeAsTool,
        SubjectRecord.keys.dependencyLevel: dependencyLevel,
      };

  factory SubjectRecord.fromJson(Map<String, dynamic> json) => SubjectRecord(
        id: json[SubjectRecord.keys.id] as String,
        version: Semver.parse(json[SubjectRecord.keys.version] as String),
        descriptor: SubjectDescriptor.fromJson(
            json[SubjectRecord.keys.descriptor] as Map<String, dynamic>),
        registeredAt:
            DateTime.parse(json[SubjectRecord.keys.registeredAt] as String),
        isDeprecated: json[SubjectRecord.keys.isDeprecated] as bool? ?? false,
        exposeAsTool: json[SubjectRecord.keys.exposeAsTool] as bool? ?? false,
        dependencyLevel: json[SubjectRecord.keys.dependencyLevel] as int? ?? 0,
      );

  @override
  SubjectRecord incrementVersion(IncrementType type) {
    final newVersion = version.increment(type);
    return SubjectRecord(
      id: id,
      version: newVersion,
      descriptor: descriptor,
      registeredAt: DateTime.now(),
      isDeprecated: isDeprecated,
      exposeAsTool: exposeAsTool,
      dependencyLevel: dependencyLevel,
    );
  }

  SubjectRecord copyWith({
    bool? isDeprecated,
    bool? exposeAsTool,
    int? dependencyLevel,
  }) =>
      SubjectRecord(
        id: id,
        version: version,
        descriptor: descriptor,
        registeredAt: registeredAt,
        isDeprecated: isDeprecated ?? this.isDeprecated,
        exposeAsTool: exposeAsTool ?? this.exposeAsTool,
        dependencyLevel: dependencyLevel ?? this.dependencyLevel,
      );

  @override
  String toString() => 'SubjectRecord($id@$version, level: $dependencyLevel)';

  @override
  // TODO: implement collectionName
  String get collectionName => throw UnimplementedError();

  @override
  // TODO: implement defaultSharingPolicy
  String get defaultSharingPolicy => throw UnimplementedError();

  @override
  // TODO: implement indexFields
  Map<String, dynamic> get indexFields => throw UnimplementedError();

  @override
  // TODO: implement jsonSchema
  Map<String, dynamic> get jsonSchema => throw UnimplementedError();

  @override
  // TODO: implement migrations
  List<Object> get migrations => throw UnimplementedError();

  @override
  // TODO: implement ownerId
  String get ownerId => throw UnimplementedError();

  @override
  // TODO: implement schemaVersion
  String get schemaVersion => throw UnimplementedError();

  @override
  // TODO: implement softDelete
  bool get softDelete => throw UnimplementedError();

  @override
  // TODO: implement tenantId
  String get tenantId => throw UnimplementedError();

  @override
  Map<String, dynamic> toMap() {
    // TODO: implement toMap
    throw UnimplementedError();
  }
}

class _SubjectRecordKeys {
  _SubjectRecordKeys._();

  final String id = 'id';
  final String version = 'version';
  final String descriptor = 'descriptor';
  final String registeredAt = 'registered_at';
  final String isDeprecated = 'is_deprecated';
  final String exposeAsTool = 'expose_as_tool';
  final String dependencyLevel = 'dependency_level';

  List<String> get all => [
        id,
        version,
        descriptor,
        registeredAt,
        isDeprecated,
        exposeAsTool,
        dependencyLevel
      ];
  Set<String> get required => {id, version, descriptor, registeredAt};
}
