import 'dart:convert';
import 'version_status.dart';
import 'semver.dart';

/// A single node in the version graph of an entity.
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

  /// Optional branch name (e.g. 'main', 'feature/x').
  final String branch;

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
        'data': jsonEncode(data), // ✅ proper serialisation
        'isCurrent': isCurrent,
        'branch': branch,
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

    return VersionNode(
      nodeId: m['nodeId'] as String,
      entityId: m['entityId'] as String,
      parentNodeId: m['parentNodeId'] as String?,
      status: VersionStatus.fromString(m['status'] as String? ?? 'draft'),
      version: m['version'] != null ? Semver.parse(m['version'] as String) : null,
      sequenceNumber: m['sequenceNumber'] as int? ?? 1,
      createdBy: m['createdBy'] as String? ?? '',
      createdAt: DateTime.tryParse(m['createdAt'] as String? ?? '') ?? DateTime.now(),
      data: data,
      isCurrent: m['isCurrent'] as bool? ?? false,
      branch: m['branch'] as String? ?? 'main',
    );
  }

  VersionNode copyWith({
    VersionStatus? status,
    Semver? version,
    bool? isCurrent,
    Map<String, dynamic>? data,
    String? branch,
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
      );

  @override
  String toString() =>
      'VersionNode(${nodeId.substring(0, 8)} v${version ?? 'draft'} [$status] branch:$branch)';
}
