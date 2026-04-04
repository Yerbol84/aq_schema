// Ответ пользователя движку когда граф приостановлен и ждёт ввода.

class UserInputResponse {
  /// ID запуска который ждёт ввода
  final String runId;

  /// ID узла на котором приостановлен граф
  final String nodeId;

  /// Данные введённые пользователем (ключ → значение)
  final Map<String, dynamic> values;

  /// true = пользователь одобрил (для manualReview узлов)
  final bool approved;

  /// Путь к загруженному файлу (для fileUpload узлов)
  final String? uploadedFilePath;

  const UserInputResponse({
    required this.runId,
    required this.nodeId,
    this.values = const {},
    this.approved = true,
    this.uploadedFilePath,
  });

  Map<String, dynamic> toJson() => {
    'runId': runId,
    'nodeId': nodeId,
    'values': values,
    'approved': approved,
    if (uploadedFilePath != null) 'uploadedFilePath': uploadedFilePath,
  };

  factory UserInputResponse.fromJson(Map<String, dynamic> json) {
    return UserInputResponse(
      runId: json['runId'] as String,
      nodeId: json['nodeId'] as String,
      values: (json['values'] as Map<String, dynamic>?) ?? {},
      approved: (json['approved'] as bool?) ?? true,
      uploadedFilePath: json['uploadedFilePath'] as String?,
    );
  }
}
