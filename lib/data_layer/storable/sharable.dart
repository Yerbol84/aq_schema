import 'storable.dart';

/// Interface for entities that support multi-tenancy and sharing.
///
/// Entities implementing this interface can be:
/// - Owned by a specific tenant (organization, team, user)
/// - Shared with other tenants via access control
/// - Isolated by tenant_id in storage
///
/// ## Multi-tenancy
///
/// [tenantId] identifies the owning tenant. Storage backends use this to:
/// - Filter queries (WHERE tenant_id = ?)
/// - Enforce data isolation
/// - Support multi-tenant SaaS deployments
///
/// ## Ownership
///
/// [ownerId] identifies the creator/owner within the tenant.
/// Used for:
/// - Permission checks (can this user edit?)
/// - Audit trails (who created this?)
/// - Default access control
///
/// ## Sharing
///
/// [defaultSharingPolicy] defines who can access this entity:
/// - 'private': only owner
/// - 'tenant': all users in the same tenant
/// - 'public': anyone (use with caution!)
///
/// Fine-grained access is managed via the `access_grants` table in storage.
abstract interface class Sharable implements Storable {
  /// Tenant (organization/team) that owns this entity.
  /// Used for data isolation in multi-tenant deployments.
  String get tenantId;

  /// User/actor who created this entity.
  /// Used for ownership checks and audit trails.
  String get ownerId;

  /// Default sharing policy: 'private', 'tenant', or 'public'.
  /// Storage backends use this to determine default access.
  String get defaultSharingPolicy;
}
