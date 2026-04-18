// pkgs/aq_schema/lib/security/models/credentials.dart
//
// Единый носитель учетных данных для авторизации.
// Сервер получает знакомую сущность, классифицирует по типу и передает обработчику.

/// Базовый носитель учетных данных для авторизации
abstract class Credentials {
  /// Тип учетных данных (discriminator для JSON)
  String get type;

  Map<String, dynamic> toJson();

  /// Фабрика для десериализации
  factory Credentials.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'google_oauth' => GoogleOAuthCredentials.fromJson(json),
      'email_password' => EmailPasswordCredentials.fromJson(json),
      'api_key' => ApiKeyCredentials.fromJson(json),
      'service_token' => ServiceTokenCredentials.fromJson(json),
      _ => throw Exception('Unknown credentials type: $type'),
    };
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  Google OAuth2 authorization code
// ═════════════════════════════════════════════════════════════════════════════

/// Google OAuth2 authorization code exchange
class GoogleOAuthCredentials implements Credentials {
  const GoogleOAuthCredentials({
    required this.code,
    required this.redirectUri,
  });

  final String code;
  final String redirectUri;

  @override
  String get type => 'google_oauth';

  factory GoogleOAuthCredentials.fromJson(Map<String, dynamic> json) =>
      GoogleOAuthCredentials(
        code: json['code'] as String,
        redirectUri: json['redirectUri'] as String,
      );

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'code': code,
        'redirectUri': redirectUri,
      };

  @override
  String toString() => 'GoogleOAuthCredentials(code: ${code.substring(0, 8)}...)';
}

// ═════════════════════════════════════════════════════════════════════════════
//  Email + Password (для будущего)
// ═════════════════════════════════════════════════════════════════════════════

/// Email + Password authentication
class EmailPasswordCredentials implements Credentials {
  const EmailPasswordCredentials({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  String get type => 'email_password';

  factory EmailPasswordCredentials.fromJson(Map<String, dynamic> json) =>
      EmailPasswordCredentials(
        email: json['email'] as String,
        password: json['password'] as String,
      );

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'email': email,
        'password': password,
      };

  @override
  String toString() => 'EmailPasswordCredentials(email: $email)';
}

// ═════════════════════════════════════════════════════════════════════════════
//  API ключ (для workers)
// ═════════════════════════════════════════════════════════════════════════════

/// API key authentication (для workers и service accounts)
class ApiKeyCredentials implements Credentials {
  const ApiKeyCredentials({required this.apiKey});

  final String apiKey;

  @override
  String get type => 'api_key';

  factory ApiKeyCredentials.fromJson(Map<String, dynamic> json) =>
      ApiKeyCredentials(apiKey: json['apiKey'] as String);

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'apiKey': apiKey,
      };

  @override
  String toString() {
    final prefix = apiKey.length > 12 ? apiKey.substring(0, 12) : apiKey;
    return 'ApiKeyCredentials(key: $prefix...)';
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  Service account token (для нечеловеков)
// ═════════════════════════════════════════════════════════════════════════════

/// Service account token (токен владельца/правообладателя)
/// Используется для создания service accounts (AI agents, workers, enterprises)
class ServiceTokenCredentials implements Credentials {
  const ServiceTokenCredentials({required this.token});

  /// JWT токен владельца/правообладателя
  final String token;

  @override
  String get type => 'service_token';

  factory ServiceTokenCredentials.fromJson(Map<String, dynamic> json) =>
      ServiceTokenCredentials(token: json['token'] as String);

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'token': token,
      };

  @override
  String toString() {
    final prefix = token.length > 12 ? token.substring(0, 12) : token;
    return 'ServiceTokenCredentials(token: $prefix...)';
  }
}
