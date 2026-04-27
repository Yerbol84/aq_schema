# IDataLayer Client Protocol - Implementation Summary

**Date:** 2026-04-18
**Status:** ✅ Complete in aq_schema

---

## What We Built

### 1. **IAuthContext Protocol** ✅
**Location:** `aq_schema/lib/security/interfaces/clients_protocols/i_auth_context.dart`

```dart
abstract interface class IAuthContext {
  static IAuthContext? get instance;
  static void initialize(IAuthContext impl);
  
  Future<String?> get currentToken;
  Future<String> get currentTenantId;
  Future<String?> get currentUserId;
}
```

**Purpose:** Provides auth state to data layer without coupling to auth implementation.

---

### 2. **Repository Interfaces** ✅
**Location:** `aq_schema/lib/data_layer/repositories/`

- `direct_repository.dart` - Simple CRUD operations
- `versioned_repository.dart` - Semver lifecycle with branching
- `logged_repository.dart` - Full audit trail with rollback

**Moved from:** `dart_vault_package/lib/repositories/` → `aq_schema/lib/data_layer/repositories/`

**Why?** These are contracts, not implementations. They belong in the source of truth.

---

### 3. **IDataLayer Client Protocol** ✅
**Location:** `aq_schema/lib/data_layer/i_data_layer.dart`

```dart
abstract interface class IDataLayer {
  // Singleton
  static IDataLayer get instance;
  static Future<void> initialize({required String endpoint, bool useBuffer = true});
  static Future<void> disconnect();
  
  // Repository factories
  DirectRepository<T> direct<T extends DirectStorable>({...});
  VersionedRepository<T> versioned<T extends VersionedStorable>({...});
  LoggedRepository<T> logged<T extends LoggedStorable>({...});
  
  // Buffer & connection info
  IBufferedStorage? get buffer;
  String get tenantId;
  String get endpoint;
  bool get isConnected;
}
```

**Purpose:** Single point of initialization and access for all data operations.

---

### 4. **Updated Exports** ✅
**Location:** `aq_schema/lib/aq_schema.dart`

Added exports:
```dart
// Data Layer Client Protocol
export 'data_layer/i_data_layer.dart';

// Repository Interfaces
export 'data_layer/repositories/direct_repository.dart';
export 'data_layer/repositories/versioned_repository.dart';
export 'data_layer/repositories/logged_repository.dart';

// Auth Context
export 'security/interfaces/clients_protocols/i_auth_context.dart';
```

---

## Client Usage (What You Wanted!)

### Initialization (One Point)
```dart
// main.dart
import 'package:aq_schema/aq_schema.dart';
import 'package:dart_vault/dart_vault.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize auth context (aq_security package)
  IAuthContext.initialize(MyAuthContextImpl());

  // 2. Initialize data layer (ONE POINT!)
  await IDataLayer.initialize(endpoint: 'http://localhost:8765');

  runApp(MyApp());
}
```

### Usage (One Point)
```dart
// anywhere_in_app.dart
import 'package:aq_schema/aq_schema.dart';

class WorkflowService {
  // ONE POINT ACCESS!
  final workflows = IDataLayer.instance.versioned<WorkflowGraph>(
    collection: WorkflowGraph.kCollection,
    fromMap: WorkflowGraph.fromMap,
  );

  Future<void> createWorkflow(WorkflowGraph graph) async {
    final node = await workflows.createEntity(graph);
    print('Created: ${node.nodeId}');
  }

  Future<void> publishWorkflow(String nodeId) async {
    await workflows.publishDraft(
      nodeId,
      increment: IncrementType.minor,
    );
  }
}
```

---

## Next Steps (For dart_vault Implementation)

### Step 5: Update dart_vault to use aq_schema repositories

**Delete:** `dart_vault_package/lib/repositories/` (moved to aq_schema)

**Update:** `dart_vault_package/lib/dart_vault.dart`
```dart
// Re-export from aq_schema
export 'package:aq_schema/aq_schema.dart' show
  IDataLayer,
  DirectRepository,
  VersionedRepository,
  LoggedRepository,
  IAuthContext;
```

### Step 6: Create DataLayerImpl in dart_vault

**Create:** `dart_vault_package/lib/client/data_layer_impl.dart`
```dart
import 'package:aq_schema/aq_schema.dart';
import 'package:dart_vault/dart_vault.dart';

class DataLayerImpl implements IDataLayer {
  final Vault _vault;
  final String _endpoint;
  
  DataLayerImpl({required Vault vault, required String endpoint})
    : _vault = vault, _endpoint = endpoint;
  
  @override
  String get tenantId => _vault.tenantId;
  
  @override
  String get endpoint => _endpoint;
  
  @override
  bool get isConnected {
    final storage = _vault.storage;
    if (storage is RemoteVaultStorage) {
      return storage.handshake != null;
    }
    return false;
  }
  
  @override
  String? get serverVersion {
    final storage = _vault.storage;
    if (storage is RemoteVaultStorage) {
      return storage.handshake?.serverVersion;
    }
    return null;
  }
  
  @override
  IBufferedStorage? get buffer => _vault.buffer;
  
  @override
  DirectRepository<T> direct<T extends DirectStorable>({
    required String collection,
    required T Function(Map<String, dynamic>) fromMap,
    List<VaultIndex> indexes = const [],
  }) => _vault.direct<T>(
    collection: collection,
    fromMap: fromMap,
    indexes: indexes,
  );
  
  @override
  VersionedRepository<T> versioned<T extends VersionedStorable>({
    required String collection,
    required T Function(Map<String, dynamic>) fromMap,
    List<VaultIndex> indexes = const [],
  }) => _vault.versioned<T>(
    collection: collection,
    fromMap: fromMap,
    indexes: indexes,
  );
  
  @override
  LoggedRepository<T> logged<T extends LoggedStorable>({
    required String collection,
    required T Function(Map<String, dynamic>) fromMap,
    List<VaultIndex> indexes = const [],
    bool captureFullSnapshot = false,
  }) => _vault.logged<T>(
    collection: collection,
    fromMap: fromMap,
    indexes: indexes,
    captureFullSnapshot: captureFullSnapshot,
  );
  
  @override
  Future<void> dispose() => _vault.dispose();
  
  /// Factory method to create and register implementation.
  static Future<void> initialize({
    required String endpoint,
    bool useBuffer = true,
  }) async {
    // TODO(aq_security): Read from IAuthContext
    final authToken = await IAuthContext.instance?.currentToken;
    final tenantId = await IAuthContext.instance?.currentTenantId ?? 'system';
    
    // Create Vault with remote storage
    final vault = await Vault.remote(
      endpoint: endpoint,
      tenantId: tenantId,
      useBuffer: useBuffer,
    );
    
    // Create implementation
    final impl = DataLayerImpl(
      vault: vault,
      endpoint: endpoint,
    );
    
    // Register with IDataLayer
    IDataLayer.register(impl);
  }
}
```

### Step 7: Wire up initialization in dart_vault

**Update:** `dart_vault_package/lib/dart_vault.dart`
```dart
export 'client/data_layer_impl.dart';

// Override IDataLayer.initialize to use DataLayerImpl
extension IDataLayerInitializer on IDataLayer {
  static Future<void> initialize({
    required String endpoint,
    bool useBuffer = true,
  }) async {
    await DataLayerImpl.initialize(
      endpoint: endpoint,
      useBuffer: useBuffer,
    );
  }
}
```

---

## Architecture Benefits ✅

1. ✅ **One initialization point**: `IDataLayer.initialize(endpoint: '...')`
2. ✅ **One access point**: `IDataLayer.instance.versioned<T>(...)`
3. ✅ **Zero implementation details** - client only sees interfaces
4. ✅ **Source of truth** - all contracts in `aq_schema`
5. ✅ **Auth from IAuthContext** - no auth params in initialize()
6. ✅ **Separation of concerns** - implementation in `dart_vault`

---

## Files Created

```
aq_schema/lib/
├── security/interfaces/clients_protocols/
│   └── i_auth_context.dart                    ← NEW
├── data_layer/
│   ├── i_data_layer.dart                      ← NEW
│   └── repositories/                          ← NEW FOLDER
│       ├── direct_repository.dart             ← MOVED from dart_vault
│       ├── versioned_repository.dart          ← MOVED from dart_vault
│       └── logged_repository.dart             ← MOVED from dart_vault
└── aq_schema.dart                             ← UPDATED exports
```

---

## Status

✅ **aq_schema changes complete**
⏳ **dart_vault implementation pending** (Steps 5-7)

The protocol is now defined in `aq_schema` as the source of truth.
Implementation in `dart_vault` is straightforward - just bridge to existing `Vault` class.
