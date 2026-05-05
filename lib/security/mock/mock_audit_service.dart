// aq_schema/lib/security/mock/mock_audit_service.dart
//
// Mock IAuditService — использует MockSecurityBackend.
//
// Гарантии реализации (aq_security обязан соблюдать):
//   logAccess(...)                      → запись в accessLogs
//   logAudit(...)                       → запись в auditTrail
//   getAccessLogs(userId)               → логи только этого пользователя
//   getAuditTrail(entityId)             → trail только этой сущности
//   clearOldLogs(before)                → удаляет записи старше before

import '../interfaces/i_audit_service.dart';
import '../models/aq_access_log.dart';
import '../models/aq_audit_trail.dart';
import 'backend/mock_security_backend.dart';

final class MockAuditService implements IAuditService {
  MockAuditService(this._backend);

  final MockSecurityBackend _backend;

  @override
  Future<void> logAccess({
    required String userId,
    required String userEmail,
    required String tenantId,
    required String resource,
    required String action,
    required bool allowed,
    String? reason,
    String? ipAddress,
    Map<String, dynamic>? metadata,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    _backend.accessLogs.add(AqAccessLog(
      id: 'log-${_backend.accessLogs.length}',
      userId: userId,
      userEmail: userEmail,
      tenantId: tenantId,
      resource: resource,
      action: action,
      allowed: allowed,
      reason: reason,
      ipAddress: ipAddress,
      timestamp: now,
    ));
  }

  @override
  Future<void> logAudit({
    required String userId,
    required String userEmail,
    required String tenantId,
    required AuditEntityType entityType,
    required String entityId,
    required String entityName,
    required AuditAction action,
    Map<String, dynamic>? before,
    Map<String, dynamic>? after,
    String? ipAddress,
    Map<String, dynamic>? metadata,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    _backend.auditTrail.add(AqAuditTrail(
      id: 'audit-${_backend.auditTrail.length}',
      userId: userId,
      userEmail: userEmail,
      tenantId: tenantId,
      entityType: entityType,
      entityId: entityId,
      entityName: entityName,
      action: action,
      before: before,
      after: after,
      ipAddress: ipAddress,
      timestamp: now,
    ));
  }

  @override
  Future<List<AqAccessLog>> getAccessLogs({
    String? userId,
    String? resource,
    String? action,
    bool? allowed,
    DateTime? from,
    DateTime? to,
    int limit = 50,
    int offset = 0,
  }) async {
    var logs = _backend.accessLogs.toList();
    if (userId != null) logs = logs.where((l) => l.userId == userId).toList();
    if (resource != null) logs = logs.where((l) => l.resource == resource).toList();
    if (action != null) logs = logs.where((l) => l.action == action).toList();
    if (allowed != null) logs = logs.where((l) => l.allowed == allowed).toList();
    if (from != null) {
      final fromTs = from.millisecondsSinceEpoch ~/ 1000;
      logs = logs.where((l) => l.timestamp >= fromTs).toList();
    }
    if (to != null) {
      final toTs = to.millisecondsSinceEpoch ~/ 1000;
      logs = logs.where((l) => l.timestamp <= toTs).toList();
    }
    return logs.skip(offset).take(limit).toList();
  }

  @override
  Future<List<AqAuditTrail>> getAuditTrail({
    String? entityId,
    AuditEntityType? entityType,
    String? userId,
    DateTime? from,
    DateTime? to,
    int limit = 50,
    int offset = 0,
  }) async {
    var trail = _backend.auditTrail.toList();
    if (entityId != null) trail = trail.where((t) => t.entityId == entityId).toList();
    if (entityType != null) trail = trail.where((t) => t.entityType == entityType).toList();
    if (userId != null) trail = trail.where((t) => t.userId == userId).toList();
    return trail.skip(offset).take(limit).toList();
  }

  @override
  Future<int> clearOldLogs(DateTime before) async {
    final beforeTs = before.millisecondsSinceEpoch ~/ 1000;
    final removedLogs = _backend.accessLogs
        .where((l) => l.timestamp < beforeTs)
        .length;
    _backend.accessLogs.removeWhere((l) => l.timestamp < beforeTs);
    _backend.auditTrail.removeWhere((t) => t.timestamp < beforeTs);
    return removedLogs;
  }
}
