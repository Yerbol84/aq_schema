// pkgs/aq_schema/lib/security/models/access_decision.dart
//
// Результат проверки доступа в RBAC системе.
// Используется AccessControlEngine для возврата решения о доступе.

/// Результат проверки доступа
///
/// Содержит решение (разрешено/запрещено) и причину.
/// Используется как возвращаемый тип для методов проверки доступа.
final class AccessDecision {
  const AccessDecision({
    required this.allowed,
    this.reason,
    this.matchedRoles = const [],
    this.matchedPermissions = const [],
    this.appliedPolicies = const [],
    this.evaluationTimeMs,
  });

  /// Разрешён ли доступ
  final bool allowed;

  /// Причина решения (особенно важна для denied)
  ///
  /// Примеры:
  /// - "Permission 'projects:write' granted via role 'Editor'"
  /// - "Access denied: missing permission 'admin:*'"
  /// - "Policy 'IP Whitelist' denied access"
  /// - "Role 'Admin' required but not assigned"
  final String? reason;

  /// Список ролей, которые были проверены и совпали
  final List<String> matchedRoles;

  /// Список разрешений, которые были найдены
  final List<String> matchedPermissions;

  /// Список ID политик, которые были применены
  final List<String> appliedPolicies;

  /// Время оценки в миллисекундах (для метрик)
  final int? evaluationTimeMs;

  /// Фабрика для создания положительного решения
  factory AccessDecision.allow({
    String? reason,
    List<String>? matchedRoles,
    List<String>? matchedPermissions,
    List<String>? appliedPolicies,
    int? evaluationTimeMs,
  }) =>
      AccessDecision(
        allowed: true,
        reason: reason,
        matchedRoles: matchedRoles ?? [],
        matchedPermissions: matchedPermissions ?? [],
        appliedPolicies: appliedPolicies ?? [],
        evaluationTimeMs: evaluationTimeMs,
      );

  /// Фабрика для создания отрицательного решения
  factory AccessDecision.deny({
    required String reason,
    List<String>? matchedRoles,
    List<String>? appliedPolicies,
    int? evaluationTimeMs,
  }) =>
      AccessDecision(
        allowed: false,
        reason: reason,
        matchedRoles: matchedRoles ?? [],
        matchedPermissions: [],
        appliedPolicies: appliedPolicies ?? [],
        evaluationTimeMs: evaluationTimeMs,
      );

  factory AccessDecision.fromJson(Map<String, dynamic> json) => AccessDecision(
        allowed: json['allowed'] as bool,
        reason: json['reason'] as String?,
        matchedRoles: (json['matchedRoles'] as List<dynamic>?)?.cast<String>() ?? [],
        matchedPermissions: (json['matchedPermissions'] as List<dynamic>?)?.cast<String>() ?? [],
        appliedPolicies: (json['appliedPolicies'] as List<dynamic>?)?.cast<String>() ?? [],
        evaluationTimeMs: json['evaluationTimeMs'] as int?,
      );

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'allowed': allowed,
    };
    if (reason != null) m['reason'] = reason;
    if (matchedRoles.isNotEmpty) m['matchedRoles'] = matchedRoles;
    if (matchedPermissions.isNotEmpty) m['matchedPermissions'] = matchedPermissions;
    if (appliedPolicies.isNotEmpty) m['appliedPolicies'] = appliedPolicies;
    if (evaluationTimeMs != null) m['evaluationTimeMs'] = evaluationTimeMs;
    return m;
  }

  @override
  String toString() => 'AccessDecision(allowed: $allowed, reason: $reason)';
}
