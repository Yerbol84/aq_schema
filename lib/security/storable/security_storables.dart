// pkgs/aq_schema/lib/security/storable/security_storables.dart
//
// Storable wrappers for all security domain models.
//
// Mapping:
//   AqUser      → DirectStorable   (simple CRUD, no history needed)
//   AqTenant    → DirectStorable
//   AqProfile   → DirectStorable
//   AqRole      → DirectStorable
//   AqUserRole  → DirectStorable
//   AqSession   → LoggedStorable   (audit: active→revoked→expired)
//   AqApiKey    → LoggedStorable   (audit: isActive, lastUsedAt)
//
// DirectRepository  understands DirectStorable
// LoggedRepository  understands LoggedStorable
// VersionedRepository understands VersionedStorable (not used here)

import 'package:aq_schema/data_layer/storable/direct_storable.dart';
import 'package:aq_schema/data_layer/storable/logged_storable.dart';

export 'storable_rbac.dart';

import '../models/aq_user.dart';
import '../models/aq_tenant.dart';
import '../models/aq_profile.dart';
import '../models/aq_role.dart';
import '../models/aq_session.dart';
import '../models/aq_api_key.dart';

// ── Collection names ──────────────────────────────────────────────────────────

abstract final class SecurityCollections {
  static const users = 'security_users';
  static const tenants = 'security_tenants';
  static const profiles = 'security_profiles';
  static const roles = 'security_roles';
  static const userRoles = 'security_user_roles';
  static const sessions = 'security_sessions';
  static const apiKeys = 'security_api_keys';
  static const all = [
    users,
    tenants,
    profiles,
    roles,
    userRoles,
    sessions,
    apiKeys
  ];
}

// ═══════════════════════════════════════════
//  DirectStorable — simple CRUD entities
// ═══════════════════════════════════════════

final class StorableUser implements DirectStorable {
  StorableUser(this._user);
  final AqUser _user;
  AqUser get domain => _user;

  @override
  String get id => _user.id;
  @override
  Map<String, dynamic> toMap() => _user.toJson();
  @override
  Map<String, dynamic> get indexFields => {
        'email': _user.email,
        'tenantId': _user.tenantId,
        'authProvider': _user.authProvider.value,
        'providerUserId': _user.providerUserId ?? '',
        'userType': _user.userType.value,
        'isActive': _user.isActive,
      };
  @override
  Map<String, dynamic> get jsonSchema => {
        'type': 'object',
        'properties': {
          'id': {'type': 'string'},
          'email': {'type': 'string', 'format': 'email'},
          'tenantId': {'type': 'string'},
          'authProvider': {'type': 'string'},
          'providerUserId': {'type': 'string'},
          'userType': {'type': 'string'},
          'isActive': {'type': 'boolean'},
        },
        'required': ['id', 'email', 'tenantId'],
      };
  static StorableUser fromMap(Map<String, dynamic> m) =>
      StorableUser(AqUser.fromJson(m));

  @override
  String get collectionName => SecurityCollections.users;

  @override
  bool get softDelete => true;
}

final class StorableTenant implements DirectStorable {
  StorableTenant(this._t);
  final AqTenant _t;
  AqTenant get domain => _t;

  @override
  String get id => _t.id;
  @override
  Map<String, dynamic> toMap() => _t.toJson();
  @override
  Map<String, dynamic> get indexFields => {
        'slug': _t.slug,
        'plan': _t.plan.value,
        'isActive': _t.isActive,
        'ownerId': _t.ownerId ?? '',
      };
  @override
  Map<String, dynamic> get jsonSchema => {
        'type': 'object',
        'properties': {
          'id': {'type': 'string'},
          'slug': {'type': 'string'},
          'plan': {'type': 'string'},
          'isActive': {'type': 'boolean'},
          'ownerId': {'type': 'string'},
        },
        'required': ['id', 'slug'],
      };
  static StorableTenant fromMap(Map<String, dynamic> m) =>
      StorableTenant(AqTenant.fromJson(m));

  @override
  String get collectionName => SecurityCollections.tenants;

  @override
  bool get softDelete => true;
}

final class StorableProfile implements DirectStorable {
  StorableProfile(this._p);
  final AqProfile _p;
  AqProfile get domain => _p;

  @override
  String get id => _p.userId; // 1:1 with user
  @override
  Map<String, dynamic> toMap() => _p.toJson();
  @override
  Map<String, dynamic> get indexFields => {
        'userId': _p.userId,
        'locale': _p.locale ?? '',
      };
  @override
  Map<String, dynamic> get jsonSchema => {
        'type': 'object',
        'properties': {
          'userId': {'type': 'string'},
          'locale': {'type': 'string'},
        },
        'required': ['userId'],
      };
  static StorableProfile fromMap(Map<String, dynamic> m) =>
      StorableProfile(AqProfile.fromJson(m));

  @override
  String get collectionName => SecurityCollections.profiles;

  @override
  bool get softDelete => true;
}

/// TODO: Миграция на VersionedStorable
/// См. pkgs/dart_vault_package/other_layer_tasks/secure_layer/REQUIREMENTS_FOR_DATA_LAYER.md
///
/// Когда дата-слой подтвердит поддержку VersionedRepository:
/// - Изменить implements DirectStorable → implements VersionedStorable
/// - Добавить entityId, ownerId, sharedWith
/// - Обновить VaultRoleRepository для работы с версиями
/// - Создать миграционный скрипт для существующих данных
final class StorableRole implements DirectStorable {
  StorableRole(this._r);
  final AqRole _r;
  AqRole get domain => _r;

  @override
  String get id => _r.id;
  @override
  Map<String, dynamic> toMap() => _r.toJson();
  @override
  Map<String, dynamic> get indexFields => {
        'name': _r.name,
        'tenantId': _r.tenantId ?? '',
        'isSystem': _r.isSystem,
      };
  @override
  Map<String, dynamic> get jsonSchema => {
        'type': 'object',
        'properties': {
          'id': {'type': 'string'},
          'name': {'type': 'string'},
          'tenantId': {'type': 'string'},
          'isSystem': {'type': 'boolean'},
        },
        'required': ['id', 'name'],
      };
  static StorableRole fromMap(Map<String, dynamic> m) =>
      StorableRole(AqRole.fromJson(m));

  @override
  String get collectionName => SecurityCollections.roles;

  @override
  bool get softDelete => true;
}

final class StorableUserRole implements DirectStorable {
  StorableUserRole(this._ur);
  final AqUserRole _ur;
  AqUserRole get domain => _ur;

  /// Composite PK guarantees uniqueness per assignment.
  @override
  String get id => '${_ur.userId}_${_ur.roleId}_${_ur.tenantId}';
  @override
  Map<String, dynamic> toMap() => _ur.toJson();
  @override
  Map<String, dynamic> get indexFields => {
        'userId': _ur.userId,
        'roleId': _ur.roleId,
        'tenantId': _ur.tenantId,
      };
  @override
  Map<String, dynamic> get jsonSchema => {
        'type': 'object',
        'properties': {
          'userId': {'type': 'string'},
          'roleId': {'type': 'string'},
          'tenantId': {'type': 'string'},
        },
        'required': ['userId', 'roleId', 'tenantId'],
      };
  static StorableUserRole fromMap(Map<String, dynamic> m) =>
      StorableUserRole(AqUserRole.fromJson(m));

  @override
  String get collectionName => SecurityCollections.userRoles;

  @override
  bool get softDelete => true;

  // ── TTL Support (заглушка, ожидает реализацию от дата-слоя) ──────────────────

  /// TODO: Ожидает реализацию TTL Support в dart_vault
  /// См. pkgs/dart_vault_package/other_layer_tasks/secure_layer/REQUIREMENTS_FOR_DATA_LAYER.md
  ///
  /// Когда дата-слой реализует TTL:
  /// - Раскомментировать этот метод
  /// - Временные назначения ролей будут автоматически удаляться при expiration
  /// - Клиент больше не будет видеть expired назначения

  // @override
  // int? get expiresAt => _ur.expiresAt;
}

// ═══════════════════════════════════════════
//  LoggedStorable — entities with audit trail
// ═══════════════════════════════════════════

/// Session is LoggedStorable — LoggedRepository records a diff
/// on every save(), giving us full audit of status transitions.
final class StorableSession implements LoggedStorable {
  StorableSession(this._s);
  final AqSession _s;
  AqSession get domain => _s;

  @override
  String get id => _s.id;
  @override
  Map<String, dynamic> toMap() => _s.toJson();

  /// Only status-relevant fields in diff log — other fields are static.
  @override
  Set<String> get trackedFields => {
        'status',
        'lastSeenAt',
        'revokedAt',
        'revokedReason',
      };
  @override
  Map<String, dynamic> get indexFields => {
        'userId': _s.userId,
        'tenantId': _s.tenantId,
        'status': _s.status.value,
        'expiresAt': _s.expiresAt,
      };
  @override
  Map<String, dynamic> get jsonSchema => {
        'type': 'object',
        'properties': {
          'id': {'type': 'string'},
          'userId': {'type': 'string'},
          'tenantId': {'type': 'string'},
          'status': {'type': 'string'},
          'expiresAt': {'type': 'string', 'format': 'date-time'},
        },
        'required': ['id', 'userId', 'tenantId'],
      };
  static StorableSession fromMap(Map<String, dynamic> m) =>
      StorableSession(AqSession.fromJson(m));

  @override
  String get collectionName => SecurityCollections.sessions;

  @override
  bool get softDelete => true;

  // ── TTL Support (заглушка, ожидает реализацию от дата-слоя) ──────────────────

  /// TODO: Ожидает реализацию TTL Support в dart_vault
  /// См. pkgs/dart_vault_package/other_layer_tasks/secure_layer/REQUIREMENTS_FOR_DATA_LAYER.md
  ///
  /// Когда дата-слой реализует TTL:
  /// - Раскомментировать эти методы
  /// - Удалить ручную expiration логику из VaultSessionRepository.purgeExpired()

  // @override
  // int? get expiresAt => _s.expiresAt;

  // @override
  // StorableSession? onExpire() {
  //   return StorableSession(_s.copyWith(
  //     status: SessionStatus.expired,
  //   ));
  // }
}

/// ApiKey is LoggedStorable — track creation, revocation, last-used.
final class StorableApiKey implements LoggedStorable {
  StorableApiKey(this._k);
  final AqApiKey _k;
  AqApiKey get domain => _k;

  @override
  String get id => _k.id;
  @override
  Map<String, dynamic> toMap() => _k.toJson();

  @override
  Set<String> get trackedFields => {'isActive', 'lastUsedAt'};
  @override
  Map<String, dynamic> get indexFields => {
        'userId': _k.userId,
        'tenantId': _k.tenantId,
        'keyHash': _k.keyHash,
        'isActive': _k.isActive,
      };
  @override
  Map<String, dynamic> get jsonSchema => {
        'type': 'object',
        'properties': {
          'id': {'type': 'string'},
          'userId': {'type': 'string'},
          'tenantId': {'type': 'string'},
          'keyHash': {'type': 'string'},
          'isActive': {'type': 'boolean'},
        },
        'required': ['id', 'userId', 'tenantId', 'keyHash'],
      };
  static StorableApiKey fromMap(Map<String, dynamic> m) =>
      StorableApiKey(AqApiKey.fromJson(m));

  @override
  String get collectionName => SecurityCollections.apiKeys;

  @override
  bool get softDelete => true;

  // ── TTL Support (заглушка, ожидает реализацию от дата-слоя) ──────────────────

  /// TODO: Ожидает реализацию TTL Support в dart_vault
  /// См. pkgs/dart_vault_package/other_layer_tasks/secure_layer/REQUIREMENTS_FOR_DATA_LAYER.md
  ///
  /// Когда дата-слой реализует TTL:
  /// - Раскомментировать эти методы
  /// - API ключи будут автоматически деактивироваться при expiration

  // @override
  // int? get expiresAt => _k.expiresAt;

  // @override
  // StorableApiKey? onExpire() {
  //   return StorableApiKey(_k.copyWith(
  //     isActive: false,
  //   ));
  // }
}
