// aq_schema/lib/tools/models/tool_package_manifest.dart
//
// Манифест пакета инструментов — единица независимого развития.
// Парсится из aq_tool_package.yaml реестром при hot-install.

import 'tool_capability.dart';
import 'tool_ref.dart';

/// Определение одного инструмента внутри пакета.
final class ToolDefinition {
  static final _ToolDefinitionKeys _keys = _ToolDefinitionKeys._();
  static _ToolDefinitionKeys get keys => _keys;

  final String name;
  final String version;
  final String namespace;

  /// Dart entry: "lib/tools/llm_complete_v2.dart#LlmCompleteV2Tool"
  final String entry;

  final List<ToolCapability> requiredCaps;
  final List<ToolCapability> optionalCaps;

  /// Версия с которой устарел. null = актуален.
  final String? deprecatedSince;

  /// Миграционный путь.
  final ToolRef? replacedBy;

  /// Таймаут выполнения. null = дефолтный.
  final Duration? timeout;

  const ToolDefinition({
    required this.name,
    required this.version,
    required this.namespace,
    required this.entry,
    this.requiredCaps = const [],
    this.optionalCaps = const [],
    this.deprecatedSince,
    this.replacedBy,
    this.timeout,
  });

  bool get isDeprecated => deprecatedSince != null;

  Map<String, dynamic> toJson() => {
        ToolDefinition.keys.name: name,
        ToolDefinition.keys.version: version,
        ToolDefinition.keys.namespace: namespace,
        ToolDefinition.keys.entry: entry,
        ToolDefinition.keys.requiredCaps:
            requiredCaps.map((c) => c.toString()).toList(),
        ToolDefinition.keys.optionalCaps:
            optionalCaps.map((c) => c.toString()).toList(),
        if (deprecatedSince != null)
          ToolDefinition.keys.deprecatedSince: deprecatedSince,
        if (replacedBy != null)
          ToolDefinition.keys.replacedBy: replacedBy!.toJson(),
        if (timeout != null)
          ToolDefinition.keys.timeoutSeconds: timeout!.inSeconds,
      };
}

class _ToolDefinitionKeys {
  _ToolDefinitionKeys._();

  final String name = 'name';
  final String version = 'version';
  final String namespace = 'namespace';
  final String entry = 'entry';
  final String requiredCaps = 'required_caps';
  final String optionalCaps = 'optional_caps';
  final String deprecatedSince = 'deprecated_since';
  final String replacedBy = 'replaced_by';
  final String timeoutSeconds = 'timeout_seconds';

  Set<String> get required => {name, version, namespace, entry};
}

/// Манифест пакета инструментов.
///
/// Соответствует aq_tool_package.yaml.
/// Передаётся в IAQToolRegistry.install() при hot-install.
final class ToolPackageManifest {
  static final _ToolPackageManifestKeys _keys = _ToolPackageManifestKeys._();
  static _ToolPackageManifestKeys get keys => _keys;

  final String packageName;
  final String packageVersion;

  /// Минимальная версия движка: ">=3.0.0"
  final String minEngineVersion;

  final List<ToolDefinition> tools;

  const ToolPackageManifest({
    required this.packageName,
    required this.packageVersion,
    required this.minEngineVersion,
    required this.tools,
  });

  Map<String, dynamic> toJson() => {
        ToolPackageManifest.keys.packageName: packageName,
        ToolPackageManifest.keys.packageVersion: packageVersion,
        ToolPackageManifest.keys.minEngineVersion: minEngineVersion,
        ToolPackageManifest.keys.tools:
            tools.map((t) => t.toJson()).toList(),
      };

  factory ToolPackageManifest.fromJson(Map<String, dynamic> json) =>
      ToolPackageManifest(
        packageName:
            json[ToolPackageManifest.keys.packageName] as String,
        packageVersion:
            json[ToolPackageManifest.keys.packageVersion] as String,
        minEngineVersion:
            json[ToolPackageManifest.keys.minEngineVersion] as String,
        tools: (json[ToolPackageManifest.keys.tools] as List)
            .cast<Map<String, dynamic>>()
            .map(_toolFromJson)
            .toList(),
      );

  static ToolDefinition _toolFromJson(Map<String, dynamic> j) =>
      ToolDefinition(
        name: j[ToolDefinition.keys.name] as String,
        version: j[ToolDefinition.keys.version] as String,
        namespace: j[ToolDefinition.keys.namespace] as String,
        entry: j[ToolDefinition.keys.entry] as String,
        deprecatedSince:
            j[ToolDefinition.keys.deprecatedSince] as String?,
        timeout: j[ToolDefinition.keys.timeoutSeconds] != null
            ? Duration(
                seconds: j[ToolDefinition.keys.timeoutSeconds] as int)
            : null,
      );

  @override
  String toString() => 'ToolPackageManifest($packageName@$packageVersion)';
}

class _ToolPackageManifestKeys {
  _ToolPackageManifestKeys._();

  final String packageName = 'name';
  final String packageVersion = 'version';
  final String minEngineVersion = 'min_engine_version';
  final String tools = 'tools';

  Set<String> get required =>
      {packageName, packageVersion, minEngineVersion, tools};
}
