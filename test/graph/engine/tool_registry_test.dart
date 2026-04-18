// Тесты для ToolRegistry - регистрация и получение tools (hands)

import 'package:test/test.dart';


import 'package:aq_schema/aq_schema.dart';

// Mock Hand для тестирования
class MockHand implements IHand {
  @override
  final String id;

  @override
  final String description;

  @override
  final bool isSystemTool;

  final Future<dynamic> Function(Map<String, dynamic>, RunContext)? handler;

  MockHand({
    required this.id,
    this.description = 'Mock hand',
    this.isSystemTool = false,
    this.handler,
  });

  @override
  Future<dynamic> execute(Map<String, dynamic> params, RunContext context) {
    if (handler != null) {
      return handler!(params, context);
    }
    return Future.value({'result': 'mock_result'});
  }

  @override
  Map<String, dynamic> get toolSchema => {
        'name': id,
        'description': description,
        'parameters': {
          'type': 'object',
          'properties': {},
        },
      };
}

void main() {
  group('ToolRegistry - Registration', () {
    test('should register a hand', () {
      final registry = ToolRegistry();
      final hand = MockHand(id: 'test_tool');

      registry.register(hand);

      expect(registry.getHand('test_tool'), hand);
    });

    test('should register multiple hands', () {
      final registry = ToolRegistry();
      final hand1 = MockHand(id: 'tool1');
      final hand2 = MockHand(id: 'tool2');
      final hand3 = MockHand(id: 'tool3');

      registry.register(hand1);
      registry.register(hand2);
      registry.register(hand3);

      expect(registry.getHand('tool1'), hand1);
      expect(registry.getHand('tool2'), hand2);
      expect(registry.getHand('tool3'), hand3);
    });

    test('should overwrite hand with same id', () {
      final registry = ToolRegistry();
      final hand1 = MockHand(id: 'tool', description: 'First version');
      final hand2 = MockHand(id: 'tool', description: 'Second version');

      registry.register(hand1);
      registry.register(hand2);

      final retrieved = registry.getHand('tool');
      expect(retrieved, hand2);
      expect(retrieved?.description, 'Second version');
    });
  });

  group('ToolRegistry - Retrieval', () {
    late ToolRegistry registry;

    setUp(() {
      registry = ToolRegistry();
      registry.register(MockHand(id: 'fs_read', description: 'Read file'));
      registry.register(MockHand(id: 'fs_write', description: 'Write file'));
      registry.register(MockHand(id: 'llm_ask', description: 'Ask LLM'));
      registry.register(MockHand(id: 'git_commit', description: 'Git commit'));
    });

    test('should get hand by id', () {
      final hand = registry.getHand('fs_read');

      expect(hand, isNotNull);
      expect(hand?.id, 'fs_read');
      expect(hand?.description, 'Read file');
    });

    test('should return null for non-existent hand', () {
      final hand = registry.getHand('nonexistent');

      expect(hand, isNull);
    });

    test('should get all registered hands', () {
      final hands = registry.registeredHands;

      expect(hands.length, 4);
      expect(hands.map((h) => h.id), containsAll(['fs_read', 'fs_write', 'llm_ask', 'git_commit']));
    });
  });

  group('ToolRegistry - Schemas', () {
    late ToolRegistry registry;

    setUp(() {
      registry = ToolRegistry();
      registry.register(MockHand(id: 'fs_read', description: 'Read file'));
      registry.register(MockHand(id: 'fs_write', description: 'Write file'));
      registry.register(MockHand(id: 'llm_ask', description: 'Ask LLM'));
      registry.register(MockHand(id: 'git_commit', description: 'Git commit'));
    });

    test('should get all schemas', () {
      final schemas = registry.getAllSchemas();

      expect(schemas.length, 4);
      expect(schemas[0], isA<Map<String, dynamic>>());
      expect(schemas[0]['name'], isNotNull);
      expect(schemas[0]['description'], isNotNull);
    });

    test('should get schemas by category prefix', () {
      final fsSchemas = registry.getSchemasByCategory('fs_');

      expect(fsSchemas.length, 2);
      expect(fsSchemas.map((s) => s['name']), containsAll(['fs_read', 'fs_write']));
    });

    test('should return empty list for non-matching prefix', () {
      final schemas = registry.getSchemasByCategory('db_');

      expect(schemas, isEmpty);
    });

    test('should filter schemas correctly', () {
      final gitSchemas = registry.getSchemasByCategory('git_');

      expect(gitSchemas.length, 1);
      expect(gitSchemas[0]['name'], 'git_commit');
    });
  });

  group('ToolRegistry - System Tools', () {
    test('should register system tools', () {
      final registry = ToolRegistry();
      final systemTool = MockHand(
        id: 'system_log',
        description: 'System logging',
        isSystemTool: true,
      );

      registry.register(systemTool);

      final retrieved = registry.getHand('system_log');
      expect(retrieved?.isSystemTool, true);
    });

    test('should mix system and user tools', () {
      final registry = ToolRegistry();
      registry.register(MockHand(id: 'user_tool', isSystemTool: false));
      registry.register(MockHand(id: 'system_tool', isSystemTool: true));

      final hands = registry.registeredHands;
      expect(hands.length, 2);
      expect(hands.where((h) => h.isSystemTool).length, 1);
      expect(hands.where((h) => !h.isSystemTool).length, 1);
    });
  });

  group('ToolRegistry - Real-world Scenarios', () {
    test('should handle file system tools', () {
      final registry = ToolRegistry();

      registry.register(MockHand(
        id: 'fs_read',
        description: 'Read file from disk',
        handler: (params, context) async {
          final path = params['path'] as String;
          return {'content': 'File content from $path'};
        },
      ));

      registry.register(MockHand(
        id: 'fs_write',
        description: 'Write file to disk',
        handler: (params, context) async {
          final path = params['path'] as String;
          final content = params['content'] as String;
          return {'success': true, 'path': path};
        },
      ));

      final readHand = registry.getHand('fs_read');
      final writeHand = registry.getHand('fs_write');

      expect(readHand, isNotNull);
      expect(writeHand, isNotNull);
      expect(readHand?.description, contains('Read'));
      expect(writeHand?.description, contains('Write'));
    });

    test('should handle LLM tools', () {
      final registry = ToolRegistry();

      registry.register(MockHand(
        id: 'llm_ask',
        description: 'Ask LLM a question',
        handler: (params, context) async {
          final prompt = params['prompt'] as String;
          return {'response': 'LLM response to: $prompt'};
        },
      ));

      final llmHand = registry.getHand('llm_ask');
      expect(llmHand, isNotNull);
    });

    test('should handle git tools', () {
      final registry = ToolRegistry();

      registry.register(MockHand(id: 'git_commit', description: 'Create git commit'));
      registry.register(MockHand(id: 'git_push', description: 'Push to remote'));
      registry.register(MockHand(id: 'git_pull', description: 'Pull from remote'));

      final gitSchemas = registry.getSchemasByCategory('git_');
      expect(gitSchemas.length, 3);
    });

    test('should support tool discovery', () {
      final registry = ToolRegistry();

      // Register various tools
      registry.register(MockHand(id: 'fs_read'));
      registry.register(MockHand(id: 'fs_write'));
      registry.register(MockHand(id: 'fs_delete'));
      registry.register(MockHand(id: 'db_query'));
      registry.register(MockHand(id: 'db_insert'));
      registry.register(MockHand(id: 'http_get'));
      registry.register(MockHand(id: 'http_post'));

      // Discover by category
      expect(registry.getSchemasByCategory('fs_').length, 3);
      expect(registry.getSchemasByCategory('db_').length, 2);
      expect(registry.getSchemasByCategory('http_').length, 2);

      // Get all tools
      expect(registry.registeredHands.length, 7);
    });
  });

  group('ToolRegistry - Edge Cases', () {
    test('should handle empty registry', () {
      final registry = ToolRegistry();

      expect(registry.registeredHands, isEmpty);
      expect(registry.getAllSchemas(), isEmpty);
      expect(registry.getHand('anything'), isNull);
    });

    test('should handle special characters in tool id', () {
      final registry = ToolRegistry();
      final hand = MockHand(id: 'tool-with-dashes_and_underscores.123');

      registry.register(hand);

      expect(registry.getHand('tool-with-dashes_and_underscores.123'), hand);
    });

    test('should handle case-sensitive tool ids', () {
      final registry = ToolRegistry();
      final hand1 = MockHand(id: 'Tool');
      final hand2 = MockHand(id: 'tool');

      registry.register(hand1);
      registry.register(hand2);

      expect(registry.getHand('Tool'), hand1);
      expect(registry.getHand('tool'), hand2);
      expect(registry.registeredHands.length, 2);
    });
  });

  group('ToolRegistry - Schema Structure', () {
    test('should return valid tool schema', () {
      final registry = ToolRegistry();
      final hand = MockHand(id: 'test_tool', description: 'Test tool');

      registry.register(hand);

      final schemas = registry.getAllSchemas();
      expect(schemas.length, 1);

      final schema = schemas[0];
      expect(schema['name'], 'test_tool');
      expect(schema['description'], 'Test tool');
      expect(schema['parameters'], isA<Map>());
    });

    test('should maintain schema consistency', () {
      final registry = ToolRegistry();

      registry.register(MockHand(id: 'tool1', description: 'First tool'));
      registry.register(MockHand(id: 'tool2', description: 'Second tool'));

      final schemas = registry.getAllSchemas();

      for (final schema in schemas) {
        expect(schema, containsPair('name', isA<String>()));
        expect(schema, containsPair('description', isA<String>()));
        expect(schema, containsPair('parameters', isA<Map>()));
      }
    });
  });
}
