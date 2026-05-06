import 'dart:async';
import 'package:aq_schema/aq_schema.dart';
import 'backend/mock_data_backend.dart';

final class InMemoryVersionedRepository<T extends VersionedStorable>
    implements VersionedRepository<T> {
  final MockDataBackend _backend;
  final String _collection;
  final T Function(Map<String, dynamic>) _fromMap;
  final _controller = StreamController<List<VersionNode>>.broadcast();

  InMemoryVersionedRepository({
    required MockDataBackend backend,
    required String collection,
    required T Function(Map<String, dynamic>) fromMap,
  })  : _backend = backend,
        _collection = collection,
        _fromMap = fromMap;

  String get _nodesCol => '${_collection}__nodes';
  String get _metaCol => '${_collection}__meta';

  Map<String, Map<String, dynamic>> get _nodes =>
      _backend.collectionStore(_nodesCol);
  Map<String, Map<String, dynamic>> get _meta =>
      _backend.collectionStore(_metaCol);

  int _seq = 0;
  String _id() => '${DateTime.now().microsecondsSinceEpoch}-${_seq++}';

  void _notify() => _controller.add(
        _nodes.values.map(VersionNode.fromMap).toList(),
      );

  @override
  Future<VersionNode> createEntity(T model) async {
    final nodeId = _id();
    final node = VersionNode(
      nodeId: nodeId,
      entityId: model.id,
      status: VersionStatus.draft,
      sequenceNumber: 1,
      createdBy: model.ownerId,
      createdAt: DateTime.now(),
      data: model.toMap(),
      isCurrent: false,
      branch: 'main',
    );
    _nodes[nodeId] = node.toMap();
    _meta[model.id] = {'entityId': model.id, 'ownerId': model.ownerId, 'currentNodeId': null, 'sequenceCounter': 1};
    _notify();
    return node;
  }

  @override
  Future<VersionNode> createDraftFrom(String parentNodeId, T model) async {
    final parent = VersionNode.fromMap(_nodes[parentNodeId]!);
    final meta = _meta[parent.entityId]!;
    final seq = (meta['sequenceCounter'] as int) + 1;
    final nodeId = _id();
    final node = VersionNode(
      nodeId: nodeId,
      entityId: parent.entityId,
      parentNodeId: parentNodeId,
      status: VersionStatus.draft,
      sequenceNumber: seq,
      createdBy: model.ownerId,
      createdAt: DateTime.now(),
      data: model.toMap(),
      isCurrent: false,
      branch: parent.branch,
    );
    _nodes[nodeId] = node.toMap();
    _meta[parent.entityId] = {...meta, 'sequenceCounter': seq};
    _notify();
    return node;
  }

  @override
  Future<void> updateDraft(String nodeId, T model) async {
    final node = VersionNode.fromMap(_nodes[nodeId]!);
    _nodes[nodeId] = node.copyWith(data: model.toMap()).toMap();
    _notify();
  }

  @override
  Future<VersionNode> publishDraft(String nodeId, {required IncrementType increment}) async {
    final node = VersionNode.fromMap(_nodes[nodeId]!);
    final latest = await getLatestPublished(node.entityId);
    final current = latest?.version ?? Semver.zero;
    final newVersion = switch (increment) {
      IncrementType.major => current.incrementMajor(),
      IncrementType.minor => current.incrementMinor(),
      IncrementType.patch => current.incrementPatch(),
    };
    // clear current flag
    for (final n in _nodes.values.where((m) => m['entityId'] == node.entityId && m['isCurrent'] == true)) {
      n['isCurrent'] = false;
    }
    final published = node.copyWith(status: VersionStatus.published, version: newVersion, isCurrent: true);
    _nodes[nodeId] = published.toMap();
    _meta[node.entityId] = {..._meta[node.entityId]!, 'currentNodeId': nodeId};
    _notify();
    return published;
  }

  @override
  Future<VersionNode> snapshotVersion(String nodeId) async {
    final node = VersionNode.fromMap(_nodes[nodeId]!);
    final snapped = node.copyWith(status: VersionStatus.snapshot);
    _nodes[nodeId] = snapped.toMap();
    _notify();
    return snapped;
  }

  @override
  Future<void> deleteVersion(String nodeId) async {
    final node = VersionNode.fromMap(_nodes[nodeId]!);
    _nodes[nodeId] = node.copyWith(status: VersionStatus.deleted, isCurrent: false).toMap();
    _notify();
  }

  @override
  Future<void> deleteEntity(String entityId) async {
    _nodes.removeWhere((_, m) => m['entityId'] == entityId);
    _meta.remove(entityId);
    _notify();
  }

  @override
  Future<T?> getCurrent(String entityId) async {
    final meta = _meta[entityId];
    final currentNodeId = meta?['currentNodeId'] as String?;
    if (currentNodeId == null) return null;
    return getVersion(currentNodeId);
  }

  @override
  Future<T?> getVersion(String nodeId) async {
    final data = _nodes[nodeId];
    if (data == null) return null;
    final node = VersionNode.fromMap(data);
    if (node.status == VersionStatus.deleted) return null;
    return _fromMap(node.data);
  }

  @override
  Future<List<VersionNode>> listVersions(String entityId, {VersionStatus? status, String? branch}) async {
    return _nodes.values
        .map(VersionNode.fromMap)
        .where((n) => n.entityId == entityId)
        .where((n) => status == null || n.status == status)
        .where((n) => branch == null || n.branch == branch)
        .toList()
      ..sort((a, b) => a.sequenceNumber.compareTo(b.sequenceNumber));
  }

  @override
  Future<VersionNode?> getLatestPublished(String entityId) async {
    final published = await listVersions(entityId, status: VersionStatus.published);
    if (published.isEmpty) return null;
    published.sort((a, b) => (b.version ?? Semver.zero).compareTo(a.version ?? Semver.zero));
    return published.first;
  }

  @override
  Future<List<VersionNode>> findNodes({VaultQuery? query}) async =>
      _nodes.values.map(VersionNode.fromMap).toList();

  @override
  Future<PageResult<VersionNode>> findNodesPage(VaultQuery query) async {
    final all = _nodes.values.map(VersionNode.fromMap).toList();
    final offset = query.offset ?? 0;
    final limit = query.limit ?? all.length;
    return PageResult(
        items: all.skip(offset).take(limit).toList(),
        total: all.length,
        offset: offset,
        limit: limit);
  }

  @override
  Future<List<String>> listBranches(String entityId) async {
    final nodes = await listVersions(entityId);
    return nodes.map((n) => n.branch).toSet().toList()..sort();
  }

  @override
  Future<void> setCurrentVersion(String entityId, String nodeId, {required String requesterId}) async {
    for (final n in _nodes.values.where((m) => m['entityId'] == entityId)) {
      n['isCurrent'] = false;
    }
    _nodes[nodeId]!['isCurrent'] = true;
    _meta[entityId] = {..._meta[entityId]!, 'currentNodeId': nodeId};
    _notify();
  }

  // ── Branching (minimal for mocks) ─────────────────────────────────────────

  @override
  Future<VersionNode> createBranch(String parentNodeId, {required String branchName, required T model}) async {
    final parent = VersionNode.fromMap(_nodes[parentNodeId]!);
    final meta = _meta[parent.entityId]!;
    final seq = (meta['sequenceCounter'] as int) + 1;
    final nodeId = _id();
    final node = VersionNode(
      nodeId: nodeId, entityId: parent.entityId, parentNodeId: parentNodeId,
      status: VersionStatus.draft, sequenceNumber: seq, createdBy: model.ownerId,
      createdAt: DateTime.now(), data: model.toMap(), isCurrent: false, branch: branchName,
    );
    _nodes[nodeId] = node.toMap();
    _meta[parent.entityId] = {...meta, 'sequenceCounter': seq};
    _notify();
    return node;
  }

  @override
  Future<VersionNode> mergeToMain(String entityId, {required String sourceBranch, required String requesterId, required T Function(Map<String, dynamic>) fromMap}) async {
    final nodes = await listVersions(entityId, branch: sourceBranch);
    final head = nodes.last;
    return createDraftFrom(head.nodeId, fromMap(head.data));
  }

  // ── Access Control (no-op in mock) ────────────────────────────────────────

  @override
  Future<void> grantAccess(String entityId, {required String actorId, required AccessLevel level, required String requesterId}) async {}

  @override
  Future<void> revokeAccess(String entityId, {required String actorId, required String requesterId}) async {}

  @override
  Future<bool> hasAccess(String entityId, {required String actorId, required AccessLevel minimumLevel}) async => true;

  @override
  Future<List<AqResourcePermission>> listGrants(String entityId) async => [];

  @override
  Future<void> registerIndex(VaultIndex index) async {}

  @override
  Stream<List<VersionNode>> watchVersions(String entityId) => _controller.stream
      .map((nodes) => nodes.where((n) => n.entityId == entityId).toList());

  @override
  Stream<List<VersionNode>> watchAllEntities({VaultQuery? query}) => _controller.stream;
}
