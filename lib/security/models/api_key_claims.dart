// Модель для claims API ключа

/// Claims API ключа для контроля доступа
///
/// Содержит информацию о правах доступа (scope) для API ключа
class AQApiKeyClaims {
  /// Список разрешённых scope
  /// Примеры: 'llm', 'fs:read', 'fs:write', '*' (wildcard)
  final List<String> scope;

  /// ID проекта к которому привязан ключ
  final String? projectId;

  /// ID пользователя-владельца ключа
  final String? userId;

  /// Дополнительные метаданные
  final Map<String, dynamic>? metadata;

  const AQApiKeyClaims({
    required this.scope,
    this.projectId,
    this.userId,
    this.metadata,
  });

  /// Проверить наличие scope
  bool allows(String requiredScope) {
    return scope.contains(requiredScope) || scope.contains('*');
  }

  /// Проверить наличие любого из scope
  bool allowsAny(List<String> requiredScopes) {
    if (scope.contains('*')) return true;
    return requiredScopes.any((s) => scope.contains(s));
  }

  Map<String, dynamic> toJson() => {
        'scope': scope,
        if (projectId != null) 'projectId': projectId,
        if (userId != null) 'userId': userId,
        if (metadata != null) 'metadata': metadata,
      };

  factory AQApiKeyClaims.fromJson(Map<String, dynamic> json) => AQApiKeyClaims(
        scope: (json['scope'] as List).cast<String>(),
        projectId: json['projectId'] as String?,
        userId: json['userId'] as String?,
        metadata: json['metadata'] as Map<String, dynamic>?,
      );

  /// Создать unrestricted claims (для локального режима)
  factory AQApiKeyClaims.unrestricted() => const AQApiKeyClaims(
        scope: ['*'],
      );
}
