// pkgs/aq_schema/lib/security/models/aq_user.dart
//
// Platform user entity. All participants — humans and machines — are AqUsers.

/// What kind of user this is.
enum UserType {
  platformAdmin('platform_admin'),
  developer('developer'),
  endUser('end_user'),
  service('service'); // machine-to-machine

  const UserType(this.value);
  final String value;

  static UserType fromString(String s) =>
      UserType.values.firstWhere((e) => e.value == s,
          orElse: () => UserType.endUser);
}

/// Which identity provider authenticated this user.
enum AuthProvider {
  google('google'),
  emailPassword('email_password'),
  apiKey('api_key'),
  mock('mock');

  const AuthProvider(this.value);
  final String value;

  static AuthProvider fromString(String s) =>
      AuthProvider.values.firstWhere((e) => e.value == s,
          orElse: () => AuthProvider.mock);
}

/// A platform user.
final class AqUser {
  const AqUser({
    required this.id,
    required this.email,
    required this.userType,
    required this.tenantId,
    required this.authProvider,
    required this.isActive,
    required this.createdAt,
    this.displayName,
    this.photoUrl,
    this.providerUserId,
    this.isVerified = false,
    this.lastLoginAt,
    this.updatedAt,
  });

  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final UserType userType;

  /// The tenant this user belongs to.
  final String tenantId;

  final AuthProvider authProvider;

  /// User ID in the external provider (Google `sub`, etc.).
  final String? providerUserId;

  final bool isActive;
  final bool isVerified;
  final int? lastLoginAt;
  final int createdAt;
  final int? updatedAt;

  factory AqUser.fromJson(Map<String, dynamic> json) => AqUser(
        id: json['id'] as String,
        email: json['email'] as String,
        displayName: json['displayName'] as String?,
        photoUrl: json['photoUrl'] as String?,
        userType: UserType.fromString(json['userType'] as String? ?? 'end_user'),
        tenantId: json['tenantId'] as String,
        authProvider: AuthProvider.fromString(
            json['authProvider'] as String? ?? 'mock'),
        providerUserId: json['providerUserId'] as String?,
        isActive: json['isActive'] as bool? ?? true,
        isVerified: json['isVerified'] as bool? ?? false,
        lastLoginAt: json['lastLoginAt'] as int?,
        createdAt: json['createdAt'] as int,
        updatedAt: json['updatedAt'] as int?,
      );

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'id': id,
      'email': email,
      'userType': userType.value,
      'tenantId': tenantId,
      'authProvider': authProvider.value,
      'isActive': isActive,
      'isVerified': isVerified,
      'createdAt': createdAt,
    };
    if (displayName != null) m['displayName'] = displayName;
    if (photoUrl != null) m['photoUrl'] = photoUrl;
    if (providerUserId != null) m['providerUserId'] = providerUserId;
    if (lastLoginAt != null) m['lastLoginAt'] = lastLoginAt;
    if (updatedAt != null) m['updatedAt'] = updatedAt;
    return m;
  }

  AqUser copyWith({
    String? displayName,
    String? photoUrl,
    UserType? userType,
    bool? isActive,
    bool? isVerified,
    int? lastLoginAt,
    int? updatedAt,
  }) =>
      AqUser(
        id: id,
        email: email,
        displayName: displayName ?? this.displayName,
        photoUrl: photoUrl ?? this.photoUrl,
        userType: userType ?? this.userType,
        tenantId: tenantId,
        authProvider: authProvider,
        providerUserId: providerUserId,
        isActive: isActive ?? this.isActive,
        isVerified: isVerified ?? this.isVerified,
        lastLoginAt: lastLoginAt ?? this.lastLoginAt,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  String toString() =>
      'AqUser(id: $id, email: $email, type: ${userType.value})';
}
