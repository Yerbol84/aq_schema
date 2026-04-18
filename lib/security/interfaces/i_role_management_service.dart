// pkgs/aq_schema/lib/security/interfaces/i_role_management_service.dart
//
// Интерфейс для управления ролями и назначениями ролей пользователям.
// Реализуется в aq_security, используется в aq_security_ui.

import '../models/aq_role.dart';
import '../models/aq_user.dart';

/// Сервис управления ролями (RBAC)
///
/// Этот интерфейс определяет все операции для работы с ролями:
/// - CRUD операции над ролями
/// - Назначение/отзыв ролей пользователям
/// - Получение информации о ролях и их назначениях
///
/// ВАЖНО ДЛЯ BACKEND РАЗРАБОТЧИКА:
/// - Все операции должны проверять права доступа текущего пользователя
/// - Системные роли (isSystem: true) нельзя удалять или изменять их имя
/// - При удалении роли нужно отозвать её у всех пользователей
/// - Роли могут быть platform-level (tenantId == null) или tenant-scoped
/// - Platform-level роли видны во всех тенантах, но назначаются в контексте тенанта
abstract interface class IRoleManagementService {
  // ── CRUD операции над ролями ──────────────────────────────────────────────

  /// Получить список всех ролей в текущем тенанте
  ///
  /// Возвращает:
  /// - Все роли, созданные в текущем тенанте (tenantId == currentTenantId)
  /// - Все platform-level роли (tenantId == null)
  ///
  /// Сортировка: системные роли первыми, затем по имени
  ///
  /// Права доступа: требуется 'roles:read' или 'admin:*'
  Future<List<AqRole>> getRoles();

  /// Получить роль по ID
  ///
  /// Параметры:
  /// - roleId: ID роли
  ///
  /// Возвращает:
  /// - AqRole если роль найдена и доступна в текущем тенанте
  /// - null если роль не найдена или недоступна
  ///
  /// Права доступа: требуется 'roles:read' или 'admin:*'
  Future<AqRole?> getRole(String roleId);

  /// Создать новую роль
  ///
  /// Параметры:
  /// - name: Имя роли (обязательно, минимум 3 символа, уникально в рамках тенанта)
  /// - description: Описание роли (опционально)
  /// - permissions: Список прав доступа (обязательно, минимум 1 право)
  ///   Формат: 'resource:action' (например, 'projects:read', 'graphs:write')
  ///   Поддерживаются wildcards: 'projects:*', '*' (полный доступ)
  ///
  /// Бизнес-логика:
  /// - Роль создаётся в контексте текущего тенанта (tenantId = currentTenantId)
  /// - isSystem устанавливается в false (только backend может создавать системные роли)
  /// - createdAt устанавливается в текущее время (Unix timestamp в секундах)
  /// - Валидация: имя должно быть уникальным в рамках тенанта
  /// - Валидация: все permissions должны существовать в системе
  ///
  /// Аудит:
  /// - Создать запись в AqAuditTrail с action=create, entityType=role
  ///
  /// Права доступа: требуется 'roles:write' или 'admin:*'
  ///
  /// Исключения:
  /// - ValidationException: если имя невалидно или не уникально
  /// - PermissionException: если у пользователя нет прав
  Future<AqRole> createRole({
    required String name,
    String? description,
    required List<String> permissions,
  });

  /// Обновить существующую роль
  ///
  /// Параметры:
  /// - roleId: ID роли для обновления
  /// - name: Новое имя (опционально, если null - не меняется)
  /// - description: Новое описание (опционально, если null - не меняется)
  /// - permissions: Новый список прав (опционально, если null - не меняется)
  ///
  /// Бизнес-логика:
  /// - Системные роли (isSystem: true) нельзя переименовывать (name игнорируется)
  /// - Можно изменять permissions даже у системных ролей (для кастомизации)
  /// - Валидация: новое имя должно быть уникальным в рамках тенанта
  /// - Валидация: все permissions должны существовать в системе
  ///
  /// Аудит:
  /// - Создать запись в AqAuditTrail с action=update, entityType=role
  /// - В changes записать diff: что было изменено (before/after)
  ///
  /// Права доступа: требуется 'roles:write' или 'admin:*'
  ///
  /// Исключения:
  /// - NotFoundException: если роль не найдена
  /// - ValidationException: если новое имя невалидно или не уникально
  /// - PermissionException: если у пользователя нет прав
  Future<AqRole> updateRole({
    required String roleId,
    String? name,
    String? description,
    List<String>? permissions,
  });

  /// Удалить роль
  ///
  /// Параметры:
  /// - roleId: ID роли для удаления
  ///
  /// Бизнес-логика:
  /// - Системные роли (isSystem: true) нельзя удалять
  /// - При удалении роли нужно отозвать её у всех пользователей (удалить все AqUserRole)
  /// - Soft delete: можно пометить роль как deleted вместо физического удаления
  ///
  /// Аудит:
  /// - Создать запись в AqAuditTrail с action=delete, entityType=role
  /// - В changes записать удалённую роль и список пользователей, у которых она была
  ///
  /// Права доступа: требуется 'roles:delete' или 'admin:*'
  ///
  /// Исключения:
  /// - NotFoundException: если роль не найдена
  /// - ValidationException: если роль системная
  /// - PermissionException: если у пользователя нет прав
  Future<void> deleteRole(String roleId);

  // ── Назначение ролей пользователям ────────────────────────────────────────

  /// Назначить роль пользователю
  ///
  /// Параметры:
  /// - userId: ID пользователя
  /// - roleId: ID роли
  /// - expiresAt: Опциональное время истечения (Unix timestamp в секундах)
  ///
  /// Бизнес-логика:
  /// - Создаётся запись AqUserRole с tenantId = currentTenantId
  /// - grantedBy = currentUserId
  /// - grantedAt = текущее время
  /// - Если роль уже назначена пользователю - ничего не делать (идемпотентность)
  /// - Валидация: пользователь должен существовать
  /// - Валидация: роль должна существовать и быть доступна в текущем тенанте
  ///
  /// Аудит:
  /// - Создать запись в AqAuditTrail с action=assign, entityType=role
  /// - В changes записать: roleId, roleName, toUserId, toUserEmail
  ///
  /// Права доступа: требуется 'roles:assign' или 'admin:*'
  ///
  /// Исключения:
  /// - NotFoundException: если пользователь или роль не найдены
  /// - PermissionException: если у пользователя нет прав
  Future<void> assignRole({
    required String userId,
    required String roleId,
    int? expiresAt,
  });

  /// Отозвать роль у пользователя
  ///
  /// Параметры:
  /// - userId: ID пользователя
  /// - roleId: ID роли
  ///
  /// Бизнес-логика:
  /// - Удаляется запись AqUserRole для данного пользователя, роли и текущего тенанта
  /// - Если роль не была назначена - ничего не делать (идемпотентность)
  ///
  /// Аудит:
  /// - Создать запись в AqAuditTrail с action=revoke, entityType=role
  /// - В changes записать: roleId, roleName, fromUserId, fromUserEmail
  ///
  /// Права доступа: требуется 'roles:revoke' или 'admin:*'
  ///
  /// Исключения:
  /// - PermissionException: если у пользователя нет прав
  Future<void> revokeRole({
    required String userId,
    required String roleId,
  });

  // ── Получение информации о назначениях ────────────────────────────────────

  /// Получить список ролей пользователя
  ///
  /// Параметры:
  /// - userId: ID пользователя
  ///
  /// Возвращает:
  /// - Список всех ролей, назначенных пользователю в текущем тенанте
  /// - Не включает истёкшие роли (expiresAt < now)
  ///
  /// Права доступа: требуется 'roles:read' или 'admin:*'
  Future<List<AqRole>> getUserRoles(String userId);

  /// Получить список пользователей с данной ролью
  ///
  /// Параметры:
  /// - roleId: ID роли
  ///
  /// Возвращает:
  /// - Список всех пользователей, которым назначена эта роль в текущем тенанте
  /// - Не включает пользователей с истёкшими назначениями
  ///
  /// Права доступа: требуется 'roles:read' или 'admin:*'
  Future<List<AqUser>> getUsersByRole(String roleId);

  // ── Получение списка всех прав ────────────────────────────────────────────

  /// Получить список всех доступных прав в системе
  ///
  /// Возвращает:
  /// - Список всех permission keys, которые можно назначать ролям
  /// - Формат: 'resource:action' (например, 'projects:read', 'graphs:write')
  /// - Включает wildcards: 'projects:*', 'admin:*'
  ///
  /// Группировка для UI:
  /// Backend может вернуть Map<String, List<String>> где ключ - ресурс, значение - действия:
  /// {
  ///   "projects": ["read", "write", "delete", "admin"],
  ///   "graphs": ["read", "write", "execute", "delete"],
  ///   "admin": ["*"]
  /// }
  ///
  /// Права доступа: требуется 'roles:read' или 'admin:*'
  Future<List<String>> getAllPermissions();
}
