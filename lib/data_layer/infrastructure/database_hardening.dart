// pkgs/aq_schema/lib/data_layer/infrastructure/database_hardening.dart
//
// Интерфейс для Database Hardening.
// Реализация должна быть в dart_vault_package.

/// Connection pool statistics
final class ConnectionPoolStats {
  const ConnectionPoolStats({
    required this.totalConnections,
    required this.activeConnections,
    required this.idleConnections,
    required this.waitingRequests,
    required this.maxConnections,
  });

  final int totalConnections;
  final int activeConnections;
  final int idleConnections;
  final int waitingRequests;
  final int maxConnections;

  double get utilizationPercent =>
      maxConnections > 0 ? (activeConnections / maxConnections) * 100 : 0;

  factory ConnectionPoolStats.fromJson(Map<String, dynamic> json) =>
      ConnectionPoolStats(
        totalConnections: json['totalConnections'] as int,
        activeConnections: json['activeConnections'] as int,
        idleConnections: json['idleConnections'] as int,
        waitingRequests: json['waitingRequests'] as int,
        maxConnections: json['maxConnections'] as int,
      );

  Map<String, dynamic> toJson() => {
        'totalConnections': totalConnections,
        'activeConnections': activeConnections,
        'idleConnections': idleConnections,
        'waitingRequests': waitingRequests,
        'maxConnections': maxConnections,
        'utilizationPercent': utilizationPercent,
      };
}

/// Database index information
final class DatabaseIndex {
  const DatabaseIndex({
    required this.name,
    required this.table,
    required this.columns,
    required this.isUnique,
    required this.size,
  });

  final String name;
  final String table;
  final List<String> columns;
  final bool isUnique;
  final int size; // bytes

  factory DatabaseIndex.fromJson(Map<String, dynamic> json) => DatabaseIndex(
        name: json['name'] as String,
        table: json['table'] as String,
        columns: (json['columns'] as List).cast<String>(),
        isUnique: json['isUnique'] as bool,
        size: json['size'] as int,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'table': table,
        'columns': columns,
        'isUnique': isUnique,
        'size': size,
      };
}

/// Query performance statistics
final class QueryPerformanceStats {
  const QueryPerformanceStats({
    required this.query,
    required this.executionCount,
    required this.avgDurationMs,
    required this.maxDurationMs,
    required this.totalDurationMs,
  });

  final String query;
  final int executionCount;
  final double avgDurationMs;
  final double maxDurationMs;
  final double totalDurationMs;

  factory QueryPerformanceStats.fromJson(Map<String, dynamic> json) =>
      QueryPerformanceStats(
        query: json['query'] as String,
        executionCount: json['executionCount'] as int,
        avgDurationMs: (json['avgDurationMs'] as num).toDouble(),
        maxDurationMs: (json['maxDurationMs'] as num).toDouble(),
        totalDurationMs: (json['totalDurationMs'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'query': query,
        'executionCount': executionCount,
        'avgDurationMs': avgDurationMs,
        'maxDurationMs': maxDurationMs,
        'totalDurationMs': totalDurationMs,
      };
}

/// Database health check result
final class DatabaseHealthCheck {
  const DatabaseHealthCheck({
    required this.healthy,
    required this.checks,
    this.error,
  });

  final bool healthy;
  final Map<String, bool> checks;
  final String? error;

  factory DatabaseHealthCheck.fromJson(Map<String, dynamic> json) =>
      DatabaseHealthCheck(
        healthy: json['healthy'] as bool,
        checks: (json['checks'] as Map<String, dynamic>).cast<String, bool>(),
        error: json['error'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'healthy': healthy,
        'checks': checks,
        if (error != null) 'error': error,
      };
}

/// Database Hardening interface
///
/// Реализация должна быть в dart_vault_package и инициализироваться через:
/// ```dart
/// IDatabaseHardening.initialize(MyDatabaseHardeningImpl());
/// ```
abstract interface class IDatabaseHardening {
  /// Singleton instance
  static IDatabaseHardening? _instance;

  static IDatabaseHardening get instance {
    if (_instance == null) {
      throw StateError(
        'IDatabaseHardening not initialized. '
        'Call IDatabaseHardening.initialize() first.',
      );
    }
    return _instance!;
  }

  /// Initialize singleton instance
  static void initialize(IDatabaseHardening implementation) {
    _instance = implementation;
  }

  /// Reset instance (для тестов)
  static void reset() {
    _instance = null;
  }

  /// Получить статистику connection pool
  Future<ConnectionPoolStats> getConnectionPoolStats();

  /// Настроить connection pool
  Future<void> configureConnectionPool({
    required int minConnections,
    required int maxConnections,
    required int connectionTimeout,
  });

  /// Получить список индексов
  Future<List<DatabaseIndex>> listIndexes({String? table});

  /// Создать индекс
  Future<void> createIndex({
    required String name,
    required String table,
    required List<String> columns,
    bool unique = false,
  });

  /// Удалить индекс
  Future<void> dropIndex(String name);

  /// Оптимизировать индексы (analyze, vacuum)
  Future<void> optimizeIndexes();

  /// Получить статистику производительности запросов
  Future<List<QueryPerformanceStats>> getQueryPerformanceStats({
    int? limit,
    double? minDurationMs,
  });

  /// Очистить статистику запросов
  Future<void> clearQueryStats();

  /// Выполнить VACUUM (PostgreSQL)
  Future<void> vacuum({bool full = false});

  /// Выполнить ANALYZE (обновить статистику)
  Future<void> analyze({String? table});

  /// Health check базы данных
  Future<DatabaseHealthCheck> healthCheck();

  /// Получить размер базы данных
  Future<int> getDatabaseSize();

  /// Получить размер таблицы
  Future<int> getTableSize(String table);

  /// Проверить foreign keys
  Future<bool> verifyForeignKeys();

  /// Проверить constraints
  Future<bool> verifyConstraints();
}

/// Mock implementation для тестов
final class MockDatabaseHardening implements IDatabaseHardening {
  int _minConnections = 5;
  int _maxConnections = 20;
  int _activeConnections = 3;
  final List<DatabaseIndex> _indexes = [];
  final List<QueryPerformanceStats> _queryStats = [];

  @override
  Future<ConnectionPoolStats> getConnectionPoolStats() async {
    return ConnectionPoolStats(
      totalConnections: _activeConnections + 2,
      activeConnections: _activeConnections,
      idleConnections: 2,
      waitingRequests: 0,
      maxConnections: _maxConnections,
    );
  }

  @override
  Future<void> configureConnectionPool({
    required int minConnections,
    required int maxConnections,
    required int connectionTimeout,
  }) async {
    _minConnections = minConnections;
    _maxConnections = maxConnections;
  }

  @override
  Future<List<DatabaseIndex>> listIndexes({String? table}) async {
    if (table != null) {
      return _indexes.where((i) => i.table == table).toList();
    }
    return _indexes;
  }

  @override
  Future<void> createIndex({
    required String name,
    required String table,
    required List<String> columns,
    bool unique = false,
  }) async {
    _indexes.add(DatabaseIndex(
      name: name,
      table: table,
      columns: columns,
      isUnique: unique,
      size: 1024, // Mock size
    ));
  }

  @override
  Future<void> dropIndex(String name) async {
    _indexes.removeWhere((i) => i.name == name);
  }

  @override
  Future<void> optimizeIndexes() async {
    // Mock optimization
  }

  @override
  Future<List<QueryPerformanceStats>> getQueryPerformanceStats({
    int? limit,
    double? minDurationMs,
  }) async {
    var stats = _queryStats;

    if (minDurationMs != null) {
      stats = stats.where((s) => s.avgDurationMs >= minDurationMs).toList();
    }

    stats.sort((a, b) => b.avgDurationMs.compareTo(a.avgDurationMs));

    if (limit != null) {
      stats = stats.take(limit).toList();
    }

    return stats;
  }

  @override
  Future<void> clearQueryStats() async {
    _queryStats.clear();
  }

  @override
  Future<void> vacuum({bool full = false}) async {
    // Mock vacuum
  }

  @override
  Future<void> analyze({String? table}) async {
    // Mock analyze
  }

  @override
  Future<DatabaseHealthCheck> healthCheck() async {
    return const DatabaseHealthCheck(
      healthy: true,
      checks: {
        'connection': true,
        'disk_space': true,
        'replication': true,
      },
    );
  }

  @override
  Future<int> getDatabaseSize() async {
    return 1024 * 1024 * 100; // 100 MB
  }

  @override
  Future<int> getTableSize(String table) async {
    return 1024 * 1024 * 10; // 10 MB
  }

  @override
  Future<bool> verifyForeignKeys() async {
    return true;
  }

  @override
  Future<bool> verifyConstraints() async {
    return true;
  }

  /// Add mock query stats (для тестов)
  void addQueryStats(QueryPerformanceStats stats) {
    _queryStats.add(stats);
  }

  /// Clear all data (для тестов)
  void clear() {
    _indexes.clear();
    _queryStats.clear();
    _minConnections = 5;
    _maxConnections = 20;
    _activeConnections = 3;
  }
}
