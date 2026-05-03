// aq_schema/lib/tools/interfaces/i_tool_repository.dart
//
// Порт персистентности для Tool Registry.
// Реализация: InMemoryToolRepository (aq_tool_registry) или VaultToolRepository (dart_vault).

import '../models/tool_record.dart';
import '../../core/aq_platform_context.dart';

/// Репозиторий ToolRecord.
abstract interface class IToolRepository {
  static IToolRepository? _instance;

  static IToolRepository get instance =>
      AQPlatformContext.current?.toolRepository ??
      _instance ??
      (throw AssertionError('IToolRepository not initialized.'));

  static void initialize(IToolRepository impl) => _instance = impl;
  static void reset() => _instance = null;

  /// Сохранить или обновить запись.
  Future<void> save(ToolRecord record);

  /// Найти последнюю версию по id.
  Future<ToolRecord?> findById(String id);

  /// Найти все версии по id.
  Future<List<ToolRecord>> findVersions(String id);

  /// Найти все записи (опционально фильтр по namespace).
  Future<List<ToolRecord>> findAll({String? namespace});

  /// Удалить все версии по id.
  Future<void> delete(String id);
}
