// pkgs/aq_schema/lib/security/mock/mock_audit_service.dart
//
// Mock реализация IAuditService для тестов.

import '../interfaces/i_audit_service.dart';
import '../models/aq_access_log.dart';
import '../models/aq_audit_trail.dart';

/// Mock реализация IAuditService
class MockAuditService implements IAuditService {
  final List<AqAccessLog> _accessLogs = [];
  final List<AqAuditTrail> _auditTrail = [];

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
    _accessLogs.add(AqAccessLog(
      id: 'log_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      userEmail: userEmail,
      tenantId: tenantId,
      resource: resource,
      action: action,
      allowed: allowed,
      timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      reason: reason,
      ipAddress: ipAddress,
      userAgent: userAgent,
      metadata: metadata,
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
    _auditTrail.add(AqAuditTrail(
      id: 'audit_${DateTime.now().millisecondsSinceEpoch}',
      action: action,
      entityType: entityType,
      entityId: entityId,
      entityName: entityName,
      userId: userId,
      userEmail: userEmail,
      tenantId: tenantId,
      timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      changes: changes,
      reason: reason,
      ipAddress: ipAddress,
      metadata: metadata,
    ));
  }

  @override
  Future<List<AqAccessLog>> getAccessLogs(AccessLogFilter filter) async {
    var logs = List<AqAccessLog>.from(_accessLogs);

    // Применяем фильтры
    if (filter.userId != null) {
      logs = logs.where((l) => l.userId == filter.userId).toList();
    }
    if (filter.tenantId != null) {
      logs = logs.where((l) => l.tenantId == filter.tenantId).toList();
    }
    if (filter.resource != null) {
      logs = logs.where((l) => l.resource.contains(filter.resource!)).toList();
    }
    if (filter.action != null) {
      logs = logs.where((l) => l.action == filter.action).toList();
    }
    if (filter.allowed != null) {
      logs = logs.where((l) => l.allowed == filter.allowed).toList();
    }
    if (filter.startTime != null) {
      logs = logs.where((l) => l.timestamp >= filter.startTime!).toList();
    }
    if (filter.endTime != null) {
      logs = logs.where((l) => l.timestamp <= filter.endTime!).toList();
    }

    // Сортировка по времени (desc)
    logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // Pagination
    final start = filter.offset;
    final end = (start + filter.limit).clamp(0, logs.length);
    return logs.sublist(start, end);
  }

  @override
  Future<List<AqAuditTrail>> getAuditTrail(AuditTrailFilter filter) async {
    var trail = List<AqAuditTrail>.from(_auditTrail);

    // Применяем фильтры
    if (filter.userId != null) {
      trail = trail.where((t) => t.userId == filter.userId).toList();
    }
    if (filter.tenantId != null) {
      trail = trail.where((t) => t.tenantId == filter.tenantId).toList();
    }
    if (filter.action != null) {
      trail = trail.where((t) => t.action == filter.action).toList();
    }
    if (filter.entityType != null) {
      trail = trail.where((t) => t.entityType == filter.entityType).toList();
    }
    if (filter.entityId != null) {
      trail = trail.where((t) => t.entityId == filter.entityId).toList();
    }
    if (filter.startTime != null) {
      trail = trail.where((t) => t.timestamp >= filter.startTime!).toList();
    }
    if (filter.endTime != null) {
      trail = trail.where((t) => t.timestamp <= filter.endTime!).toList();
    }
    if (filter.searchQuery != null) {
      final query = filter.searchQuery!.toLowerCase();
      trail = trail.where((t) =>
        t.entityName.toLowerCase().contains(query) ||
        t.userEmail.toLowerCase().contains(query) ||
        (t.reason?.toLowerCase().contains(query) ?? false)
      ).toList();
    }

    // Сортировка по времени (desc)
    trail.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // Pagination
    final start = filter.offset;
    final end = (start + filter.limit).clamp(0, trail.length);
    return trail.sublist(start, end);
  }

  @override
  Future<Map<String, dynamic>> getAccessLogStats({
    String? tenantId,
    required int startTime,
    required int endTime,
  }) async {
    var logs = _accessLogs.where((l) =>
      l.timestamp >= startTime && l.timestamp <= endTime
    );

    if (tenantId != null) {
      logs = logs.where((l) => l.tenantId == tenantId);
    }

    final total = logs.length;
    final allowed = logs.where((l) => l.allowed).length;
    final denied = total - allowed;

    return {
      'total': total,
      'allowed': allowed,
      'denied': denied,
      'byResource': <String, int>{},
      'byAction': <String, int>{},
      'topUsers': <Map<String, dynamic>>[],
      'deniedReasons': <String, int>{},
    };
  }

  @override
  Future<Map<String, dynamic>> getAuditTrailStats({
    String? tenantId,
    required int startTime,
    required int endTime,
  }) async {
    var trail = _auditTrail.where((t) =>
      t.timestamp >= startTime && t.timestamp <= endTime
    );

    if (tenantId != null) {
      trail = trail.where((t) => t.tenantId == tenantId);
    }

    return {
      'total': trail.length,
      'byAction': <String, int>{},
      'byEntityType': <String, int>{},
      'topUsers': <Map<String, dynamic>>[],
    };
  }

  @override
  Future<int> cleanupAccessLogs({required int olderThan}) async {
    final before = _accessLogs.length;
    _accessLogs.removeWhere((l) => l.timestamp < olderThan);
    return before - _accessLogs.length;
  }

  @override
  Future<int> cleanupAuditTrail({required int olderThan}) async {
    final before = _auditTrail.length;
    _auditTrail.removeWhere((t) => t.timestamp < olderThan);
    return before - _auditTrail.length;
  }
}
