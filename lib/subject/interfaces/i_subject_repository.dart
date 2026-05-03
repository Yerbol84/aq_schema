// aq_schema/lib/subject/interfaces/i_subject_repository.dart
//
// Порт персистентности для Subject Registry.
// Реализация: InMemorySubjectRepository (aq_subject_registry) или VaultSubjectRepository (dart_vault).

import '../models/subject_record.dart';
import '../../core/aq_platform_context.dart';

/// Репозиторий SubjectRecord.
abstract interface class ISubjectRepository {
  static ISubjectRepository? _instance;

  static ISubjectRepository get instance =>
      AQPlatformContext.current?.subjectRepository ??
      _instance ??
      (throw AssertionError('ISubjectRepository not initialized.'));

  static void initialize(ISubjectRepository impl) => _instance = impl;
  static void reset() => _instance = null;

  /// Сохранить или обновить запись.
  Future<void> save(SubjectRecord record);

  /// Найти последнюю версию по id.
  Future<SubjectRecord?> findById(String id);

  /// Найти все версии по id.
  Future<List<SubjectRecord>> findVersions(String id);

  /// Найти все записи (опционально фильтр по namespace).
  Future<List<SubjectRecord>> findAll({String? namespace});

  /// Удалить все версии по id.
  Future<void> delete(String id);
}
