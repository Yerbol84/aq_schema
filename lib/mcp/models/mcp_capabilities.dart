/// MCP server capabilities advertised during initialize handshake.
library;

/// Server capabilities returned in initialize response.
final class McpCapabilities {
  const McpCapabilities({
    this.tools = const McpToolsCapability(),
    this.logging,
    this.aqExtensions,
  });

  factory McpCapabilities.fromJson(Map<String, dynamic> json) {
    final toolsRaw = json['tools'] as Map<String, dynamic>?;
    final aqRaw = json['_aq_extensions'] as Map<String, dynamic>?;
    return McpCapabilities(
      tools: toolsRaw != null
          ? McpToolsCapability.fromJson(toolsRaw)
          : const McpToolsCapability(),
      logging: json['logging'] as Map<String, dynamic>?,
      aqExtensions: aqRaw != null ? AqExtensions.fromJson(aqRaw) : null,
    );
  }

  final McpToolsCapability tools;
  final Map<String, dynamic>? logging;

  /// AQ EXTENSION: vendor-specific capabilities.
  final AqExtensions? aqExtensions;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'tools': tools.toJson(),
    };
    if (logging != null) map['logging'] = logging;
    if (aqExtensions != null) map['_aq_extensions'] = aqExtensions!.toJson();
    return map;
  }
}

/// Tool-related capabilities subset.
final class McpToolsCapability {
  const McpToolsCapability({this.listChanged = false});

  factory McpToolsCapability.fromJson(Map<String, dynamic> json) =>
      McpToolsCapability(
        listChanged: (json['listChanged'] as bool?) ?? false,
      );

  /// Whether server sends notifications when tool list changes.
  final bool listChanged;

  Map<String, dynamic> toJson() => {'listChanged': listChanged};
}

/// AQ vendor extensions advertised in initialize response.
final class AqExtensions {
  const AqExtensions({
    this.authSupported = false,
    this.authMethods = const [],
    this.asyncJobs = false,
    this.workerCount = 0,
  });

  factory AqExtensions.fromJson(Map<String, dynamic> json) {
    final authRaw = json['auth'] as Map<String, dynamic>?;
    return AqExtensions(
      authSupported: (authRaw?['supported'] as bool?) ?? false,
      authMethods: (authRaw?['methods'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      asyncJobs: (json['async_jobs'] as bool?) ?? false,
      workerCount: (json['worker_count'] as int?) ?? 0,
    );
  }

  final bool authSupported;
  final List<String> authMethods;
  final bool asyncJobs;
  final int workerCount;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'async_jobs': asyncJobs,
      'worker_count': workerCount,
    };
    if (authSupported || authMethods.isNotEmpty) {
      map['auth'] = {
        'supported': authSupported,
        'methods': authMethods,
      };
    }
    return map;
  }
}

/// Server info block in initialize response.
final class McpServerInfo {
  const McpServerInfo({
    required this.name,
    required this.version,
  });

  factory McpServerInfo.fromJson(Map<String, dynamic> json) => McpServerInfo(
        name: json['name'] as String,
        version: json['version'] as String,
      );

  final String name;
  final String version;

  Map<String, dynamic> toJson() => {'name': name, 'version': version};
}

/// Client info block in initialize request.
final class McpClientInfo {
  const McpClientInfo({
    required this.name,
    required this.version,
  });

  factory McpClientInfo.fromJson(Map<String, dynamic> json) => McpClientInfo(
        name: json['name'] as String,
        version: json['version'] as String,
      );

  final String name;
  final String version;

  Map<String, dynamic> toJson() => {'name': name, 'version': version};
}
