// aq_schema/lib/tools/models/tool_result.dart
//
// Результат вызова инструмента через IAQToolRuntime.
// Расширенная версия ToolCallResult — содержит метаданные выполнения.

import 'tool_ref.dart';

/// Метаданные выполнения инструмента.
final class ToolResultMeta {
  static final _ToolResultMetaKeys _keys = _ToolResultMetaKeys._();
  static _ToolResultMetaKeys get keys => _keys;

  /// Время выполнения.
  final Duration elapsed;

  /// Фактическая версия инструмента которая выполнила вызов.
  final ToolRef resolvedRef;

  /// Тип исполнителя: "local", "mcp", "grpc", "http", "sandbox"
  final String executorType;

  /// ID sandbox если выполнялось в изоляции. null = без sandbox.
  final String? sandboxId;

  const ToolResultMeta({
    required this.elapsed,
    required this.resolvedRef,
    required this.executorType,
    this.sandboxId,
  });

  Map<String, dynamic> toJson() => {
        ToolResultMeta.keys.elapsedMs: elapsed.inMilliseconds,
        ToolResultMeta.keys.resolvedRef: resolvedRef.toJson(),
        ToolResultMeta.keys.executorType: executorType,
        if (sandboxId != null) ToolResultMeta.keys.sandboxId: sandboxId,
      };
}

class _ToolResultMetaKeys {
  _ToolResultMetaKeys._();

  final String elapsedMs = 'elapsed_ms';
  final String resolvedRef = 'resolved_ref';
  final String executorType = 'executor_type';
  final String sandboxId = 'sandbox_id';

  List<String> get all => [elapsedMs, resolvedRef, executorType, sandboxId];
  Set<String> get required => {elapsedMs, resolvedRef, executorType};
}

/// Результат вызова инструмента через IAQToolRuntime.
///
/// Никогда не бросает исключение — ошибки через [ToolResult.failure].
final class ToolResult {
  static final _ToolResultKeys _keys = _ToolResultKeys._();
  static _ToolResultKeys get keys => _keys;

  final bool success;
  final dynamic output;
  final String? error;
  final String? errorCode;
  final ToolResultMeta meta;

  const ToolResult._({
    required this.success,
    required this.meta,
    this.output,
    this.error,
    this.errorCode,
  });

  factory ToolResult.success({
    required dynamic output,
    required ToolResultMeta meta,
  }) =>
      ToolResult._(success: true, output: output, meta: meta);

  factory ToolResult.failure({
    required String error,
    required ToolResultMeta meta,
    String? errorCode,
  }) =>
      ToolResult._(
        success: false,
        error: error,
        errorCode: errorCode,
        meta: meta,
      );

  Map<String, dynamic> toJson() => {
        ToolResult.keys.success: success,
        if (output != null) ToolResult.keys.output: output,
        if (error != null) ToolResult.keys.error: error,
        if (errorCode != null) ToolResult.keys.errorCode: errorCode,
        ToolResult.keys.meta: meta.toJson(),
      };

  @override
  String toString() => success
      ? 'ToolResult.success(${meta.resolvedRef})'
      : 'ToolResult.failure($error)';
}

class _ToolResultKeys {
  _ToolResultKeys._();

  final String success = 'success';
  final String output = 'output';
  final String error = 'error';
  final String errorCode = 'error_code';
  final String meta = 'meta';

  List<String> get all => [success, output, error, errorCode, meta];
  Set<String> get required => {success, meta};
}

/// Чанк потокового результата (для callStream).
final class ToolResultChunk {
  final String? text;
  final Map<String, dynamic>? data;
  final bool isDone;

  const ToolResultChunk({this.text, this.data, this.isDone = false});

  const ToolResultChunk.done() : text = null, data = null, isDone = true;
}
