// aq_schema/lib/security/mock/mock_policy_service.dart
//
// Mock IPolicyService — использует MockSecurityBackend.
//
// Гарантии реализации (aq_security обязан соблюдать):
//   getPolicies()                       → все активные политики
//   createPolicy(новая)                 → сохранена в backend
//   createPolicy(дублирующее имя)       → throws Exception('policy_already_exists')
//   deletePolicy(несуществующая)        → throws Exception('policy_not_found')
//   evaluatePolicy(IP в blacklist)      → deny
//   evaluatePolicy(IP не в blacklist)   → allow

import '../interfaces/i_policy_service.dart';
import '../models/aq_policy.dart';
import '../models/access_context.dart';
import '../models/access_decision.dart';
import 'backend/mock_security_backend.dart';

final class MockPolicyService implements IPolicyService {
  MockPolicyService(this._backend);

  final MockSecurityBackend _backend;

  @override
  Future<List<AqPolicy>> getPolicies({bool includeInactive = false}) async =>
      _backend.policies
          .where((p) => includeInactive || p.isActive)
          .toList();

  @override
  Future<AqPolicy?> getPolicyById(String policyId) async =>
      _backend.policies.where((p) => p.id == policyId).firstOrNull;

  @override
  Future<AqPolicy> createPolicy({
    required String name,
    String? description,
    required List<PolicyStatement> statements,
    int priority = 0,
    String? tenantId,
  }) async {
    if (_backend.policies.any((p) => p.name == name)) {
      throw Exception('policy_already_exists');
    }
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final policy = AqPolicy(
      id: 'policy-${_backend.policies.length + 1}',
      name: name,
      description: description,
      tenantId: tenantId ?? 'default',
      priority: priority,
      isActive: true,
      statements: statements,
      createdAt: now,
      createdBy: 'mock',
    );
    _backend.policies.add(policy);
    return policy;
  }

  @override
  Future<AqPolicy> updatePolicy({
    required String policyId,
    String? name,
    String? description,
    List<PolicyStatement>? statements,
    int? priority,
    bool? isActive,
  }) async {
    final idx = _backend.policies.indexWhere((p) => p.id == policyId);
    if (idx == -1) throw Exception('policy_not_found');
    final old = _backend.policies[idx];
    final updated = AqPolicy(
      id: old.id,
      name: name ?? old.name,
      description: description ?? old.description,
      tenantId: old.tenantId,
      priority: priority ?? old.priority,
      isActive: isActive ?? old.isActive,
      statements: statements ?? old.statements,
      createdAt: old.createdAt,
      createdBy: old.createdBy,
      updatedAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    );
    _backend.policies[idx] = updated;
    return updated;
  }

  @override
  Future<void> deletePolicy(String policyId) async {
    final removed = _backend.policies.removeWhere((p) => p.id == policyId);
    if (removed == 0) throw Exception('policy_not_found');
  }

  @override
  Future<PolicyEvaluationResult> evaluatePolicy(
    PolicyContext context,
  ) async {
    for (final policy in _backend.policies
        .where((p) => p.isActive)
        .toList()
      ..sort((a, b) => b.priority.compareTo(a.priority))) {
      for (final statement in policy.statements) {
        if (_matchesConditions(statement.conditions, context)) {
          if (statement.effect == PolicyEffect.deny) {
            return PolicyEvaluationResult(
              allowed: false,
              reason: 'Denied by policy: ${policy.name}',
              appliedPolicyId: policy.id,
            );
          }
        }
      }
    }
    return const PolicyEvaluationResult(allowed: true, reason: 'No policy denied');
  }

  bool _matchesConditions(
    List<PolicyCondition> conditions,
    PolicyContext context,
  ) {
    for (final cond in conditions) {
      if (cond.type == PolicyConditionType.ipAddress) {
        final blocked = (cond.value as List).cast<String>();
        if (context.ipAddress != null && blocked.contains(context.ipAddress)) {
          return true;
        }
      }
    }
    return false;
  }
}
