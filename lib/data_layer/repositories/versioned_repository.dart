import 'package:aq_schema/aq_schema.dart';

/// Repository for entities with semver lifecycle, branching, and
/// cross-tenant access control.
///
/// Use for: graphs, documents, prompts, blueprints, configs.
///
/// ## Lifecycle
/// ```
/// createEntity() → DRAFT node
///   ↓ edit via updateDraft()
/// publishDraft() → PUBLISHED node  (gets semver)
///   ↓ snapshotVersion() → SNAPSHOT (immutable archive)
/// createDraftFrom() → new DRAFT branching from any node
/// ```
///
/// ## Branching
/// Every node belongs to a [branch] (default: 'main').
/// [createBranch] creates a new DRAFT node on a named branch.
/// [mergeToMain] copies branch content back to main.
///
/// ## Multi-tenancy
/// [requesterId] is checked against the entity's [ownerId] and permissions
/// via [IVaultSecurityProtocol] on every mutating operation.
abstract interface class VersionedRepository<T extends VersionedStorable> {
  // ── Lifecycle: Create & Edit ───────────────────────────────────────────────

  Future<VersionNode> createEntity(T model);

  Future<VersionNode> createDraftFrom(String parentNodeId, T model);

  /// Update data inside a DRAFT node.
  Future<void> updateDraft(String nodeId, T model);

  // ── Lifecycle: Publish & Archive ──────────────────────────────────────────

  /// Promote a DRAFT to PUBLISHED, assigning a semver.
  Future<VersionNode> publishDraft(
    String nodeId, {
    required IncrementType increment,
  });

  /// Archive a PUBLISHED version as an immutable SNAPSHOT.
  Future<VersionNode> snapshotVersion(String nodeId);

  /// Soft-delete a node.
  Future<void> deleteVersion(String nodeId);

  /// Delete entire entity with all its versions.
  Future<void> deleteEntity(String entityId);

  // ── Branching ──────────────────────────────────────────────────────────────

  /// Create a new DRAFT on [branchName] branching from [parentNodeId].
  Future<VersionNode> createBranch(
    String parentNodeId, {
    required String branchName,
    required T model,
  });

  /// Merge [sourceBranch] head into 'main' by creating a new DRAFT on main.
  /// Returns the new main-branch DRAFT node.
  Future<VersionNode> mergeToMain(
    String entityId, {
    required String sourceBranch,
    required String requesterId,
    required T Function(Map<String, dynamic>) fromMap,
  });

  /// List all unique branch names for [entityId].
  Future<List<String>> listBranches(String entityId);

  // ── Current Version ────────────────────────────────────────────────────────

  /// Set [nodeId] as the active version returned by [getCurrent].
  Future<void> setCurrentVersion(
    String entityId,
    String nodeId, {
    required String requesterId,
  });

  /// Get the current PUBLISHED version data, or null if no published version.
  Future<T?> getCurrent(String entityId);

  /// Get data from a specific [nodeId].
  Future<T?> getVersion(String nodeId);

  // ── Access Control ─────────────────────────────────────────────────────────

  Future<void> grantAccess(
    String entityId, {
    required String actorId,
    required AccessLevel level,
    required String requesterId,
  });

  Future<void> revokeAccess(
    String entityId, {
    required String actorId,
    required String requesterId,
  });

  Future<bool> hasAccess(
    String entityId, {
    required String actorId,
    required AccessLevel minimumLevel,
  });

  Future<List<AqResourcePermission>> listGrants(String entityId);

  // ── Queries ────────────────────────────────────────────────────────────────

  Future<List<VersionNode>> listVersions(
    String entityId, {
    VersionStatus? status,
    String? branch,
  });

  Future<List<VersionNode>> findNodes({VaultQuery? query});

  Future<PageResult<VersionNode>> findNodesPage(VaultQuery query);

  Future<VersionNode?> getLatestPublished(String entityId);

  // ── Indexes ────────────────────────────────────────────────────────────────

  Future<void> registerIndex(VaultIndex index);

  // ── Streams ────────────────────────────────────────────────────────────────

  /// Watch all version nodes for [entityId].
  /// Emits on every lifecycle transition (publish, snapshot, delete, etc.)
  Stream<List<VersionNode>> watchVersions(String entityId);

  /// Watch all nodes in this collection.
  /// Useful for dashboards listing many entities.
  ///
  /// TODO (collaborative editing): for real-time multi-user sync, add a
  /// WebSocket / SSE transport layer above this stream.  Each client subscribes
  /// to `watchAllEntities()` and applies optimistic updates locally; the server
  /// broadcasts diffs via the same `VaultStorage.watchChanges` mechanism backed
  /// by Redis Pub/Sub (not InMemory) so updates propagate across processes.
  Stream<List<VersionNode>> watchAllEntities({VaultQuery? query});
}
