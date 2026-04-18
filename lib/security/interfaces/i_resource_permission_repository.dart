// pkgs/aq_schema/lib/security/interfaces/i_resource_permission_repository.dart
//
// Интерфейс репозитория для хранения прав доступа на ресурсы.
//
// Реализация должна быть в aq_security пакете.

import '../models/aq_resource_permission.dart';

/// Репозиторий для хранения прав доступа на ресурсы.
///
/// ## Назначение
///
/// Этот интерфейс определяет контракт для хранения и получения прав доступа
/// на уровне ресурсов (Resource-Level Access Control).
///
/// Data Layer (`dart_vault_package`) требует только эти методы для работы
/// с правами. Реализация должна быть в `aq_security`.
///
/// ## Реализация
///
/// Реализация должна:
/// - Хранить права в таблице `resource_permissions`
/// - Фильтровать истёкшие права (expiresAt < now)
/// - Обеспечивать уникальность (resourceId, userId)
/// - Поддерживать индексы для быстрого поиска
///
/// ## Использование
///
/// ```dart
/// final repo = IResourcePermissionRepository.instance;
///
/// // Сохранить право
/// await repo.save(AqResourcePermission(
///   id: uuid.v4(),
///   resourceId: 'project-123',
///   userId: 'user-456',
///   level: AccessLevel.write,
///   grantedBy: 'admin-789',
///   grantedAt: DateTime.now(),
/// ));
///
/// // Получить права на ресурс
/// final grants = await repo.findByResource('project-123');
/// ```
abstract interface class IResourcePermissionRepository {
  /// Сохранить право доступа (insert or update).
  ///
  /// **Поведение:**
  /// - Если право уже существует для (resourceId, userId) — обновить уровень
  /// - Если права нет — создать новое
  ///
  /// **Параметры:**
  /// - [permission] — право доступа для сохранения
  ///
  /// **SQL (пример):**
  /// ```sql
  /// INSERT INTO resource_permissions (id, resource_id, user_id, level, granted_by, granted_at, expires_at)
  /// VALUES ($1, $2, $3, $4, $5, $6, $7)
  /// ON CONFLICT (resource_id, user_id)
  /// DO UPDATE SET level = $4, granted_by = $5, granted_at = $6, expires_at = $7;
  /// ```
  Future<void> save(AqResourcePermission permission);

  /// Удалить право доступа.
  ///
  /// **Поведение:**
  /// - Если права нет — ничего не делает (idempotent)
  ///
  /// **Параметры:**
  /// - [resourceId] — ID ресурса
  /// - [userId] — ID пользователя
  ///
  /// **SQL (пример):**
  /// ```sql
  /// DELETE FROM resource_permissions
  /// WHERE resource_id = $1 AND user_id = $2;
  /// ```
  Future<void> delete({
    required String resourceId,
    required String userId,
  });

  /// Получить все права на ресурс.
  ///
  /// **Поведение:**
  /// - Возвращает только активные права (не истёкшие)
  /// - Фильтр: `expires_at IS NULL OR expires_at > NOW()`
  /// - Сортировка: по уровню доступа (admin → write → read)
  ///
  /// **Параметры:**
  /// - [resourceId] — ID ресурса
  ///
  /// **Возвращает:**
  /// Список [AqResourcePermission] с информацией о правах.
  ///
  /// **SQL (пример):**
  /// ```sql
  /// SELECT * FROM resource_permissions
  /// WHERE resource_id = $1
  ///   AND (expires_at IS NULL OR expires_at > NOW())
  /// ORDER BY
  ///   CASE level
  ///     WHEN 'admin' THEN 1
  ///     WHEN 'write' THEN 2
  ///     WHEN 'read' THEN 3
  ///   END;
  /// ```
  Future<List<AqResourcePermission>> findByResource(String resourceId);

  /// Получить все ресурсы пользователя.
  ///
  /// **Поведение:**
  /// - Возвращает ID ресурсов, к которым пользователь имеет доступ
  /// - Опционально фильтрует по минимальному уровню доступа
  /// - Возвращает только активные права (не истёкшие)
  ///
  /// **Параметры:**
  /// - [userId] — ID пользователя
  /// - [minimumLevel] — минимальный уровень доступа (опционально)
  ///
  /// **Возвращает:**
  /// Список ID ресурсов.
  ///
  /// **SQL (пример без фильтра):**
  /// ```sql
  /// SELECT DISTINCT resource_id FROM resource_permissions
  /// WHERE user_id = $1
  ///   AND (expires_at IS NULL OR expires_at > NOW());
  /// ```
  ///
  /// **SQL (пример с фильтром minimumLevel = write):**
  /// ```sql
  /// SELECT DISTINCT resource_id FROM resource_permissions
  /// WHERE user_id = $1
  ///   AND level IN ('write', 'admin')
  ///   AND (expires_at IS NULL OR expires_at > NOW());
  /// ```
  Future<List<String>> findResourcesByUser({
    required String userId,
    AccessLevel? minimumLevel,
  });

  /// Проверить наличие права.
  ///
  /// **Поведение:**
  /// - Проверяет, имеет ли пользователь право >= minimumLevel
  /// - Учитывает только активные права (не истёкшие)
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
  /// **Логика уровней:**
  /// - admin >= write >= read
  /// - Если minimumLevel = read, то подходят read, write, admin
  /// - Если minimumLevel = write, то подходят write, admin
  /// - Если minimumLevel = admin, то подходит только admin
  ///
  /// **SQL (пример для minimumLevel = write):**
  /// ```sql
  /// SELECT EXISTS(
  ///   SELECT 1 FROM resource_permissions
  ///   WHERE resource_id = $1
  ///     AND user_id = $2
  ///     AND level IN ('write', 'admin')
  ///     AND (expires_at IS NULL OR expires_at > NOW())
  /// );
  /// ```
  Future<bool> exists({
    required String resourceId,
    required String userId,
    required AccessLevel minimumLevel,
  });

  /// Удалить все права на ресурс.
  ///
  /// **Использование:**
  /// При удалении ресурса (проекта, графа) нужно удалить все права на него.
  ///
  /// **Параметры:**
  /// - [resourceId] — ID ресурса
  ///
  /// **SQL (пример):**
  /// ```sql
  /// DELETE FROM resource_permissions
  /// WHERE resource_id = $1;
  /// ```
  Future<void> deleteAllByResource(String resourceId);
}
