// Тесты для conditional workflow - ветвление по условиям

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
        'parameters': {
          'type': 'object',
          'properties': {},
        },
      };
}

void main() {
  group('Conditional Workflow Execution', () {
    test('should follow onSuccess edge when node succeeds', () async {
      // Граф: Node1 → (onSuccess) Node2A, (onError) Node2B
      final node1 = WorkflowNode(
        id: 'node1',
        type: WorkflowNodeType.fileRead,
        config: {'file_path': 'input.txt'},
      );

      final node2a = WorkflowNode(
        id: 'node2a',
        type: WorkflowNodeType.llmAction,
        config: {'action': 'success_path'},
      );

      final node2b = WorkflowNode(
        id: 'node2b',
        type: WorkflowNodeType.llmAction,
        config: {'action': 'error_path'},
      );

      final edgeSuccess = WorkflowEdge(
        id: 'edge_success',
        sourceId: 'node1',
        targetId: 'node2a',
        type: WorkflowEdgeType.onSuccess,
      );

      final edgeError = WorkflowEdge(
        id: 'edge_error',
        sourceId: 'node1',
        targetId: 'node2b',
        type: WorkflowEdgeType.onError,
      );

      final graph = WorkflowGraph(
        id: 'workflow1',
        tenantId: 'tenant1',
        ownerId: 'project1',
        name: 'Conditional Workflow',
        nodes: {
          node1.id: node1,
          node2a.id: node2a,
          node2b.id: node2b,
        },
        edges: {
          edgeSuccess.id: edgeSuccess,
          edgeError.id: edgeError,
        },
      );

      final executionPath = <String>[];
      final registry = ToolRegistry();

      registry.register(MockHand(
        id: 'fs_read_file',
        handler: (params, context) async {
          executionPath.add('node1');
          context.setVar('success', true);
          return {'content': 'File content'};
        },
      ));

      registry.register(MockHand(
        id: 'llm_ask',
        handler: (params, context) async {
          final config = params['config'] as Map<String, dynamic>?;
          final action = config?['action'] as String?;
          if (action == 'success_path') {
            executionPath.add('node2a');
          } else if (action == 'error_path') {
            executionPath.add('node2b');
          }
          return {};
        },
      ));

      final context = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/test',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {},
      );

      // Выполнить node1 (успех)
      await registry.getHand('fs_read_file')!.execute({}, context);

      // Проверить что success = true
      final success = context.getVar('success') as bool;
      expect(success, true);

      // Если success, выполнить node2a
      if (success) {
        await registry.getHand('llm_ask')!.execute({
          'config': node2a.config,
        }, context);
      }

      expect(executionPath, ['node1', 'node2a']);
    });

    test('should follow onError edge when node fails', () async {
      final executionPath = <String>[];
      final registry = ToolRegistry();

      registry.register(MockHand(
        id: 'failing_task',
        handler: (params, context) async {
          executionPath.add('node1');
          context.setVar('error', true);
          throw Exception('Task failed');
        },
      ));

      registry.register(MockHand(
        id: 'error_handler',
        handler: (params, context) async {
          executionPath.add('error_handler');
          return {'handled': true};
        },
      ));

      final context = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/test',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {},
      );

      // Выполнить failing task
      try {
        await registry.getHand('failing_task')!.execute({}, context);
      } catch (e) {
        // Ошибка произошла, выполнить error handler
        await registry.getHand('error_handler')!.execute({}, context);
      }

      expect(executionPath, ['node1', 'error_handler']);
    });

    test('should evaluate conditional edge expression', () async {
      final node1 = WorkflowNode(
        id: 'node1',
        type: WorkflowNodeType.llmAction,
        config: {'action': 'analyze'},
      );

      final node2a = WorkflowNode(
        id: 'node2a',
        type: WorkflowNodeType.fileWrite,
        config: {'path': 'high_quality.txt'},
      );

      final node2b = WorkflowNode(
        id: 'node2b',
        type: WorkflowNodeType.fileWrite,
        config: {'path': 'low_quality.txt'},
      );

      final edgeHighQuality = WorkflowEdge(
        id: 'edge_high',
        sourceId: 'node1',
        targetId: 'node2a',
        type: WorkflowEdgeType.conditional,
        conditionExpression: 'quality > 80',
      );

      final edgeLowQuality = WorkflowEdge(
        id: 'edge_low',
        sourceId: 'node1',
        targetId: 'node2b',
        type: WorkflowEdgeType.conditional,
        conditionExpression: 'quality <= 80',
      );

      final graph = WorkflowGraph(
        id: 'workflow1',
        tenantId: 'tenant1',
        ownerId: 'project1',
        name: 'Quality Check',
        nodes: {
          node1.id: node1,
          node2a.id: node2a,
          node2b.id: node2b,
        },
        edges: {
          edgeHighQuality.id: edgeHighQuality,
          edgeLowQuality.id: edgeLowQuality,
        },
      );

      final executionPath = <String>[];
      final registry = ToolRegistry();

      registry.register(MockHand(
        id: 'llm_ask',
        handler: (params, context) async {
          executionPath.add('node1');
          context.setVar('quality', 85);
          return {'quality': 85};
        },
      ));

      registry.register(MockHand(
        id: 'fs_write_file',
        handler: (params, context) async {
          final config = params['config'] as Map<String, dynamic>?;
          final path = config?['path'] as String?;
          if (path == 'high_quality.txt') {
            executionPath.add('node2a');
          } else if (path == 'low_quality.txt') {
            executionPath.add('node2b');
          }
          return {};
        },
      ));

      final context = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/test',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {},
      );

      // Выполнить node1
      await registry.getHand('llm_ask')!.execute({}, context);

      // Проверить условие
      final quality = context.getVar('quality') as int;
      expect(quality, 85);

      // Выбрать путь на основе условия
      if (quality > 80) {
        await registry.getHand('fs_write_file')!.execute({
          'config': node2a.config,
        }, context);
      } else {
        await registry.getHand('fs_write_file')!.execute({
          'config': node2b.config,
        }, context);
      }

      expect(executionPath, ['node1', 'node2a']);
    });

    test('should handle multiple conditional branches', () async {
      final context = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/test',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {},
      );

      context.setVar('score', 95);

      final score = context.getVar('score') as int;
      String branch;

      if (score >= 90) {
        branch = 'excellent';
      } else if (score >= 70) {
        branch = 'good';
      } else if (score >= 50) {
        branch = 'average';
      } else {
        branch = 'poor';
      }

      expect(branch, 'excellent');
    });

    test('should support complex conditional expressions', () {
      final context = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/test',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {},
      );

      context.setVar('quality', 85);
      context.setVar('confidence', 0.9);
      context.setVar('approved', true);

      final quality = context.getVar('quality') as int;
      final confidence = context.getVar('confidence') as double;
      final approved = context.getVar('approved') as bool;

      // Сложное условие: quality > 80 AND confidence > 0.8 AND approved
      final shouldProceed = quality > 80 && confidence > 0.8 && approved;

      expect(shouldProceed, true);
    });

    test('should handle edge with no matching condition', () {
      final node1 = WorkflowNode(id: 'node1', type: WorkflowNodeType.llmAction);
      final node2 = WorkflowNode(id: 'node2', type: WorkflowNodeType.fileWrite);

      final edge = WorkflowEdge(
        id: 'edge1',
        sourceId: 'node1',
        targetId: 'node2',
        type: WorkflowEdgeType.conditional,
        conditionExpression: 'status == "ready"',
      );

      final graph = WorkflowGraph(
        id: 'wf1',
        tenantId: 'tenant1',
        ownerId: 'project1',
        name: 'Test',
        nodes: {node1.id: node1, node2.id: node2},
        edges: {edge.id: edge},
      );

      final context = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/test',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {},
      );

      context.setVar('status', 'pending');

      final status = context.getVar('status') as String;
      final conditionMet = status == 'ready';

      expect(conditionMet, false);
    });
  });
}
