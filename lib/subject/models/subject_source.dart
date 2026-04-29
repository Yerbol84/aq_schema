// aq_schema/lib/subject/models/subject_source.dart
//
// Источник Subject — откуда взять код/конфигурацию.
//
// Sealed class с подтипами для каждого SubjectKind.
// Типобезопасность + валидация на этапе компиляции.

/// Источник Subject.
///
/// Sealed class — каждый SubjectKind имеет свой тип Source.
sealed class SubjectSource {
  const SubjectSource();

  Map<String, dynamic> toJson();

  static SubjectSource fromJson(String kind, Map<String, dynamic> json) {
    return switch (kind) {
      'llm_endpoint' => LlmEndpointSource.fromJson(json),
      'llm_agent' => LlmAgentSource.fromJson(json),
      'git_repo' => GitRepoSource.fromJson(json),
      'docker_image' => DockerImageSource.fromJson(json),
      'api_endpoint' => ApiEndpointSource.fromJson(json),
      'prompt_template' => PromptTemplateSource.fromJson(json),
      'script' => ScriptSource.fromJson(json),
      'mcp_server' => McpServerSource.fromJson(json),
      'aq_graph' => AqGraphSource.fromJson(json),
      'wasm_module' => WasmModuleSource.fromJson(json),
      _ => throw ArgumentError('Unknown SubjectKind: $kind'),
    };
  }
}

/// LLM API endpoint.
final class LlmEndpointSource extends SubjectSource {
  final String baseUrl;
  final String apiKeyRef; // Ссылка на секрет в vault
  final String model;

  const LlmEndpointSource({
    required this.baseUrl,
    required this.apiKeyRef,
    required this.model,
  });

  @override
  Map<String, dynamic> toJson() => {
        'base_url': baseUrl,
        'api_key_ref': apiKeyRef,
        'model': model,
      };

  factory LlmEndpointSource.fromJson(Map<String, dynamic> json) =>
      LlmEndpointSource(
        baseUrl: json['base_url'] as String,
        apiKeyRef: json['api_key_ref'] as String,
        model: json['model'] as String,
      );
}

/// LLM Agent с tool-use capability.
final class LlmAgentSource extends SubjectSource {
  final String provider;
  final String model;
  final String apiKeyRef;
  final int maxTokens;
  final double temperature;

  const LlmAgentSource({
    required this.provider,
    required this.model,
    required this.apiKeyRef,
    this.maxTokens = 4096,
    this.temperature = 0.7,
  });

  @override
  Map<String, dynamic> toJson() => {
        'provider': provider,
        'model': model,
        'api_key_ref': apiKeyRef,
        'max_tokens': maxTokens,
        'temperature': temperature,
      };

  factory LlmAgentSource.fromJson(Map<String, dynamic> json) =>
      LlmAgentSource(
        provider: json['provider'] as String,
        model: json['model'] as String,
        apiKeyRef: json['api_key_ref'] as String,
        maxTokens: json['max_tokens'] as int? ?? 4096,
        temperature: json['temperature'] as double? ?? 0.7,
      );
}

/// Git репозиторий.
final class GitRepoSource extends SubjectSource {
  final String url;
  final String branch;
  final String entrypoint;
  final List<String>? buildSteps;
  final String? cacheKey;

  const GitRepoSource({
    required this.url,
    required this.branch,
    required this.entrypoint,
    this.buildSteps,
    this.cacheKey,
  });

  @override
  Map<String, dynamic> toJson() => {
        'url': url,
        'branch': branch,
        'entrypoint': entrypoint,
        if (buildSteps != null) 'build_steps': buildSteps,
        if (cacheKey != null) 'cache_key': cacheKey,
      };

  factory GitRepoSource.fromJson(Map<String, dynamic> json) => GitRepoSource(
        url: json['url'] as String,
        branch: json['branch'] as String,
        entrypoint: json['entrypoint'] as String,
        buildSteps: json['build_steps'] != null
            ? List<String>.from(json['build_steps'] as List)
            : null,
        cacheKey: json['cache_key'] as String?,
      );
}

/// Docker образ.
final class DockerImageSource extends SubjectSource {
  final String image;
  final String? tag;
  final List<String>? command;

  const DockerImageSource({
    required this.image,
    this.tag,
    this.command,
  });

  @override
  Map<String, dynamic> toJson() => {
        'image': image,
        if (tag != null) 'tag': tag,
        if (command != null) 'command': command,
      };

  factory DockerImageSource.fromJson(Map<String, dynamic> json) =>
      DockerImageSource(
        image: json['image'] as String,
        tag: json['tag'] as String?,
        command: json['command'] != null
            ? List<String>.from(json['command'] as List)
            : null,
      );
}

/// HTTP API endpoint.
final class ApiEndpointSource extends SubjectSource {
  final String baseUrl;
  final String? authType; // "bearer", "api_key", "basic"
  final String? authRef; // Ссылка на секрет

  const ApiEndpointSource({
    required this.baseUrl,
    this.authType,
    this.authRef,
  });

  @override
  Map<String, dynamic> toJson() => {
        'base_url': baseUrl,
        if (authType != null) 'auth_type': authType,
        if (authRef != null) 'auth_ref': authRef,
      };

  factory ApiEndpointSource.fromJson(Map<String, dynamic> json) =>
      ApiEndpointSource(
        baseUrl: json['base_url'] as String,
        authType: json['auth_type'] as String?,
        authRef: json['auth_ref'] as String?,
      );
}

/// Prompt шаблон.
final class PromptTemplateSource extends SubjectSource {
  final String template;
  final String llmRef; // Ссылка на LLM Subject

  const PromptTemplateSource({
    required this.template,
    required this.llmRef,
  });

  @override
  Map<String, dynamic> toJson() => {
        'template': template,
        'llm_ref': llmRef,
      };

  factory PromptTemplateSource.fromJson(Map<String, dynamic> json) =>
      PromptTemplateSource(
        template: json['template'] as String,
        llmRef: json['llm_ref'] as String,
      );
}

/// Inline скрипт.
final class ScriptSource extends SubjectSource {
  final String sourceCode;
  final String language; // "python", "javascript", "bash"

  const ScriptSource({
    required this.sourceCode,
    required this.language,
  });

  @override
  Map<String, dynamic> toJson() => {
        'source_code': sourceCode,
        'language': language,
      };

  factory ScriptSource.fromJson(Map<String, dynamic> json) => ScriptSource(
        sourceCode: json['source_code'] as String,
        language: json['language'] as String,
      );
}

/// MCP сервер.
final class McpServerSource extends SubjectSource {
  final String? command; // Для stdio transport
  final String? url; // Для HTTP transport

  const McpServerSource({this.command, this.url})
      : assert(command != null || url != null,
            'Either command or url must be provided');

  @override
  Map<String, dynamic> toJson() => {
        if (command != null) 'command': command,
        if (url != null) 'url': url,
      };

  factory McpServerSource.fromJson(Map<String, dynamic> json) =>
      McpServerSource(
        command: json['command'] as String?,
        url: json['url'] as String?,
      );
}

/// AQ Graph.
final class AqGraphSource extends SubjectSource {
  final String blueprintId;
  final String? versionId;

  const AqGraphSource({
    required this.blueprintId,
    this.versionId,
  });

  @override
  Map<String, dynamic> toJson() => {
        'blueprint_id': blueprintId,
        if (versionId != null) 'version_id': versionId,
      };

  factory AqGraphSource.fromJson(Map<String, dynamic> json) => AqGraphSource(
        blueprintId: json['blueprint_id'] as String,
        versionId: json['version_id'] as String?,
      );
}

/// WASM модуль.
final class WasmModuleSource extends SubjectSource {
  final String? filePath; // Локальный файл
  final String? url; // Удалённый URL

  const WasmModuleSource({this.filePath, this.url})
      : assert(filePath != null || url != null,
            'Either filePath or url must be provided');

  @override
  Map<String, dynamic> toJson() => {
        if (filePath != null) 'file_path': filePath,
        if (url != null) 'url': url,
      };

  factory WasmModuleSource.fromJson(Map<String, dynamic> json) =>
      WasmModuleSource(
        filePath: json['file_path'] as String?,
        url: json['url'] as String?,
      );
}
