// pkgs/aq_schema/lib/security/interfaces/i_audit_service.dart
//
// Интерфейс для аудита и логирования действий в системе безопасности.
// Реализуется в aq_security, используется в aq_security_ui.

import '../models/aq_access_log.dart';
import '../models/aq_audit_trail.dart';

/// Сервис аудита и логирования
///
/// Этот интерфейс определяет все операции для работы с логами и аудитом:
/// - Запись логов доступа (access logs)
/// - Запись аудит-трейла (audit trail)
/// - Получение и фильтрация логов
/// - Очистка старых логов
///
/// ВАЖНО ДЛЯ BACKEND РАЗРАБОТЧИКА:
/// - Все операции записи (logAccess, logAudit) должны быть асинхронными и не блокировать основной поток
/// - Логи должны храниться в отдельной таблице/коллекции для производительности
/// - Рекомендуется использовать time-series database или партиционирование по времени
/// - Логи должны быть immutable (нельзя изменять после создания)
/// - Необходима автоматическая очистка старых логов (retention policy)
abstract interface class IAuditService {
  // ── Запись логов ──────────────────────────────────────────────────────────

  /// Записать лог попытки доступа к ресурсу
  ///
  /// Параметры:
  /// - userId: ID пользователя, который пытался получить доступ
  /// - userEmail: Email пользователя (для удобства в UI)
  /// - tenantId: ID тенанта
  /// - resource: Ресурс (формат: "resourceType:resourceId")
  /// - action: Действие (read, write, delete, execute, admin)
  /// - allowed: Был ли доступ разрешён
  /// - reason: Причина решения (особенно важна для denied)
  /// - ipAddress: IP адрес клиента (опционально)
  /// - userAgent: User-Agent браузера (опционально)
  /// - metadata: Дополнительные метаданные (опционально)
  ///
  /// Бизнес-логика:
  /// - Создать запись AqAccessLog с уникальным ID
  /// - timestamp = текущее время (Unix timestamp в секундах)
  /// - Запись должна быть асинхронной (не блокировать основной поток)
  /// - Если запись не удалась - логировать ошибку, но не падать
  ///
  /// Когда вызывать:
  /// - После каждой проверки доступа (hasPermission, hasRole, evaluatePolicy)
  /// - При попытке доступа к защищённому ресурсу
  /// - При API запросах к защищённым endpoints
  ///
  /// Права доступа: не требуются (используется внутри системы)
  Future<void> logAccess({
    required String userId,
    required String userEmail,
    required String tenantId,
    required String resource,
    required String action,
    required bool allowed,
    String? reason,
    String? ipAddress,
    String? userAgent,
    Map<String, dynamic>? metadata,
  });

  /// Записать изменение в аудит-трейл
  ///
  /// Параметры:
  /// - action: Тип действия (create, update, delete, assign, revoke)
  /// - entityType: Тип сущности (role, permission, policy, user, apiKey, session)
  /// - entityId: ID изменённой сущности
  /// - entityName: Название сущности (для UI)
  /// - userId: ID пользователя, который сделал изменение
  /// - userEmail: Email пользователя (для UI)
  /// - tenantId: ID тенанта
  /// - changes: Детали изменений (diff before/after)
  /// - reason: Причина изменения (опционально)
  /// - ipAddress: IP адрес клиента (опционально)
  /// - metadata: Дополнительные метаданные (опционально)
  ///
  /// Бизнес-логика:
  /// - Создать запись AqAuditTrail с уникальным ID
  /// - timestamp = текущее время (Unix timestamp в секундах)
  /// - Запись должна быть асинхронной (не блокировать основной поток)
  /// - Если запись не удалась - логировать ошибку, но не падать
  ///
  /// Когда вызывать:
  /// - После каждого изменения в системе безопасности:
  ///   - Создание/обновление/удаление роли
  ///   - Назначение/отзыв роли пользователю
  ///   - Создание/обновление/удаление политики
  ///   - Создание/ротация/отзыв API ключа
  ///   - Отзыв сессии
  ///
  /// Права доступа: не требуются (используется внутри системы)
  Future<void> logAudit({
    required AuditActionType action,
    required AuditEntityType entityType,
    required String entityId,
    required String entityName,
    required String userId,
    required String userEmail,
    required String tenantId,
    Map<String, dynamic>? changes,
    String? reason,
    String? ipAddress,
    Map<String, dynamic>? metadata,
  });

  // ── Получение логов ───────────────────────────────────────────────────────

  /// Получить логи доступа с фильтрацией
  ///
  /// Параметры:
  /// - filter: Фильтр для запроса (см. AccessLogFilter)
  ///
  /// Возвращает:
  /// - Список логов доступа, отсортированных по времени (desc)
  /// - Максимум filter.limit записей (по умолчанию 100)
  /// - С учётом filter.offset для pagination
  ///
  /// Бизнес-логика фильтрации:
  /// - userId: точное совпадение
  /// - tenantId: точное совпадение
  /// - resource: поддерживает wildcard ("project:*" = все проекты)
  /// - action: точное совпадение
  /// - allowed: точное совпадение (null = все)
  /// - startTime/endTime: временной диапазон (включительно)
  /// - ipAddress: точное совпадение
  ///
  /// Оптимизация:
  /// - Использовать индексы на (tenantId, timestamp)
  /// - Использовать индексы на (userId, timestamp)
  /// - Использовать индексы на (resource, timestamp)
  ///
  /// Права доступа: требуется 'audit:read' или 'admin:*'
  Future<List<AqAccessLog>> getAccessLogs(AccessLogFilter filter);

  /// Получить аудит-трейл с фильтрацией
  ///
  /// Параметры:
  /// - filter: Фильтр для запроса (см. AuditTrailFilter)
  ///
  /// Возвращает:
  /// - Список записей аудита, отсортированных по времени (desc)
  /// - Максимум filter.limit записей (по умолчанию 100)
  /// - С учётом filter.offset для pagination
  ///
  /// Бизнес-логика фильтрации:
  /// - userId: точное совпадение (кто сделал изменение)
  /// - tenantId: точное совпадение
  /// - action: точное совпадение (create, update, delete, assign, revoke)
  /// - entityType: точное совпадение (role, permission, policy, user)
  /// - entityId: точное совпадение (конкретная сущность)
  /// - startTime/endTime: временной диапазон (включительно)
  /// - searchQuery: полнотекстовый поиск по entityName, userEmail, reason
  ///
  /// Оптимизация:
  /// - Использовать индексы на (tenantId, timestamp)
  /// - Использовать индексы на (userId, timestamp)
  /// - Использовать индексы на (entityType, entityId, timestamp)
  /// - Использовать full-text search для searchQuery
  ///
  /// Права доступа: требуется 'audit:read' или 'admin:*'
  Future<List<AqAuditTrail>> getAuditTrail(AuditTrailFilter filter);

  // ── Статистика и аналитика ────────────────────────────────────────────────

  /// Получить статистику по логам доступа
  ///
  /// Параметры:
  /// - tenantId: ID тенанта (опционально, null = текущий тенант)
  /// - startTime: Начало периода (Unix timestamp в секундах)
  /// - endTime: Конец периода (Unix timestamp в секундах)
  ///
  /// Возвращает:
  /// Map со статистикой:
  /// {
  ///   "total": 1000,                    // Всего попыток доступа
  ///   "allowed": 950,                   // Разрешённых
  ///   "denied": 50,                     // Запрещённых
  ///   "byResource": {                   // По ресурсам
  ///     "project": 600,
  ///     "graph": 300,
  ///     "instruction": 100
  ///   },
  ///   "byAction": {                     // По действиям
  ///     "read": 700,
  ///     "write": 200,
  ///     "delete": 50,
  ///     "execute": 50
  ///   },
  ///   "topUsers": [                     // Топ пользователей по активности
  ///     {"userId": "user-1", "email": "user1@example.com", "count": 300},
  ///     {"userId": "user-2", "email": "user2@example.com", "count": 250}
  ///   ],
  ///   "deniedReasons": {                // Причины отказов
  ///     "Insufficient permissions": 30,
  ///     "Policy denied": 15,
  ///     "Role required": 5
  ///   }
  /// }
  ///
  /// Права доступа: требуется 'audit:read' или 'admin:*'
  Future<Map<String, dynamic>> getAccessLogStats({
    String? tenantId,
    required int startTime,
    required int endTime,
  });

  /// Получить статистику по аудит-трейлу
  ///
  /// Параметры:
  /// - tenantId: ID тенанта (опционально, null = текущий тенант)
  /// - startTime: Начало периода (Unix timestamp в секундах)
  /// - endTime: Конец периода (Unix timestamp в секундах)
  ///
  /// Возвращает:
  /// Map со статистикой:
  /// {
  ///   "total": 500,                     // Всего изменений
  ///   "byAction": {                     // По типу действия
  ///     "create": 100,
  ///     "update": 250,
  ///     "delete": 50,
  ///     "assign": 80,
  ///     "revoke": 20
  ///   },
  ///   "byEntityType": {                 // По типу сущности
  ///     "role": 150,
  ///     "permission": 50,
  ///     "policy": 100,
  ///     "user": 200
  ///   },
  ///   "topUsers": [                     // Топ пользователей по изменениям
  ///     {"userId": "admin-1", "email": "admin1@example.com", "count": 200},
  ///     {"userId": "admin-2", "email": "admin2@example.com", "count": 150}
  ///   ]
  /// }
  ///
  /// Права доступа: требуется 'audit:read' или 'admin:*'
  Future<Map<String, dynamic>> getAuditTrailStats({
    String? tenantId,
    required int startTime,
    required int endTime,
  });

  // ── Очистка старых логов ──────────────────────────────────────────────────

  /// Удалить старые логи доступа
  ///
  /// Параметры:
  /// - olderThan: Unix timestamp в секундах (удалить логи старше этой даты)
  ///
  /// Возвращает:
  /// - Количество удалённых записей
  ///
  /// Бизнес-логика:
  /// - Удалить все записи AqAccessLog где timestamp < olderThan
  /// - Рекомендуется вызывать периодически (например, раз в день через cron)
  /// - Рекомендуемый retention period: 90 дней для access logs
  ///
  /// Права доступа: требуется 'audit:delete' или 'admin:*'
  Future<int> cleanupAccessLogs({required int olderThan});

  /// Удалить старые записи аудит-трейла
  ///
  /// Параметры:
  /// - olderThan: Unix timestamp в секундах (удалить записи старше этой даты)
  ///
  /// Возвращает:
  /// - Количество удалённых записей
  ///
  /// Бизнес-логика:
  /// - Удалить все записи AqAuditTrail где timestamp < olderThan
  /// - Рекомендуется вызывать периодически (например, раз в день через cron)
  /// - Рекомендуемый retention period: 365 дней для audit trail (дольше чем access logs)
  ///
  /// Права доступа: требуется 'audit:delete' или 'admin:*'
  Future<int> cleanupAuditTrail({required int olderThan});
}
