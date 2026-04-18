// Тесты для простого линейного workflow - последовательное выполнение узлов

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
  group('Linear Workflow Execution', () {
    test('should execute nodes in sequence', () async {
      // Создать граф: Node1 → Node2 → Node3
      final node1 = WorkflowNode(
        id: 'node1',
        type: WorkflowNodeType.fileRead,
        config: {
          'file_path': 'input.txt',
          'output_var': 'content',
        },
      );

      final node2 = WorkflowNode(
        id: 'node2',
        type: WorkflowNodeType.llmAction,
        config: {
          'prompt_blueprint_id': 'analyze_prompt',
          'output_var': 'analysis',
        },
      );

      final node3 = WorkflowNode(
        id: 'node3',
        type: WorkflowNodeType.fileWrite,
        config: {
          'file_path': 'output.txt',
          'input_var': 'analysis',
        },
      );

      final edge1 = WorkflowEdge(
        id: 'edge1',
        sourceId: 'node1',
        targetId: 'node2',
      );

      final edge2 = WorkflowEdge(
        id: 'edge2',
        sourceId: 'node2',
        targetId: 'node3',
      );

      final graph = WorkflowGraph(
        id: 'workflow1',
        tenantId: 'tenant1',
        ownerId: 'project1',
        name: 'Linear Workflow',
        nodes: {
          node1.id: node1,
          node2.id: node2,
          node3.id: node3,
        },
        edges: {
          edge1.id: edge1,
          edge2.id: edge2,
        },
      );

      // Создать mock tools
      final executionOrder = <String>[];

      final registry = ToolRegistry();
      registry.register(MockHand(
        id: 'fs_read_file',
        handler: (params, context) async {
          executionOrder.add('node1');
          context.setVar('content', 'File content');
          return {'content': 'File content'};
        },
      ));

      registry.register(MockHand(
        id: 'llm_ask',
        handler: (params, context) async {
          executionOrder.add('node2');
          final content = context.getVar('content');
          context.setVar('analysis', 'Analysis of: $content');
          return {'response': 'Analysis of: $content'};
        },
      ));

      registry.register(MockHand(
        id: 'fs_write_file',
        handler: (params, context) async {
          executionOrder.add('node3');
          final analysis = context.getVar('analysis');
          return {'success': true, 'written': analysis};
        },
      ));

      // Создать контекст
      final logs = <String>[];
      final context = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/test',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {
          logs.add(msg);
        },
      );

      // Выполнить узлы вручную (симуляция runner)
      // Node 1
      final hand1 = registry.getHand('fs_read_file');
      await hand1!.execute({}, context);

      // Node 2
      final hand2 = registry.getHand('llm_ask');
      await hand2!.execute({}, context);

      // Node 3
      final hand3 = registry.getHand('fs_write_file');
      await hand3!.execute({}, context);

      // Проверки
      expect(executionOrder, ['node1', 'node2', 'node3']);
      expect(context.getVar('content'), 'File content');
      expect(context.getVar('analysis'), 'Analysis of: File content');
    });

    test('should pass data between nodes via context', () async {
      final registry = ToolRegistry();
      
      registry.register(MockHand(
        id: 'step1',
        handler: (params, context) async {
          context.setVar('x', 10);
          return {'x': 10};
        },
      ));

      registry.register(MockHand(
        id: 'step2',
        handler: (params, context) async {
          final x = context.getVar('x') as int;
          context.setVar('y', x * 2);
          return {'y': x * 2};
        },
      ));

      registry.register(MockHand(
        id: 'step3',
        handler: (params, context) async {
          final y = context.getVar('y') as int;
          context.setVar('z', y + 5);
          return {'z': y + 5};
        },
      ));

      final context = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/test',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {},
      );

      // Выполнить последовательно
      await registry.getHand('step1')!.execute({}, context);
      await registry.getHand('step2')!.execute({}, context);
      await registry.getHand('step3')!.execute({}, context);

      expect(context.getVar('x'), 10);
      expect(context.getVar('y'), 20);
      expect(context.getVar('z'), 25);
    });

    test('should log execution progress', () async {
      final logs = <String>[];
      final context = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/test',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {
          logs.add(msg);
        },
      );

      final registry = ToolRegistry();
      registry.register(MockHand(
        id: 'task1',
        handler: (params, context) async {
          context.log('Task 1 started', branch: 'main');
          context.log('Task 1 completed', branch: 'main');
          return {};
        },
      ));

      registry.register(MockHand(
        id: 'task2',
        handler: (params, context) async {
          context.log('Task 2 started', branch: 'main');
          context.log('Task 2 completed', branch: 'main');
          return {};
        },
      ));

      await registry.getHand('task1')!.execute({}, context);
      await registry.getHand('task2')!.execute({}, context);

      expect(logs.length, greaterThanOrEqualTo(4));
      expect(logs.any((l) => l.contains('Task 1 started')), true);
      expect(logs.any((l) => l.contains('Task 2 completed')), true);
    });

    test('should handle empty workflow', () {
      final graph = WorkflowGraph.empty(
        id: 'empty1',
        tenantId: 'tenant1',
        projectId: 'project1',
        name: 'Empty Workflow',
      );

      expect(graph.nodes, isEmpty);
      expect(graph.edges, isEmpty);
    });

    test('should identify start node (no incoming edges)', () {
      final node1 = WorkflowNode(id: 'node1', type: WorkflowNodeType.fileRead);
      final node2 = WorkflowNode(id: 'node2', type: WorkflowNodeType.llmAction);
      final node3 = WorkflowNode(id: 'node3', type: WorkflowNodeType.fileWrite);

      final edge1 = WorkflowEdge(id: 'e1', sourceId: 'node1', targetId: 'node2');
      final edge2 = WorkflowEdge(id: 'e2', sourceId: 'node2', targetId: 'node3');

      final graph = WorkflowGraph(
        id: 'wf1',
        tenantId: 'tenant1',
        ownerId: 'project1',
        name: 'Test',
        nodes: {node1.id: node1, node2.id: node2, node3.id: node3},
        edges: {edge1.id: edge1, edge2.id: edge2},
      );

      // Найти узлы без входящих рёбер
      final allTargetIds = graph.edges.values.map((e) => e.targetId).toSet();
      final startNodes = graph.nodes.values
          .where((n) => !allTargetIds.contains(n.id))
          .toList();

      expect(startNodes.length, 1);
      expect(startNodes.first.id, 'node1');
    });

    test('should identify end node (no outgoing edges)', () {
      final node1 = WorkflowNode(id: 'node1', type: WorkflowNodeType.fileRead);
      final node2 = WorkflowNode(id: 'node2', type: WorkflowNodeType.llmAction);
      final node3 = WorkflowNode(id: 'node3', type: WorkflowNodeType.fileWrite);

      final edge1 = WorkflowEdge(id: 'e1', sourceId: 'node1', targetId: 'node2');
      final edge2 = WorkflowEdge(id: 'e2', sourceId: 'node2', targetId: 'node3');

      final graph = WorkflowGraph(
        id: 'wf1',
        tenantId: 'tenant1',
        ownerId: 'project1',
        name: 'Test',
        nodes: {node1.id: node1, node2.id: node2, node3.id: node3},
        edges: {edge1.id: edge1, edge2.id: edge2},
      );

      // Найти узлы без исходящих рёбер
      final allSourceIds = graph.edges.values.map((e) => e.sourceId).toSet();
      final endNodes = graph.nodes.values
          .where((n) => !graph.edges.values.any((e) => e.sourceId == n.id))
          .toList();

      expect(endNodes.length, 1);
      expect(endNodes.first.id, 'node3');
    });
  });
}
