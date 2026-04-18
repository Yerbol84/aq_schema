// pkgs/aq_schema/lib/security/models/aq_scope.dart
//
// Scope definitions для fine-grained access control.
// Используется в JWT tokens и API keys.

/// Scope определяет конкретное разрешение на действие с ресурсом.
/// Формат: "resource:action" или "resource:action:id"
///
/// Примеры:
/// - "projects:read" — чтение всех проектов
/// - "projects:write" — создание/изменение проектов
/// - "projects:delete" — удаление проектов
/// - "projects:read:abc123" — чтение конкретного проекта
/// - "users:admin" — полный доступ к пользователям
final class AqScope {
  const AqScope({
    required this.resource,
    required this.action,
    this.resourceId,
  });

  /// Тип ресурса: projects, users, graphs, etc.
  final String resource;

  /// Действие: read, write, delete, admin, execute, etc.
  final String action;

  /// ID конкретного ресурса (опционально)
  final String? resourceId;

  /// Полное имя scope: "resource:action" или "resource:action:id"
  String get fullName {
    if (resourceId != null) {
      return '$resource:$action:$resourceId';
    }
    return '$resource:$action';
  }

  /// Проверяет, покрывает ли этот scope другой scope.
  ///
  /// Примеры:
  /// - "projects:admin" покрывает "projects:read"
  /// - "projects:read" покрывает "projects:read:abc123"
  /// - "projects:write" НЕ покрывает "projects:delete"
  bool covers(AqScope other) {
    // Разные ресурсы — не покрывает
    if (resource != other.resource) return false;

    // admin покрывает всё для этого ресурса
    if (action == 'admin') return true;

    // Разные действия — не покрывает
    if (action != other.action) return false;

    // Если у нас нет resourceId, покрываем все ресурсы
    if (resourceId == null) return true;

    // Если у нас есть resourceId, покрываем только тот же ресурс
    return resourceId == other.resourceId;
  }

  /// Парсит scope из строки "resource:action" или "resource:action:id"
  factory AqScope.parse(String scope) {
    final parts = scope.split(':');
    if (parts.length < 2) {
      throw FormatException('Invalid scope format: $scope');
    }

    return AqScope(
      resource: parts[0],
      action: parts[1],
      resourceId: parts.length > 2 ? parts[2] : null,
    );
  }

  @override
  String toString() => fullName;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AqScope &&
          runtimeType == other.runtimeType &&
          resource == other.resource &&
          action == other.action &&
          resourceId == other.resourceId;

  @override
  int get hashCode => Object.hash(resource, action, resourceId);
}

/// Набор предопределённых scopes для системы.
abstract final class AqScopes {
  // ── Projects ──────────────────────────────────────────────────────────────
  static const projectsRead = 'projects:read';
  static const projectsWrite = 'projects:write';
  static const projectsDelete = 'projects:delete';
  static const projectsAdmin = 'projects:admin';

  // ── Graphs ────────────────────────────────────────────────────────────────
  static const graphsRead = 'graphs:read';
  static const graphsWrite = 'graphs:write';
  static const graphsExecute = 'graphs:execute';
  static const graphsDelete = 'graphs:delete';
  static const graphsAdmin = 'graphs:admin';

  // ── Users ─────────────────────────────────────────────────────────────────
  static const usersRead = 'users:read';
  static const usersWrite = 'users:write';
  static const usersDelete = 'users:delete';
  static const usersAdmin = 'users:admin';

  // ── API Keys ──────────────────────────────────────────────────────────────
  static const apiKeysRead = 'api_keys:read';
  static const apiKeysWrite = 'api_keys:write';
  static const apiKeysRotate = 'api_keys:rotate';
  static const apiKeysRevoke = 'api_keys:revoke';
  static const apiKeysAdmin = 'api_keys:admin';

  // ── Sessions ──────────────────────────────────────────────────────────────
  static const sessionsRead = 'sessions:read';
  static const sessionsRevoke = 'sessions:revoke';
  static const sessionsAdmin = 'sessions:admin';

  // ── Tenants ───────────────────────────────────────────────────────────────
  static const tenantsRead = 'tenants:read';
  static const tenantsWrite = 'tenants:write';
  static const tenantsAdmin = 'tenants:admin';

  // ── System ────────────────────────────────────────────────────────────────
  static const systemAdmin = 'system:admin';
  static const systemAudit = 'system:audit';

  /// Все доступные scopes
  static const all = [
    projectsRead,
    projectsWrite,
    projectsDelete,
    projectsAdmin,
    graphsRead,
    graphsWrite,
    graphsExecute,
    graphsDelete,
    graphsAdmin,
    usersRead,
    usersWrite,
    usersDelete,
    usersAdmin,
    apiKeysRead,
    apiKeysWrite,
    apiKeysRotate,
    apiKeysRevoke,
    apiKeysAdmin,
    sessionsRead,
    sessionsRevoke,
    sessionsAdmin,
    tenantsRead,
    tenantsWrite,
    tenantsAdmin,
    systemAdmin,
    systemAudit,
  ];
}

/// Проверяет, есть ли у пользователя требуемые scopes.
class ScopeChecker {
  const ScopeChecker(this.userScopes);

  final List<String> userScopes;

  /// Проверяет, есть ли хотя бы один из требуемых scopes.
  bool hasAny(List<String> requiredScopes) {
    if (requiredScopes.isEmpty) return true;

    final userParsed = userScopes.map(AqScope.parse).toList();
    final requiredParsed = requiredScopes.map(AqScope.parse).toList();

    for (final required in requiredParsed) {
      for (final user in userParsed) {
        if (user.covers(required)) {
          return true;
        }
      }
    }

    return false;
  }

  /// Проверяет, есть ли все требуемые scopes.
  bool hasAll(List<String> requiredScopes) {
    if (requiredScopes.isEmpty) return true;

    final userParsed = userScopes.map(AqScope.parse).toList();
    final requiredParsed = requiredScopes.map(AqScope.parse).toList();

    for (final required in requiredParsed) {
      var found = false;
      for (final user in userParsed) {
        if (user.covers(required)) {
          found = true;
          break;
        }
      }
      if (!found) return false;
    }

    return true;
  }

  /// Проверяет конкретный scope.
  bool has(String scope) => hasAny([scope]);
}
