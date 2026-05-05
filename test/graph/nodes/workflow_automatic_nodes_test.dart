// Тесты для AutomaticWorkflowNode

import 'package:test/test.dart';
import 'package:aq_schema/graph/nodes/workflow/automatic/automatic_workflow_node.dart';
import 'package:aq_schema/aq_schema.dart';
import 'package:aq_schema/tools.dart';

class _MockToolProtocol implements IToolEngineProtocol {
  final Map<String, dynamic> Function(String, Map<String, dynamic>)? handler;
  String? lastToolName;
  Map<String, dynamic>? lastParams;

  _MockToolProtocol({this.handler});

  @override
  Future<ToolResult> callTool(String name, Map<String, dynamic> args,
      RunContext context, {String? namespace}) async {
    lastToolName = name;
    lastParams = args;
    final output = handler?.call(name, args) ?? {'ok': true};
    return ToolResult.success(
      output: output,
      meta: ToolResultMeta(
          elapsed: Duration.zero,
          resolvedRef: ToolRef(name),
          executorType: 'mock'),
    );
  }

  @override
  Stream<ToolResultChunk> callToolStream(String name, Map<String, dynamic> args,
      RunContext context, {String? namespace}) => Stream.empty();

  @override
  Future<bool> hasTool(String name, {String? namespace}) async => true;

  @override
  Future<List<ToolEngineDescriptor>> getAvailableTools({String? namespace}) async => [];

  @override
  Stream<ToolLifecycleEvent> get lifecycleEvents => Stream.empty();
}

RunContext _ctx() => RunContext(
      runId: 'run-1',
      projectId: 'proj-1',
      projectPath: '/tmp',
      log: (msg, {type = 'info', depth = 0, required branch, details}) {},
    );

void main() {
  late _MockToolProtocol mock;

  setUp(() {
    mock = _MockToolProtocol();
    IToolEngineProtocol.initialize(mock);
  });

  tearDown(() => IToolEngineProtocol.reset());

  group('AutomaticWorkflowNode', () {
    test('вызывает инструмент с правильным toolName', () async {
      final node = AutomaticWorkflowNode(
        id: 'n1',
        toolName: 'llm_ask',
        params: {'prompt': 'Hello'},
        outputVar: 'result',
      );

      await node.execute(_ctx());

      expect(mock.lastToolName, 'llm_ask');
      expect(mock.lastParams, {'prompt': 'Hello'});
    });

    test('подставляет {{variables}} в params', () async {
      final node = AutomaticWorkflowNode(
        id: 'n1',
        toolName: 'fs_read',
        params: {'path': '{{file_path}}'},
        outputVar: 'content',
      );

      final ctx = _ctx();
      ctx.setVar('file_path', '/tmp/test.txt');
      await node.execute(ctx);

      expect(mock.lastParams!['path'], '/tmp/test.txt');
    });

    test('сохраняет результат в outputVar', () async {
      mock = _MockToolProtocol(handler: (_, __) => {'content': 'file content'});
      IToolEngineProtocol.initialize(mock);

      final node = AutomaticWorkflowNode(
        id: 'n1',
        toolName: 'fs_read',
        params: {},
        outputVar: 'content',
      );

      final ctx = _ctx();
      await node.execute(ctx);

      expect(ctx.getVar('content'), {'content': 'file content'});
    });

    test('бросает исключение если toolName пустой', () async {
      final node = AutomaticWorkflowNode(
        id: 'n1',
        toolName: '',
        params: {},
        outputVar: 'result',
      );

      expect(() => node.execute(_ctx()), throwsException);
    });

    test('nodeType == automatic', () {
      final node = AutomaticWorkflowNode(
          id: 'n1', toolName: 'any', outputVar: 'out');
      expect(node.nodeType, 'automatic');
    });

    group('сериализация', () {
      test('toJson / fromJson round-trip', () {
        final node = AutomaticWorkflowNode(
          id: 'n1',
          toolName: 'git_commit',
          params: {'message': 'feat: {{feature}}'},
          outputVar: 'commit_result',
        );

        final json = node.toJson();
        final restored = AutomaticWorkflowNode.fromJson(json);

        expect(restored.id, node.id);
        expect(restored.toolName, node.toolName);
        expect(restored.params, node.params);
        expect(restored.outputVar, node.outputVar);
      });

      test('fromJson с дефолтным outputVar', () {
        final node = AutomaticWorkflowNode.fromJson({
          'id': 'n1',
          'type': 'automatic',
          'toolName': 'llm_ask',
        });

        expect(node.outputVar, 'result');
        expect(node.params, isEmpty);
      });
    });
  });
}
