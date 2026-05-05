// pkgs/aq_schema/lib/security/interfaces/clients_protocols/i_vault_security_protocol.dart
//
// Порт безопасности для dart_vault Data Layer.
// Реализация: aq_security/lib/src/client/aq_vault_security_protocol.dart
// Мок для тестов: aq_schema/lib/security/interfaces/clients_protocols/mocks/mock_vault_security_protocol.dart

import 'package:aq_schema/aq_schema.dart';

/// # IVaultSecurityProtocol — порт безопасности для data layer
///
/// Data layer не знает о ролях, JWT, политиках. Он просто спрашивает:
/// "Можно?" — и получает типобезопасный ответ.
///
/// ---
///
/// ## 📦 Data Layer (dart_vault) — как использовать
///
/// ```dart
/// // В PostgresVaultStorage или любом VaultStorage:
///
/// Future<Map<String, dynamic>?> get(String collection, String id) async {
///   final protocol = IVaultSecurityProtocol.instance;
///
///   // Если security не инициализирован — всё разрешено (dev режим)
///   if (protocol == null) return await _db.get(collection, id);
///
///   final claims = await protocol.extractClaims(headers);
///   final decision = await protocol.canRead(
///     claims: claims,
///     collection: collection,
///     entityId: id,
///   );
///
///   return switch (decision) {
///     AccessAllowed() => await _db.get(collection, id),
///     AccessDenied(:final reason) => throw SecurityException(reason),
///     AccessRestricted(:final allowedIds) when allowedIds.contains(id)
///       => await _db.get(collection, id),
///     AccessRestricted() => throw SecurityException('Access denied to $id'),
///   };
/// }
/// ```
///
/// ---
///
/// ## 🧪 Тесты (без aq_security)
///
/// ```dart
/// import 'package:aq_schema/security_testing.dart';
///
/// setUp(() => IVaultSecurityProtocol.initialize(MockVaultSecurityProtocol()));
/// tearDown(() => IVaultSecurityProtocol.reset());
/// ```
///
/// ---
///
/// ## 🚀 Production (main.dart)
///
/// ```dart
/// import 'package:aq_security/aq_security.dart';
///
/// IVaultSecurityProtocol.initialize(
///   AqVaultSecurityProtocol(introspectionEndpoint: 'https://auth.example.com/introspect'),
/// );
/// ```
abstract interface class IVaultSecurityProtocol {
  // ══════════════════════════════════════════════════════════════════════════
  // Singleton
  // ══════════════════════════════════════════════════════════════════════════

  static IVaultSecurityProtocol? _instance;

  /// null если security не инициализирован (dev режим — всё разрешено).
  static IVaultSecurityProtocol? get instance => _instance;

  /// Регистрирует реализацию. Вызывается один раз в main.dart.
  static void initialize(IVaultSecurityProtocol instance) {
    _instance = instance;
  }

  /// Сбросить singleton (для тестов).
  static void reset() {
    _instance = null;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Подсервисы
  // ══════════════════════════════════════════════════════════════════════════

  /// Сервис управления правами на уровне ресурсов.
  ///
  /// Используется для выдачи, отзыва и получения списка прав
  /// на конкретные ресурсы (проекты, графы, инструкции).
  ///
  /// **Пример использования в VersionedRepository:**
  /// ```dart
  /// @override
  /// Future<void> grantAccess(
  ///   String entityId, {
  ///   required String actorId,
  ///   required AccessLevel level,
  ///   required String requesterId,
  /// }) async {
  ///   final protocol = IVaultSecurityProtocol.instance;
  ///
  ///   // 1. Проверить, может ли requester выдавать права
  ///   final claims = await protocol.extractClaims(headers);
  ///   final decision = await protocol.canGrant(
  ///     claims: claims,
  ///     collection: _collection,
  ///     entityId: entityId,
  ///     targetUserId: actorId,
  ///     level: level,
  ///   );
  ///
  ///   if (decision is! AccessAllowed) {
  ///     throw VaultAccessDeniedException('Cannot grant access');
  ///   }
  ///
  ///   // 2. Выдать право через сервис
  ///   await protocol.resourcePermissions.grant(
  ///     resourceId: entityId,
  ///     userId: actorId,
  ///     level: level,
  ///     grantedBy: requesterId,
  ///   );
  /// }
  /// ```
  IResourcePermissionService get resourcePermissions;

  // ══════════════════════════════════════════════════════════════════════════
  // Извлечение контекста из запроса
  // ══════════════════════════════════════════════════════════════════════════

  /// Извлечь claims из HTTP headers (JWT, API key, etc.)
  ///
  /// Data layer передаёт headers, получает claims или null.
  /// Если null — запрос анонимный (может быть разрешён или нет).
  ///
  /// **Пример:**
  /// ```dart
  /// final claims = await protocol.extractClaims({
  ///   'Authorization': 'Bearer eyJ...',
  /// });
  /// ```
  Future<AqTokenClaims?> extractClaims(Map<String, String> headers);

  // ══════════════════════════════════════════════════════════════════════════
  // Проверка прав доступа (декларативно)
  // ══════════════════════════════════════════════════════════════════════════

  /// Можно ли читать из коллекции?
  ///
  /// Data layer: "Хочу прочитать из 'projects'. Можно?"
  /// Security: "Да" / "Нет" / "Да, но только эти ID: [...]"
  ///
  /// **Параметры:**
  /// - [claims] — токен пользователя (null = анонимный)
  /// - [collection] — имя коллекции
  /// - [entityId] — ID конкретной сущности (опционально)
  ///
  /// **Возвращает:**
  /// - [AccessAllowed] — можно читать всё
  /// - [AccessDenied] — нельзя читать
  /// - [AccessRestricted] — можно читать только указанные ID
  Future<AccessDecision> canRead({
    required AqTokenClaims? claims,
    required String collection,
    String? entityId,
  });

  /// Можно ли писать в коллекцию?
  ///
  /// **Параметры:**
  /// - [claims] — токен пользователя
  /// - [collection] — имя коллекции
  /// - [entityId] — ID сущности (null = создание новой)
  /// - [data] — данные для записи (для валидации)
  Future<AccessDecision> canWrite({
    required AqTokenClaims? claims,
    required String collection,
    String? entityId,
    required Map<String, dynamic> data,
  });

  /// Можно ли удалить из коллекции?
  Future<AccessDecision> canDelete({
    required AqTokenClaims? claims,
    required String collection,
    required String entityId,
  });

  /// Можно ли опубликовать версию? (для VersionedRepository)
  Future<AccessDecision> canPublish({
    required AqTokenClaims? claims,
    required String collection,
    required String entityId,
  });

  /// Можно ли выдать доступ? (grant)
  Future<AccessDecision> canGrant({
    required AqTokenClaims? claims,
    required String collection,
    required String entityId,
    required String targetUserId,
    required AccessLevel level,
  });

  // ══════════════════════════════════════════════════════════════════════════
  // Rate Limiting (декларативно)
  // ══════════════════════════════════════════════════════════════════════════

  /// Проверить rate limit.
  ///
  /// Data layer: "Пользователь X хочет сделать операцию Y. Можно?"
  /// Security: "Да" / "Нет, превышен лимит, retry через N секунд"
  ///
  /// **Параметры:**
  /// - [claims] — токен пользователя
  /// - [operation] — тип операции ('read', 'write', 'delete')
  /// - [ip] — IP адрес (опционально)
  ///
  /// **Возвращает:**
  /// - [bool] — true если лимит не превышен, false если превышен
  Future<bool> checkRateLimit({
    required AqTokenClaims? claims,
    required String operation,
    String? ip,
  });

  // ══════════════════════════════════════════════════════════════════════════
  // Валидация данных (декларативно)
  // ══════════════════════════════════════════════════════════════════════════

  /// Валидировать входные данные.
  ///
  /// Data layer: "Хочу сохранить эти данные. Они валидны?"
  /// Security: "Да" / "Нет, вот ошибки: [...]"
  ///
  /// Проверяет:
  /// - SQL injection
  /// - XSS
  /// - Размер данных
  /// - Формат полей
  ///
  /// **Возвращает:**
  /// - Пустой список если данные валидны
  /// - Список [ValidationFieldError] если есть ошибки
  Future<List<ValidationFieldError>> validateData({
    required String collection,
    required Map<String, dynamic> data,
  });

  // ══════════════════════════════════════════════════════════════════════════
  // Шифрование (декларативно)
  // ══════════════════════════════════════════════════════════════════════════

  /// Зашифровать чувствительные поля перед сохранением.
  ///
  /// Data layer: "Вот данные. Зашифруй что нужно."
  /// Security: "Вот зашифрованные данные."
  ///
  /// Какие поля шифровать определяет security service на основе коллекции.
  Future<Map<String, dynamic>> encryptSensitiveFields({
    required AqTokenClaims? claims,
    required String collection,
    required Map<String, dynamic> data,
  });

  /// Расшифровать чувствительные поля после чтения.
  Future<Map<String, dynamic>> decryptSensitiveFields({
    required AqTokenClaims? claims,
    required String collection,
    required Map<String, dynamic> data,
  });

  // ══════════════════════════════════════════════════════════════════════════
  // Аудит (декларативно)
  // ══════════════════════════════════════════════════════════════════════════

  /// Записать событие аудита.
  ///
  /// Data layer: "Я сделал операцию X. Запиши."
  /// Security: "Записал."
  ///
  /// **Параметры:**
  /// - [claims] — токен пользователя
  /// - [operation] — тип операции ('read', 'write', 'delete', etc.)
  /// - [collection] — имя коллекции
  /// - [entityId] — ID сущности (опционально)
  /// - [success] — успешно ли выполнена операция
  /// - [errorMessage] — сообщение об ошибке (если success = false)
  Future<void> logOperation({
    required AqTokenClaims? claims,
    required String operation,
    required String collection,
    String? entityId,
    required bool success,
    String? errorMessage,
  });
}
