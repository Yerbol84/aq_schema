# API Contract Pattern - Implementation Guide

## Overview

The API Contract pattern provides a **single source of truth** for HTTP routes across all AQ services. This prevents client-server route mismatches and ensures type-safe API communication.

## Architecture

```
aq_schema/
├── core/
│   ├── interfaces/
│   │   └── i_aq_api_contract.dart      # Generic interface
│   └── models/
│       └── route_spec.dart             # Route metadata model
└── {service}/
    └── api_contract/
        ├── {service}_api_contract.dart        # Contract implementation
        └── {service}_api_route_builder.dart   # Type-safe builder
```

## Existing Implementations

### 1. Vault Data Service

**Location:** `aq_schema/lib/data_layer/api_contract/`

**Contract:** `VaultApiContract`

**Routes:**
- `POST /v1/vault/handshake` - Connection handshake
- `POST /v1/vault/rpc` - Repository operations
- `GET /v1/vault/watch` - SSE change notifications
- `GET /v1/vault/health` - Health check

**Usage Example:**
```dart
// Client
final contract = VaultApiContract();
final url = contract.buildUrl('http://localhost:8765', 'handshake');
await http.post(Uri.parse(url), body: jsonEncode(request));

// Server
final router = Router()
  ..post(contract.getFullRoute('handshake'), handleHandshake);
```

## How to Add New API Contracts

### Step 1: Create Contract Class

Create `aq_schema/lib/{service}/api_contract/{service}_api_contract.dart`:

```dart
import '../../core/interfaces/i_aq_api_contract.dart';
import '../../core/models/route_spec.dart';
import '{service}_api_route_builder.dart';

class AuthApiContract implements IAqApiContract {
  const AuthApiContract();

  @override
  String get apiVersion => 'v1';

  @override
  String get basePath => '/auth';

  @override
  Map<String, RouteSpec> get routes => {
    'login': const RouteSpec(
      path: '/login',
      method: 'POST',
      requestType: Map, // LoginRequest
      responseType: Map, // LoginResponse
      description: 'Authenticate user and return JWT token',
      requiresAuth: false,
    ),
    'logout': const RouteSpec(
      path: '/logout',
      method: 'POST',
      description: 'Invalidate current session',
      requiresAuth: true,
    ),
    'refresh': const RouteSpec(
      path: '/refresh',
      method: 'POST',
      requestType: Map, // RefreshTokenRequest
      responseType: Map, // RefreshTokenResponse
      description: 'Refresh access token using refresh token',
      requiresAuth: false,
    ),
  };

  @override
  IAqApiRouteBuilder createRouteBuilder(String baseUrl) {
    return AuthApiRouteBuilder(this, baseUrl);
  }

  // Route name constants
  static const String routeLogin = 'login';
  static const String routeLogout = 'logout';
  static const String routeRefresh = 'refresh';
}
```

### Step 2: Create Route Builder

Create `aq_schema/lib/{service}/api_contract/{service}_api_route_builder.dart`:

```dart
import '../../core/interfaces/i_aq_api_contract.dart';
import '{service}_api_contract.dart';

class AuthApiRouteBuilder implements IAqApiRouteBuilder {
  @override
  final AuthApiContract contract;

  @override
  final String baseUrl;

  const AuthApiRouteBuilder(this.contract, this.baseUrl);

  /// Build URL for login endpoint
  /// Route: POST /v1/auth/login
  String login() {
    return contract.buildUrl(baseUrl, AuthApiContract.routeLogin);
  }

  /// Build URL for logout endpoint
  /// Route: POST /v1/auth/logout
  String logout() {
    return contract.buildUrl(baseUrl, AuthApiContract.routeLogout);
  }

  /// Build URL for token refresh endpoint
  /// Route: POST /v1/auth/refresh
  String refresh() {
    return contract.buildUrl(baseUrl, AuthApiContract.routeRefresh);
  }
}
```

### Step 3: Export from aq_schema

Add to `aq_schema/lib/aq_schema.dart`:

```dart
// API Contracts
export 'core/interfaces/i_aq_api_contract.dart';
export 'core/models/route_spec.dart';
export '{service}/api_contract/{service}_api_contract.dart';
export '{service}/api_contract/{service}_api_route_builder.dart';
```

### Step 4: Use in Client Package

In your client package (e.g., `aq_auth_client`):

```dart
import 'package:aq_schema/aq_schema.dart';
import 'package:http/http.dart' as http;

class AuthClient {
  final String baseUrl;
  final AuthApiContract _contract = const AuthApiContract();
  late final AuthApiRouteBuilder _routes;

  AuthClient(this.baseUrl) {
    _routes = _contract.createRouteBuilder(baseUrl);
  }

  Future<LoginResponse> login(String email, String password) async {
    final url = _routes.login();  // Type-safe!
    final response = await http.post(
      Uri.parse(url),
      body: jsonEncode({'email': email, 'password': password}),
    );
    return LoginResponse.fromJson(jsonDecode(response.body));
  }

  Future<void> logout() async {
    final url = _routes.logout();  // Type-safe!
    await http.post(Uri.parse(url));
  }
}
```

### Step 5: Use in Server Package

In your server package (e.g., `aq_auth_service`):

```dart
import 'package:aq_schema/aq_schema.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

void main() async {
  final contract = AuthApiContract();

  final router = Router()
    ..post(contract.getFullRoute('login'), _handleLogin)
    ..post(contract.getFullRoute('logout'), _handleLogout)
    ..post(contract.getFullRoute('refresh'), _handleRefresh);

  final handler = Pipeline()
    .addMiddleware(logRequests())
    .addHandler(router);

  await serve(handler, '0.0.0.0', 8080);
  print('✅ Auth Service running on http://0.0.0.0:8080');
}

Response _handleLogin(Request request) async {
  // Implementation
}
```

## Route Versioning

### Adding v2 API

When you need to introduce breaking changes:

```dart
class AuthApiContractV2 implements IAqApiContract {
  const AuthApiContractV2();

  @override
  String get apiVersion => 'v2';  // ← Changed version

  @override
  String get basePath => '/auth';

  @override
  Map<String, RouteSpec> get routes => {
    'login': const RouteSpec(
      path: '/login',
      method: 'POST',
      // New request/response format
      description: 'Authenticate user with OAuth2',
      requiresAuth: false,
    ),
    // ... other routes
  };
}
```

Server can support both versions:

```dart
final contractV1 = AuthApiContract();
final contractV2 = AuthApiContractV2();

final router = Router()
  // v1 routes
  ..post(contractV1.getFullRoute('login'), _handleLoginV1)
  // v2 routes
  ..post(contractV2.getFullRoute('login'), _handleLoginV2);
```

## Benefits

✅ **Single Source of Truth** - Routes defined once in aq_schema
✅ **Type Safety** - Compile-time errors if routes mismatch
✅ **No Magic Strings** - All routes are constants
✅ **Versioning** - Easy to add v2 API alongside v1
✅ **Documentation** - Contract IS the documentation
✅ **Testing** - Can validate both sides against contract
✅ **Refactoring** - Change route once, updates everywhere

## Services That Should Implement This

- ✅ **Vault Data Service** - Implemented (2026-04-20)
  - Routes: handshake, rpc, watch, health
  - Client: RemoteVaultStorage
  - Server: dart_vault_package/example/stack/server
- ⏳ **Auth Service** - TODO
- ⏳ **MCP Adapter** - TODO
- ⏳ **Queue Service** - TODO
- ⏳ **Graph Worker** - TODO

## Migration Checklist

When migrating existing service to use API contracts:

### Phase 1: Create Contract
1. [ ] Create contract class with `AqApiContract` mixin
2. [ ] Create route builder extending `AqApiRouteBuilder`
3. [ ] Export from `aq_schema/lib/aq_schema.dart`

### Phase 2: Find All Hardcoded Routes ⚠️ CRITICAL
**Don't skip this!** Search entire codebase for hardcoded routes:

```bash
# From project root
cd pkgs

# Find all hardcoded routes
grep -r "'/handshake'" .
grep -r "'/rpc'" .
grep -r "'/health'" .
grep -r "'/watch'" .
grep -r '"/vault/' .
grep -r "'$endpoint/" .
grep -r '"$url/' .

# Check for string concatenation patterns
grep -r '\$endpoint/' .
grep -r '\$url/' .
grep -r '\$baseUrl/' .
```

### Phase 3: Update ALL Occurrences
For each file found:

1. [ ] Import contract: `import 'package:aq_schema/aq_schema.dart';`
2. [ ] Create contract instance: `final contract = VaultApiContract();`
3. [ ] Replace hardcoded routes:
   - `'$url/health'` → `contract.buildUrl(url, 'health')`
   - `'$endpoint/vault/handshake'` → `contract.buildUrl(endpoint, 'handshake')`
   - `'$endpoint/vault/rpc'` → `contract.buildUrl(endpoint, 'rpc')`

**Files to check:**
- [ ] Client storage implementations (`RemoteVaultStorage`, etc.)
- [ ] Server route handlers (`main.dart`, `router.dart`)
- [ ] Test files (`*_test.dart`)
- [ ] Example apps (`example/*/main.dart`)
- [ ] Health check utilities
- [ ] Documentation examples

### Phase 4: Verify End-to-End ⚠️ REQUIRED
1. [ ] Rebuild server: `docker compose up --build`
2. [ ] Check server logs for correct routes
3. [ ] Run client and verify connection
4. [ ] Check server logs for 404s (should be ZERO)
5. [ ] Test all operations (CRUD, handshake, health)
6. [ ] Verify data persists to database

### Phase 5: Update Documentation
1. [ ] Update README with new route patterns
2. [ ] Update API documentation
3. [ ] Add migration notes for other developers

## Common Mistakes (Lessons from 2026-04-20)

❌ **Creating the contract but not using it everywhere**
- Symptom: 404 errors in server logs
- Fix: Use grep to find ALL hardcoded routes (Phase 2)

❌ **Using contract in main code but not in tests/examples**
- Symptom: Tests pass but examples fail
- Fix: Check example apps and test utilities

❌ **Forgetting health check endpoints**
- Symptom: Health checks fail, main operations work
- Fix: Search for `/health` specifically

❌ **Not testing end-to-end after migration**
- Symptom: Looks good in code review, fails in production
- Fix: Always run actual client against actual server

❌ **Server returns raw data instead of wrapped VaultRpcResponse**
- Symptom: Client throws "Remote operation failed" despite 200 OK
- Fix: Server must wrap ALL responses in `{'success': true, 'data': ...}` format
- Example:
  ```dart
  // ❌ WRONG - returning raw data
  return Response.ok(jsonEncode(entityData));
  
  // ✅ CORRECT - wrapped in VaultRpcResponse format
  return Response.ok(jsonEncode({
    'success': true,
    'data': entityData,
  }));
  ```

❌ **Not rebuilding Docker after code changes**
- Symptom: Server logs show old behavior despite code updates
- Fix: Always `docker compose down && docker compose up --build`
- Verify: Check server logs for new debug output

## Key Insight

**Tool creation ≠ Problem solved**

Creating the API Contract Pattern was only 50% of the work. The other 50% was:
- Finding ALL places that use routes
- Migrating them ALL
- Verifying NOTHING was missed
- Testing the COMPLETE flow
- Ensuring server wraps responses correctly

Don't declare victory until the client successfully connects to the server and data persists to the database.

## Vault Data Service Implementation Summary (2026-04-20)

### What Was Fixed

1. **API Contract Pattern** - Single source of truth for routes
   - Created `VaultApiContract` with `AqApiContract` mixin
   - Routes: `/v1/vault/handshake`, `/v1/vault/rpc`, `/v1/vault/health`
   - Updated client (`RemoteVaultStorage`) to use contract
   - Updated server (`main.dart`) to use contract

2. **VaultRpcResponse Protocol** - Proper response wrapping
   - Server now wraps ALL responses: `{'success': true, 'data': ...}`
   - Error responses: `{'success': false, 'error': ..., 'errorCode': ...}`
   - Client parses wrapped format correctly

3. **Comprehensive Logging** - Debug visibility
   - Client logs: HTTP requests/responses with body preview
   - Server logs: RPC requests/responses with operation details
   - Error tracking with stack traces

4. **Docker Configuration** - Proper build context
   - Fixed build context path: `../../..` (points to pkgs/)
   - PostgreSQL SSL disabled: `sslMode: SslMode.disable`
   - Multi-stage build for optimized image

### Files Modified

**aq_schema (Protocol Layer):**
- `lib/core/interfaces/i_aq_api_contract.dart` - Generic contract mixin
- `lib/data_layer/api_contract/vault_api_contract.dart` - Vault routes
- `doc/API_CONTRACT_PATTERN.md` - Documentation

**dart_vault_package (Implementation Layer):**
- `lib/client/remote/remote_vault_storage.dart` - Client uses contract
- `lib/client/vault.dart` - Enhanced error logging
- `lib/client/data_layer_impl.dart` - Fixed isConnected detection
- `example/stack/server/main.dart` - Server uses contract + wraps responses
- `example/stack/docker-compose.yml` - Fixed build context
- `example/stack/console_client/main.dart` - Uses contract for health check
- `example/stack/console_client/main_comprehensive.dart` - Demo all storage modes
- `doc/STORAGE_MODES_AND_DELETION.md` - Storage mode documentation

### How to Verify

```bash
# 1. Rebuild server
cd pkgs/dart_vault_package/example/stack
docker compose down
docker compose up --build

# 2. Run comprehensive test
cd console_client
dart run main_comprehensive.dart

# 3. Check database
docker exec -it <postgres-container> psql -U vault_user -d vault_db
SELECT * FROM projects;
SELECT entity_id, node_id, state, version FROM workflow_graphs;
SELECT * FROM workflow_runs;
SELECT id, operation FROM workflow_runs_log;
```

### Expected Results

- ✅ Client connects to server successfully
- ✅ All CRUD operations work (create, read, update, delete)
- ✅ DirectStorage: Hard delete (record removed)
- ✅ VersionedStorage: Soft delete (state flag changed)
- ✅ LoggedStorage: Hard delete with audit trail
- ✅ Data persists to PostgreSQL
- ✅ No 404 errors in server logs
- ✅ No "Remote operation failed" errors

## Questions?

See existing implementation: `aq_schema/lib/data_layer/api_contract/vault_api_contract.dart`

---

**Last Updated:** 2026-04-20  
**Author:** AQ Architecture Team
