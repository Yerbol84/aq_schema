// aq_schema/lib/tools/models/tool_ref.dart
//
// Типизированная ссылка на инструмент с версионированием.
// Используется между пакетами — все ключи через .keys.

import '../../data_layer/models/semver.dart';

/// Диапазон semver-версий: ">=1.0.0 <2.0.0", "^2.0.0", "*"
final class SemVerRange {
  final String raw;

  const SemVerRange(this.raw);

  /// Проверить, удовлетворяет ли конкретная версия диапазону.
  bool satisfies(Semver version) {
    // "^X.Y.Z" → >=X.Y.Z <(X+1).0.0
    if (raw.startsWith('^')) {
      final base = Semver.parse(raw.substring(1));
      final upper = Semver(base.major + 1, 0, 0);
      return version >= base && version < upper;
    }
    // "*" → любая версия
    if (raw == '*') return true;
    // ">=X.Y.Z <A.B.C"
    if (raw.contains(' ')) {
      final parts = raw.split(' ');
      return parts.every((p) => _satisfiesPart(version, p));
    }
    return _satisfiesPart(version, raw);
  }

  bool _satisfiesPart(Semver v, String part) {
    if (part.startsWith('>=')) return v >= Semver.parse(part.substring(2));
    if (part.startsWith('<=')) return v <= Semver.parse(part.substring(2));
    if (part.startsWith('>')) return v > Semver.parse(part.substring(1));
    if (part.startsWith('<')) return v < Semver.parse(part.substring(1));
    if (part.startsWith('=')) return v == Semver.parse(part.substring(1));
    return v == Semver.parse(part);
  }

  @override
  String toString() => raw;
}

/// Типизированная ссылка на инструмент.
///
/// Используется движком для запроса инструмента из реестра.
/// Либо точная версия, либо диапазон — не оба сразу.
final class ToolRef {
  static final _ToolRefKeys _keys = _ToolRefKeys._();
  static _ToolRefKeys get keys => _keys;

  /// Имя инструмента: "llm_complete", "fs_read"
  final String name;

  /// Namespace: "aq/llm", "community/git". null = глобальный.
  final String? namespace;

  /// Точная версия (если известна).
  final Semver? exactVersion;

  /// Диапазон версий: "^2.0.0", ">=1.0.0 <2.0.0"
  final SemVerRange? range;

  const ToolRef(
    this.name, {
    this.namespace,
    this.exactVersion,
    this.range,
  }) : assert(
          exactVersion == null || range == null,
          'Specify either exactVersion or range, not both',
        );

  /// Полный идентификатор: "aq/llm/llm_complete@2.1.0"
  String get fullId {
    final ns = namespace != null ? '$namespace/' : '';
    final ver = exactVersion != null ? '@$exactVersion' : '';
    return '$ns$name$ver';
  }

  Map<String, dynamic> toJson() => {
        ToolRef.keys.name: name,
        if (namespace != null) ToolRef.keys.namespace: namespace,
        if (exactVersion != null)
          ToolRef.keys.exactVersion: exactVersion.toString(),
        if (range != null) ToolRef.keys.range: range.toString(),
      };

  factory ToolRef.fromJson(Map<String, dynamic> json) => ToolRef(
        json[ToolRef.keys.name] as String,
        namespace: json[ToolRef.keys.namespace] as String?,
        exactVersion: json[ToolRef.keys.exactVersion] != null
            ? Semver.parse(json[ToolRef.keys.exactVersion] as String)
            : null,
        range: json[ToolRef.keys.range] != null
            ? SemVerRange(json[ToolRef.keys.range] as String)
            : null,
      );

  @override
  bool operator ==(Object other) =>
      other is ToolRef &&
      name == other.name &&
      namespace == other.namespace &&
      exactVersion == other.exactVersion;

  @override
  int get hashCode => Object.hash(name, namespace, exactVersion);

  @override
  String toString() => fullId;
}

class _ToolRefKeys {
  _ToolRefKeys._();

  final String name = 'name';
  final String namespace = 'namespace';
  final String exactVersion = 'exact_version';
  final String range = 'range';

  List<String> get all => [name, namespace, exactVersion, range];
  Set<String> get required => {name};
}
