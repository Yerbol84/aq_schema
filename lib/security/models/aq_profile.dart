// pkgs/aq_schema/lib/security/models/aq_profile.dart
//
// Extended user profile. 1:1 with AqUser.

final class AqProfile {
  const AqProfile({
    required this.userId,
    this.bio,
    this.timezone,
    this.locale,
    this.preferences = const {},
    this.updatedAt,
  });

  final String userId;
  final String? bio;

  /// IANA timezone: 'Europe/Berlin'
  final String? timezone;

  /// BCP-47 locale: 'en-US', 'ru'
  final String? locale;

  final Map<String, dynamic> preferences;
  final int? updatedAt;

  factory AqProfile.fromJson(Map<String, dynamic> json) => AqProfile(
        userId: json['userId'] as String,
        bio: json['bio'] as String?,
        timezone: json['timezone'] as String?,
        locale: json['locale'] as String?,
        preferences: (json['preferences'] as Map<String, dynamic>?) ?? {},
        updatedAt: json['updatedAt'] as int?,
      );

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{'userId': userId};
    if (bio != null) m['bio'] = bio;
    if (timezone != null) m['timezone'] = timezone;
    if (locale != null) m['locale'] = locale;
    if (preferences.isNotEmpty) m['preferences'] = preferences;
    if (updatedAt != null) m['updatedAt'] = updatedAt;
    return m;
  }

  AqProfile copyWith({
    String? bio,
    String? timezone,
    String? locale,
    Map<String, dynamic>? preferences,
    int? updatedAt,
  }) =>
      AqProfile(
        userId: userId,
        bio: bio ?? this.bio,
        timezone: timezone ?? this.timezone,
        locale: locale ?? this.locale,
        preferences: preferences ?? this.preferences,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
