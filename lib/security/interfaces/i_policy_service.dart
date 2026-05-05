// pkgs/aq_schema/lib/security/interfaces/i_policy_service.dart
//
// Порт управления политиками доступа (ABAC/PBAC).
// Доступен через ISecurityService.instance.policies
//
// 🔑 Только для admin UI — создание/редактирование политик.
// Политики применяются автоматически в AccessControlEngine при каждой проверке прав.
//
// Пример:
//   final policies = await ISecurityService.instance.policies.getPolicies();
//   await ISecurityService.instance.policies.createPolicy(policy);

import '../models/aq_policy.dart';

/// Сервис управления политиками доступа
///
/// Этот интерфейс определяет все операции для работы с политиками:
/// - CRUD операции над политиками
/// - Оценка политик (policy evaluation)
/// - Управление приоритетами и активацией
///
/// ВАЖНО ДЛЯ BACKEND РАЗРАБОТЧИКА:
/// - Политики позволяют реализовать сложные правила доступа на основе контекста
/// - Политики оцениваются в порядке приоритета (больше = выше)
/// - Deny всегда побеждает Allow (если хотя бы одна политика deny - доступ запрещён)
/// - Неактивные политики (isActive: false) не участвуют в оценке
/// - Политики работают в дополнение к RBAC (сначала проверяются роли, потом политики)
abstract interface class IPolicyService {
  // ── CRUD операции над политиками ──────────────────────────────────────────

  /// Получить список всех политик в текущем тенанте
  ///
  /// Параметры:
  /// - includeInactive: включать ли неактивные политики (по умолчанию false)
  ///
  /// Возвращает:
  /// - Список всех политик текущего тенанта
  /// - Сортировка: по приоритету (desc), затем по имени
  ///
  /// Права доступа: требуется 'policies:read' или 'admin:*'
  Future<List<AqPolicy>> getPolicies({bool includeInactive = false});

  /// Получить политику по ID
  ///
  /// Параметры:
  /// - policyId: ID политики
  ///
  /// Возвращает:
  /// - AqPolicy если политика найдена и принадлежит текущему тенанту
  /// - null если политика не найдена
  ///
  /// Права доступа: требуется 'policies:read' или 'admin:*'
  Future<AqPolicy?> getPolicy(String policyId);

  /// Создать новую политику
  ///
  /// Параметры:
  /// - name: Имя политики (обязательно, минимум 3 символа)
  /// - description: Описание политики (опционально)
  /// - statements: Список statement'ов (обязательно, минимум 1)
  /// - isActive: Активна ли политика (по умолчанию true)
  /// - priority: Приоритет политики (по умолчанию 0, больше = выше)
  ///
  /// Бизнес-логика:
  /// - Политика создаётся в контексте текущего тенанта
  /// - createdAt устанавливается в текущее время
  /// - createdBy = currentUserId
  /// - Валидация: имя должно быть уникальным в рамках тенанта
  /// - Валидация: все conditions в statements должны быть валидными
  ///
  /// Аудит:
  /// - Создать запись в AqAuditTrail с action=create, entityType=policy
  ///
  /// Права доступа: требуется 'policies:write' или 'admin:*'
  ///
  /// Исключения:
  /// - ValidationException: если данные невалидны
  /// - PermissionException: если у пользователя нет прав
  Future<AqPolicy> createPolicy({
    required String name,
    String? description,
    required List<PolicyStatement> statements,
    bool isActive = true,
    int priority = 0,
  });

  /// Обновить существующую политику
  ///
  /// Параметры:
  /// - policyId: ID политики для обновления
  /// - name: Новое имя (опционально)
  /// - description: Новое описание (опционально)
  /// - statements: Новые statement'ы (опционально)
  /// - isActive: Новый статус активности (опционально)
  /// - priority: Новый приоритет (опционально)
  ///
  /// Бизнес-логика:
  /// - Обновляются только переданные поля (null = не меняется)
  /// - Валидация: новое имя должно быть уникальным
  ///
  /// Аудит:
  /// - Создать запись в AqAuditTrail с action=update, entityType=policy
  /// - В changes записать diff изменений
  ///
  /// Права доступа: требуется 'policies:write' или 'admin:*'
  ///
  /// Исключения:
  /// - NotFoundException: если политика не найдена
  /// - ValidationException: если данные невалидны
  /// - PermissionException: если у пользователя нет прав
  Future<AqPolicy> updatePolicy({
    required String policyId,
    String? name,
    String? description,
    List<PolicyStatement>? statements,
    bool? isActive,
    int? priority,
  });

  /// Удалить политику
  ///
  /// Параметры:
  /// - policyId: ID политики для удаления
  ///
  /// Бизнес-логика:
  /// - Физическое удаление политики из БД
  /// - После удаления политика больше не участвует в оценке доступа
  ///
  /// Аудит:
  /// - Создать запись в AqAuditTrail с action=delete, entityType=policy
  /// - В changes записать удалённую политику
  ///
  /// Права доступа: требуется 'policies:delete' или 'admin:*'
  ///
  /// Исключения:
  /// - NotFoundException: если политика не найдена
  /// - PermissionException: если у пользователя нет прав
  Future<void> deletePolicy(String policyId);

  // ── Оценка политик ────────────────────────────────────────────────────────

  /// Оценить политики для данного контекста
  ///
  /// Параметры:
  /// - context: Контекст для оценки (пользователь, ресурс, атрибуты и т.д.)
  ///
  /// Возвращает:
  /// - PolicyEvaluationResult с решением (allowed/denied) и причиной
  ///
  /// Бизнес-логика оценки:
  /// 1. Получить все активные политики текущего тенанта
  /// 2. Отсортировать по приоритету (desc)
  /// 3. Для каждой политики:
  ///    - Оценить все conditions в каждом statement
  ///    - Если все conditions выполнены (с учётом logic: and/or/not):
  ///      - Если effect = deny → немедленно вернуть deny (deny всегда побеждает)
  ///      - Если effect = allow → запомнить как matched policy
  /// 4. Если есть хотя бы одна matched allow policy → вернуть allow
  /// 5. Если нет matched policies → вернуть deny (default deny)
  ///
  /// Примеры условий для оценки:
  ///
  /// TimeRange:
  /// - Проверить, что context.timestamp попадает в указанный диапазон
  ///
  /// IpAddress:
  /// - Проверить, что context.ipAddress соответствует условию (equals, in_list, matches)
  ///
  /// UserAttribute:
  /// - Проверить атрибут пользователя: context.userAttributes[field] operator value
  ///
  /// ResourceAttribute:
  /// - Проверить атрибут ресурса: context.resourceAttributes[field] operator value
  ///
  /// Scope:
  /// - Проверить, что требуемый scope есть в context.scopes
  ///
  /// Role:
  /// - Проверить, что требуемая роль есть в context.roles
  ///
  /// Логирование:
  /// - Каждая оценка политики должна логироваться в AqAccessLog
  /// - В metadata записать: appliedPolicies, evaluationTimeMs
  ///
  /// Права доступа: не требуются (используется внутри системы)
  Future<PolicyEvaluationResult> evaluatePolicy(PolicyContext context);

  /// Тестовая оценка политики (для UI)
  ///
  /// Параметры:
  /// - userId: ID пользователя для теста
  /// - resource: Ресурс для теста (формат: "resourceType:resourceId")
  /// - action: Действие для теста
  /// - additionalContext: Дополнительный контекст (IP, атрибуты и т.д.)
  ///
  /// Возвращает:
  /// - PolicyEvaluationResult с детальным объяснением решения
  ///
  /// Бизнес-логика:
  /// - Построить PolicyContext из параметров
  /// - Вызвать evaluatePolicy(context)
  /// - Вернуть результат с детальным reason (какие политики сработали, почему)
  ///
  /// Права доступа: требуется 'policies:test' или 'admin:*'
  Future<PolicyEvaluationResult> testPolicy({
    required String userId,
    required String resource,
    required String action,
    Map<String, dynamic>? additionalContext,
  });
}
