// Запрос на запуск графа.
// Клиент (Flutter-приложение) отправляет это движку чтобы начать выполнение.

class GraphRunRequest {
  /// Уникальный ID этого запуска (генерирует клиент, например uuid v4)
  final String runId;

  /// ID проекта
  final String projectId;

  /// Путь к папке проекта на диске (нужен для file hands)
  final String projectPath;

  /// ID blueprint (графа) который нужно запустить
  final String blueprintId;

  /// Начальные переменные — кладутся в RunContext.state перед стартом
  final Map<String, dynamic> initialVariables;

  /// Если не null — это Resume (возобновление после паузы).
  /// Содержит сохранённый JSON состояния RunContext.
  final String? resumeStateJson;

  /// При Resume — ID узла с которого продолжить
  final String? resumeFromNodeId;

  const GraphRunRequest({
    required this.runId,
    required this.projectId,
    required this.projectPath,
    required this.blueprintId,
    this.initialVariables = const {},
    this.resumeStateJson,
    this.resumeFromNodeId,
  });

  bool get isResume => resumeStateJson != null;

  Map<String, dynamic> toJson() => {
    'runId': runId,
    'projectId': projectId,
    'projectPath': projectPath,
    'blueprintId': blueprintId,
    'initialVariables': initialVariables,
    if (resumeStateJson != null) 'resumeStateJson': resumeStateJson,
    if (resumeFromNodeId != null) 'resumeFromNodeId': resumeFromNodeId,
  };

  factory GraphRunRequest.fromJson(Map<String, dynamic> json) {
    return GraphRunRequest(
      runId: json['runId'] as String,
      projectId: json['projectId'] as String,
      projectPath: json['projectPath'] as String,
      blueprintId: json['blueprintId'] as String,
      initialVariables:
          (json['initialVariables'] as Map<String, dynamic>?) ?? {},
      resumeStateJson: json['resumeStateJson'] as String?,
      resumeFromNodeId: json['resumeFromNodeId'] as String?,
    );
  }
}
