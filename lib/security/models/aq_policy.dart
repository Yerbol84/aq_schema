// pkgs/aq_schema/lib/security/models/aq_policy.dart
//
// Policy-based access control для сложных правил доступа.
// Позволяет определять условия доступа на основе контекста (время, IP, атрибуты).

/// Тип условия в policy
enum PolicyConditionType {
  timeRange('time_range'),           // Временной диапазон
  ipAddress('ip_address'),           // IP адрес
  userAttribute('user_attribute'),   // Атрибут пользователя
  resourceAttribute('resource_attribute'), // Атрибут ресурса
  scope('scope'),                    // Scope requirement
  role('role'),                      // Role requirement
  custom('custom');                  // Кастомное условие

  const PolicyConditionType(this.value);
  final String value;

  static PolicyConditionType fromString(String s) =>
      PolicyConditionType.values.firstWhere((e) => e.value == s);
}

/// Оператор сравнения
enum PolicyOperator {
  equals('equals'),
  notEquals('not_equals'),
  contains('contains'),
  notContains('not_contains'),
  greaterThan('greater_than'),
  lessThan('less_than'),
  inList('in_list'),
  notInList('not_in_list'),
  matches('matches');              // Regex match

  const PolicyOperator(this.value);
  final String value;

  static PolicyOperator fromString(String s) =>
      PolicyOperator.values.firstWhere((e) => e.value == s);
}

/// Логический оператор для композиции условий
enum PolicyLogic {
  and('and'),
  or('or'),
  not('not');

  const PolicyLogic(this.value);
  final String value;

  static PolicyLogic fromString(String s) =>
      PolicyLogic.values.firstWhere((e) => e.value == s);
}

/// Policy effect — разрешить или запретить
enum PolicyEffect {
  allow('allow'),
  deny('deny');

  const PolicyEffect(this.value);
  final String value;

  static PolicyEffect fromString(String s) =>
      PolicyEffect.values.firstWhere((e) => e.value == s);
}

/// Policy condition — одно условие
final class PolicyCondition {
  const PolicyCondition({
    required this.type,
    required this.operator,
    required this.value,
    this.field,
  });

  final PolicyConditionType type;
  final PolicyOperator operator;
  final dynamic value;
  final String? field;  // Для user_attribute, resource_attribute

  factory PolicyCondition.fromJson(Map<String, dynamic> json) => PolicyCondition(
        type: PolicyConditionType.fromString(json['type'] as String),
        operator: PolicyOperator.fromString(json['operator'] as String),
        value: json['value'],
        field: json['field'] as String?,
      );

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'type': type.value,
      'operator': operator.value,
      'value': value,
    };
    if (field != null) m['field'] = field;
    return m;
  }
}

/// Policy statement — группа условий с логикой
final class PolicyStatement {
  const PolicyStatement({
    required this.effect,
    required this.conditions,
    this.logic = PolicyLogic.and,
  });

  final PolicyEffect effect;
  final List<PolicyCondition> conditions;
  final PolicyLogic logic;

  factory PolicyStatement.fromJson(Map<String, dynamic> json) => PolicyStatement(
        effect: PolicyEffect.fromString(json['effect'] as String),
        conditions: (json['conditions'] as List<dynamic>)
            .map((c) => PolicyCondition.fromJson(c as Map<String, dynamic>))
            .toList(),
        logic: json['logic'] != null
            ? PolicyLogic.fromString(json['logic'] as String)
            : PolicyLogic.and,
      );

  Map<String, dynamic> toJson() => {
        'effect': effect.value,
        'conditions': conditions.map((c) => c.toJson()).toList(),
        'logic': logic.value,
      };
}

/// Policy — полное правило доступа
final class AqPolicy {
  const AqPolicy({
    required this.id,
    required this.name,
    required this.tenantId,
    required this.statements,
    required this.createdAt,
    required this.createdBy,
    this.description,
    this.isActive = true,
    this.priority = 0,
  });

  static const String kCollection = 'rbac_policies';

  final String id;
  final String name;
  final String? description;
  final String tenantId;
  final List<PolicyStatement> statements;
  final bool isActive;
  final int priority;  // Больше = выше приоритет
  final int createdAt;
  final String createdBy;

  AqPolicy copyWith({
    String? id,
    String? name,
    String? description,
    String? tenantId,
    List<PolicyStatement>? statements,
    bool? isActive,
    int? priority,
    int? createdAt,
    String? createdBy,
  }) {
    return AqPolicy(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      tenantId: tenantId ?? this.tenantId,
      statements: statements ?? this.statements,
      isActive: isActive ?? this.isActive,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  factory AqPolicy.fromJson(Map<String, dynamic> json) => AqPolicy(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        tenantId: json['tenantId'] as String,
        statements: (json['statements'] as List<dynamic>)
            .map((s) => PolicyStatement.fromJson(s as Map<String, dynamic>))
            .toList(),
        isActive: json['isActive'] as bool? ?? true,
        priority: json['priority'] as int? ?? 0,
        createdAt: json['createdAt'] as int,
        createdBy: json['createdBy'] as String,
      );

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'id': id,
      'name': name,
      'tenantId': tenantId,
      'statements': statements.map((s) => s.toJson()).toList(),
      'isActive': isActive,
      'priority': priority,
      'createdAt': createdAt,
      'createdBy': createdBy,
    };
    if (description != null) m['description'] = description;
    return m;
  }
}

/// Policy evaluation context — контекст для проверки policy
final class PolicyContext {
  const PolicyContext({
    required this.userId,
    required this.tenantId,
    this.userAttributes = const {},
    this.resourceAttributes = const {},
    this.ipAddress,
    this.timestamp,
    this.scopes = const [],
    this.roles = const [],
  });

  final String userId;
  final String tenantId;
  final Map<String, dynamic> userAttributes;
  final Map<String, dynamic> resourceAttributes;
  final String? ipAddress;
  final int? timestamp;
  final List<String> scopes;
  final List<String> roles;

  factory PolicyContext.fromJson(Map<String, dynamic> json) => PolicyContext(
        userId: json['userId'] as String,
        tenantId: json['tenantId'] as String,
        userAttributes: json['userAttributes'] as Map<String, dynamic>? ?? {},
        resourceAttributes: json['resourceAttributes'] as Map<String, dynamic>? ?? {},
        ipAddress: json['ipAddress'] as String?,
        timestamp: json['timestamp'] as int?,
        scopes: (json['scopes'] as List<dynamic>?)?.cast<String>() ?? [],
        roles: (json['roles'] as List<dynamic>?)?.cast<String>() ?? [],
      );

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'tenantId': tenantId,
        'userAttributes': userAttributes,
        'resourceAttributes': resourceAttributes,
        if (ipAddress != null) 'ipAddress': ipAddress,
        if (timestamp != null) 'timestamp': timestamp,
        'scopes': scopes,
        'roles': roles,
      };
}

/// Policy evaluation result
final class PolicyEvaluationResult {
  const PolicyEvaluationResult({
    required this.allowed,
    this.matchedPolicies = const [],
    this.reason,
  });

  final bool allowed;
  final List<String> matchedPolicies;  // IDs matched policies
  final String? reason;

  factory PolicyEvaluationResult.allow({List<String>? matchedPolicies}) =>
      PolicyEvaluationResult(
        allowed: true,
        matchedPolicies: matchedPolicies ?? [],
      );

  factory PolicyEvaluationResult.deny({String? reason, List<String>? matchedPolicies}) =>
      PolicyEvaluationResult(
        allowed: false,
        reason: reason,
        matchedPolicies: matchedPolicies ?? [],
      );
}

/// Repository interface для policies
abstract interface class IPolicyRepository {
  Future<AqPolicy> create(AqPolicy policy);
  Future<AqPolicy> update(AqPolicy policy);
  Future<void> delete(String policyId);
  Future<AqPolicy?> findById(String id);
  Future<List<AqPolicy>> findByTenant(String tenantId);
  Future<List<AqPolicy>> findActive(String tenantId);
}

/// Алиас для обратной совместимости
/// Используется в aq_security для единообразия именования
typedef AqAccessPolicy = AqPolicy;
