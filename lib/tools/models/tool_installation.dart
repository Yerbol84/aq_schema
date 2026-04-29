// aq_schema/lib/tools/models/tool_installation.dart
//
// Установка инструмента для конкретного workspace/user.
// Связывает workspace с конкретной версией инструмента.
//
// ═══════════════════════════════════════════════════════════════════════════════
// ИСПОЛЬЗОВАНИЕ DATA_LAYER
// ═══════════════════════════════════════════════════════════════════════════════
//
// ToolInstallation — это DirectStorable. Используй directRepository<ToolInstallation>().
//
// ── Установить инструмент для workspace ───────────────────────────────────────
//
// final installation = ToolInstallation(
//   id: 'workspace123:aq/llm/llm_complete@2.0.0',
//   workspaceId: 'workspace123',
//   toolRef: ToolRef('llm_complete',
//     namespace: 'aq/llm',
//     exactVersion: Semver(2, 0, 0),
//   ),
//   installedAt: DateTime.now(),
//   installedBy: 'user456',
// );
//
// await dataLayer.directRepository<ToolInstallation>().create(installation);
//
// ── Получить установку ────────────────────────────────────────────────────────
//
// final installation = await dataLayer
//     .directRepository<ToolInstallation>()
//     .read('workspace123:aq/llm/llm_complete@2.0.0');
//
// ── Получить все установки workspace ──────────────────────────────────────────
//
// final query = QueryBuilder()
//     .where('workspace_id', '=', 'workspace123')
//     .where('is_active', '=', true)
//     .build();
//
// final installations = await dataLayer
//     .directRepository<ToolInstallation>()
//     .query(query);
//
// ── Активировать инструмент ───────────────────────────────────────────────────
//
// final updated = installation.copyWith(
//   isActive: true,
//   activatedAt: DateTime.now(),
// );
//
// await dataLayer.directRepository<ToolInstallation>().update(updated);
//
// ── Деактивировать инструмент ─────────────────────────────────────────────────
//
// final updated = installation.copyWith(
//   isActive: false,
//   deactivatedAt: DateTime.now(),
// );
//
// await dataLayer.directRepository<ToolInstallation>().update(updated);
//
// ── Удалить установку ─────────────────────────────────────────────────────────
//
// await dataLayer
//     .directRepository<ToolInstallation>()
//     .delete('workspace123:aq/llm/llm_complete@2.0.0');
//
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:aq_schema/aq_schema.dart';

import '../../data_layer/storable/storable.dart';
import 'tool_ref.dart';

/// Установка инструмента для workspace/user.
///
/// Отвечает на вопрос: "Какие инструменты установлены у workspace X?"
///
/// ```dart
/// final installation = ToolInstallation(
///   id: 'workspace123:aq/llm/llm_complete@2.0.0',
///   workspaceId: 'workspace123',
///   toolRef: ToolRef('llm_complete', namespace: 'aq/llm', exactVersion: Semver(2, 0, 0)),
///   installedAt: DateTime.now(),
/// );
///
/// await dataLayer.directRepository<ToolInstallation>().create(installation);
/// ```
final class ToolInstallation implements DirectStorable {
  static final _ToolInstallationKeys _keys = _ToolInstallationKeys._();
  static _ToolInstallationKeys get keys => _keys;

  @override
  final String id; // "{workspaceId}:{toolId}"

  final String workspaceId; // или userId
  final ToolRef toolRef;
  final bool isActive;
  final DateTime installedAt;
  final String? installedBy; // userId кто установил
  final DateTime? activatedAt;
  final DateTime? deactivatedAt;

  const ToolInstallation({
    required this.id,
    required this.workspaceId,
    required this.toolRef,
    this.isActive = false,
    required this.installedAt,
    this.installedBy,
    this.activatedAt,
    this.deactivatedAt,
  });

  @override
  String get domain => 'tools';

  @override
  Map<String, dynamic> toJson() => {
        ToolInstallation.keys.id: id,
        ToolInstallation.keys.workspaceId: workspaceId,
        ToolInstallation.keys.toolRef: toolRef.toJson(),
        ToolInstallation.keys.isActive: isActive,
        ToolInstallation.keys.installedAt: installedAt.toIso8601String(),
        if (installedBy != null) ToolInstallation.keys.installedBy: installedBy,
        if (activatedAt != null)
          ToolInstallation.keys.activatedAt: activatedAt!.toIso8601String(),
        if (deactivatedAt != null)
          ToolInstallation.keys.deactivatedAt: deactivatedAt!.toIso8601String(),
      };

  factory ToolInstallation.fromJson(Map<String, dynamic> json) =>
      ToolInstallation(
        id: json[ToolInstallation.keys.id] as String,
        workspaceId: json[ToolInstallation.keys.workspaceId] as String,
        toolRef: ToolRef.fromJson(
            json[ToolInstallation.keys.toolRef] as Map<String, dynamic>),
        isActive: json[ToolInstallation.keys.isActive] as bool? ?? false,
        installedAt:
            DateTime.parse(json[ToolInstallation.keys.installedAt] as String),
        installedBy: json[ToolInstallation.keys.installedBy] as String?,
        activatedAt: json[ToolInstallation.keys.activatedAt] != null
            ? DateTime.parse(json[ToolInstallation.keys.activatedAt] as String)
            : null,
        deactivatedAt: json[ToolInstallation.keys.deactivatedAt] != null
            ? DateTime.parse(
                json[ToolInstallation.keys.deactivatedAt] as String)
            : null,
      );

  ToolInstallation copyWith({
    bool? isActive,
    DateTime? activatedAt,
    DateTime? deactivatedAt,
  }) =>
      ToolInstallation(
        id: id,
        workspaceId: workspaceId,
        toolRef: toolRef,
        isActive: isActive ?? this.isActive,
        installedAt: installedAt,
        installedBy: installedBy,
        activatedAt: activatedAt ?? this.activatedAt,
        deactivatedAt: deactivatedAt ?? this.deactivatedAt,
      );

  @override
  String toString() => 'ToolInstallation($workspaceId:${toolRef.fullId})';

  @override
  // TODO: implement collectionName
  String get collectionName => throw UnimplementedError();

  @override
  // TODO: implement indexFields
  Map<String, dynamic> get indexFields => throw UnimplementedError();

  @override
  // TODO: implement jsonSchema
  Map<String, dynamic> get jsonSchema => throw UnimplementedError();

  @override
  // TODO: implement softDelete
  bool get softDelete => throw UnimplementedError();

  @override
  Map<String, dynamic> toMap() {
    // TODO: implement toMap
    throw UnimplementedError();
  }
}

class _ToolInstallationKeys {
  _ToolInstallationKeys._();

  final String id = 'id';
  final String workspaceId = 'workspace_id';
  final String toolRef = 'tool_ref';
  final String isActive = 'is_active';
  final String installedAt = 'installed_at';
  final String installedBy = 'installed_by';
  final String activatedAt = 'activated_at';
  final String deactivatedAt = 'deactivated_at';

  List<String> get all => [
        id,
        workspaceId,
        toolRef,
        isActive,
        installedAt,
        installedBy,
        activatedAt,
        deactivatedAt
      ];
  Set<String> get required => {id, workspaceId, toolRef, installedAt};
}
