// aq_schema/lib/tools/models/tool_source.dart

import 'package:pub_semver/pub_semver.dart';

/// Источник Tool.
sealed class ToolSource {
  const ToolSource();

  factory ToolSource.native() => NativeToolSource();
  factory ToolSource.subject(String subjectId, Version version) =>
      SubjectToolSource(subjectId, version);
}

/// Native Tool (Dart код).
final class NativeToolSource extends ToolSource {
  const NativeToolSource();
}

/// Subject-as-Tool.
final class SubjectToolSource extends ToolSource {
  final String subjectId;
  final Version version;

  const SubjectToolSource(this.subjectId, this.version);
}
