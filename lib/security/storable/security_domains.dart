// pkgs/aq_schema/lib/security/storable/security_domains.dart
//
// Описание всех security-доменов для VaultRegistry.
// Сервер читает этот список чтобы:
//   1. Создать таблицы (через PostgresSchemaDeployer)
//   2. Зарегистрировать коллекции в VaultRegistry
//
// Паттерн идентичен AqDomains в aq_schema/lib/adapter/adapter_models.dart.

import 'package:aq_schema/aq_schema.dart';
import 'security_storables.dart';

/// Все security домены — единый источник истины.
/// Сервер и клиент читают этот список.
class AqSecurityDomains {
  AqSecurityDomains._();

  static final List<DomainDescriptor<Storable>> all = [
    // ── Users (Direct) ───────────────────────────────────────────────────────
    DomainDescriptor.direct(
      collection: SecurityCollections.users,
      fromMap: StorableUser.fromMap,
      indexes: [
        VaultIndex(name: 'idx_sec_users_email', field: 'email'),
        VaultIndex(name: 'idx_sec_users_tenant', field: 'tenantId'),
        VaultIndex(name: 'idx_sec_users_provider_id', field: 'providerUserId'),
      ],
    ),

    // ── Tenants (Direct) ─────────────────────────────────────────────────────
    DomainDescriptor.direct(
      collection: SecurityCollections.tenants,
      fromMap: StorableTenant.fromMap,
      indexes: [
        VaultIndex(name: 'idx_sec_tenants_slug', field: 'slug', unique: true),
        VaultIndex(name: 'idx_sec_tenants_owner', field: 'ownerId'),
      ],
    ),

    // ── Profiles (Direct) ────────────────────────────────────────────────────
    DomainDescriptor.direct(
      collection: SecurityCollections.profiles,
      fromMap: StorableProfile.fromMap,
      indexes: [
        VaultIndex(name: 'idx_sec_profiles_user', field: 'userId'),
      ],
    ),

    // ── Roles (Direct) ───────────────────────────────────────────────────────
    DomainDescriptor.direct(
      collection: SecurityCollections.roles,
      fromMap: StorableRole.fromMap,
      indexes: [
        VaultIndex(name: 'idx_sec_roles_name', field: 'name'),
        VaultIndex(name: 'idx_sec_roles_tenant', field: 'tenantId'),
      ],
    ),

    // ── UserRoles (Direct) ───────────────────────────────────────────────────
    DomainDescriptor.direct(
      collection: SecurityCollections.userRoles,
      fromMap: StorableUserRole.fromMap,
      indexes: [
        VaultIndex(name: 'idx_sec_ur_user', field: 'userId'),
        VaultIndex(name: 'idx_sec_ur_tenant', field: 'tenantId'),
      ],
    ),

    // ── Sessions (Logged) ────────────────────────────────────────────────────
    // LoggedStorable → таблица data + data__log
    DomainDescriptor.logged(
      collection: SecurityCollections.sessions,
      fromMap: StorableSession.fromMap,
      indexes: [
        VaultIndex(name: 'idx_sec_sess_user', field: 'userId'),
        VaultIndex(name: 'idx_sec_sess_status', field: 'status'),
        VaultIndex(name: 'idx_sec_sess_expires', field: 'expiresAt'),
      ],
    ),

    // ── ApiKeys (Logged) ─────────────────────────────────────────────────────
    DomainDescriptor.logged(
      collection: SecurityCollections.apiKeys,
      fromMap: StorableApiKey.fromMap,
      indexes: [
        VaultIndex(name: 'idx_sec_apikey_hash', field: 'keyHash', unique: true),
        VaultIndex(name: 'idx_sec_apikey_user', field: 'userId'),
        VaultIndex(name: 'idx_sec_apikey_active', field: 'isActive'),
      ],
    ),
  ];
}
