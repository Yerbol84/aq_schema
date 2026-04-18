// Test реализация AQAuthClient для тестов и локального режима.
//
// **НАЗНАЧЕНИЕ:** Mock реализация для unit тестов и разработки без реального auth сервиса.
//
// **ИСПОЛЬЗОВАНИЕ В MCP:**
// - Для тестирования MCP клиентов без реального сервера
// - Для локальной разработки без поднятия auth сервиса
// - Генерирует mock токены с предсказуемой структурой
//
// **ОТЛИЧИЕ ОТ РЕАЛЬНОЙ РЕАЛИЗАЦИИ:**
// - Не делает HTTP запросов
// - Всегда успешно логинит любые credentials
// - Генерирует mock JWT токены (не валидные для реального сервера)
// - Автоматически обновляет токены по таймеру
//
// **ПРИМЕР:**
// ```dart
// // В тестах
// final authClient = TestAuthClient();
// final token = await authClient.loginWithCredentials('test@example.com', 'any');
//
// // Использовать в MCP запросе
// final mcpRequest = {
//   'params': {
//     '_aq_auth': {
//       'type': 'bearer',
//       'token': token.rawJwt,
//     },
//   },
// };
//
// // Симулировать истечение токена
// authClient.simulateTokenExpiry();
// ```

import 'dart:async';
import 'i_auth_client.dart';
import '../security/models/api_key_claims.dart';

/// Test реализация AQAuthClient для unit тестов и локальной разработки.
///
/// **ВОЗМОЖНОСТИ:**
/// - Генерация mock токенов без HTTP запросов
/// - Автоматическое обновление токенов по таймеру
/// - Симуляция событий (TokenExpired, TokenRefreshed)
/// - Управление API ключами проектов
///
/// **НЕ ИСПОЛЬЗОВАТЬ В ПРОДАКШНЕ:**
/// - Токены не валидны для реального auth сервиса
/// - Нет реальной проверки credentials
/// - Нет защиты от атак
class TestAuthClient implements AQAuthClient {
  AQToken? _currentToken;
  final Map<String, AQApiKey> _projectApiKeys = {};
  final StreamController<AQAuthEvent> _eventsController =
      StreamController<AQAuthEvent>.broadcast();
  Timer? _refreshTimer;
  bool _disposed = false;

  /// Создать TestAuthClient с начальным токеном.
  ///
  /// **ПАРАМЕТРЫ:**
  /// - initialToken: Начальный токен (опционально)
  /// - projectApiKeys: Предустановленные API ключи проектов (опционально)
  ///
  /// **ИСПОЛЬЗОВАНИЕ:**
  /// ```dart
  /// // Пустой клиент
  /// final client = TestAuthClient();
  ///
  /// // С начальным токеном
  /// final token = AQToken(...);
  /// final client = TestAuthClient(initialToken: token);
  ///
  /// // С API ключами
  /// final client = TestAuthClient(
  ///   projectApiKeys: {
  ///     'project-1': AQApiKeyClaims(scope: ['llm']),
  ///   },
  /// );
  /// ```
  TestAuthClient({
    AQToken? initialToken,
    Map<String, AQApiKeyClaims>? projectApiKeys,
  }) : _currentToken = initialToken {
    // Конвертировать apiKeyClaims в AQApiKey если переданы
    if (projectApiKeys != null) {
      for (final entry in projectApiKeys.entries) {
        _projectApiKeys[entry.key] = AQApiKey(
          keyId: 'test-key-${entry.key}',
          secret: 'test-secret',
          projectId: entry.key,
          scope: entry.value.scope,
        );
      }
    }

    // Запустить автоматический refresh если есть токен
    if (_currentToken != null) {
      _scheduleRefresh(_currentToken!);
    }
  }

  @override
  Future<AQToken> loginWithCredentials(String email, String password) async {
    if (_disposed) throw StateError('AuthClient disposed');

    // Для тестов создаём mock токен
    final token = _createMockToken(
      userId: 'test-user-${email.split('@').first}',
      email: email,
    );

    _currentToken = token;
    _scheduleRefresh(token);

    return token;
  }

  @override
  Future<AQToken> loginWithApiKey(String apiKey) async {
    if (_disposed) throw StateError('AuthClient disposed');

    // Для тестов создаём mock токен
    final token = _createMockToken(
      userId: 'api-key-user',
      email: null,
    );

    _currentToken = token;
    _scheduleRefresh(token);

    return token;
  }

  @override
  Future<AQToken?> get currentToken async {
    if (_disposed) throw StateError('AuthClient disposed');

    if (_currentToken == null) return null;

    // Если токен истекает скоро — обновить
    if (_currentToken!.willExpireSoon(const Duration(minutes: 2))) {
      await _refreshToken();
    }

    return _currentToken;
  }

  @override
  AQTokenClaims? validateLocally(String rawToken) {
    if (_disposed) throw StateError('AuthClient disposed');

    // Для тестов просто проверяем что токен не пустой
    if (rawToken.isEmpty) return null;

    // Возвращаем mock claims
    return const AQTokenClaims(
      userId: 'validated-user',
      email: 'test@example.com',
      roles: ['user'],
    );
  }

  @override
  Future<AQApiKey> getOrCreateProjectApiKey(
    String projectId, {
    List<String> scope = const ['*'],
  }) async {
    if (_disposed) throw StateError('AuthClient disposed');

    // Если ключ уже есть — вернуть его
    if (_projectApiKeys.containsKey(projectId)) {
      return _projectApiKeys[projectId]!;
    }

    // Создать новый ключ
    final apiKey = AQApiKey(
      keyId: 'test-key-$projectId',
      secret: 'test-secret-${DateTime.now().millisecondsSinceEpoch}',
      projectId: projectId,
      scope: scope,
    );

    _projectApiKeys[projectId] = apiKey;
    return apiKey;
  }

  @override
  Future<void> logout() async {
    if (_disposed) return;

    _currentToken = null;
    _refreshTimer?.cancel();
    _refreshTimer = null;

    _eventsController.add(const LoggedOut());
  }

  @override
  Stream<AQAuthEvent> get events => _eventsController.stream;

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;

    _refreshTimer?.cancel();
    await _eventsController.close();
  }

  // ── Private методы ──────────────────────────────────────────────────────────

  /// Создать mock токен для тестов.
  ///
  /// **ПАРАМЕТРЫ:**
  /// - userId: ID пользователя
  /// - email: Email пользователя (опционально)
  /// - validity: Срок действия токена (по умолчанию 15 минут)
  ///
  /// **ФОРМАТ ТОКЕНА:**
  /// - rawJwt: 'mock-jwt-{timestamp}' (не валидный JWT)
  /// - claims: userId, email, roles=['user']
  /// - expiresAt: now + validity
  AQToken _createMockToken({
    required String userId,
    String? email,
    Duration validity = const Duration(minutes: 15),
  }) {
    final now = DateTime.now();
    final expiresAt = now.add(validity);

    return AQToken(
      rawJwt: 'mock-jwt-${now.millisecondsSinceEpoch}',
      claims: AQTokenClaims(
        userId: userId,
        email: email,
        roles: ['user'],
      ),
      expiresAt: expiresAt,
    );
  }

  /// Запланировать автоматическое обновление токена.
  ///
  /// **ПОВЕДЕНИЕ:**
  /// - Обновляет токен за 2 минуты до истечения
  /// - Эмитит TokenRefreshed при успешном обновлении
  /// - Эмитит TokenExpired если токен уже истёк
  void _scheduleRefresh(AQToken token) {
    _refreshTimer?.cancel();

    // Обновить за 2 минуты до истечения
    final refreshAt = token.expiresAt.subtract(const Duration(minutes: 2));
    final delay = refreshAt.difference(DateTime.now());

    if (delay.isNegative) {
      // Токен уже истёк или истекает очень скоро
      _eventsController.add(const TokenExpired());
      return;
    }

    _refreshTimer = Timer(delay, () {
      if (!_disposed) {
        _refreshToken();
      }
    });
  }

  /// Обновить текущий токен (внутренний метод).
  ///
  /// **ВЫЗЫВАЕТСЯ:**
  /// - Автоматически по таймеру из _scheduleRefresh()
  /// - Вручную из currentToken если токен истекает скоро
  ///
  /// **ДЕЙСТВИЯ:**
  /// - Создаёт новый mock токен с теми же claims
  /// - Обновляет _currentToken
  /// - Планирует следующее обновление
  /// - Эмитит TokenRefreshed event
  Future<void> _refreshToken() async {
    if (_currentToken == null) return;

    // Создать новый токен
    final newToken = _createMockToken(
      userId: _currentToken!.claims.userId,
      email: _currentToken!.claims.email,
    );

    _currentToken = newToken;
    _scheduleRefresh(newToken);

    _eventsController.add(TokenRefreshed(newToken));
  }

  /// Установить токен вручную (для тестов).
  ///
  /// **ИСПОЛЬЗОВАНИЕ В ТЕСТАХ:**
  /// ```dart
  /// final client = TestAuthClient();
  /// final customToken = AQToken(
  ///   rawJwt: 'custom-jwt',
  ///   claims: AQTokenClaims(userId: 'test-123'),
  ///   expiresAt: DateTime.now().add(Duration(hours: 1)),
  /// );
  /// client.setToken(customToken);
  /// ```
  void setToken(AQToken token) {
    _currentToken = token;
    _scheduleRefresh(token);
  }

  /// Симулировать истечение токена (для тестов).
  ///
  /// **ИСПОЛЬЗОВАНИЕ В ТЕСТАХ:**
  /// ```dart
  /// test('should handle token expiry', () async {
  ///   final client = TestAuthClient();
  ///   await client.loginWithCredentials('test@example.com', 'pass');
  ///
  ///   // Слушать события
  ///   final events = <AQAuthEvent>[];
  ///   client.events.listen(events.add);
  ///
  ///   // Симулировать истечение
  ///   client.simulateTokenExpiry();
  ///
  ///   await Future.delayed(Duration(milliseconds: 100));
  ///   expect(events.last, isA<TokenExpired>());
  /// });
  /// ```
  void simulateTokenExpiry() {
    _eventsController.add(const TokenExpired());
  }
}
