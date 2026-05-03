// aq_schema/lib/tools/models/tool_contract.dart
//
// Полный контракт инструмента — что он умеет и что ему нужно.
// Хранится в AQToolRegistry. Используется движком для capability negotiation.

import 'tool_capability.dart';
import 'tool_ref.dart';
import 'tool_source.dart';

/// Полный контракт инструмента.
///
/// Содержит всё что нужно знать реестру и движку об инструменте:
/// - идентификацию (ref)
/// - схемы ввода/вывода (для LLM tool-use)
/// - capabilities (для sandbox negotiation)
/// - миграционный путь (deprecation)
final class ToolContract {
  static final _ToolContractKeys _keys = _ToolContractKeys._();
  static _ToolContractKeys get keys => _keys;

  final ToolRef ref;

  /// Описание для LLM tool-use schema.
  final String description;

  /// JSON Schema входных параметров.
  final Map<String, dynamic> inputSchema;

  /// JSON Schema выходных данных.
  final Map<String, dynamic> outputSchema;

  /// Без этих capabilities инструмент не работает совсем.
  final List<ToolCapability> requiredCaps;

  /// Без этих capabilities инструмент работает ограниченно.
  final List<ToolCapability> optionalCaps;

  /// Версия с которой инструмент устарел. null = актуален.
  final String? deprecatedSince;

  /// Миграционный путь при deprecation.
  final ToolRef? replacedBy;

  /// Источник Tool. null = NativeToolSource (Dart код).
  /// SubjectToolSource — Tool является оберткой над Subject (exposeAsTool: true).
  final ToolSource? source;

  /// Максимальный размер выходных данных в байтах. Default: 8192.
  /// ToolRuntime обрезает data до этого лимита перед возвратом агенту.
  final int maxOutputBytes;

  const ToolContract({
    required this.ref,
    required this.description,
    required this.inputSchema,
    this.outputSchema = const {},
    this.requiredCaps = const [],
    this.optionalCaps = const [],
    this.deprecatedSince,
    this.replacedBy,
    this.source,
    this.maxOutputBytes = 8192,
  });

  bool get isDeprecated => deprecatedSince != null;

  factory ToolContract.fromJson(Map<String, dynamic> json) {
    // Десериализация capabilities из строк вида "FS_WRITE:/tmp/**"
    List<ToolCapability> _parseCaps(List<dynamic>? raw) {
      if (raw == null) return const [];
      return raw.map((s) => _parseCapability(s as String)).whereType<ToolCapability>().toList();
    }

    return ToolContract(
      ref: ToolRef.fromJson(json[ToolContract.keys.ref] as Map<String, dynamic>),
      description: json[ToolContract.keys.description] as String,
      inputSchema: (json[ToolContract.keys.inputSchema] as Map<String, dynamic>?) ?? {},
      outputSchema: (json[ToolContract.keys.outputSchema] as Map<String, dynamic>?) ?? {},
      requiredCaps: _parseCaps(json[ToolContract.keys.requiredCaps] as List?),
      optionalCaps: _parseCaps(json[ToolContract.keys.optionalCaps] as List?),
      deprecatedSince: json[ToolContract.keys.deprecatedSince] as String?,
      replacedBy: json[ToolContract.keys.replacedBy] != null
          ? ToolRef.fromJson(json[ToolContract.keys.replacedBy] as Map<String, dynamic>)
          : null,
      maxOutputBytes: (json[ToolContract.keys.maxOutputBytes] as int?) ?? 8192,
    );
  }

  /// Парсинг capability из строки (формат из toString()).
  static ToolCapability? _parseCapability(String s) {
    if (s.startsWith('FS_READ:')) return FsReadCap(s.substring(8));
    if (s.startsWith('FS_WRITE:')) return FsWriteCap(s.substring(9));
    if (s.startsWith('NET_OUT:')) {
      final rest = s.substring(8);
      final colonIdx = rest.lastIndexOf(':');
      if (colonIdx > 0) {
        final port = int.tryParse(rest.substring(colonIdx + 1));
        if (port != null) return NetOutCap(rest.substring(0, colonIdx), port: port);
      }
      return NetOutCap(rest);
    }
    if (s.startsWith('PROC_SPAWN:')) {
      final binaries = s.substring(11).split(',').where((b) => b.isNotEmpty).toList();
      return ProcSpawnCap(binaries);
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
        ToolContract.keys.ref: ref.toJson(),
        ToolContract.keys.description: description,
        ToolContract.keys.inputSchema: inputSchema,
        ToolContract.keys.outputSchema: outputSchema,
        ToolContract.keys.requiredCaps:
            requiredCaps.map((c) => c.toString()).toList(),
        ToolContract.keys.optionalCaps:
            optionalCaps.map((c) => c.toString()).toList(),
        if (deprecatedSince != null)
          ToolContract.keys.deprecatedSince: deprecatedSince,
        if (replacedBy != null)
          ToolContract.keys.replacedBy: replacedBy!.toJson(),
        ToolContract.keys.maxOutputBytes: maxOutputBytes,
      };

  @override
  String toString() => 'ToolContract(${ref.fullId})';
}

class _ToolContractKeys {
  _ToolContractKeys._();

  final String ref = 'ref';
  final String description = 'description';
  final String inputSchema = 'input_schema';
  final String outputSchema = 'output_schema';
  final String requiredCaps = 'required_caps';
  final String optionalCaps = 'optional_caps';
  final String deprecatedSince = 'deprecated_since';
  final String replacedBy = 'replaced_by';
  final String maxOutputBytes = 'max_output_bytes';

  List<String> get all => [
        ref,
        description,
        inputSchema,
        outputSchema,
        requiredCaps,
        optionalCaps,
        deprecatedSince,
        replacedBy,
        maxOutputBytes,
      ];
  Set<String> get required => {ref, description, inputSchema};
}
