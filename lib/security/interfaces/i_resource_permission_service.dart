// pkgs/aq_schema/lib/security/interfaces/i_resource_permission_service.dart
//
// Интерфейс для управления правами доступа на уровне ресурсов.
//
// Этот сервис отвечает за выдачу, отзыв и получение списка прав
// на конкретные ресурсы (проекты, графы, инструкции и т.д.).

import '../models/aq_resource_permission.dart';

/// Сервис управления правами доступа на уровне ресурсов.
///
/// ## Философия
///
/// Этот сервис реализует Resource-Level Access Control (RLAC) —
/// управление правами на конкретные ресурсы, независимо от ролей.
///
/// **Отличие от RBAC:**
/// - RBAC: "Пользователь X имеет роль Admin → может редактировать все проекты"
/// - RLAC: "Пользователь X имеет право Write на проект-123 → может редактировать только его"
///
/// **Комбинация:**
/// Финальное решение о доступе = RBAC ∩ RLAC ∩ PBAC (политики)
///
/// ## Использование
///
/// ### В UI (выдача прав)
///
/// ```dart
/// final service = ISecurityService.instance.resourcePermissions;
///
/// // Выдать право на чтение проекта
/// await service.grant(
///   resourceId: 'project-123',
///   userId: 'user-456',
///   level: AccessLevel.read,
///   grantedBy: currentUser.id,
/// );
/// ```
///
/// ### В Data Layer (проверка прав)
///
/// ```dart
/// // Получить список прав на ресурс
/// final grants = await service.list('project-123');
///
/// // Проверить, есть ли у пользователя право
/// final hasAccess = grants.any(
///   (g) => g.userId == 'user-456' && g.level.index >= AccessLevel.read.index,
/// );
/// ```
///
/// ### В VersionedRepository
///
/// ```dart
/// @override
/// Future<void> grantAccess(
///   String entityId, {
///   required String actorId,
///   required AccessLevel level,
///   required String requesterId,
/// }) async {
///   // 1. Проверить, может ли requester выдавать права
///   final protocol = IVaultSecurityProtocol.instance;
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
///
/// ## Хранение
///
/// Права хранятся в таблице `resource_permissions`:
/// ```sql
/// CREATE TABLE resource_permissions (
///   id UUID PRIMARY KEY,
///   resource_id TEXT NOT NULL,
///   user_id TEXT NOT NULL,
///   level TEXT NOT NULL, -- 'read', 'write', 'admin'
///   granted_by TEXT NOT NULL,
///   granted_at TIMESTAMPTZ NOT NULL,
///   expires_at TIMESTAMPTZ,
///   UNIQUE(resource_id, user_id)
/// );
/// ```
///
/// ## Кэширование
///
/// Реализация должна кэшировать права на короткое время (30-60 сек):
/// ```dart
/// final cacheKey = 'resource_permissions:$resourceId';
/// final cached = await cache.get(cacheKey);
/// if (cached != null) return cached;
///
/// final result = await _loadFromDb(resourceId);
/// await cache.set(cacheKey, result, ttl: Duration(seconds: 30));
/// return result;
/// ```
///
/// ## Аудит
///
/// Все операции должны логироваться:
/// ```dart
/// await audit.logAccess(
///   userId: grantedBy,
///   resource: resourceId,
///   action: 'grant_access',
///   allowed: true,
///   metadata: {
///     'targetUserId': userId,
///     'level': level.name,
///   },
/// );
/// ```
abstract interface class IResourcePermissionService {
  /// Выдать право доступа на ресурс.
  ///
  /// **Параметры:**
  /// - [resourceId] — ID ресурса (entityId из VersionedStorable)
  /// - [userId] — ID пользователя, которому выдаётся право
  /// - [level] — уровень доступа (read, write, admin)
  /// - [grantedBy] — ID пользователя, который выдаёт право
  /// - [expiresAt] — дата истечения права (опционально)
  ///
  /// **Поведение:**
  /// - Если право уже существует — обновляет уровень
  /// - Если уровень понижается — требует подтверждения (опционально)
  /// - Логирует операцию в audit trail
  ///
  /// **Исключения:**
  /// - [SecurityException] — если grantedBy не имеет права выдавать доступ
  /// - [ValidationException] — если параметры невалидны
  Future<void> grant({
    required String resourceId,
    required String userId,
    required AccessLevel level,
    required String grantedBy,
    DateTime? expiresAt,
  });

  /// Отозвать право доступа на ресурс.
  ///
  /// **Параметры:**
  /// - [resourceId] — ID ресурса
  /// - [userId] — ID пользователя, у которого отзывается право
  /// - [revokedBy] — ID пользователя, который отзывает право
  ///
  /// **Поведение:**
  /// - Если права нет — ничего не делает (idempotent)
  /// - Логирует операцию в audit trail
  ///
  /// **Исключения:**
  /// - [SecurityException] — если revokedBy не имеет права отзывать доступ
  Future<void> revoke({
    required String resourceId,
    required String userId,
    required String revokedBy,
  });

  /// Получить список всех прав на ресурс.
  ///
  /// **Параметры:**
  /// - [resourceId] — ID ресурса
  ///
  /// **Возвращает:**
  /// Список [AqResourcePermission] с информацией о правах:
  /// - userId — кому выдано право
  /// - level — уровень доступа
  /// - grantedBy — кто выдал
  /// - grantedAt — когда выдано
  /// - expiresAt — когда истекает (если задано)
  ///
  /// **Поведение:**
  /// - Возвращает только активные права (не истёкшие)
  /// - Сортирует по уровню доступа (admin → write → read)
  /// - Кэширует результат на 30-60 секунд
  Future<List<AqResourcePermission>> list(String resourceId);

  /// Проверить, имеет ли пользователь право на ресурс.
  ///
  /// **Параметры:**
  /// - [resourceId] — ID ресурса
  /// - [userId] — ID пользователя
  /// - [minimumLevel] — минимальный требуемый уровень доступа
  ///
  /// **Возвращает:**
  /// - true — если пользователь имеет право >= minimumLevel
  /// - false — если права нет или уровень ниже
  ///
  /// **Поведение:**
  /// - Проверяет только RLAC (не учитывает RBAC и политики)
  /// - Для полной проверки используйте IVaultSecurityProtocol.canRead/canWrite
  Future<bool> hasAccess({
    required String resourceId,
    required String userId,
    required AccessLevel minimumLevel,
  });

  /// Получить все ресурсы, к которым пользователь имеет доступ.
  ///
  /// **Параметры:**
  /// - [userId] — ID пользователя
  /// - [minimumLevel] — минимальный уровень доступа (опционально)
  ///
  /// **Возвращает:**
  /// Список ID ресурсов, к которым пользователь имеет доступ.
  ///
  /// **Использование:**
  /// ```dart
  /// // Получить все проекты, где пользователь имеет право на запись
  /// final resourceIds = await service.listUserResources(
  ///   userId: 'user-123',
  ///   minimumLevel: AccessLevel.write,
  /// );
  ///
  /// // Загрузить проекты из БД
  /// final projects = await projectRepo.findByIds(resourceIds);
  /// ```
  Future<List<String>> listUserResources({
    required String userId,
    AccessLevel? minimumLevel,
  });

  /// Скопировать права с одного ресурса на другой.
  ///
  /// **Параметры:**
  /// - [sourceResourceId] — ID исходного ресурса
  /// - [targetResourceId] — ID целевого ресурса
  /// - [copiedBy] — ID пользователя, который копирует права
  ///
  /// **Использование:**
  /// При создании копии проекта или ветки графа.
  ///
  /// **Поведение:**
  /// - Копирует все права с source на target
  /// - Не копирует истёкшие права
  /// - Логирует операцию
  Future<void> copyPermissions({
    required String sourceResourceId,
    required String targetResourceId,
    required String copiedBy,
  });

  /// Удалить все права на ресурс.
  ///
  /// **Параметры:**
  /// - [resourceId] — ID ресурса
  /// - [deletedBy] — ID пользователя, который удаляет права
  ///
  /// **Использование:**
  /// При удалении ресурса (проекта, графа).
  ///
  /// **Поведение:**
  /// - Удаляет все права на ресурс
  /// - Логирует операцию
  /// - Очищает кэш
  Future<void> deleteAllPermissions({
    required String resourceId,
    required String deletedBy,
  });
}
