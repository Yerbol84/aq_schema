// aq_schema/lib/subject/models/subject_capabilities.dart

import '../../tools/models/tool_capability.dart';

/// Capabilities требуемые Subject.
final class SubjectCapabilities {
  static final _SubjectCapabilitiesKeys _keys = _SubjectCapabilitiesKeys._();
  static _SubjectCapabilitiesKeys get keys => _keys;

  final List<ToolCapability> required;
  final List<ToolCapability> optional;

  const SubjectCapabilities({
    this.required = const [],
    this.optional = const [],
  });

  Map<String, dynamic> toJson() => {
        SubjectCapabilities.keys.required: required.map((c) => c.toString()).toList(),
        SubjectCapabilities.keys.optional: optional.map((c) => c.toString()).toList(),
      };

  factory SubjectCapabilities.fromJson(Map<String, dynamic> json) {
    // TODO: Парсинг ToolCapability из строк
    // Пока заглушка
    return const SubjectCapabilities();
  }
}

class _SubjectCapabilitiesKeys {
  _SubjectCapabilitiesKeys._();
  final String required = 'required';
  final String optional = 'optional';
}
