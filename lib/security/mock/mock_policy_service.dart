// pkgs/aq_schema/lib/security/mock/mock_policy_service.dart
//
// Mock реализация IPolicyService для тестов.

import '../interfaces/i_policy_service.dart';
import '../models/aq_policy.dart';

/// Mock реализация IPolicyService
class MockPolicyService implements IPolicyService {
  final List<AqPolicy> _policies = [];

  @override
  Future<List<AqPolicy>> getPolicies({bool includeInactive = false}) async {
    if (includeInactive) {
      return List.from(_policies);
    }
    return _policies.where((p) => p.isActive).toList();
  }

  @override
  Future<AqPolicy?> getPolicy(String policyId) async {
    try {
      return _policies.firstWhere((p) => p.id == policyId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AqPolicy> createPolicy({
    required String name,
    String? description,
    required List<PolicyStatement> statements,
    bool isActive = true,
    int priority = 0,
  }) async {
    final policy = AqPolicy(
      id: 'policy_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: description,
      tenantId: 'mock_tenant',
      statements: statements,
      isActive: isActive,
      priority: priority,
      createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      createdBy: 'mock_user',
    );
    _policies.add(policy);
    return policy;
  }

  @override
  Future<AqPolicy> updatePolicy({
    required String policyId,
    String? name,
    String? description,
    List<PolicyStatement>? statements,
    bool? isActive,
    int? priority,
  }) async {
    final index = _policies.indexWhere((p) => p.id == policyId);
    if (index == -1) throw Exception('Policy not found');

    final oldPolicy = _policies[index];
    final updatedPolicy = AqPolicy(
      id: oldPolicy.id,
      name: name ?? oldPolicy.name,
      description: description ?? oldPolicy.description,
      tenantId: oldPolicy.tenantId,
      statements: statements ?? oldPolicy.statements,
      isActive: isActive ?? oldPolicy.isActive,
      priority: priority ?? oldPolicy.priority,
      createdAt: oldPolicy.createdAt,
      createdBy: oldPolicy.createdBy,
    );

    _policies[index] = updatedPolicy;
    return updatedPolicy;
  }

  @override
  Future<void> deletePolicy(String policyId) async {
    _policies.removeWhere((p) => p.id == policyId);
  }

  @override
  Future<PolicyEvaluationResult> evaluatePolicy(PolicyContext context) async {
    // Mock: всегда разрешаем
    return PolicyEvaluationResult.allow(
      matchedPolicies: _policies.where((p) => p.isActive).map((p) => p.id).toList(),
    );
  }

  @override
  Future<PolicyEvaluationResult> testPolicy({
    required String userId,
    required String resource,
    required String action,
    Map<String, dynamic>? additionalContext,
  }) async {
    return PolicyEvaluationResult.allow(
      matchedPolicies: ['mock_policy'],
    );
  }
}
