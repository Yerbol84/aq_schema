// Интерфейс клиента аутентификации для MCP протокола.
//
// **НАЗНАЧЕНИЕ:** Управление токенами на стороне MCP клиента.
// Используется приложениями для получения токенов перед отправкой MCP запросов.
//
// **РОЛЬ В MCP АРХИТЕКТУРЕ:**
// 1. Приложение логинится через AQAuthClient → получает AQToken
// 2. Приложение извлекает rawJwt из токена
// 3. Приложение отправляет MCP запрос с params._aq_auth = {type: "bearer", token: rawJwt}
// 4. Adapter валидирует токен через AuthProvider
//
// **ОТЛИЧИЕ ОТ security/:**
// - auth/AQAuthClient — клиентская библиотека для получения токенов (MCP уровень)
// - security/ISecurityService — серверный сервис управления пользователями (App уровень)
//
// **ЖИЗНЕННЫЙ ЦИКЛ ТОКЕНА:**
// ```
// App → AQAuthClient.loginWithCredentials()
//   → AQToken (rawJwt + claims + expiresAt)
//   → MCP Request с rawJwt в params._aq_auth
//   → Adapter → AuthProvider.validate()
//   → AuthContext → Worker
// ```

import 'dart:async';

/// Токен доступа с claims для MCP протокола.
///
/// **ИСПОЛЬЗОВАНИЕ В MCP:**
/// - Получается из AQAuthClient.loginWithCredentials() или loginWithApiKey()
/// - Содержит rawJwt для отправки в MCP запросах
/// - Автоматически обновляется через AQAuthClient.currentToken
///
/// **СТРУКТУРА:**
/// - rawJwt: JWT токен для params._aq_auth
/// - claims: Декодированные данные (userId, email, roles)
/// - expiresAt: Время истечения для автоматического refresh
///
/// **ПРИМЕР:**
/// ```dart
/// final token = await authClient.loginWithCredentials(email, password);
/// final mcpRequest = {
///   'method': 'tools/call',
///   'params': {
///     'name': 'llm_complete',
///     '_aq_auth': {
///       'type': 'bearer',
///       'token': token.rawJwt,
///     },
///   },
/// };
/// ```
class AQToken {
  final String rawJwt;
  final AQTokenClaims claims;
  final DateTime expiresAt;

  const AQToken({
    required this.rawJwt,
    required this.claims,
    required this.expiresAt,
  });

  /// Проверить истёк ли токен
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Проверить истечёт ли токен скоро
  bool willExpireSoon(Duration buffer) =>
      DateTime.now().add(buffer).isAfter(expiresAt);

  Map<String, dynamic> toJson() => {
        'rawJwt': rawJwt,
        'claims': claims.toJson(),
        'expiresAt': expiresAt.toIso8601String(),
      };

  factory AQToken.fromJson(Map<String, dynamic> json) => AQToken(
        rawJwt: json['rawJwt'] as String,
        claims: AQTokenClaims.fromJson(json['claims'] as Map<String, dynamic>),
        expiresAt: DateTime.parse(json['expiresAt'] as String),
      );
}

/// Claims токена доступа для MCP протокола.
///
/// **НАЗНАЧЕНИЕ:**
/// - Декодированные данные из JWT токена
/// - Используются клиентом для отображения информации о пользователе
/// - НЕ отправляются в MCP запросах (только rawJwt)
///
/// **ОТЛИЧИЕ ОТ auth/AuthContext:**
/// - AQTokenClaims — клиентская структура (простая: userId, email, roles)
/// - AuthContext — серверная структура (полная: subject, scopes, timestamp, validated)
///
/// **ОТЛИЧИЕ ОТ security/AqTokenClaims:**
/// - auth/AQTokenClaims — для MCP клиента (простые поля)
/// - security/AqTokenClaims — для JWT сервиса (полные JWT поля: sub, tid, exp, jti, sid)
class AQTokenClaims {
  final String userId;
  final String? email;
  final List<String> roles;
  final Map<String, dynamic>? metadata;

  const AQTokenClaims({
    required this.userId,
    this.email,
    this.roles = const [],
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        if (email != null) 'email': email,
        'roles': roles,
        if (metadata != null) 'metadata': metadata,
      };

  factory AQTokenClaims.fromJson(Map<String, dynamic> json) => AQTokenClaims(
        userId: json['userId'] as String,
        email: json['email'] as String?,
        roles: (json['roles'] as List?)?.cast<String>() ?? [],
        metadata: json['metadata'] as Map<String, dynamic>?,
      );
}

/// API ключ проекта для MCP протокола.
///
/// **НАЗНАЧЕНИЕ:**
/// - Долгоживущие ключи для автоматизации и CI/CD
/// - Альтернатива JWT токенам для machine-to-machine коммуникации
/// - Привязаны к конкретному проекту с ограниченными scopes
///
/// **ИСПОЛЬЗОВАНИЕ В MCP:**
/// ```dart
/// // Получить ключ для проекта
/// final apiKey = await authClient.getOrCreateProjectApiKey(
///   projectId,
///   scope: ['llm', 'fs:read'],
/// );
///
/// // Использовать в MCP запросе
/// final mcpRequest = {
///   'params': {
///     '_aq_auth': {
///       'type': 'apikey',
///       'token': apiKey.secret,
///     },
///   },
/// };
/// ```
///
/// **ОТЛИЧИЕ ОТ security/AqApiKey:**
/// - auth/AQApiKey — клиентская структура для MCP (projectId, scope)
/// - security/AqApiKey — серверная структура для RBAC (userId, permissions, tenantId)
///
/// **БЕЗОПАСНОСТЬ:**
/// - secret должен храниться в переменных окружения
/// - Не логировать secret в открытом виде
/// - Проверять expiresAt перед использованием
class AQApiKey {
  final String keyId;
  final String secret;
  final String projectId;
  final List<String> scope;
  final DateTime? expiresAt;

  const AQApiKey({
    required this.keyId,
    required this.secret,
    required this.projectId,
    required this.scope,
    this.expiresAt,
  });

  Map<String, dynamic> toJson() => {
        'keyId': keyId,
        'secret': secret,
        'projectId': projectId,
        'scope': scope,
        if (expiresAt != null) 'expiresAt': expiresAt!.toIso8601String(),
      };

  factory AQApiKey.fromJson(Map<String, dynamic> json) => AQApiKey(
        keyId: json['keyId'] as String,
        secret: json['secret'] as String,
        projectId: json['projectId'] as String,
        scope: (json['scope'] as List).cast<String>(),
        expiresAt: json['expiresAt'] != null
            ? DateTime.parse(json['expiresAt'] as String)
            : null,
      );
}

/// События аутентификации для MCP клиента.
///
/// **НАЗНАЧЕНИЕ:**
/// - Уведомления о изменениях состояния токена
/// - Позволяет приложению реагировать на истечение/обновление токенов
/// - Используется для автоматического переподключения MCP соединений
///
/// **ИСПОЛЬЗОВАНИЕ:**
/// ```dart
/// authClient.events.listen((event) {
///   switch (event) {
///     case TokenRefreshed(:final newToken):
///       // Обновить токен в MCP клиенте
///       mcpClient.updateAuth(newToken.rawJwt);
///     case TokenExpired():
///       // Переподключиться или показать форму логина
///       await mcpClient.disconnect();
///     case LoggedOut():
///       // Очистить состояние приложения
///       await mcpClient.disconnect();
///   }
/// });
/// ```
sealed class AQAuthEvent {
  const AQAuthEvent();
}

/// Токен обновлён автоматически.
///
/// **КОГДА ЭМИТИТСЯ:**
/// - AQAuthClient автоматически обновил истекающий токен
/// - Обычно за 5 минут до истечения текущего токена
///
/// **ДЕЙСТВИЯ:**
/// - Обновить токен в активных MCP соединениях
/// - Сохранить новый токен в локальное хранилище
class TokenRefreshed extends AQAuthEvent {
  final AQToken newToken;
  const TokenRefreshed(this.newToken);
}

/// Токен истёк и не может быть обновлён.
///
/// **КОГДА ЭМИТИТСЯ:**
/// - Токен истёк и refresh token тоже истёк
/// - Сервер отклонил попытку обновления токена
///
/// **ДЕЙСТВИЯ:**
/// - Отключить все MCP соединения
/// - Показать форму логина пользователю
/// - Очистить сохранённые токены
class TokenExpired extends AQAuthEvent {
  const TokenExpired();
}

/// Пользователь вышел из системы.
///
/// **КОГДА ЭМИТИТСЯ:**
/// - Вызван AQAuthClient.logout()
/// - Пользователь явно нажал "Выйти"
///
/// **ДЕЙСТВИЯ:**
/// - Отключить все MCP соединения
/// - Очистить состояние приложения
/// - Перенаправить на экран логина
class LoggedOut extends AQAuthEvent {
  const LoggedOut();
}

/// Интерфейс клиента аутентификации для MCP протокола.
///
/// **РОЛЬ В MCP АРХИТЕКТУРЕ:**
/// - Клиентская библиотека для получения токенов перед отправкой MCP запросов
/// - Управляет жизненным циклом токенов (получение, обновление, валидация)
/// - Автоматически обновляет истекающие токены
/// - Управляет API ключами проектов
///
/// **ЖИЗНЕННЫЙ ЦИКЛ:**
/// ```
/// 1. App создаёт AQAuthClient
/// 2. App вызывает loginWithCredentials() или loginWithApiKey()
/// 3. AQAuthClient получает токен от auth сервиса
/// 4. App использует token.rawJwt в MCP запросах
/// 5. AQAuthClient автоматически обновляет токен перед истечением
/// 6. App получает TokenRefreshed event и обновляет MCP соединения
/// ```
///
/// **ИСПОЛЬЗОВАНИЕ:**
/// ```dart
/// // Создать клиент
/// final authClient = AQAuthClientImpl(
///   authServiceUrl: 'http://localhost:8080',
/// );
///
/// // Войти
/// final token = await authClient.loginWithCredentials(
///   'user@example.com',
///   'password',
/// );
///
/// // Использовать в MCP запросе
/// final mcpRequest = {
///   'method': 'tools/call',
///   'params': {
///     'name': 'llm_complete',
///     '_aq_auth': {
///       'type': 'bearer',
///       'token': token.rawJwt,
///     },
///   },
/// };
///
/// // Слушать события
/// authClient.events.listen((event) {
///   if (event is TokenRefreshed) {
///     // Обновить токен в MCP клиенте
///   }
/// });
/// ```
///
/// **РЕАЛИЗАЦИИ:**
/// - AQAuthClientImpl — основная реализация (в пакете aq_auth)
/// - TestAuthClient — mock для тестов (в этом файле)
///
/// **ОТЛИЧИЕ ОТ security/ISecurityService:**
/// - AQAuthClient — клиентская библиотека (получение токенов для MCP)
/// - ISecurityService — серверный сервис (управление пользователями, RBAC)
abstract interface class AQAuthClient {
  /// Войти по email и паролю.
  ///
  /// **ИСПОЛЬЗОВАНИЕ:**
  /// - Основной способ аутентификации для пользователей
  /// - Отправляет credentials на auth сервис
  /// - Получает JWT токен в ответ
  ///
  /// **ВОЗВРАЩАЕТ:**
  /// - AQToken с rawJwt для использования в MCP запросах
  ///
  /// **ИСКЛЮЧЕНИЯ:**
  /// - AQAuthException если credentials неверные
  /// - AQAuthException если сервис недоступен
  ///
  /// **ПРИМЕР:**
  /// ```dart
  /// try {
  ///   final token = await authClient.loginWithCredentials(
  ///     'user@example.com',
  ///     'password123',
  ///   );
  ///   print('Logged in as ${token.claims.userId}');
  /// } catch (e) {
  ///   print('Login failed: $e');
  /// }
  /// ```
  Future<AQToken> loginWithCredentials(String email, String password);

  /// Войти по API ключу.
  ///
  /// **ИСПОЛЬЗОВАНИЕ:**
  /// - Для автоматизации и CI/CD
  /// - Для machine-to-machine коммуникации
  /// - API ключ должен быть создан через getOrCreateProjectApiKey()
  ///
  /// **ВОЗВРАЩАЕТ:**
  /// - AQToken с rawJwt для использования в MCP запросах
  ///
  /// **ИСКЛЮЧЕНИЯ:**
  /// - AQAuthException если ключ невалиден или истёк
  ///
  /// **ПРИМЕР:**
  /// ```dart
  /// final apiKey = env['AQ_API_KEY'];
  /// final token = await authClient.loginWithApiKey(apiKey);
  /// ```
  Future<AQToken> loginWithApiKey(String apiKey);

  /// Получить текущий токен с автоматическим обновлением.
  ///
  /// **ПОВЕДЕНИЕ:**
  /// - Возвращает кэшированный токен если он валиден
  /// - Автоматически обновляет токен если он истекает скоро (< 5 минут)
  /// - Возвращает null если пользователь не залогинен
  ///
  /// **ИСПОЛЬЗОВАНИЕ:**
  /// - Вызывать перед каждым MCP запросом
  /// - Не нужно вручную проверять isExpired
  ///
  /// **ПРИМЕР:**
  /// ```dart
  /// final token = await authClient.currentToken;
  /// if (token == null) {
  ///   // Показать форму логина
  ///   return;
  /// }
  /// // Использовать token.rawJwt в MCP запросе
  /// ```
  Future<AQToken?> get currentToken;

  /// Валидировать токен локально без обращения к серверу.
  ///
  /// **ИСПОЛЬЗОВАНИЕ:**
  /// - Быстрая проверка токена без сетевого запроса
  /// - Проверяет подпись JWT и срок действия
  /// - НЕ проверяет отозван ли токен (для этого нужен запрос к серверу)
  ///
  /// **ВОЗВРАЩАЕТ:**
  /// - AQTokenClaims если токен валиден
  /// - null если токен невалиден или истёк
  ///
  /// **ПРИМЕР:**
  /// ```dart
  /// final claims = authClient.validateLocally(rawJwt);
  /// if (claims != null) {
  ///   print('Token valid for user ${claims.userId}');
  /// }
  /// ```
  AQTokenClaims? validateLocally(String rawToken);

  /// Получить или создать API ключ для проекта.
  ///
  /// **ИСПОЛЬЗОВАНИЕ:**
  /// - Создать долгоживущий ключ для автоматизации
  /// - Ограничить доступ ключа через scopes
  /// - Если ключ уже существует — вернуть его
  ///
  /// **ПАРАМЕТРЫ:**
  /// - projectId: ID проекта для которого создаётся ключ
  /// - scope: Список разрешений (например, ['llm', 'fs:read'])
  ///   - '*' — полный доступ
  ///   - 'llm' — только LLM запросы
  ///   - 'fs:read' — только чтение файлов
  ///
  /// **ВОЗВРАЩАЕТ:**
  /// - AQApiKey с secret для использования в loginWithApiKey()
  ///
  /// **БЕЗОПАСНОСТЬ:**
  /// - secret возвращается только один раз при создании
  /// - Сохраните secret в безопасном месте (переменные окружения)
  /// - Не логируйте secret в открытом виде
  ///
  /// **ПРИМЕР:**
  /// ```dart
  /// final apiKey = await authClient.getOrCreateProjectApiKey(
  ///   'project-123',
  ///   scope: ['llm', 'fs:read'],
  /// );
  /// print('Save this key: ${apiKey.secret}');
  /// // Сохранить в .env файл
  /// ```
  Future<AQApiKey> getOrCreateProjectApiKey(
    String projectId, {
    List<String> scope = const ['*'],
  });

  /// Выйти из системы.
  ///
  /// **ДЕЙСТВИЯ:**
  /// - Удаляет кэшированный токен
  /// - Отменяет автоматическое обновление токена
  /// - Эмитит LoggedOut event
  /// - Отзывает токен на сервере (если поддерживается)
  ///
  /// **ИСПОЛЬЗОВАНИЕ:**
  /// ```dart
  /// await authClient.logout();
  /// // Перенаправить на экран логина
  /// ```
  Future<void> logout();

  /// Stream событий аутентификации.
  ///
  /// **СОБЫТИЯ:**
  /// - TokenRefreshed — токен автоматически обновлён
  /// - TokenExpired — токен истёк и не может быть обновлён
  /// - LoggedOut — пользователь вышел
  ///
  /// **ИСПОЛЬЗОВАНИЕ:**
  /// ```dart
  /// authClient.events.listen((event) {
  ///   switch (event) {
  ///     case TokenRefreshed(:final newToken):
  ///       mcpClient.updateAuth(newToken.rawJwt);
  ///     case TokenExpired():
  ///       showLoginScreen();
  ///     case LoggedOut():
  ///       clearAppState();
  ///   }
  /// });
  /// ```
  Stream<AQAuthEvent> get events;

  /// Освободить ресурсы.
  ///
  /// **ИСПОЛЬЗОВАНИЕ:**
  /// - Вызвать при закрытии приложения
  /// - Останавливает автоматическое обновление токенов
  /// - Закрывает stream событий
  ///
  /// **ПРИМЕР:**
  /// ```dart
  /// @override
  /// void dispose() {
  ///   authClient.dispose();
  ///   super.dispose();
  /// }
  /// ```
  Future<void> dispose();
}

/// Исключение при ошибке аутентификации.
///
/// **КОГДА БРОСАЕТСЯ:**
/// - Неверные credentials в loginWithCredentials()
/// - Невалидный API ключ в loginWithApiKey()
/// - Сервис аутентификации недоступен
/// - Токен отозван на сервере
///
/// **ПОЛЯ:**
/// - message: Человекочитаемое описание ошибки
/// - code: Код ошибки для программной обработки (опционально)
/// - originalError: Исходная ошибка если есть (опционально)
///
/// **КОДЫ ОШИБОК:**
/// - 'invalid_credentials' — неверный email или пароль
/// - 'invalid_api_key' — невалидный API ключ
/// - 'token_expired' — токен истёк
/// - 'token_revoked' — токен отозван
/// - 'service_unavailable' — сервис недоступен
///
/// **ОБРАБОТКА:**
/// ```dart
/// try {
///   final token = await authClient.loginWithCredentials(email, password);
/// } on AQAuthException catch (e) {
///   if (e.code == 'invalid_credentials') {
///     showError('Неверный email или пароль');
///   } else if (e.code == 'service_unavailable') {
///     showError('Сервис временно недоступен');
///   } else {
///     showError(e.message);
///   }
/// }
/// ```
class AQAuthException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AQAuthException(this.message, {this.code, this.originalError});

  @override
  String toString() =>
      'AQAuthException: $message${code != null ? ' (code: $code)' : ''}';
}
