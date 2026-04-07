import 'package:aq_schema/aq_schema.dart';

/// Describes how a single domain should be stored.
enum StorageKind { direct, versioned, logged }

/// Domain descriptor — everything the data layer needs to manage one domain.
///
/// Both the client (to create the right repository) and the server
/// (to create the right tables) read from [AqDomains.all].
/// One list. One source of truth.
final class DomainDescriptor<T extends Storable> {
  final String collection;
  final StorageKind kind;
  final T Function(Map<String, dynamic>) fromMap;
  final List<VaultIndex> indexes;

  const DomainDescriptor._({
    required this.collection,
    required this.kind,
    required this.fromMap,
    this.indexes = const [],
  });

  factory DomainDescriptor.direct({
    required String collection,
    required T Function(Map<String, dynamic>) fromMap,
    List<VaultIndex> indexes = const [],
  }) =>
      DomainDescriptor._(
          collection: collection,
          kind: StorageKind.direct,
          fromMap: fromMap,
          indexes: indexes);

  factory DomainDescriptor.versioned({
    required String collection,
    required T Function(Map<String, dynamic>) fromMap,
    List<VaultIndex> indexes = const [],
  }) =>
      DomainDescriptor._(
          collection: collection,
          kind: StorageKind.versioned,
          fromMap: fromMap,
          indexes: indexes);

  factory DomainDescriptor.logged({
    required String collection,
    required T Function(Map<String, dynamic>) fromMap,
    List<VaultIndex> indexes = const [],
  }) =>
      DomainDescriptor._(
          collection: collection,
          kind: StorageKind.logged,
          fromMap: fromMap,
          indexes: indexes);
}

/// All AQ Studio domains.
///
/// Server auto-creates tables from this list.
/// Client auto-creates repositories from this list.
/// Add a domain here once — it works everywhere.
class AqDomains {
  AqDomains._();

  static final List<DomainDescriptor> all = [
    // ── Projects ──────────────────────────────────────────────────────────────
    DomainDescriptor.direct(
      collection: AqStudioProject.kCollection,
      fromMap: AqStudioProject.fromMap,
      indexes: [
        VaultIndex(name: 'idx_proj_type', field: 'projectType'),
        VaultIndex(name: 'idx_proj_opened', field: 'lastOpened'),
      ],
    ),

    // ── Graphs ────────────────────────────────────────────────────────────────
    DomainDescriptor.versioned(
      collection: WorkflowGraph.kCollection,
      fromMap: WorkflowGraph.fromMap,
      indexes: [
        VaultIndex(name: 'idx_wf_owner', field: 'ownerId'),
        VaultIndex(name: 'idx_wf_name', field: 'name'),
      ],
    ),

    DomainDescriptor.versioned(
      collection: InstructionGraph.kCollection,
      fromMap: InstructionGraph.fromMap,
      indexes: [
        VaultIndex(name: 'idx_ig_owner', field: 'ownerId'),
        VaultIndex(name: 'idx_ig_name', field: 'name'),
      ],
    ),

    DomainDescriptor.versioned(
      collection: PromptGraph.kCollection,
      fromMap: PromptGraph.fromMap,
      indexes: [
        VaultIndex(name: 'idx_pg_owner', field: 'ownerId'),
        VaultIndex(name: 'idx_pg_name', field: 'name'),
      ],
    ),
  ];
}
