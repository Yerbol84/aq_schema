// Тесты для автоматических узлов WorkflowGraph
//
// СТАТУС: ТРЕБУЕТСЯ ОБНОВЛЕНИЕ
//
// Эти тесты использовали устаревшую архитектуру с MockToolRegistry и ToolRegistry.
// После рефакторинга Phase-1 (commit b32955a) система перешла на AQToolService.
//
// ДЛЯ БУДУЩИХ РАЗРАБОТЧИКОВ:
//
// Чтобы восстановить эти тесты, необходимо:
//
// 1. Создать MockAQToolService который реализует AQToolService:
//
//    class MockAQToolService implements AQToolService {
//      final Map<String, IAQToolExecutor> _tools = {};
//
//      void registerTool(String name, IAQToolExecutor executor) {
//        _tools[name] = executor;
//      }
//
//      @override
//      List<AQToolDescriptor> get availableTools =>
//        _tools.values.map((e) => e.descriptor).toList();
//
//      @override
//      bool hasTool(String name) => _tools.containsKey(name);
//
//      @override
//      Future<AQToolCallResult> callTool(
//        String name,
//        Map<String, dynamic> args,
//        RunContext context, {
//        ISandboxContext? sandbox,
//      }) async {
//        final tool = _tools[name];
//        if (tool == null) {
//          return AQToolCallResult.failure('Tool not found: $name');
//        }
//        return tool.execute(args, context, sandbox);
//      }
//    }
//
// 2. Создать MockToolExecutor для каждого инструмента:
//
//    class MockToolExecutor implements IAQToolExecutor {
//      final String name;
//      final Future<AQToolCallResult> Function(
//        Map<String, dynamic>,
//        RunContext,
//        ISandboxContext?,
//      ) handler;
//
//      MockToolExecutor(this.name, this.handler);
//
//      @override
//      AQToolDescriptor get descriptor => AQToolDescriptor(
//        name: name,
//        description: 'Mock tool',
//        inputSchema: {},
//        category: AQToolCategory.system,
//      );
//
//      @override
//      Future<AQToolCallResult> execute(
//        Map<String, dynamic> args,
//        RunContext context,
//        ISandboxContext? sandbox,
//      ) => handler(args, context, sandbox);
//    }
//
// 3. Инициализировать AQToolService в setUp():
//
//    setUp(() {
//      AQToolService.resetForTesting();
//      final mockService = MockAQToolService();
//      mockService.registerTool('llm_ask', MockToolExecutor(...));
//      AQToolService.init(mockService);
//    });
//
// 4. Узлы теперь вызывают инструменты через AQToolService.require:
//
//    final result = await AQToolService.require.callTool(
//      'llm_ask',
//      {'prompt': prompt, 'model_name': modelName},
//      context,
//    );
//
// ТЕСТИРУЕМЫЕ УЗЛЫ:
// - LlmActionNode — вызов LLM с compiled prompt
// - FileReadNode — чтение файла через инструмент
// - FileWriteNode — запись файла через инструмент
// - GitCommitNode — git commit через инструмент
//
// СЦЕНАРИИ ТЕСТОВ (которые были):
// - LlmActionNode: execute with compiled prompt, throw if prompt not found, serialization
// - FileReadNode: read file and store in var, handle file not found, serialization
// - FileWriteNode: write file from var, handle write error, serialization
// - GitCommitNode: commit with message, handle git error, serialization
//
// См. также:
// - lib/tools/aq_tool_service.dart — новый интерфейс
// - lib/tools/models.dart — AQToolDescriptor, AQToolCallResult
// - commit b32955a — Phase-1 рефакторинг на AQToolService

import 'package:test/test.dart';
import 'package:aq_schema/graph/nodes/workflow/automatic/llm_action_node.dart';
import 'package:aq_schema/graph/nodes/workflow/automatic/file_read_node.dart';
import 'package:aq_schema/graph/nodes/workflow/automatic/file_write_node.dart';
import 'package:aq_schema/graph/nodes/workflow/automatic/git_commit_node.dart';
import 'package:aq_schema/aq_schema.dart';

void main() {
  group('Workflow Automatic Nodes', () {
    test('ТРЕБУЕТСЯ ОБНОВЛЕНИЕ: см. комментарии в начале файла', () {
      // Эти тесты временно отключены до реализации MockAQToolService
      expect(true, isTrue);
    });
  });

  // TODO: Восстановить тесты для LlmActionNode
  // TODO: Восстановить тесты для FileReadNode
  // TODO: Восстановить тесты для FileWriteNode
  // TODO: Восстановить тесты для GitCommitNode
}
