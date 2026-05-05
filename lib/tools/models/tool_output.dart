/// Причина отказа в выполнении Tool.
enum ToolDenyReason {
  /// Tool не в списке разрешённых для этого агента.
  notAllowed,

  /// Tool не зарегистрирован в реестре.
  notFound,

  /// Handler для tool не зарегистрирован в runtime.
  noHandler,
}

/// Выходные данные Tool.
final class ToolOutput {
  final bool success;
  final Map<String, Object?>? data;

  /// Текстовое представление результата для LLM.
  ///
  /// Если задан — LlmAgentExecutor передаёт именно его в role=tool message.
  /// Если null — LlmAgentExecutor использует jsonEncode(data) как fallback.
  ///
  /// Handlers должны задавать textContent когда результат — человекочитаемый текст
  /// (содержимое файла, список файлов, тело HTTP ответа).
  final String? textContent;

  final String? error;

  /// Если success=false — причина отказа (структурированная).
  final ToolDenyReason? denyReason;

  const ToolOutput({
    required this.success,
    this.data,
    this.textContent,
    this.error,
    this.denyReason,
  });

  Map<String, dynamic> toJson() => {
        'success': success,
        if (data != null) 'data': data,
        if (textContent != null) 'text_content': textContent,
        if (error != null) 'error': error,
        if (denyReason != null) 'deny_reason': denyReason!.name,
      };
}
