// pkgs/aq_schema/lib/security/models/aq_tenant.dart
//
// Organization / company entity.
// Every user belongs to exactly one tenant.
// Tenant defines the billing boundary and isolation unit.

/// Subscription plan.
enum TenantPlan {
  free('free'),
  starter('starter'),
  pro('pro'),
  enterprise('enterprise');

  const TenantPlan(this.value);
  final String value;

  static TenantPlan fromString(String s) =>
      TenantPlan.values.firstWhere((e) => e.value == s,
          orElse: () => TenantPlan.free);
}

/// Organization / company.
final class AqTenant {
  const AqTenant({
    required this.id,
    required this.name,
    required this.slug,
    required this.plan,
    required this.isActive,
    required this.createdAt,
    this.ownerId,
    this.logoUrl,
    this.settings = const {},
    this.updatedAt,
  });

  final String id;
  final String name;

  /// URL-safe unique identifier: "acme-corp"
  final String slug;

  final TenantPlan plan;
  final bool isActive;

  /// User ID of the tenant owner.
  final String? ownerId;
  final String? logoUrl;
  final Map<String, dynamic> settings;
  final int createdAt;
  final int? updatedAt;

  factory AqTenant.fromJson(Map<String, dynamic> json) => AqTenant(
        id: json['id'] as String,
        name: json['name'] as String,
        slug: json['slug'] as String,
        plan: TenantPlan.fromString(json['plan'] as String? ?? 'free'),
        isActive: json['isActive'] as bool? ?? true,
        ownerId: json['ownerId'] as String?,
        logoUrl: json['logoUrl'] as String?,
        settings: (json['settings'] as Map<String, dynamic>?) ?? {},
        createdAt: json['createdAt'] as int,
        updatedAt: json['updatedAt'] as int?,
      );

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'id': id,
      'name': name,
      'slug': slug,
      'plan': plan.value,
      'isActive': isActive,
      'createdAt': createdAt,
    };
    if (ownerId != null) m['ownerId'] = ownerId;
    if (logoUrl != null) m['logoUrl'] = logoUrl;
    if (settings.isNotEmpty) m['settings'] = settings;
    if (updatedAt != null) m['updatedAt'] = updatedAt;
    return m;
  }

  AqTenant copyWith({
    String? name,
    String? slug,
    TenantPlan? plan,
    bool? isActive,
    String? ownerId,
    String? logoUrl,
    Map<String, dynamic>? settings,
    int? updatedAt,
  }) =>
      AqTenant(
        id: id,
        name: name ?? this.name,
        slug: slug ?? this.slug,
        plan: plan ?? this.plan,
        isActive: isActive ?? this.isActive,
        ownerId: ownerId ?? this.ownerId,
        logoUrl: logoUrl ?? this.logoUrl,
        settings: settings ?? this.settings,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  String toString() => 'AqTenant(id: $id, slug: $slug, plan: ${plan.value})';
}
