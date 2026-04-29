// aq_schema/lib/tools/models/tool_record.dart
//
// Версионируемая запись инструмента в глобальном реестре.
// Один инструмент = много версий в истории.
//
// ═══════════════════════════════════════════════════════════════════════════════
// ИСПОЛЬЗОВАНИЕ DATA_LAYER
// ═══════════════════════════════════════════════════════════════════════════════
//
// ToolRecord — это VersionedStorable. Используй versionedRepository<ToolRecord>().
//
// ── Создать новую версию инструмента ──────────────────────────────────────────
//
// final record = ToolRecord(
//   id: 'aq/llm/llm_complete',        // БЕЗ @version!
//   version: Semver(2, 0, 0),
//   contract: contract,
//   registeredAt: DateTime.now(),
// );
//
// await dataLayer.versionedRepository<ToolRecord>().create(record);
//
// ── Получить конкретную версию ────────────────────────────────────────────────
//
// final record = await dataLayer
//     .versionedRepository<ToolRecord>()
//     .readVersion('aq/llm/llm_complete', Semver(2, 0, 0));
//
// ── Получить последнюю версию ─────────────────────────────────────────────────
//
// final record = await dataLayer
//     .versionedRepository<ToolRecord>()
//     .read('aq/llm/llm_complete');
//
// ── Получить все версии инструмента ───────────────────────────────────────────
//
// final versions = await dataLayer
//     .versionedRepository<ToolRecord>()
//     .listVersions('aq/llm/llm_complete');
//
// // Отфильтровать по SemVerRange
// final matching = versions.where((v) =>
//   SemVerRange('^2.0.0').satisfies(v.version)
// );
//
// ── Пометить версию как deprecated ────────────────────────────────────────────
//
// final updated = record.copyWith(isDeprecated: true);
// await dataLayer.versionedRepository<ToolRecord>().update(updated);
//
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:aq_schema/aq_schema.dart';

import 'tool_contract.dart';

/// Версионируемая запись инструмента в глобальном реестре.
///
/// Один инструмент (по id) может иметь несколько версий.
/// Data layer автоматически управляет версионированием.
///
/// ```dart
/// final record = ToolRecord(
///   id: 'aq/llm/llm_complete',  // БЕЗ @version
///   version: Semver(2, 0, 0),
///   contract: contract,
///   registeredAt: DateTime.now(),
/// );
///
/// await dataLayer.versionedRepository<ToolRecord>().create(record);
/// ```
final class ToolRecord implements VersionedStorable {
  static final _ToolRecordKeys _keys = _ToolRecordKeys._();
  static _ToolRecordKeys get keys => _keys;

  @override
  final String id; // "{namespace}/{name}" (БЕЗ версии!)

  @override
  final Semver version; // версия инструмента

  final ToolContract contract;
  final DateTime registeredAt;
  final bool isDeprecated;

  const ToolRecord({
    required this.id,
    required this.version,
    required this.contract,
    required this.registeredAt,
    this.isDeprecated = false,
  });

  @override
  String get domain => 'tools';

  @override
  Map<String, dynamic> toJson() => {
        ToolRecord.keys.id: id,
        ToolRecord.keys.version: version.toString(),
        ToolRecord.keys.contract: contract.toJson(),
        ToolRecord.keys.registeredAt: registeredAt.toIso8601String(),
        ToolRecord.keys.isDeprecated: isDeprecated,
      };

  factory ToolRecord.fromJson(Map<String, dynamic> json) => ToolRecord(
        id: json[ToolRecord.keys.id] as String,
        version: Semver.parse(json[ToolRecord.keys.version] as String),
        contract: ToolContract.fromJson(
            json[ToolRecord.keys.contract] as Map<String, dynamic>),
        registeredAt:
            DateTime.parse(json[ToolRecord.keys.registeredAt] as String),
        isDeprecated: json[ToolRecord.keys.isDeprecated] as bool? ?? false,
      );

  @override
  ToolRecord incrementVersion(IncrementType type) {
    final newVersion = version.increment(type);
    return ToolRecord(
      id: id,
      version: newVersion,
      contract: contract,
      registeredAt: DateTime.now(),
      isDeprecated: isDeprecated,
    );
  }

  ToolRecord copyWith({
    bool? isDeprecated,
  }) =>
      ToolRecord(
        id: id,
        version: version,
        contract: contract,
        registeredAt: registeredAt,
        isDeprecated: isDeprecated ?? this.isDeprecated,
      );

  @override
  String toString() => 'ToolRecord($id@$version)';

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

class _ToolRecordKeys {
  _ToolRecordKeys._();

  final String id = 'id';
  final String version = 'version';
  final String contract = 'contract';
  final String registeredAt = 'registered_at';
  final String isDeprecated = 'is_deprecated';

  List<String> get all => [id, version, contract, registeredAt, isDeprecated];
  Set<String> get required => {id, version, contract, registeredAt};
}
