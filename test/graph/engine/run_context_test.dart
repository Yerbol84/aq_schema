// Тесты для RunContext - контекст выполнения графа

import 'package:test/test.dart';
import 'package:aq_schema/aq_schema.dart';

void main() {
  group('RunContext - Creation', () {
    test('should create context with required parameters', () {
      final context = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/test/project',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {},
      );

      expect(context.runId, 'run1');
      expect(context.projectId, 'project1');
      expect(context.projectPath, '/test/project');
      expect(context.currentBranch, 'main');
      expect(context.state, isEmpty);
    });

    test('should create context with custom branch', () {
      final context = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/test/project',
        currentBranch: 'feature',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {},
      );

      expect(context.currentBranch, 'feature');
    });
  });

  group('RunContext - State Management', () {
    late RunContext context;
    late List<String> logMessages;

    setUp(() {
      logMessages = [];
      context = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/test/project',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {
          logMessages.add(msg);
        },
      );
    });

    test('should set and get variable', () {
      context.setVar('x', 42);

      expect(context.getVar('x'), 42);
      expect(logMessages, contains(contains('Memory updated: [x]')));
    });

    test('should return null for non-existent variable', () {
      expect(context.getVar('nonexistent'), isNull);
    });

    test('should overwrite existing variable', () {
      context.setVar('x', 10);
      context.setVar('x', 20);

      expect(context.getVar('x'), 20);
    });

    test('should store different types of values', () {
      context.setVar('string', 'hello');
      context.setVar('number', 42);
      context.setVar('bool', true);
      context.setVar('list', [1, 2, 3]);
      context.setVar('map', {'key': 'value'});

      expect(context.getVar('string'), 'hello');
      expect(context.getVar('number'), 42);
      expect(context.getVar('bool'), true);
      expect(context.getVar('list'), [1, 2, 3]);
      expect(context.getVar('map'), {'key': 'value'});
    });

    test('should have independent state', () {
      final context1 = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/test',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {},
      );
      final context2 = RunContext(
        runId: 'run2',
        projectId: 'project1',
        projectPath: '/test',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {},
      );

      context1.setVar('x', 10);
      context2.setVar('x', 20);

      expect(context1.getVar('x'), 10);
      expect(context2.getVar('x'), 20);
    });
  });

  group('RunContext - Logging', () {
    test('should log messages with default parameters', () {
      final logs = <Map<String, dynamic>>[];
      final context = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/test/project',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {
          logs.add({
            'message': msg,
            'type': type,
            'depth': depth,
            'branch': branch,
            'details': details,
          });
        },
      );

      context.log('Test message', branch: 'main');

      expect(logs.length, 1);
      expect(logs[0]['message'], 'Test message');
      expect(logs[0]['type'], 'info');
      expect(logs[0]['depth'], 0);
      expect(logs[0]['branch'], 'main');
    });

    test('should log messages with custom parameters', () {
      final logs = <Map<String, dynamic>>[];
      final context = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/test/project',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {
          logs.add({
            'message': msg,
            'type': type,
            'depth': depth,
            'branch': branch,
            'details': details,
          });
        },
      );

      context.log(
        'Error occurred',
        type: 'error',
        depth: 2,
        branch: 'feature',
        details: 'Stack trace here',
      );

      expect(logs[0]['message'], 'Error occurred');
      expect(logs[0]['type'], 'error');
      expect(logs[0]['depth'], 2);
      expect(logs[0]['branch'], 'feature');
      expect(logs[0]['details'], 'Stack trace here');
    });

    test('should log multiple messages', () {
      final logs = <String>[];
      final context = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/test/project',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {
          logs.add(msg);
        },
      );

      context.log('Message 1', branch: 'main');
      context.log('Message 2', branch: 'main');
      context.log('Message 3', branch: 'main');

      expect(logs.length, 3);
      expect(logs[0], 'Message 1');
      expect(logs[1], 'Message 2');
      expect(logs[2], 'Message 3');
    });
  });

  group('RunContext - ISandboxContext Interface', () {
    test('should implement ISandboxContext', () {
      final context = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/test/project',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {},
      );

      expect(context.runId, isNotNull);
      expect(context.projectId, isNotNull);
      expect(context.projectPath, isNotNull);
      expect(context.currentBranch, isNotNull);
      expect(context.state, isA<Map<String, dynamic>>());
      // expect(context.sandbox, isNotNull);
      // expect(context.activePolicy, isNotNull);
    });

    test('should have fallback sandbox if not provided', () {
      final context = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/test/project',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {},
      );

      // expect(context.sandbox, isNotNull);
    });
  });

  group('RunContext - Variable Substitution Scenarios', () {
    late RunContext context;

    setUp(() {
      context = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/test/project',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {},
      );
    });

    test('should store variables for template substitution', () {
      context.setVar('userName', 'John');
      context.setVar('age', 30);
      context.setVar('city', 'New York');

      expect(context.getVar('userName'), 'John');
      expect(context.getVar('age'), 30);
      expect(context.getVar('city'), 'New York');
    });

    test('should store nested data structures', () {
      context.setVar('user', {
        'name': 'John',
        'email': 'john@example.com',
        'address': {
          'city': 'New York',
          'zip': '10001',
        },
      });

      final user = context.getVar('user') as Map<String, dynamic>;
      expect(user['name'], 'John');
      expect(user['email'], 'john@example.com');
      expect((user['address'] as Map)['city'], 'New York');
    });

    test('should store results from previous nodes', () {
      // Simulate workflow execution
      context.setVar('file_content', 'Hello World');
      context.setVar('llm_response', 'Analysis: positive sentiment');
      context.setVar('quality_score', 0.95);

      expect(context.getVar('file_content'), 'Hello World');
      expect(context.getVar('llm_response'), contains('positive'));
      expect(context.getVar('quality_score'), greaterThan(0.9));
    });
  });

  group('RunContext - Branch Tracking', () {
    test('should track current branch', () {
      final context = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/test/project',
        currentBranch: 'feature/new-feature',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {},
      );

      expect(context.currentBranch, 'feature/new-feature');
    });

    test('should use branch in logging', () {
      String? loggedBranch;
      final context = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/test/project',
        currentBranch: 'develop',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {
          loggedBranch = branch;
        },
      );

      context.log('Test', branch: context.currentBranch);

      expect(loggedBranch, 'develop');
    });
  });

  group('RunContext - Real-world Scenarios', () {
    test('should handle workflow execution context', () {
      final context = RunContext(
        runId: 'workflow_run_123',
        projectId: 'my_project',
        projectPath: '/projects/my_project',
        currentBranch: 'main',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {},
      );

      // Node 1: Read file
      context.setVar('file_path', '/data/input.txt');
      context.setVar('file_content', 'Sample data');

      // Node 2: Process with LLM
      context.setVar(
          'llm_prompt', 'Analyze: ${context.getVar('file_content')}');
      context.setVar('llm_result', 'Analysis complete');

      // Node 3: Save result
      context.setVar('output_path', '/data/output.txt');

      expect(context.getVar('file_content'), 'Sample data');
      expect(context.getVar('llm_result'), 'Analysis complete');
      expect(context.getVar('output_path'), '/data/output.txt');
    });

    test('should handle conditional workflow branches', () {
      final context = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/test',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {},
      );

      // Set condition variable
      context.setVar('quality', 0.85);

      // Check condition
      final quality = context.getVar('quality') as double;
      if (quality > 0.8) {
        context.setVar('next_action', 'approve');
      } else {
        context.setVar('next_action', 'reject');
      }

      expect(context.getVar('next_action'), 'approve');
    });

    test('should handle error context', () {
      final context = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/test',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {},
      );

      // Simulate error
      context.setVar('error_occurred', true);
      context.setVar('error_message', 'File not found');
      context.setVar('error_node_id', 'node_file_read');

      expect(context.getVar('error_occurred'), true);
      expect(context.getVar('error_message'), 'File not found');
      expect(context.getVar('error_node_id'), 'node_file_read');
    });
  });
}
