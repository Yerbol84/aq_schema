// aq_schema/lib/subject/models/subject_spec.dart
//
// Спецификация Subject — КАК его запускать.

import '../../tools/models/tool_ref.dart';
import 'subject_capabilities.dart';
import 'subject_interface.dart';
import 'subject_kind.dart';
import 'subject_runtime.dart';
import 'subject_source.dart';

/// Спецификация Subject.
///
/// Определяет КАК запускать Subject:
/// • kind — тип Subject
/// • source — откуда взять (типизированный!)
/// • interface — как общаться
/// • tools — зависимости от Tools
/// • runtime — настройки выполнения
/// • capabilities — что нужно для работы
final class SubjectSpec {
  static final _SubjectSpecKeys _keys = _SubjectSpecKeys._();
  static _SubjectSpecKeys get keys => _keys;

  final SubjectKind kind;
  final SubjectSource source; // ← Теперь типизированный!
  final SubjectInterface interface;

  /// Зависимости от Tools.
  ///
  /// Ключ — алиас Tool в Subject (например "llm", "fs").
  /// Значение — ссылка на Tool в реестре.
  final Map<String, ToolRef> tools;

  final SubjectRuntime? runtime;
  final SubjectCapabilities? capabilities;

  const SubjectSpec({
    required this.kind,
    required this.source,
    required this.interface,
    this.tools = const {},
    this.runtime,
    this.capabilities,
  });

  Map<String, dynamic> toJson() => {
        SubjectSpec.keys.kind: kind.value,
        SubjectSpec.keys.source: source.toJson(),
        SubjectSpec.keys.interface: interface.toJson(),
        if (tools.isNotEmpty)
          SubjectSpec.keys.tools:
              tools.map((k, v) => MapEntry(k, v.toJson())),
        if (runtime != null) SubjectSpec.keys.runtime: runtime!.toJson(),
        if (capabilities != null)
          SubjectSpec.keys.capabilities: capabilities!.toJson(),
      };

  factory SubjectSpec.fromJson(Map<String, dynamic> json) {
    final kind = SubjectKind.parse(json[SubjectSpec.keys.kind] as String);
    return SubjectSpec(
      kind: kind,
      source: SubjectSource.fromJson(
        kind.value,
        json[SubjectSpec.keys.source] as Map<String, dynamic>,
      ),
      interface: SubjectInterface.fromJson(
          json[SubjectSpec.keys.interface] as Map<String, dynamic>),
      tools: json[SubjectSpec.keys.tools] != null
          ? (json[SubjectSpec.keys.tools] as Map).map(
              (k, v) => MapEntry(
                k as String,
                ToolRef.fromJson(v as Map<String, dynamic>),
              ),
            )
          : const {},
      runtime: json[SubjectSpec.keys.runtime] != null
          ? SubjectRuntime.fromJson(
              json[SubjectSpec.keys.runtime] as Map<String, dynamic>)
          : null,
      capabilities: json[SubjectSpec.keys.capabilities] != null
          ? SubjectCapabilities.fromJson(
              json[SubjectSpec.keys.capabilities] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  String toString() => 'SubjectSpec($kind)';
}

class _SubjectSpecKeys {
  _SubjectSpecKeys._();
  final String kind = 'kind';
  final String source = 'source';
  final String interface = 'interface';
  final String tools = 'tools';
  final String runtime = 'runtime';
  final String capabilities = 'capabilities';

  Set<String> get required => {kind, source, interface};
}
