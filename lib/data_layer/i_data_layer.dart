// aq_schema/lib/data_layer/i_data_layer.dart
//
// Client protocol for Data Layer access.
//
// ## Philosophy
//
// Client doesn't know about:
// - Storage implementations (Postgres, InMemory, Remote)
// - HTTP/RPC protocols
// - Handshakes, connections, buffers
//
// Client only knows:
// - Domain models from aq_schema (WorkflowGraph, etc.)
// - Repository interfaces (Direct, Versioned, Logged)
// - One initialization point
// - One access point
//
// ## Usage
//
// ```dart
// // 1. Initialize auth context (aq_security package)
// IAuthContext.initialize(MyAuthContextImpl());
//
// // 2. Initialize data layer once in main.dart
// await IDataLayer.initialize(endpoint: 'http://localhost:8765');
//
// // 3. Use everywhere in app
// final workflows = IDataLayer.instance.versioned<WorkflowGraph>(
//   collection: WorkflowGraph.kCollection,
//   fromMap: WorkflowGraph.fromMap,
// );
//
// final node = await workflows.createEntity(myWorkflow);
// await workflows.publishDraft(node.nodeId, increment: IncrementType.minor);
// ```
//
// ## Implementation
//
// The actual implementation lives in dart_vault package.
// aq_schema only defines the contract.
//
// ```dart
// // In dart_vault package:
// class DataLayerImpl implements IDataLayer {
//   final Vault _vault;
//
//   @override
//   DirectRepository<T> direct<T extends DirectStorable>(...) {
//     return _vault.direct<T>(...);
//   }
//   // ...
// }
// ```

import 'package:aq_schema/aq_schema.dart';

/// Client protocol for Data Layer access.
///
/// Single point of initialization and access for all data operations.
/// Client doesn't need to know about storage, HTTP, or implementation details.
///
/// ## Initialization
///
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///
///   // 1. Initialize auth context (aq_security package)
///   IAuthContext.initialize(MyAuthContextImpl());
///
///   // 2. Initialize data layer
///   await IDataLayer.initialize(endpoint: 'http://localhost:8765');
///
///   runApp(MyApp());
/// }
/// ```
///
/// ## Usage
///
/// ```dart
/// // Direct repository (simple CRUD)
/// final projects = IDataLayer.instance.direct<AqStudioProject>(
///   collection: AqStudioProject.kCollection,
///   fromMap: AqStudioProject.fromMap,
/// );
/// await projects.save(myProject);
///
/// // Versioned repository (semver lifecycle)
/// final workflows = IDataLayer.instance.versioned<WorkflowGraph>(
///   collection: WorkflowGraph.kCollection,
///   fromMap: WorkflowGraph.fromMap,
/// );
/// final node = await workflows.createEntity(myWorkflow);
/// await workflows.publishDraft(node.nodeId, increment: IncrementType.minor);
///
/// // Logged repository (audit trail)
/// final runs = IDataLayer.instance.logged<WorkflowRun>(
///   collection: 'workflow_runs',
///   fromMap: WorkflowRun.fromMap,
/// );
/// await runs.save(myRun, actorId: currentUser.id);
/// ```
abstract interface class IDataLayer {
  // ══════════════════════════════════════════════════════════════════════════
  // Singleton
  // ══════════════════════════════════════════════════════════════════════════

  static IDataLayer? _instance;

  /// Global singleton instance.
  ///
  /// Available after [initialize] is called.
  /// Throws assertion error if accessed before initialization.
  ///
  /// ```dart
  /// final workflows = IDataLayer.instance.versioned<WorkflowGraph>(...);
  /// ```
  static IDataLayer get instance {
    assert(
      _instance != null,
      '[IDataLayer] Call IDataLayer.initialize() before accessing instance',
    );
    return _instance!;
  }

  /// Check if data layer is initialized.
  static bool get isInitialized => _instance != null;

  /// Initialize the data layer with remote endpoint.
  ///
  /// **Call once in main.dart before runApp().**
  ///
  /// Auth is read from [IAuthContext] (aq_security package).
  /// If [IAuthContext] is not initialized, data layer works in development mode
  /// without authentication.
  ///
  /// ```dart
  /// void main() async {
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///
  ///   // 1. Initialize auth context (aq_security)
  ///   IAuthContext.initialize(MyAuthContextImpl());
  ///
  ///   // 2. Initialize data layer
  ///   await IDataLayer.initialize(
  ///     endpoint: 'http://localhost:8765',
  ///     useBuffer: true,  // Enable offline-first
  ///   );
  ///
  ///   runApp(MyApp());
  /// }
  /// ```
  ///
  /// Register implementation (called by dart_vault package).
  ///
  /// **Protocol Level:** This method only registers an implementation instance.
  /// It knows NOTHING about endpoints, connections, or implementation details.
  ///
  /// **Implementation Level (dart_vault):** Creates the implementation with
  /// all connection details (endpoint, buffer, auth) and registers it here.
  ///
  /// **Client Usage:**
  /// ```dart
  /// import 'package:dart_vault/dart_vault.dart';
  ///
  /// // Implementation creates itself with details
  /// final impl = await DataLayerImpl.connect(
  ///   endpoint: 'http://localhost:8765',
  ///   useBuffer: false,
  /// );
  ///
  /// // Register with protocol
  /// IDataLayer.register(impl);
  ///
  /// // Use protocol everywhere
  /// final repo = IDataLayer.instance.direct<Project>(...);
  /// ```
  static void register(IDataLayer implementation) {
    if (_instance != null) {
      throw DataLayerException(
        'IDataLayer already registered. Call disconnect() first.',
      );
    }
    _instance = implementation;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Repository Factories
  // ══════════════════════════════════════════════════════════════════════════

  /// Create a Direct repository for simple CRUD operations.
  ///
  /// **Use for:**
  /// - Projects
  /// - Settings
  /// - Simple entities without version history
  ///
  /// **Example:**
  /// ```dart
  /// final projects = IDataLayer.instance.direct<AqStudioProject>(
  ///   collection: AqStudioProject.kCollection,
  ///   fromMap: AqStudioProject.fromMap,
  /// );
  ///
  /// await projects.save(myProject);
  /// final project = await projects.findById('project-123');
  /// await projects.delete('project-123');
  /// ```
  DirectRepository<T> direct<T extends DirectStorable>({
    required String collection,
    required T Function(Map<String, dynamic>) fromMap,
    List<VaultIndex> indexes = const [],
  });

  /// Create a Versioned repository for entities with semver lifecycle.
  ///
  /// **Use for:**
  /// - Workflow graphs
  /// - Instruction graphs
  /// - Prompt graphs
  /// - Documents with version history
  ///
  /// **Lifecycle:**
  /// ```
  /// createEntity() → DRAFT
  ///   ↓ updateDraft()
  /// publishDraft() → PUBLISHED (v1.0.0)
  ///   ↓ snapshotVersion()
  /// SNAPSHOT (immutable)
  /// ```
  ///
  /// **Example:**
  /// ```dart
  /// final workflows = IDataLayer.instance.versioned<WorkflowGraph>(
  ///   collection: WorkflowGraph.kCollection,
  ///   fromMap: WorkflowGraph.fromMap,
  /// );
  ///
  /// // Create draft
  /// final node = await workflows.createEntity(myWorkflow);
  ///
  /// // Edit draft
  /// await workflows.updateDraft(node.nodeId, updatedWorkflow);
  ///
  /// // Publish
  /// final published = await workflows.publishDraft(
  ///   node.nodeId,
  ///   increment: IncrementType.minor,
  /// );
  ///
  /// // Get current version
  /// final current = await workflows.getCurrent(myWorkflow.id);
  /// ```
  VersionedRepository<T> versioned<T extends VersionedStorable>({
    required String collection,
    required T Function(Map<String, dynamic>) fromMap,
    List<VaultIndex> indexes = const [],
  });

  /// Create a Logged repository for entities with full audit trail.
  ///
  /// **Use for:**
  /// - Workflow runs
  /// - User sessions
  /// - Audit logs
  /// - Any entity requiring complete change history
  ///
  /// **Features:**
  /// - Field-level diffs for every change
  /// - Optional full snapshots
  /// - Rollback support
  /// - Actor tracking (who made the change)
  ///
  /// **Example:**
  /// ```dart
  /// final runs = IDataLayer.instance.logged<WorkflowRun>(
  ///   collection: 'workflow_runs',
  ///   fromMap: WorkflowRun.fromMap,
  ///   captureFullSnapshot: true,
  /// );
  ///
  /// // Create with actor
  /// await runs.save(myRun, actorId: currentUser.id);
  ///
  /// // Get history
  /// final history = await runs.getHistory(myRun.id);
  ///
  /// // Rollback
  /// await runs.rollbackTo(myRun.id, history[5].entryId, actorId: currentUser.id);
  /// ```
  LoggedRepository<T> logged<T extends LoggedStorable>({
    required String collection,
    required T Function(Map<String, dynamic>) fromMap,
    List<VaultIndex> indexes = const [],
    bool captureFullSnapshot = false,
  });

  // ══════════════════════════════════════════════════════════════════════════
  // Buffer Management (Offline-First)
  // ══════════════════════════════════════════════════════════════════════════

  /// Local buffer for offline-first operations.
  ///
  /// Available when initialized with `useBuffer: true` (default).
  /// Returns null if buffer is disabled.
  ///
  /// **Use cases:**
  /// - Check unsaved changes before navigation
  /// - Save to remote database
  /// - Discard local changes
  /// - Preload data for offline work
  ///
  /// **Example:**
  /// ```dart
  /// // Check if entity has unsaved changes
  /// final isDirty = IDataLayer.instance.buffer?.isDirty(
  ///   WorkflowGraph.kCollection,
  ///   graphId,
  /// ) ?? false;
  ///
  /// if (isDirty) {
  ///   // Show "Save changes?" dialog
  ///   await IDataLayer.instance.buffer?.flush(
  ///     WorkflowGraph.kCollection,
  ///     id: graphId,
  ///   );
  /// }
  ///
  /// // Discard changes
  /// await IDataLayer.instance.buffer?.discard(
  ///   WorkflowGraph.kCollection,
  ///   id: graphId,
  /// );
  ///
  /// // Preload for offline
  /// await IDataLayer.instance.buffer?.warmupAll(
  ///   WorkflowGraph.kCollection,
  /// );
  /// ```
  IBufferedStorage? get buffer;

  // ══════════════════════════════════════════════════════════════════════════
  // Connection Info
  // ══════════════════════════════════════════════════════════════════════════

  /// Current tenant ID.
  String get tenantId;

  /// Data Service endpoint URL.
  String get endpoint;

  /// Server version (from handshake).
  /// Null if not connected yet.
  String? get serverVersion;

  /// Check if connected to remote server.
  bool get isConnected;

  // ══════════════════════════════════════════════════════════════════════════
  // Lifecycle
  // ══════════════════════════════════════════════════════════════════════════

  /// Dispose resources.
  ///
  /// Called automatically by [disconnect].
  /// Do not call directly unless you know what you're doing.
  Future<void> dispose();
}

/// Data layer exception.
class DataLayerException implements Exception {
  final String message;
  final Object? cause;

  DataLayerException(this.message, {this.cause});

  @override
  String toString() =>
      'DataLayerException: $message${cause != null ? ' (cause: $cause)' : ''}';
}
