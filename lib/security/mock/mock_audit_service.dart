// aq_schema/lib/security/mock/mock_audit_service.dart
//
// Mock IAuditService — использует MockSecurityBackend.
//
// Гарантии реализации (aq_security обязан соблюдать):
//   logAccess(...)                      → запись в accessLogs
//   logAudit(...)                       → запись в auditTrail
//   getAccessLogs(filter)               → логи по фильтру
//   getAuditTrail(filter)               → trail по фильтру
//   cleanupAccessLogs(olderThan)        → удаляет старые записи

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
    String? userAgent,
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
    required AuditActionType action,
    required AuditEntityType entityType,
    required String entityId,
    required String entityName,
    required String userId,
    required String userEmail,
    required String tenantId,
    Map<String, dynamic>? changes,
    String? reason,
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
      changes: changes,
      reason: reason,
      ipAddress: ipAddress,
      timestamp: now,
    ));
  }

  @override
  Future<List<AqAccessLog>> getAccessLogs(AccessLogFilter filter) async {
    var logs = _backend.accessLogs.toList();
    if (filter.userId != null) {
      logs = logs.where((l) => l.userId == filter.userId).toList();
    }
    if (filter.resource != null) {
      logs = logs.where((l) => l.resource == filter.resource).toList();
    }
    if (filter.action != null) {
      logs = logs.where((l) => l.action == filter.action).toList();
    }
    if (filter.allowed != null) {
      logs = logs.where((l) => l.allowed == filter.allowed).toList();
    }
    return logs
        .skip(filter.offset)
        .take(filter.limit)
        .toList();
  }

  @override
  Future<List<AqAuditTrail>> getAuditTrail(AuditTrailFilter filter) async {
    var trail = _backend.auditTrail.toList();
    if (filter.entityId != null) {
      trail = trail.where((t) => t.entityId == filter.entityId).toList();
    }
    if (filter.entityType != null) {
      trail = trail.where((t) => t.entityType == filter.entityType).toList();
    }
    if (filter.userId != null) {
      trail = trail.where((t) => t.userId == filter.userId).toList();
    }
    return trail
        .skip(filter.offset)
        .take(filter.limit)
        .toList();
  }

  @override
  Future<Map<String, dynamic>> getAccessLogStats({
    String? tenantId,
    required int startTime,
    required int endTime,
  }) async {
    final logs = _backend.accessLogs
        .where((l) => l.timestamp >= startTime && l.timestamp <= endTime)
        .toList();
    return {
      'total': logs.length,
      'allowed': logs.where((l) => l.allowed).length,
      'denied': logs.where((l) => !l.allowed).length,
    };
  }

  @override
  Future<Map<String, dynamic>> getAuditTrailStats({
    String? tenantId,
    required int startTime,
    required int endTime,
  }) async {
    final trail = _backend.auditTrail
        .where((t) => t.timestamp >= startTime && t.timestamp <= endTime)
        .toList();
    return {'total': trail.length};
  }

  @override
  Future<int> cleanupAccessLogs({required int olderThan}) async {
    final before = _backend.accessLogs
        .where((l) => l.timestamp < olderThan)
        .length;
    _backend.accessLogs.removeWhere((l) => l.timestamp < olderThan);
    return before;
  }

  @override
  Future<int> cleanupAuditTrail({required int olderThan}) async {
    final before = _backend.auditTrail
        .where((t) => t.timestamp < olderThan)
        .length;
    _backend.auditTrail.removeWhere((t) => t.timestamp < olderThan);
    return before;
  }
}
