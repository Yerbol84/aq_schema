// pkgs/aq_schema/lib/data_layer/infrastructure/backup_service.dart
//
// Интерфейс для Backup & Recovery.
// Реализация должна быть в dart_vault_package.

/// Backup metadata
final class BackupMetadata {
  const BackupMetadata({
    required this.id,
    required this.timestamp,
    required this.size,
    required this.collections,
    this.description,
    this.tags = const [],
  });

  final String id;
  final int timestamp;
  final int size; // bytes
  final List<String> collections;
  final String? description;
  final List<String> tags;

  factory BackupMetadata.fromJson(Map<String, dynamic> json) => BackupMetadata(
        id: json['id'] as String,
        timestamp: json['timestamp'] as int,
        size: json['size'] as int,
        collections: (json['collections'] as List).cast<String>(),
        description: json['description'] as String?,
        tags: (json['tags'] as List?)?.cast<String>() ?? [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp,
        'size': size,
        'collections': collections,
        if (description != null) 'description': description,
        'tags': tags,
      };
}

/// Backup result
final class BackupResult {
  const BackupResult({
    required this.success,
    required this.backupId,
    this.metadata,
    this.error,
  });

  final bool success;
  final String backupId;
  final BackupMetadata? metadata;
  final String? error;
}

/// Restore result
final class RestoreResult {
  const RestoreResult({
    required this.success,
    required this.restoredCollections,
    required this.restoredRecords,
    this.error,
  });

  final bool success;
  final List<String> restoredCollections;
  final int restoredRecords;
  final String? error;
}

/// Backup retention policy
final class BackupRetentionPolicy {
  const BackupRetentionPolicy({
    required this.maxBackups,
    required this.maxAgeDays,
    this.keepDaily = 7,
    this.keepWeekly = 4,
    this.keepMonthly = 12,
  });

  final int maxBackups;
  final int maxAgeDays;
  final int keepDaily;
  final int keepWeekly;
  final int keepMonthly;
}

/// Backup Service interface
///
/// Реализация должна быть в dart_vault_package и инициализироваться через:
/// ```dart
/// IBackupService.initialize(MyBackupServiceImpl());
/// ```
abstract interface class IBackupService {
  /// Singleton instance
  static IBackupService? _instance;

  static IBackupService get instance {
    if (_instance == null) {
      throw StateError(
        'IBackupService not initialized. '
        'Call IBackupService.initialize() first.',
      );
    }
    return _instance!;
  }

  /// Initialize singleton instance
  static void initialize(IBackupService implementation) {
    _instance = implementation;
  }

  /// Reset instance (для тестов)
  static void reset() {
    _instance = null;
  }

  /// Создать backup
  Future<BackupResult> createBackup({
    List<String>? collections, // null = все коллекции
    String? description,
    List<String>? tags,
  });

  /// Восстановить из backup
  Future<RestoreResult> restoreBackup({
    required String backupId,
    List<String>? collections, // null = все коллекции из backup
    bool overwrite = false,
  });

  /// Получить список backups
  Future<List<BackupMetadata>> listBackups({
    List<String>? tags,
    int? limit,
  });

  /// Получить metadata backup
  Future<BackupMetadata?> getBackupMetadata(String backupId);

  /// Удалить backup
  Future<void> deleteBackup(String backupId);

  /// Применить retention policy
  Future<int> applyRetentionPolicy(BackupRetentionPolicy policy);

  /// Проверить backup (verify integrity)
  Future<bool> verifyBackup(String backupId);

  /// Получить размер всех backups
  Future<int> getTotalBackupSize();

  /// Экспортировать backup в файл
  Future<String> exportBackup({
    required String backupId,
    required String destinationPath,
  });

  /// Импортировать backup из файла
  Future<BackupResult> importBackup({
    required String sourcePath,
    String? description,
  });
}

/// Mock implementation для тестов
final class MockBackupService implements IBackupService {
  final Map<String, BackupMetadata> _backups = {};
  final Map<String, Map<String, List<Map<String, dynamic>>>> _backupData = {};

  @override
  Future<BackupResult> createBackup({
    List<String>? collections,
    String? description,
    List<String>? tags,
  }) async {
    final backupId = 'backup_${DateTime.now().millisecondsSinceEpoch}';
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    final metadata = BackupMetadata(
      id: backupId,
      timestamp: timestamp,
      size: 1024, // Mock size
      collections: collections ?? ['all'],
      description: description,
      tags: tags ?? [],
    );

    _backups[backupId] = metadata;
    _backupData[backupId] = {}; // Mock data

    return BackupResult(
      success: true,
      backupId: backupId,
      metadata: metadata,
    );
  }

  @override
  Future<RestoreResult> restoreBackup({
    required String backupId,
    List<String>? collections,
    bool overwrite = false,
  }) async {
    final metadata = _backups[backupId];
    if (metadata == null) {
      return RestoreResult(
        success: false,
        restoredCollections: [],
        restoredRecords: 0,
        error: 'Backup not found',
      );
    }

    return RestoreResult(
      success: true,
      restoredCollections: metadata.collections,
      restoredRecords: 100, // Mock count
    );
  }

  @override
  Future<List<BackupMetadata>> listBackups({
    List<String>? tags,
    int? limit,
  }) async {
    var backups = _backups.values.toList();

    if (tags != null && tags.isNotEmpty) {
      backups =
          backups.where((b) => b.tags.any((t) => tags.contains(t))).toList();
    }

    backups.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (limit != null) {
      backups = backups.take(limit).toList();
    }

    return backups;
  }

  @override
  Future<BackupMetadata?> getBackupMetadata(String backupId) async {
    return _backups[backupId];
  }

  @override
  Future<void> deleteBackup(String backupId) async {
    _backups.remove(backupId);
    _backupData.remove(backupId);
  }

  @override
  Future<int> applyRetentionPolicy(BackupRetentionPolicy policy) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final maxAge = policy.maxAgeDays * 24 * 3600;

    final toDelete = _backups.entries
        .where((e) => now - e.value.timestamp > maxAge)
        .map((e) => e.key)
        .toList();

    for (final id in toDelete) {
      await deleteBackup(id);
    }

    return toDelete.length;
  }

  @override
  Future<bool> verifyBackup(String backupId) async {
    return _backups.containsKey(backupId);
  }

  @override
  Future<int> getTotalBackupSize() async {
    return _backups.values.fold(0, (sum, b) async => (await sum) + b.size);
  }

  @override
  Future<String> exportBackup({
    required String backupId,
    required String destinationPath,
  }) async {
    if (!_backups.containsKey(backupId)) {
      throw Exception('Backup not found');
    }
    return destinationPath;
  }

  @override
  Future<BackupResult> importBackup({
    required String sourcePath,
    String? description,
  }) async {
    return createBackup(
        description: description ?? 'Imported from $sourcePath');
  }

  /// Clear all backups (для тестов)
  void clear() {
    _backups.clear();
    _backupData.clear();
  }
}
