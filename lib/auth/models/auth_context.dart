/// Auth domain models and abstract interfaces for MCP protocol.
///
/// **НАЗНАЧЕНИЕ:** Аутентификация на уровне MCP протокола (worker ↔ adapter).
/// Эти типы используются для валидации токенов в MCP запросах, НЕ для управления
/// пользователями приложения (для этого используйте security/).
///
/// **АРХИТЕКТУРА:**
/// - MCP клиент отправляет токен в `params._aq_auth` → AuthTokenPayload
/// - AuthProvider валидирует токен → AuthResult
/// - При успехе создаётся AuthContext (без сырого токена)
/// - AuthContext передаётся в Redis очередь вместе с job
/// - Worker получает AuthContext и выполняет задачу
///
/// **ВЕРСИИ:**
/// - v1: MockAuthProvider — всегда успех, для разработки
/// - v2: JwtAuthProvider, OAuth2AuthProvider — реальная валидация
///
/// **ОТЛИЧИЕ ОТ security/:**
/// - auth/ — инфраструктурный слой (MCP протокол, worker↔adapter)
/// - security/ — прикладной слой (пользователи, роли, сессии, RBAC)
library;

// ══════════════════════════════════════════════════════════
//  Enums
// ══════════════════════════════════════════════════════════

/// Тип механизма авторизации для MCP протокола.
///
/// **ИСПОЛЬЗОВАНИЕ В MCP:**
/// - Определяет какой AuthProvider использовать для валидации
/// - Передаётся в AuthTokenPayload от MCP клиента
/// - Влияет на формат токена и логику валидации
enum AuthType {
  bearer('bearer'),
  apikey('apikey'),
  oauth2('oauth2'),
  oauth2Token('oauth2_token'),
  none('none'),
  mock('mock');

  const AuthType(this.value);
  final String value;

  static AuthType fromString(String s) => switch (s) {
        'bearer' => AuthType.bearer,
        'apikey' => AuthType.apikey,
        'oauth2' => AuthType.oauth2,
        'oauth2_token' => AuthType.oauth2Token,
        'mock' => AuthType.mock,
        _ => AuthType.none,
      };
}

/// Причина отказа в аутентификации MCP запроса.
///
/// **ИСПОЛЬЗОВАНИЕ В MCP:**
/// - Возвращается в AuthResult.failureReason при неудачной валидации
/// - Помогает MCP клиенту понять почему запрос отклонён
/// - Логируется для мониторинга безопасности
enum AuthFailureReason {
  tokenMissing('token_missing'),
  tokenExpired('token_expired'),
  tokenInvalid('token_invalid'),
  tokenRevoked('token_revoked'),
  scopeInsufficient('scope_insufficient'),
  serviceUnavailable('service_unavailable');

  const AuthFailureReason(this.value);
  final String value;

  static AuthFailureReason fromString(String s) => AuthFailureReason.values
      .firstWhere((e) => e.value == s, orElse: () => AuthFailureReason.tokenInvalid);
}

// ══════════════════════════════════════════════════════════
//  AuthTokenPayload — сырой входящий токен от MCP клиента
// ══════════════════════════════════════════════════════════

/// Сырой токен из MCP запроса (ещё не валидирован).
///
/// **РОЛЬ В MCP ПРОТОКОЛЕ:**
/// - MCP клиент отправляет токен в `params._aq_auth`
/// - Adapter извлекает AuthTokenPayload из запроса
/// - Передаёт в AuthProvider.validate() для проверки
/// - НЕ сохраняется в Redis — только валидированный AuthContext
///
/// **ФОРМАТ:**
/// ```json
/// {
///   "type": "bearer",
///   "token": "eyJhbGc..."
/// }
/// ```
/// или для OAuth2:
/// ```json
/// {
///   "type": "oauth2",
///   "oauth2": {
///     "access_token": "...",
///     "token_type": "Bearer",
///     "expires_in": 3600
///   }
/// }
/// ```
///
/// **БЕЗОПАСНОСТЬ:**
/// - Содержит сырой токен — не логировать полностью
/// - Не передавать в worker — только AuthContext
final class AuthTokenPayload {
  const AuthTokenPayload({
    required this.type,
    this.token,
    this.oauth2,
  });

  factory AuthTokenPayload.fromJson(Map<String, dynamic> json) {
    final oauth2Raw = json['oauth2'] as Map<String, dynamic>?;
    return AuthTokenPayload(
      type: AuthType.fromString((json['type'] as String?) ?? 'none'),
      token: json['token'] as String?,
      oauth2: oauth2Raw != null ? OAuth2TokenPayload.fromJson(oauth2Raw) : null,
    );
  }

  final AuthType type;
  final String? token;
  final OAuth2TokenPayload? oauth2;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'type': type.value};
    if (token != null) map['token'] = token;
    if (oauth2 != null) map['oauth2'] = oauth2!.toJson();
    return map;
  }

  static const empty = AuthTokenPayload(type: AuthType.none);
}

/// OAuth2 токен внутри [AuthTokenPayload].
///
/// **РОЛЬ В MCP:**
/// - Используется когда MCP клиент аутентифицируется через OAuth2
/// - Содержит access_token и метаданные OAuth2 провайдера
/// - OAuth2AuthProvider извлекает и валидирует эти данные
final class OAuth2TokenPayload {
  const OAuth2TokenPayload({
    required this.accessToken,
    required this.tokenType,
    this.refreshToken,
    this.expiresIn,
    this.scope,
  });

  factory OAuth2TokenPayload.fromJson(Map<String, dynamic> json) =>
      OAuth2TokenPayload(
        accessToken: json['access_token'] as String,
        tokenType: json['token_type'] as String,
        refreshToken: json['refresh_token'] as String?,
        expiresIn: json['expires_in'] as int?,
        scope: json['scope'] as String?,
      );

  final String accessToken;
  final String tokenType;
  final String? refreshToken;
  final int? expiresIn;
  final String? scope;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'access_token': accessToken,
      'token_type': tokenType,
    };
    if (refreshToken != null) map['refresh_token'] = refreshToken;
    if (expiresIn != null) map['expires_in'] = expiresIn;
    if (scope != null) map['scope'] = scope;
    return map;
  }
}

// ══════════════════════════════════════════════════════════
//  AuthContext — внутреннее валидированное состояние
// ══════════════════════════════════════════════════════════

/// Валидированное состояние аутентификации для MCP протокола.
///
/// **РОЛЬ В MCP АРХИТЕКТУРЕ:**
/// 1. AuthProvider.validate() создаёт AuthContext после успешной проверки токена
/// 2. Adapter сохраняет AuthContext в Redis вместе с job
/// 3. Worker получает AuthContext из Redis и выполняет задачу
/// 4. AuthContext НЕ содержит сырой токен — только валидированные claims
///
/// **ЖИЗНЕННЫЙ ЦИКЛ:**
/// ```
/// MCP Request → AuthTokenPayload → AuthProvider.validate()
///   → AuthContext → Redis Queue → Worker
/// ```
///
/// **ОТЛИЧИЕ ОТ AuthTokenPayload:**
/// - AuthTokenPayload — сырой вход (может быть невалидным)
/// - AuthContext — валидированный результат (всегда безопасен)
///
/// **БЕЗОПАСНОСТЬ:**
/// - Не содержит сырой токен (только subject, scopes, claims)
/// - Можно безопасно логировать и передавать между сервисами
/// - Проверяйте isExpired перед использованием
final class AuthContext {
  const AuthContext({
    required this.type,
    required this.validated,
    required this.timestamp,
    this.subject,
    this.scopes = const [],
    this.claims,
    this.expiresAt,
    this.isMock = false,
  });

  factory AuthContext.fromJson(Map<String, dynamic> json) => AuthContext(
        type: AuthType.fromString(json['type'] as String),
        validated: json['validated'] as bool,
        timestamp: json['timestamp'] as int,
        subject: json['subject'] as String?,
        scopes: (json['scopes'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        claims: json['claims'] as Map<String, dynamic>?,
        expiresAt: json['expires_at'] as int?,
        isMock: (json['_mock'] as bool?) ?? false,
      );

  final AuthType type;
  final bool validated;
  final int timestamp;
  final String? subject;
  final List<String> scopes;
  final Map<String, dynamic>? claims;
  final int? expiresAt;

  /// AQ EXTENSION: true when MockAuthProvider was used.
  final bool isMock;

  bool get isExpired {
    if (expiresAt == null) return false;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return now >= expiresAt!;
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'type': type.value,
      'validated': validated,
      'timestamp': timestamp,
    };
    if (subject != null) map['subject'] = subject;
    if (scopes.isNotEmpty) map['scopes'] = scopes;
    if (claims != null) map['claims'] = claims;
    if (expiresAt != null) map['expires_at'] = expiresAt;
    if (isMock) map['_mock'] = true;
    return map;
  }

  /// Pre-built mock context used by [MockAuthProvider].
  static AuthContext mockContext() => AuthContext(
        type: AuthType.mock,
        validated: true,
        subject: 'mock-user',
        scopes: const ['*'],
        isMock: true,
        timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      );

  /// Pre-built unauthenticated context for tools that don't require auth.
  static AuthContext anonymous() => AuthContext(
        type: AuthType.none,
        validated: true,
        timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      );

  @override
  String toString() =>
      'AuthContext(type: ${type.value}, subject: $subject, mock: $isMock)';
}

// ══════════════════════════════════════════════════════════
//  AuthResult — результат валидации
// ══════════════════════════════════════════════════════════

/// Результат валидации токена в MCP протоколе.
///
/// **РОЛЬ В MCP:**
/// - Возвращается из AuthProvider.validate()
/// - Adapter проверяет success перед постановкой job в очередь
/// - При success=false MCP запрос отклоняется с ошибкой
///
/// **ИСПОЛЬЗОВАНИЕ:**
/// ```dart
/// final result = await authProvider.validate(tokenPayload);
/// if (!result.success) {
///   return McpError.unauthorized(result.failureReason?.value);
/// }
/// // Использовать result.context для job
/// ```
final class AuthResult {
  const AuthResult({
    required this.success,
    required this.timestamp,
    this.context,
    this.failureReason,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    final ctxRaw = json['context'] as Map<String, dynamic>?;
    final errorStr = json['error'] as String?;
    return AuthResult(
      success: json['success'] as bool,
      timestamp: json['timestamp'] as int,
      context: ctxRaw != null ? AuthContext.fromJson(ctxRaw) : null,
      failureReason: errorStr != null
          ? AuthFailureReason.fromString(errorStr)
          : null,
    );
  }

  /// True when token was accepted.
  final bool success;

  /// Populated when [success] is true.
  final AuthContext? context;

  /// Populated when [success] is false.
  final AuthFailureReason? failureReason;

  final int timestamp;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'success': success,
      'timestamp': timestamp,
    };
    if (context != null) map['context'] = context!.toJson();
    if (failureReason != null) map['error'] = failureReason!.value;
    return map;
  }

  /// Pre-built mock success result.
  static AuthResult mock() => AuthResult(
        success: true,
        context: AuthContext.mockContext(),
        timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      );

  /// Pre-built failure result.
  static AuthResult failure(AuthFailureReason reason) => AuthResult(
        success: false,
        failureReason: reason,
        timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      );

  @override
  String toString() =>
      'AuthResult(success: $success, reason: ${failureReason?.value})';
}

// ══════════════════════════════════════════════════════════
//  AuthProvider — абстрактный интерфейс
// ══════════════════════════════════════════════════════════

/// Абстрактный интерфейс провайдера аутентификации для MCP.
///
/// **РОЛЬ В АРХИТЕКТУРЕ:**
/// - Единая точка валидации токенов в MCP протоколе
/// - Реализации: MockAuthProvider (v1), JwtAuthProvider (v2), OAuth2AuthProvider (v2)
/// - Adapter зависит только от интерфейса — реализацию можно менять без изменения кода
///
/// **ВЕРСИИ:**
/// - **v1 (MockAuthProvider):** Всегда возвращает success, логирует вызовы, для разработки
/// - **v2 (JwtAuthProvider):** Валидирует JWT токены, проверяет подпись и срок
/// - **v2 (OAuth2AuthProvider):** Валидирует OAuth2 токены через внешний провайдер
///
/// **ИСПОЛЬЗОВАНИЕ В ADAPTER:**
/// ```dart
/// final authProvider = JwtAuthProvider(secretKey: '...');
/// final result = await authProvider.validate(tokenPayload);
/// if (!result.success) {
///   return McpError.unauthorized();
/// }
/// // Передать result.context в Redis
/// ```
///
/// **РАСШИРЕНИЕ:**
/// Для добавления нового типа аутентификации:
/// 1. Добавить значение в AuthType enum
/// 2. Создать класс реализующий AuthProvider
/// 3. Зарегистрировать в adapter
abstract interface class AuthProvider {
  /// Является ли этот провайдер mock-заглушкой (v1).
  ///
  /// **ИСПОЛЬЗОВАНИЕ:**
  /// - true для MockAuthProvider (разработка/тесты)
  /// - false для реальных провайдеров (продакшн)
  /// - Adapter может логировать предупреждение если isMock=true в продакшне
  bool get isMock;

  /// Валидирует сырой токен от MCP клиента.
  ///
  /// **ПРОЦЕСС:**
  /// 1. Извлекает токен из tokenPayload
  /// 2. Проверяет подпись (для JWT) или обращается к OAuth2 провайдеру
  /// 3. Проверяет срок действия
  /// 4. Извлекает claims (subject, scopes)
  /// 5. Возвращает AuthResult с AuthContext или failureReason
  ///
  /// **ВАЖНО:**
  /// - Метод должен быть быстрым (< 100ms)
  /// - Не должен бросать исключения — возвращать AuthResult.failure()
  /// - Кэшировать результаты если возможно
  Future<AuthResult> validate(AuthTokenPayload tokenPayload);

  /// Обновляет истёкший AuthContext (только для OAuth2).
  ///
  /// **ИСПОЛЬЗОВАНИЕ:**
  /// - Worker вызывает если обнаружил что AuthContext.isExpired = true
  /// - OAuth2AuthProvider использует refresh_token для получения нового access_token
  /// - Другие провайдеры возвращают тот же context без изменений
  ///
  /// **РЕАЛИЗАЦИЯ ПО УМОЛЧАНИЮ:**
  /// ```dart
  /// Future<AuthContext> refresh(AuthContext expiredContext) async {
  ///   return expiredContext; // Не поддерживается
  /// }
  /// ```
  Future<AuthContext> refresh(AuthContext expiredContext);

  /// Проверяет наличие всех требуемых scopes в контексте.
  ///
  /// **ИСПОЛЬЗОВАНИЕ В MCP:**
  /// - AuthMiddleware.authorize() вызывает для проверки прав на tool
  /// - Если tool требует scopes=['llm', 'fs:read'], проверяет что все есть в ctx.scopes
  /// - Wildcard '*' в ctx.scopes разрешает всё
  ///
  /// **ПРИМЕР:**
  /// ```dart
  /// final hasAccess = authProvider.hasScope(ctx, ['llm', 'fs:read']);
  /// if (!hasAccess) {
  ///   return McpError.forbidden('Insufficient scopes');
  /// }
  /// ```
  bool hasScope(AuthContext ctx, List<String> requiredScopes);
}

// ══════════════════════════════════════════════════════════
//  AuthMiddleware — абстрактный интерфейс
// ══════════════════════════════════════════════════════════

/// Middleware интерфейс для контроля доступа к MCP запросам.
///
/// **РОЛЬ В MCP ADAPTER:**
/// - Adapter вызывает middleware перед обработкой каждого MCP запроса
/// - Разделяет аутентификацию (authenticate) и авторизацию (authorize)
/// - Позволяет централизованно управлять доступом к tools
///
/// **ПРОЦЕСС ОБРАБОТКИ MCP ЗАПРОСА:**
/// ```
/// 1. MCP Request → Adapter
/// 2. Adapter извлекает params._aq_auth → AuthTokenPayload
/// 3. middleware.authenticate(payload) → AuthResult
/// 4. Если !success → return McpError.unauthorized()
/// 5. middleware.authorize(context, toolName) → bool
/// 6. Если !authorized → return McpError.forbidden()
/// 7. Выполнить tool и вернуть результат
/// ```
///
/// **РЕАЛИЗАЦИЯ:**
/// ```dart
/// class DefaultAuthMiddleware implements AuthMiddleware {
///   final AuthProvider provider;
///   final Map<String, List<String>> toolScopes;
///
///   Future<AuthResult> authenticate(AuthTokenPayload? payload) async {
///     if (payload == null) return AuthResult.failure(AuthFailureReason.tokenMissing);
///     return await provider.validate(payload);
///   }
///
///   Future<bool> authorize(AuthContext ctx, String toolName) async {
///     final requiredScopes = toolScopes[toolName] ?? [];
///     return provider.hasScope(ctx, requiredScopes);
///   }
/// }
/// ```
abstract interface class AuthMiddleware {
  /// Аутентифицирует сырой токен из MCP запроса.
  ///
  /// **ВЫЗЫВАЕТСЯ:** Adapter перед обработкой каждого MCP запроса
  ///
  /// **ПАРАМЕТРЫ:**
  /// - payload: Токен из params._aq_auth (может быть null для публичных tools)
  ///
  /// **ВОЗВРАЩАЕТ:**
  /// - AuthResult.success с AuthContext если токен валиден
  /// - AuthResult.failure с причиной если токен невалиден или отсутствует
  ///
  /// **ПРИМЕР:**
  /// ```dart
  /// final result = await middleware.authenticate(tokenPayload);
  /// if (!result.success) {
  ///   return McpError.unauthorized(result.failureReason?.value);
  /// }
  /// ```
  Future<AuthResult> authenticate(AuthTokenPayload? payload);

  /// Проверяет право использовать конкретный tool.
  ///
  /// **ВЫЗЫВАЕТСЯ:** Adapter после успешной аутентификации
  ///
  /// **ПАРАМЕТРЫ:**
  /// - ctx: Валидированный AuthContext из authenticate()
  /// - toolName: Имя tool из MCP запроса (например, "llm_complete")
  ///
  /// **ВОЗВРАЩАЕТ:**
  /// - true если ctx.scopes содержит все требуемые scopes для tool
  /// - false если прав недостаточно
  ///
  /// **ПРИМЕР:**
  /// ```dart
  /// final allowed = await middleware.authorize(context, 'llm_complete');
  /// if (!allowed) {
  ///   return McpError.forbidden('Tool requires llm scope');
  /// }
  /// ```
  Future<bool> authorize(AuthContext ctx, String toolName);
}
