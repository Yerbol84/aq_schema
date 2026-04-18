// pkgs/aq_schema/lib/security/models/rbac_metrics.dart
//
// Метрики RBAC системы для мониторинга и аналитики.

/// Метрики RBAC системы
///
/// Содержит статистику работы системы контроля доступа.
/// Используется для мониторинга производительности и выявления проблем.
final class RBACMetrics {
  const RBACMetrics({
    required this.totalChecks,
    required this.allowedChecks,
    required this.deniedChecks,
    required this.cacheHits,
    required this.cacheMisses,
    required this.avgEvaluationTimeMs,
    required this.maxEvaluationTimeMs,
    required this.policyEvaluations,
    required this.timestamp,
    this.byResource = const {},
    this.byAction = const {},
    this.topDeniedReasons = const {},
    // Дополнительные поля для совместимости со старым кодом
    this.avgCheckDuration = 0.0,
    this.checksByResource = const {},
    this.checksByAction = const {},
    this.checksByUser = const {},
    this.totalDenials = 0,
    this.denialsByReason = const {},
    this.denialsByResource = const {},
    this.roleUsage = const {},
    this.permissionUsage = const {},
    this.policyTriggers = const {},
    this.policyDenials = const {},
  });

  /// Общее количество проверок доступа
  final int totalChecks;

  /// Количество разрешённых проверок
  final int allowedChecks;

  /// Количество запрещённых проверок
  final int deniedChecks;

  /// Количество попаданий в кэш
  final int cacheHits;

  /// Количество промахов кэша
  final int cacheMisses;

  /// Среднее время оценки доступа (миллисекунды)
  final double avgEvaluationTimeMs;

  /// Максимальное время оценки доступа (миллисекунды)
  final int maxEvaluationTimeMs;

  /// Количество оценок политик
  final int policyEvaluations;

  /// Unix timestamp (секунды) когда были собраны метрики
  final int timestamp;

  /// Статистика по ресурсам
  /// Ключ: тип ресурса, значение: количество проверок
  /// Пример: {"projects": 1000, "graphs": 500}
  final Map<String, int> byResource;

  /// Статистика по действиям
  /// Ключ: действие, значение: количество проверок
  /// Пример: {"read": 700, "write": 200, "delete": 100}
  final Map<String, int> byAction;

  /// Топ причин отказа
  /// Ключ: причина, значение: количество
  /// Пример: {"Insufficient permissions": 30, "Policy denied": 15}
  final Map<String, int> topDeniedReasons;

  // ── Дополнительные поля для совместимости ─────────────────────────────────

  /// Среднее время проверки (для совместимости)
  final double avgCheckDuration;

  /// Проверки по ресурсам (для совместимости)
  final Map<String, int> checksByResource;

  /// Проверки по действиям (для совместимости)
  final Map<String, int> checksByAction;

  /// Проверки по пользователям
  final Map<String, int> checksByUser;

  /// Общее количество отказов
  final int totalDenials;

  /// Отказы по причинам
  final Map<String, int> denialsByReason;

  /// Отказы по ресурсам
  final Map<String, int> denialsByResource;

  /// Использование ролей
  final Map<String, int> roleUsage;

  /// Использование разрешений
  final Map<String, int> permissionUsage;

  /// Срабатывания политик
  final Map<String, int> policyTriggers;

  /// Отказы по политикам
  final Map<String, int> policyDenials;

  /// Процент попаданий в кэш
  double get cacheHitRate {
    final total = cacheHits + cacheMisses;
    return total > 0 ? (cacheHits / total) * 100 : 0.0;
  }

  /// Процент разрешённых проверок
  double get allowedRate {
    return totalChecks > 0 ? (allowedChecks / totalChecks) * 100 : 0.0;
  }

  /// Процент запрещённых проверок
  double get deniedRate {
    return totalChecks > 0 ? (deniedChecks / totalChecks) * 100 : 0.0;
  }

  factory RBACMetrics.fromJson(Map<String, dynamic> json) => RBACMetrics(
        totalChecks: json['totalChecks'] as int,
        allowedChecks: json['allowedChecks'] as int? ?? 0,
        deniedChecks: json['deniedChecks'] as int? ?? 0,
        cacheHits: json['cacheHits'] as int,
        cacheMisses: json['cacheMisses'] as int,
        avgEvaluationTimeMs: (json['avgEvaluationTimeMs'] as num?)?.toDouble() ?? 0.0,
        maxEvaluationTimeMs: json['maxEvaluationTimeMs'] as int? ?? 0,
        policyEvaluations: json['policyEvaluations'] as int? ?? 0,
        timestamp: json['timestamp'] as int,
        byResource: (json['byResource'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(k, v as int),
            ) ??
            {},
        byAction: (json['byAction'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(k, v as int),
            ) ??
            {},
        topDeniedReasons: (json['topDeniedReasons'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(k, v as int),
            ) ??
            {},
        avgCheckDuration: (json['avgCheckDuration'] as num?)?.toDouble() ?? 0.0,
        checksByResource: (json['checksByResource'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(k, v as int),
            ) ??
            {},
        checksByAction: (json['checksByAction'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(k, v as int),
            ) ??
            {},
        checksByUser: (json['checksByUser'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(k, v as int),
            ) ??
            {},
        totalDenials: json['totalDenials'] as int? ?? 0,
        denialsByReason: (json['denialsByReason'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(k, v as int),
            ) ??
            {},
        denialsByResource: (json['denialsByResource'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(k, v as int),
            ) ??
            {},
        roleUsage: (json['roleUsage'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(k, v as int),
            ) ??
            {},
        permissionUsage: (json['permissionUsage'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(k, v as int),
            ) ??
            {},
        policyTriggers: (json['policyTriggers'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(k, v as int),
            ) ??
            {},
        policyDenials: (json['policyDenials'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(k, v as int),
            ) ??
            {},
      );

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'totalChecks': totalChecks,
      'allowedChecks': allowedChecks,
      'deniedChecks': deniedChecks,
      'cacheHits': cacheHits,
      'cacheMisses': cacheMisses,
      'avgEvaluationTimeMs': avgEvaluationTimeMs,
      'maxEvaluationTimeMs': maxEvaluationTimeMs,
      'policyEvaluations': policyEvaluations,
      'timestamp': timestamp,
      'cacheHitRate': cacheHitRate,
      'allowedRate': allowedRate,
      'deniedRate': deniedRate,
      'avgCheckDuration': avgCheckDuration,
      'totalDenials': totalDenials,
    };
    if (byResource.isNotEmpty) m['byResource'] = byResource;
    if (byAction.isNotEmpty) m['byAction'] = byAction;
    if (topDeniedReasons.isNotEmpty) m['topDeniedReasons'] = topDeniedReasons;
    if (checksByResource.isNotEmpty) m['checksByResource'] = checksByResource;
    if (checksByAction.isNotEmpty) m['checksByAction'] = checksByAction;
    if (checksByUser.isNotEmpty) m['checksByUser'] = checksByUser;
    if (denialsByReason.isNotEmpty) m['denialsByReason'] = denialsByReason;
    if (denialsByResource.isNotEmpty) m['denialsByResource'] = denialsByResource;
    if (roleUsage.isNotEmpty) m['roleUsage'] = roleUsage;
    if (permissionUsage.isNotEmpty) m['permissionUsage'] = permissionUsage;
    if (policyTriggers.isNotEmpty) m['policyTriggers'] = policyTriggers;
    if (policyDenials.isNotEmpty) m['policyDenials'] = policyDenials;
    return m;
  }

  /// Создать пустые метрики
  factory RBACMetrics.empty() => RBACMetrics(
        totalChecks: 0,
        allowedChecks: 0,
        deniedChecks: 0,
        cacheHits: 0,
        cacheMisses: 0,
        avgEvaluationTimeMs: 0.0,
        maxEvaluationTimeMs: 0,
        policyEvaluations: 0,
        timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      );

  @override
  String toString() =>
      'RBACMetrics(total: $totalChecks, allowed: $allowedChecks, denied: $deniedChecks, cacheHitRate: ${cacheHitRate.toStringAsFixed(1)}%)';
}
