/// MCP Tool — abstract interface and concrete implementation.
library;

import 'package:aq_schema/auth/models/auth_context.dart';
import 'package:meta/meta.dart';

/// Authorization requirement declaration for a tool.
final class AuthRequirement {
  const AuthRequirement({
    required this.required,
    required this.type,
    this.scopes = const [],
  });

  factory AuthRequirement.fromJson(Map<String, dynamic> json) {
    return AuthRequirement(
      required: (json['required'] as bool?) ?? false,
      type: AuthType.fromString((json['type'] as String?) ?? 'none'),
      scopes:
          (json['scopes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  final bool required;
  final AuthType type;
  final List<String> scopes;

  Map<String, dynamic> toJson() => {
    'required': required,
    'type': type.value,
    if (scopes.isNotEmpty) 'scopes': scopes,
  };

  static const none = AuthRequirement(required: false, type: AuthType.none);
}

/// Abstract contract for an MCP tool definition.
///
/// All packages that expose tools must implement this interface.
/// The interface is defined in aq_schema and is the single source of truth
/// for what a tool looks like to the rest of the ecosystem.
abstract interface class McpTool {
  /// Snake-case tool name. Pattern: ^[a-z][a-z0-9_]*$
  String get name;

  /// Human-readable description shown to LLM clients.
  String get description;

  /// JSON Schema (as Dart map) for input parameters.
  Map<String, dynamic> get inputSchema;

  /// AQ extension: authorization requirement for this tool.
  /// null means no auth requirement declared.
  AuthRequirement? get auth;

  /// Serializes to JSON map suitable for tools/list response.
  Map<String, dynamic> toJson();
}

/// Concrete implementation of [McpTool].
@immutable
final class McpToolImpl implements McpTool {
  const McpToolImpl({
    required this.name,
    required this.description,
    required this.inputSchema,
    this.auth,
  });

  factory McpToolImpl.fromJson(Map<String, dynamic> json) {
    final rawAuth = json['_aq_auth'] as Map<String, dynamic>?;
    return McpToolImpl(
      name: json['name'] as String,
      description: json['description'] as String,
      inputSchema: json['inputSchema'] as Map<String, dynamic>,
      auth: rawAuth != null ? AuthRequirement.fromJson(rawAuth) : null,
    );
  }

  @override
  final String name;

  @override
  final String description;

  @override
  final Map<String, dynamic> inputSchema;

  @override
  final AuthRequirement? auth;

  @override
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
      'description': description,
      'inputSchema': inputSchema,
    };
    if (auth != null) {
      map['_aq_auth'] = auth!.toJson();
    }
    return map;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is McpToolImpl && name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'McpTool(name: $name)';
}
