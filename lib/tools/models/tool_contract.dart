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
  });

  bool get isDeprecated => deprecatedSince != null;
  factory ToolContract.fromJson(Map<String, dynamic> json) => ToolContract(
        ref: json[ToolContract.keys.ref],
        description: json[ToolContract.keys.description],
        inputSchema: json[ToolContract.keys.inputSchema],
        //TODO add all
      );

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

  List<String> get all => [
        ref,
        description,
        inputSchema,
        outputSchema,
        requiredCaps,
        optionalCaps,
        deprecatedSince,
        replacedBy,
      ];
  Set<String> get required => {ref, description, inputSchema};
}
