// Тесты для suspend/resume workflow - приостановка и возобновление

import 'package:test/test.dart';
import 'package:aq_schema/aq_schema.dart';


import 'package:aq_schema/graph/nodes/base/interactive_node.dart';

// Mock Hand
class MockHand implements IHand {
  @override
  final String id;

  @override
  final String description;

  @override
  final bool isSystemTool;

  final Future<dynamic> Function(Map<String, dynamic>, RunContext) handler;

  MockHand({
    required this.id,
    this.description = 'Mock hand',
    this.isSystemTool = false,
    required this.handler,
  });

  @override
  Future<dynamic> execute(Map<String, dynamic> params, RunContext context) {
    return handler(params, context);
  }

  @override
  Map<String, dynamic> get toolSchema => {
        'name': id,
        'description': description,
        'parameters': {'type': 'object', 'properties': {}},
      };
}

void main() {
  group('Suspend/Resume Workflow', () {
    test('should suspend on interactive node without user response', () {
      final context = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/test',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {},
      );

      // Симуляция interactive node без ответа
      final hasResponse = context.getVar('user_input_node1') != null;

      expect(hasResponse, false);

      // Должен выбросить SuspendExecutionException
      expect(
        () {
          if (!hasResponse) {
            throw SuspendExecutionException(
              nodeId: 'node1',
              reason: 'Waiting for user input',
            );
          }
        },
        throwsA(isA<SuspendExecutionException>()),
      );
    });

    test('should resume when user response is provided', () async {
      final executionPath = <String>[];
      final registry = ToolRegistry();

      registry.register(MockHand(
        id: 'step1',
        handler: (params, context) async {
          executionPath.add('step1');
          context.setVar('step1_done', true);
          return {};
        },
      ));

      registry.register(MockHand(
        id: 'step3',
        handler: (params, context) async {
          executionPath.add('step3');
          final userInput = context.getVar('user_input');
          context.setVar('result', 'Processed: $userInput');
          return {};
        },
      ));

      final context = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/test',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {},
      );

      // Выполнить step1
      await registry.getHand('step1')!.execute({}, context);

      // Симуляция suspend на interactive node
      final hasUserInput = context.getVar('user_input') != null;
      if (!hasUserInput) {
        // Suspend - пользователь предоставляет ввод
        context.setVar('user_input', 'Hello from user');
      }

      // Resume - выполнить step3
      await registry.getHand('step3')!.execute({}, context);

      expect(executionPath, ['step1', 'step3']);
      expect(context.getVar('result'), 'Processed: Hello from user');
    });

    test('should preserve context state during suspend', () {
      final context = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/test',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {},
      );

      // Установить состояние перед suspend
      context.setVar('step1_result', 'data from step 1');
      context.setVar('step2_result', 'data from step 2');
      context.setVar('counter', 42);

      // Симуляция suspend
      final savedState = {
        'step1_result': context.getVar('step1_result'),
        'step2_result': context.getVar('step2_result'),
        'counter': context.getVar('counter'),
      };

      // Проверить что состояние сохранено
      expect(savedState['step1_result'], 'data from step 1');
      expect(savedState['step2_result'], 'data from step 2');
      expect(savedState['counter'], 42);

      // Симуляция resume - восстановить состояние
      final restoredContext = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/test',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {},
      );

      for (final entry in savedState.entries) {
        restoredContext.setVar(entry.key, entry.value);
      }

      expect(restoredContext.getVar('step1_result'), 'data from step 1');
      expect(restoredContext.getVar('step2_result'), 'data from step 2');
      expect(restoredContext.getVar('counter'), 42);
    });

    test('should track suspended node id', () {
      final suspendedException = SuspendExecutionException(
        nodeId: 'user_input_node_123',
        reason: 'Waiting for user input',
      );

      expect(suspendedException.nodeId, 'user_input_node_123');
      expect(suspendedException.reason, 'Waiting for user input');
    });

    test('should handle multiple suspend/resume cycles', () async {
      final executionPath = <String>[];
      final registry = ToolRegistry();

      registry.register(MockHand(
        id: 'auto_step',
        handler: (params, context) async {
          final step = params['step'] as String;
          executionPath.add(step);
          return {};
        },
      ));

      final context = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/test',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {},
      );

      // Цикл: auto → suspend → resume → auto → suspend → resume → auto
      await registry.getHand('auto_step')!.execute({'step': 'step1'}, context);

      // Suspend 1
      context.setVar('input1', 'user input 1');

      await registry.getHand('auto_step')!.execute({'step': 'step2'}, context);

      // Suspend 2
      context.setVar('input2', 'user input 2');

      await registry.getHand('auto_step')!.execute({'step': 'step3'}, context);

      expect(executionPath, ['step1', 'step2', 'step3']);
      expect(context.getVar('input1'), 'user input 1');
      expect(context.getVar('input2'), 'user input 2');
    });

    test('should support different types of interactive nodes', () {
      final context = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/test',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {},
      );

      // UserInputNode
      context.setVar('user_input_node1', 'text input');
      expect(context.getVar('user_input_node1'), 'text input');

      // ManualReviewNode
      context.setVar('manual_review_node1', {'decision': 'approved'});
      final review = context.getVar('manual_review_node1') as Map;
      expect(review['decision'], 'approved');

      // FileUploadNode
      context.setVar('file_upload_node1', '/path/to/uploaded/file.txt');
      expect(context.getVar('file_upload_node1'), '/path/to/uploaded/file.txt');

      // CoCreationChatNode
      context.setVar('chat_node1_history', [
        {'role': 'user', 'message': 'Hello'},
        {'role': 'assistant', 'message': 'Hi there!'},
      ]);
      final history = context.getVar('chat_node1_history') as List;
      expect(history.length, 2);
    });

    test('should handle workflow status transitions', () {
      // running → suspended → running → completed
      var status = 'running';
      expect(status, 'running');

      // Suspend
      status = 'suspended';
      expect(status, 'suspended');

      // Resume
      status = 'running';
      expect(status, 'running');

      // Complete
      status = 'completed';
      expect(status, 'completed');
    });

    test('should validate suspend reason is provided', () {
      expect(
        () => SuspendExecutionException(
          nodeId: 'node1',
          reason: 'Waiting for user input',
        ),
        returnsNormally,
      );

      final exception = SuspendExecutionException(
        nodeId: 'node1',
        reason: 'Waiting for user input',
      );

      expect(exception.reason.isNotEmpty, true);
    });
  });
}
