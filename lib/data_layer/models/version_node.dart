// pkgs/aq_schema/lib/data_layer/models/version_node.dart
import 'dart:convert';
import 'version_status.dart';
import 'semver.dart';
import '../storage/buffered_storage.dart';

/// A single node in the version graph of an entity.
///
/// [localState] — состояние записи в локальном буфере.
/// null — буфер не используется или запись синхронизирована.
/// [VaultRecordState.dirty] — запись изменена локально, flush не сделан.
/// [VaultRecordState.localOnly] — запись создана локально, в удалённой БД её нет.
/// [VaultRecordState.synced] — запись получена из удалённой БД, изменений нет.
final class VersionNode {
  final String nodeId;
  final String entityId;
  final String? parentNodeId;
  final VersionStatus status;
  final Semver? version;
  final int sequenceNumber;
  final String createdBy;
  final DateTime createdAt;
  final Map<String, dynamic> data;
  final bool isCurrent;
  final String branch;

  /// Состояние в локальном буфере. null если буфер не используется.
  final VaultRecordState? localState;

  /// true если запись содержит несохранённые локальные изменения.
  bool get isLocallyModified =>
      localState == VaultRecordState.dirty ||
      localState == VaultRecordState.localOnly;

  const VersionNode({
    required this.nodeId,
    required this.entityId,
    this.parentNodeId,
    required this.status,
    this.version,
    required this.sequenceNumber,
    required this.createdBy,
    required this.createdAt,
    required this.data,
    required this.isCurrent,
    this.branch = 'main',
    this.localState,
  });

  Map<String, dynamic> toMap() => {
        'nodeId': nodeId,
        'entityId': entityId,
        'parentNodeId': parentNodeId,
        'status': status.name,
        'version': version?.toString(),
        'sequenceNumber': sequenceNumber,
        'createdBy': createdBy,
        'createdAt': createdAt.toIso8601String(),
        'data': jsonEncode(data),
        'isCurrent': isCurrent,
        'branch': branch,
        // _ls намеренно не сериализуем — он не часть домена
      };

  factory VersionNode.fromMap(Map<String, dynamic> m) {
    final rawData = m['data'];
    final Map<String, dynamic> data;
    if (rawData is String) {
      data = (jsonDecode(rawData) as Map<String, dynamic>?) ?? {};
    } else if (rawData is Map) {
      data = Map<String, dynamic>.from(rawData);
    } else {
      data = {};
    }

    // Читаем состояние буфера если оно есть
    final lsRaw = m[IBufferedStorage.kStateKey] as String?;
    final localState = lsRaw != null
        ? VaultRecordState.values.firstWhere(
            (e) => e.name == lsRaw,
            orElse: () => VaultRecordState.synced,
          )
        : null;

    return VersionNode(
      nodeId: m['nodeId'] as String,
      entityId: m['entityId'] as String,
      parentNodeId: m['parentNodeId'] as String?,
      status: VersionStatus.fromString(m['status'] as String? ?? 'draft'),
      version:
          m['version'] != null ? Semver.parse(m['version'] as String) : null,
      sequenceNumber: m['sequenceNumber'] as int? ?? 1,
      createdBy: m['createdBy'] as String? ?? '',
      createdAt:
          DateTime.tryParse(m['createdAt'] as String? ?? '') ?? DateTime.now(),
      data: data,
      isCurrent: m['isCurrent'] as bool? ?? false,
      branch: m['branch'] as String? ?? 'main',
      localState: localState,
    );
  }

  VersionNode copyWith({
    VersionStatus? status,
    Semver? version,
    bool? isCurrent,
    Map<String, dynamic>? data,
    String? branch,
    VaultRecordState? localState,
  }) =>
      VersionNode(
        nodeId: nodeId,
        entityId: entityId,
        parentNodeId: parentNodeId,
        status: status ?? this.status,
        version: version ?? this.version,
        sequenceNumber: sequenceNumber,
        createdBy: createdBy,
        createdAt: createdAt,
        data: data ?? this.data,
        isCurrent: isCurrent ?? this.isCurrent,
        branch: branch ?? this.branch,
        localState: localState ?? this.localState,
      );

  @override
  String toString() =>
      'VersionNode(${nodeId.substring(0, 8)} v${version ?? 'draft'} '
      '[$status] branch:$branch${localState != null ? ' ls:${localState!.name}' : ''})';
}
