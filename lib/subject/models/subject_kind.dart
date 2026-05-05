// aq_schema/lib/subject/models/subject_kind.dart
//
// TD-06: SubjectKind — value object вместо enum.
//
// Добавить новый kind = зарегистрировать executor через ISubjectExecutorRegistry.
// Не нужно менять aq_schema и пересобирать все пакеты.

/// Тип Subject (испытуемого).
///
/// Value object — сравнивается по [value].
/// Новые kinds создаются через `SubjectKind('my_kind')` без изменения платформы.
final class SubjectKind {
  final String value;

  const SubjectKind(this.value);

  @override
  bool operator ==(Object other) => other is SubjectKind && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;

  /// Создать SubjectKind из строки. Никогда не бросает исключение.
  static SubjectKind parse(String value) => SubjectKind(value);
}

/// Стандартные kinds платформы.
///
/// Обратная совместимость: `SubjectKinds.llmAgent` вместо `SubjectKind.llmAgent`.
abstract final class SubjectKinds {
  static const SubjectKind llmEndpoint   = SubjectKind('llm_endpoint');
  static const SubjectKind llmAgent      = SubjectKind('llm_agent');
  static const SubjectKind gitRepo       = SubjectKind('git_repo');
  static const SubjectKind dockerImage   = SubjectKind('docker_image');
  static const SubjectKind apiEndpoint   = SubjectKind('api_endpoint');
  static const SubjectKind promptTemplate = SubjectKind('prompt_template');
  static const SubjectKind script        = SubjectKind('script');
  static const SubjectKind mcpServer     = SubjectKind('mcp_server');
  static const SubjectKind aqGraph       = SubjectKind('aq_graph');
  static const SubjectKind wasmModule    = SubjectKind('wasm_module');
}
