// aq_schema/lib/subject/models/subject_ref.dart

import '../../data_layer/models/semver.dart';

/// Ссылка на Subject.
final class SubjectRef {
  final String id;
  final Semver? version;
  
  const SubjectRef(this.id, {this.version});
  
  @override
  String toString() => version != null ? '$id@$version' : id;
}
