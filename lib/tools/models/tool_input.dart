// aq_schema/lib/tools/models/tool_input.dart

/// Входные данные для Tool.
final class ToolInput {
  final Map<String, Object?> data;

  const ToolInput({required this.data});

  Map<String, dynamic> toJson() => {'data': data};

  factory ToolInput.fromJson(Map<String, dynamic> json) =>
      ToolInput(data: json['data'] as Map<String, Object?>);
}
