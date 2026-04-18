// pkgs/aq_schema/lib/security/interfaces/clients_protocols/i_data_layer_as_clietn_secure_protocol.dart
//
// Security Protocol для dart_vault Data Layer.
//
// Data layer — тупой исполнитель. Он не думает, не анализирует.
// Просто спрашивает: "Можно?" и получает типобезопасный ответ.
//
// Реализация живёт в aq_security, использует ISecurityService.

import 'package:aq_schema/aq_schema.dart';

import '../../models/aq_token_claims.dart';
import '../../models/aq_resource_permission.dart';
import '../../models/access_decision.dart';
import '../i_resource_permission_service.dart';

/// Security Protocol для dart_vault Data Layer.
///
/// ## Философия
///
/// Data layer не знает:
/// - Кто пользователь
/// - Какие у него роли
/// - Какие политики применяются
/// - Как работает JWT
///
/// Data layer знает только:
/// - "Можно ли сделать операцию X?"
/// - Получает типобезопасный ответ: Да/Нет/С ограничениями
///
/// ## Инициализация
///
/// ### В production (main.dart)
///
/// ```dart
/// import 'package:aq_schema/aq_schema.dart';
/// import 'package:aq_security/aq_security.dart'; // Реализация
/// import 'package:dart_vault/server.dart';
///
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///
///   // 1. Создать реализацию security protocol (из aq_security)
///   final securityProtocol = AqVaultSecurityProtocol(
///     securityService: ISecurityService.instance,
///   );
///
///   // 2. Зарегистрировать singleton
///   IVaultSecurityProtocol.initialize(securityProtocol);
///
///   // 3. Создать storage с security
///   final pool = await Pool.connect(...);
///   final storage = PostgresVaultStorage(
///     pool: pool,
///     tenantId: 'system',
///     headers: request.headers, // HTTP headers с токеном
///   );
///
///   runApp(MyApp());
/// }
/// ```
///
/// ### В тестах (с mock)
///
/// ```dart
/// import 'package:aq_schema/aq_schema.dart';
/// import 'package:test/test.dart';
///
/// void main() {
///   setUp(() {
///     // Инициализировать mock для тестов
///     IVaultSecurityProtocol.initialize(MockVaultSecurityProtocol());
///   });
///
///   tearDown(() {
///     // Сбросить после тестов
///     IVaultSecurityProtocol.reset();
///   });
///
///   test('admin can delete projects', () async {
///     final storage = PostgresVaultStorage(
///       pool: pool,
///       tenantId: 'test-tenant',
///       headers: {'Authorization': 'Bearer ${TestTokens.admin}'},
///     );
///
///     await storage.delete('projects', 'project-1'); // OK
///   });
///
///   test('user cannot delete projects', () async {
///     final storage = PostgresVaultStorage(
///       pool: pool,
///       tenantId: 'test-tenant',
///       headers: {'Authorization': 'Bearer ${TestTokens.user}'},
///     );
///
///     expect(
///       () => storage.delete('projects', 'project-1'),
///       throwsA(isA<SecurityException>()),
///     );
///   });
/// }
/// ```
///
/// ### В development (без security)
///
/// ```dart
/// import 'package:aq_schema/aq_schema.dart';
///
/// void main() async {
///   // Инициализировать NoOp (всё разрешено)
///   IVaultSecurityProtocol.initialize(NoOpVaultSecurityProtocol());
///
///   runApp(MyApp());
/// }
/// ```
///
/// ## Использование в dart_vault
///
/// ### В PostgresVaultStorage
///
/// ```dart
/// class PostgresVaultStorage implements VaultStorage {
///   final Map<String, String> headers;
///
///   @override
///   Future<Map<String, dynamic>?> read(String collection, String id) async {
///     // 1. Получить protocol (может быть null если не инициализирован)
///     final protocol = IVaultSecurityProtocol.instance;
///     if (protocol == null) {
///       // Security не инициализирован — всё разрешено
///       return await _db.query('SELECT * FROM $collection WHERE id = ?', [id]);
///     }
///
///     // 2. Извлечь claims из headers
///     final claims = await protocol.extractClaims(headers);
///
///     // 3. Проверить права
///     final decision = await protocol.canRead(
///       claims: claims,
///       collection: collection,
///       entityId: id,
///     );
///
///     // 4. Обработать решение (pattern matching)
///     switch (decision) {
///       case AccessAllowed():
///         return await _db.query('SELECT * FROM $collection WHERE id = ?', [id]);
///
///       case AccessDenied(reason: final r):
///         throw SecurityException('Access denied: $r');
///
///       case AccessRestricted(allowedIds: final ids):
///         if (!ids.contains(id)) {
///           throw SecurityException('Access denied to entity $id');
///         }
///         return await _db.query('SELECT * FROM $collection WHERE id = ?', [id]);
///     }
///   }
///
///   @override
///   Future<void> write(String collection, Map<String, dynamic> data) async {
///     final protocol = IVaultSecurityProtocol.instance;
///     if (protocol == null) {
///       await _db.insert(collection, data);
///       return;
///     }
///
///     final claims = await protocol.extractClaims(headers);
///
///     // 1. Валидация данных
///     final validation = await protocol.validateData(
///       collection: collection,
///       data: data,
///     );
///
///     switch (validation) {
///       case ValidationOk():
///         break; // OK
///       case ValidationFailed(errors: final errs):
///         throw ValidationException(errs);
///     }
///
///     // 2. Проверка прав
///     final decision = await protocol.canWrite(
///       claims: claims,
///       collection: collection,
///       entityId: data['id'] as String?,
///       data: data,
///     );
///
///     switch (decision) {
///       case AccessAllowed():
///         break; // OK
///       case AccessDenied(reason: final r):
///         throw SecurityException('Write denied: $r');
///       case AccessRestricted():
///         throw SecurityException('Write restricted');
///     }
///
///     // 3. Шифрование чувствительных полей
///     final encrypted = await protocol.encryptSensitiveFields(
///       claims: claims,
///       collection: collection,
///       data: data,
///     );
///
///     // 4. Сохранение
///     await _db.insert(collection, encrypted);
///
///     // 5. Аудит
///     await protocol.logOperation(
///       claims: claims,
///       operation: 'write',
///       collection: collection,
///       entityId: data['id'] as String?,
///       success: true,
///     );
///   }
/// }
/// ```
///
/// ## Сценарии использования
///
/// ### 1. Чтение с ограничениями (RLS)
///
/// ```dart
/// final decision = await protocol.canRead(
///   claims: claims,
///   collection: 'projects',
/// );
///
/// switch (decision) {
///   case AccessAllowed():
///     // Пользователь может читать все проекты
///     return await db.query('SELECT * FROM projects');
///
///   case AccessRestricted(allowedIds: final ids):
///     // Пользователь может читать только свои проекты
///     return await db.query(
///       'SELECT * FROM projects WHERE id = ANY(?)',
///       [ids],
///     );
///
///   case AccessDenied(reason: final r):
///     throw SecurityException(r);
/// }
/// ```
///
/// ### 2. Rate limiting
///
/// ```dart
/// final rateLimit = await protocol.checkRateLimit(
///   claims: claims,
///   operation: 'read',
///   ip: request.ip,
/// );
///
/// switch (rateLimit) {
///   case RateLimitOk(remaining: final r, limit: final l):
///     // OK, осталось r запросов из l
///     response.headers['X-RateLimit-Remaining'] = r.toString();
///     response.headers['X-RateLimit-Limit'] = l.toString();
///     break;
///
///   case RateLimitExceeded(retryAfterSeconds: final retry):
///     response.statusCode = 429;
///     response.headers['Retry-After'] = retry.toString();
///     throw RateLimitException('Too many requests');
/// }
/// ```
///
/// ### 3. Валидация и шифрование
///
/// ```dart
/// // Валидация
/// final validation = await protocol.validateData(
///   collection: 'users',
///   data: {'email': userInput},
/// );
///
/// if (validation is ValidationFailed) {
///   throw ValidationException(validation.errors);
/// }
///
/// // Шифрование чувствительных полей
/// final encrypted = await protocol.encryptSensitiveFields(
///   claims: claims,
///   collection: 'users',
///   data: data,
/// );
///
/// await db.insert('users', encrypted);
/// ```
///
/// ## Важные замечания
///
/// 1. **Опциональность**: Если `IVaultSecurityProtocol.instance == null`,
///    dart_vault работает без security (всё разрешено).
///
/// 2. **Типобезопасность**: Используйте pattern matching для обработки решений.
///    Компилятор проверит, что вы обработали все случаи.
///
/// 3. **Универсальность**: Protocol не знает о бизнес-доменах (проекты, графы).
///    Он работает с абстрактными коллекциями и правами.
///
/// 4. **Тестируемость**: Используйте `MockVaultSecurityProtocol` в тестах
///    с захардкоженными токенами из `TestTokens`.
///
/// 5. **Производительность**: Реализация должна кешировать claims и решения
///    для минимизации накладных расходов.
abstract interface class IVaultSecurityProtocol {
  // ══════════════════════════════════════════════════════════════════════════
  // Singleton
  // ══════════════════════════════════════════════════════════════════════════

  /// Скрытое поле для хранения singleton instance
  static IVaultSecurityProtocol? _instance;

  /// Singleton instance геттер
  ///
  /// Используется dart_vault для получения security protocol.
  /// Возвращает null если instance не инициализирован.
  ///
  /// **Пример:**
  /// ```dart
  /// final protocol = IVaultSecurityProtocol.instance;
  /// if (protocol == null) {
  ///   // Security не инициализирован — всё разрешено
  ///   return await db.query('SELECT * FROM $collection');
  /// }
  ///
  /// final decision = await protocol.canRead(...);
  /// ```
  static IVaultSecurityProtocol? get instance => _instance;

  /// Инициализация singleton instance
  ///
  /// **ВАЖНО:** Должен быть вызван в main.dart перед использованием dart_vault.
  ///
  /// **Пример:**
  /// ```dart
  /// void main() async {
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///
  ///   // Создать реализацию
  ///   final securityProtocol = AqVaultSecurityProtocol(
  ///     securityService: ISecurityService.instance,
  ///   );
  ///
  ///   // Зарегистрировать singleton
  ///   IVaultSecurityProtocol.initialize(securityProtocol);
  ///
  ///   runApp(MyApp());
  /// }
  /// ```
  static void initialize(IVaultSecurityProtocol instance) {
    _instance = instance;
  }

  /// Сбросить singleton (для тестов)
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
