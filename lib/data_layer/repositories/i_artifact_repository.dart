import 'package:aq_schema/aq_schema.dart';

/// Repository for binary file storage with metadata management.
abstract interface class IArtifactRepository<T extends ArtifactEntry> {
  Future<void> save(T entry, List<int> bytes);
  Future<void> delete(String id);

  Future<List<int>?> loadBytes(String id);
  Stream<List<int>> streamBytes(String id);
  Future<T?> findById(String id);
  Future<List<T>> findAll({VaultQuery? query});
  Future<PageResult<T>> findPage(VaultQuery query);
  Future<bool> exists(String id);

  Stream<List<T>> watchAll({VaultQuery? query});
}
