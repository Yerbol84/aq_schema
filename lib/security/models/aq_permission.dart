// pkgs/aq_schema/lib/security/models/aq_permission.dart
//
// Модель разрешения (permission) в RBAC системе.
// Представляет конкретное право доступа к ресурсу.

/// Разрешение (permission) в RBAC системе
///
/// Представляет конкретное право доступа к ресурсу.
/// Формат: "resourceType:action" (например, "projects:read", "graphs:write")
final class AqPermission {
  const AqPermission({
    required this.key,
    required this.resourceType,
    required this.action,
    this.description,
    this.category,
    this.isSystem = false,
  });

  /// Уникальный ключ разрешения
  /// Формат: "resourceType:action"
  /// Примеры: "projects:read", "graphs:write", "admin:*"
  final String key;

  /// Тип ресурса
  /// Примеры: "projects", "graphs", "instructions", "admin"
  final String resourceType;

  /// Действие
  /// Примеры: "read", "write", "delete", "execute", "admin", "*"
  final String action;

  /// Описание разрешения (для UI)
  /// Примеры:
  /// - "Read project data and metadata"
  /// - "Create, update and delete graphs"
  /// - "Full administrative access"
  final String? description;

  /// Категория для группировки в UI
  /// Примеры: "Projects", "Graphs", "Administration", "Security"
  final String? category;

  /// Системное разрешение (нельзя удалить)
  final bool isSystem;

  /// Проверить, соответствует ли данное разрешение требуемому
  ///
  /// Поддерживает wildcards:
  /// - "admin:*" соответствует любому "admin:X"
  /// - "*" соответствует любому разрешению
  bool matches(String requiredPermission) {
    // Полный wildcard
    if (key == '*') return true;

    // Точное совпадение
    if (key == requiredPermission) return true;

    // Wildcard по действию: "projects:*" соответствует "projects:read"
    if (action == '*') {
      final requiredParts = requiredPermission.split(':');
      if (requiredParts.length == 2 && requiredParts[0] == resourceType) {
        return true;
      }
    }

    return false;
  }

  /// Создать из ключа (парсинг "resourceType:action")
  factory AqPermission.fromKey(String key, {String? description, String? category}) {
    final parts = key.split(':');
    if (parts.length != 2) {
      throw ArgumentError('Invalid permission key format: $key. Expected "resourceType:action"');
    }

    return AqPermission(
      key: key,
      resourceType: parts[0],
      action: parts[1],
      description: description,
      category: category,
    );
  }

  factory AqPermission.fromJson(Map<String, dynamic> json) => AqPermission(
        key: json['key'] as String,
        resourceType: json['resourceType'] as String,
        action: json['action'] as String,
        description: json['description'] as String?,
        category: json['category'] as String?,
        isSystem: json['isSystem'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'key': key,
      'resourceType': resourceType,
      'action': action,
      'isSystem': isSystem,
    };
    if (description != null) m['description'] = description;
    if (category != null) m['category'] = category;
    return m;
  }

  @override
  String toString() => 'AqPermission($key)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AqPermission && runtimeType == other.runtimeType && key == other.key;

  @override
  int get hashCode => key.hashCode;
}

/// Стандартные разрешения системы
///
/// Backend может использовать эти константы для проверки прав.
/// UI может использовать для отображения доступных разрешений.
class StandardPermissions {
  StandardPermissions._();

  // ── Projects ──────────────────────────────────────────────────────────────
  static const projectRead = 'projects:read';
  static const projectWrite = 'projects:write';
  static const projectDelete = 'projects:delete';
  static const projectAdmin = 'projects:admin';
  static const projectAll = 'projects:*';

  // ── Graphs ────────────────────────────────────────────────────────────────
  static const graphRead = 'graphs:read';
  static const graphWrite = 'graphs:write';
  static const graphExecute = 'graphs:execute';
  static const graphDelete = 'graphs:delete';
  static const graphAdmin = 'graphs:admin';
  static const graphAll = 'graphs:*';

  // ── Instructions ──────────────────────────────────────────────────────────
  static const instructionRead = 'instructions:read';
  static const instructionWrite = 'instructions:write';
  static const instructionDelete = 'instructions:delete';
  static const instructionAll = 'instructions:*';

  // ── Prompts ───────────────────────────────────────────────────────────────
  static const promptRead = 'prompts:read';
  static const promptWrite = 'prompts:write';
  static const promptDelete = 'prompts:delete';
  static const promptAll = 'prompts:*';

  // ── Roles & Permissions ───────────────────────────────────────────────────
  static const roleRead = 'roles:read';
  static const roleWrite = 'roles:write';
  static const roleDelete = 'roles:delete';
  static const roleAssign = 'roles:assign';
  static const roleRevoke = 'roles:revoke';
  static const roleAll = 'roles:*';

  // ── Policies ──────────────────────────────────────────────────────────────
  static const policyRead = 'policies:read';
  static const policyWrite = 'policies:write';
  static const policyDelete = 'policies:delete';
  static const policyTest = 'policies:test';
  static const policyAll = 'policies:*';

  // ── Audit ─────────────────────────────────────────────────────────────────
  static const auditRead = 'audit:read';
  static const auditDelete = 'audit:delete';
  static const auditAll = 'audit:*';

  // ── Users ─────────────────────────────────────────────────────────────────
  static const userRead = 'users:read';
  static const userWrite = 'users:write';
  static const userDelete = 'users:delete';
  static const userAll = 'users:*';

  // ── Administration ────────────────────────────────────────────────────────
  static const adminAll = 'admin:*';

  // ── Full Access ───────────────────────────────────────────────────────────
  static const all = '*';

  /// Получить все стандартные разрешения
  static List<AqPermission> getAllPermissions() => [
        // Projects
        AqPermission.fromKey(projectRead, description: 'Чтение проектов', category: 'Projects'),
        AqPermission.fromKey(projectWrite, description: 'Создание и редактирование проектов', category: 'Projects'),
        AqPermission.fromKey(projectDelete, description: 'Удаление проектов', category: 'Projects'),
        AqPermission.fromKey(projectAdmin, description: 'Администрирование проектов', category: 'Projects'),

        // Graphs
        AqPermission.fromKey(graphRead, description: 'Чтение графов', category: 'Graphs'),
        AqPermission.fromKey(graphWrite, description: 'Создание и редактирование графов', category: 'Graphs'),
        AqPermission.fromKey(graphExecute, description: 'Запуск графов', category: 'Graphs'),
        AqPermission.fromKey(graphDelete, description: 'Удаление графов', category: 'Graphs'),

        // Instructions
        AqPermission.fromKey(instructionRead, description: 'Чтение инструкций', category: 'Instructions'),
        AqPermission.fromKey(instructionWrite, description: 'Создание и редактирование инструкций', category: 'Instructions'),
        AqPermission.fromKey(instructionDelete, description: 'Удаление инструкций', category: 'Instructions'),

        // Prompts
        AqPermission.fromKey(promptRead, description: 'Чтение промптов', category: 'Prompts'),
        AqPermission.fromKey(promptWrite, description: 'Создание и редактирование промптов', category: 'Prompts'),
        AqPermission.fromKey(promptDelete, description: 'Удаление промптов', category: 'Prompts'),

        // Roles
        AqPermission.fromKey(roleRead, description: 'Просмотр ролей', category: 'Security'),
        AqPermission.fromKey(roleWrite, description: 'Создание и редактирование ролей', category: 'Security'),
        AqPermission.fromKey(roleDelete, description: 'Удаление ролей', category: 'Security'),
        AqPermission.fromKey(roleAssign, description: 'Назначение ролей пользователям', category: 'Security'),
        AqPermission.fromKey(roleRevoke, description: 'Отзыв ролей у пользователей', category: 'Security'),

        // Policies
        AqPermission.fromKey(policyRead, description: 'Просмотр политик', category: 'Security'),
        AqPermission.fromKey(policyWrite, description: 'Создание и редактирование политик', category: 'Security'),
        AqPermission.fromKey(policyDelete, description: 'Удаление политик', category: 'Security'),
        AqPermission.fromKey(policyTest, description: 'Тестирование политик', category: 'Security'),

        // Audit
        AqPermission.fromKey(auditRead, description: 'Просмотр логов и аудита', category: 'Security'),
        AqPermission.fromKey(auditDelete, description: 'Удаление старых логов', category: 'Security'),

        // Users
        AqPermission.fromKey(userRead, description: 'Просмотр пользователей', category: 'Users'),
        AqPermission.fromKey(userWrite, description: 'Создание и редактирование пользователей', category: 'Users'),
        AqPermission.fromKey(userDelete, description: 'Удаление пользователей', category: 'Users'),

        // Admin
        AqPermission.fromKey(adminAll, description: 'Полный административный доступ', category: 'Administration'),
      ];
}
