// pkgs/aq_schema/lib/security/storable/storable_rbac.dart
//
// Storable wrappers для RBAC моделей.
//
// Mapping:
//   AqRole        → DirectStorable   (используется StorableRole из security_storables.dart)
//   AqUserRole    → DirectStorable   (назначения ролей)
//   AqPolicy      → DirectStorable   (политики доступа)
//   AqAccessLog   → LoggedStorable   (логи доступа с аудитом)
//   AqAuditTrail  → LoggedStorable   (аудит изменений)

import 'package:aq_schema/data_layer/storable/direct_storable.dart';
import 'package:aq_schema/data_layer/storable/logged_storable.dart';

import '../models/aq_role.dart';
import '../models/aq_policy.dart';
import '../models/aq_access_log.dart';
import '../models/aq_audit_trail.dart';

// ═══════════════════════════════════════════
//  DirectStorable — RBAC entities
// ═══════════════════════════════════════════

// NOTE: StorableAqRole удалён — используется StorableRole из security_storables.dart
// Это устраняет дублирование и обеспечивает единую коллекцию 'security_roles'

/// Storable обёртка для AqUserRole
final class StorableAqUserRole implements DirectStorable {
  StorableAqUserRole(this._userRole);
  final AqUserRole _userRole;
  AqUserRole get domain => _userRole;

  @override
  String get id =>
      '${_userRole.userId}_${_userRole.roleId}_${_userRole.tenantId}';

  @override
  Map<String, dynamic> toMap() => _userRole.toJson();

  @override
  Map<String, dynamic> get indexFields => {
        'userId': _userRole.userId,
        'roleId': _userRole.roleId,
        'tenantId': _userRole.tenantId,
      };

  @override
  Map<String, dynamic> get jsonSchema => {
        'type': 'object',
        'properties': {
          'userId': {'type': 'string'},
          'roleId': {'type': 'string'},
          'tenantId': {'type': 'string'},
          'grantedAt': {'type': 'integer'},
        },
        'required': ['userId', 'roleId', 'tenantId', 'grantedAt'],
      };

  static StorableAqUserRole fromMap(Map<String, dynamic> m) =>
      StorableAqUserRole(AqUserRole.fromJson(m));

  @override
  String get collectionName => AqUserRole.kCollection;

  @override
  // TODO: implement softDelete
  bool get softDelete => true;
}

/// TODO: Миграция на VersionedStorable
/// См. pkgs/dart_vault_package/other_layer_tasks/secure_layer/REQUIREMENTS_FOR_DATA_LAYER.md
///
/// Когда дата-слой подтвердит поддержку VersionedRepository:
/// - Изменить implements DirectStorable → implements VersionedStorable
/// - Добавить entityId, ownerId, sharedWith
/// - Обновить VaultPolicyRepository для работы с версиями
/// - Создать миграционный скрипт для существующих данных
///
/// Storable обёртка для AqPolicy
final class StorableAqPolicy implements DirectStorable {
  StorableAqPolicy(this._policy);
  final AqPolicy _policy;
  AqPolicy get domain => _policy;

  @override
  String get id => _policy.id;

  @override
  Map<String, dynamic> toMap() => _policy.toJson();

  @override
  Map<String, dynamic> get indexFields => {
        'name': _policy.name,
        'tenantId': _policy.tenantId,
        'isActive': _policy.isActive,
        'priority': _policy.priority,
      };

  @override
  Map<String, dynamic> get jsonSchema => {
        'type': 'object',
        'properties': {
          'id': {'type': 'string'},
          'name': {'type': 'string'},
          'tenantId': {'type': 'string'},
          'isActive': {'type': 'boolean'},
          'priority': {'type': 'integer'},
          'statements': {'type': 'array'},
        },
        'required': [
          'id',
          'name',
          'tenantId',
          'statements',
          'createdAt',
          'createdBy'
        ],
      };

  static StorableAqPolicy fromMap(Map<String, dynamic> m) =>
      StorableAqPolicy(AqPolicy.fromJson(m));

  @override
  String get collectionName => AqPolicy.kCollection;

  @override
  bool get softDelete => true;
}

// ═══════════════════════════════════════════
//  LoggedStorable — RBAC audit entities
// ═══════════════════════════════════════════

/// Storable обёртка для AqAccessLog
final class StorableAqAccessLog implements LoggedStorable {
  StorableAqAccessLog(this._log);
  final AqAccessLog _log;
  AqAccessLog get domain => _log;

  @override
  String get id => _log.id;

  @override
  Map<String, dynamic> toMap() => _log.toJson();

  @override
  Set<String> get trackedFields => {
        'allowed',
        'reason',
        'timestamp',
      };

  @override
  Map<String, dynamic> get indexFields => {
        'userId': _log.userId,
        'tenantId': _log.tenantId,
        'resource': _log.resource,
        'action': _log.action,
        'allowed': _log.allowed,
        'timestamp': _log.timestamp,
      };

  @override
  Map<String, dynamic> get jsonSchema => {
        'type': 'object',
        'properties': {
          'id': {'type': 'string'},
          'userId': {'type': 'string'},
          'userEmail': {'type': 'string'},
          'tenantId': {'type': 'string'},
          'resource': {'type': 'string'},
          'action': {'type': 'string'},
          'allowed': {'type': 'boolean'},
          'timestamp': {'type': 'integer'},
        },
        'required': [
          'id',
          'userId',
          'userEmail',
          'tenantId',
          'resource',
          'action',
          'allowed',
          'timestamp'
        ],
      };

  static StorableAqAccessLog fromMap(Map<String, dynamic> m) =>
      StorableAqAccessLog(AqAccessLog.fromJson(m));

  @override
  String get collectionName => AqAccessLog.kCollection;

  @override
  bool get softDelete => true;
}

/// Storable обёртка для AqAuditTrail
final class StorableAqAuditTrail implements LoggedStorable {
  StorableAqAuditTrail(this._trail);
  final AqAuditTrail _trail;
  AqAuditTrail get domain => _trail;

  @override
  String get id => _trail.id;

  @override
  Map<String, dynamic> toMap() => _trail.toJson();

  @override
  Set<String> get trackedFields => {
        'action',
        'changes',
        'timestamp',
      };

  @override
  Map<String, dynamic> get indexFields => {
        'userId': _trail.userId,
        'tenantId': _trail.tenantId,
        'entityType': _trail.entityType.value,
        'entityId': _trail.entityId,
        'action': _trail.action.value,
        'timestamp': _trail.timestamp,
      };

  @override
  Map<String, dynamic> get jsonSchema => {
        'type': 'object',
        'properties': {
          'id': {'type': 'string'},
          'userId': {'type': 'string'},
          'userEmail': {'type': 'string'},
          'tenantId': {'type': 'string'},
          'entityType': {'type': 'string'},
          'entityId': {'type': 'string'},
          'entityName': {'type': 'string'},
          'action': {'type': 'string'},
          'timestamp': {'type': 'integer'},
        },
        'required': [
          'id',
          'userId',
          'userEmail',
          'tenantId',
          'entityType',
          'entityId',
          'entityName',
          'action',
          'timestamp'
        ],
      };

  static StorableAqAuditTrail fromMap(Map<String, dynamic> m) =>
      StorableAqAuditTrail(AqAuditTrail.fromJson(m));

  @override
  String get collectionName => AqAuditTrail.kCollection;

  @override
  bool get softDelete => true;
}
