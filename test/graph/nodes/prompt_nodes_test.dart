// Тесты для Prompt Nodes - узлы построения промптов

import 'package:test/test.dart';
import 'package:aq_schema/graph/nodes/prompt/text_block_node.dart';
import 'package:aq_schema/graph/nodes/prompt/variable_insert_node.dart';
import 'package:aq_schema/graph/nodes/prompt/conditional_block_node.dart';
import 'package:aq_schema/aq_schema.dart';

void main() {
  group('TextBlockNode', () {
    test('should return static text', () async {
      final node = TextBlockNode(
        id: 'text1',
        text: 'Hello World',
      );

      final context = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/test',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {},
      );

      final result = await node.execute(context);

      expect(result, 'Hello World');
    });

    test('should substitute variables', () async {
      final node = TextBlockNode(
        id: 'text1',
        text: 'Hello {{name}}, you are {{age}} years old',
      );

      final context = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/test',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {},
      );

      context.setVar('name', 'John');
      context.setVar('age', 30);

      final result = await node.execute(context);

      expect(result, 'Hello John, you are 30 years old');
    });

    test('should leave missing variables as is', () async {
      final node = TextBlockNode(
        id: 'text1',
        text: 'Hello {{name}}, welcome to {{city}}',
      );

      final context = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/test',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {},
      );

      context.setVar('name', 'Alice');

      final result = await node.execute(context);

      expect(result, 'Hello Alice, welcome to {{city}}');
    });

    test('should serialize to json', () {
      final node = TextBlockNode(
        id: 'text1',
        text: 'Test text',
      );

      final json = node.toJson();

      expect(json['id'], 'text1');
      expect(json['type'], 'textBlock');
      expect(json['config']['text'], 'Test text');
    });

    test('should deserialize from json', () {
      final json = {
        'id': 'text1',
        'type': 'textBlock',
        'config': {
          'text': 'Hello World',
        },
      };

      final node = TextBlockNode.fromJson(json);

      expect(node.id, 'text1');
      expect(node.text, 'Hello World');
    });

    test('should copyWith', () {
      final node = TextBlockNode(
        id: 'text1',
        text: 'Original',
      );

      final updated = node.copyWith(
        id: 'text2',
        text: 'Updated',
      ) as TextBlockNode;

      expect(updated.id, 'text2');
      expect(updated.text, 'Updated');
    });
  });

  group('VariableInsertNode', () {
    test('should return variable value', () async {
      final node = VariableInsertNode(
        id: 'var1',
        varName: 'userName',
      );

      final context = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/test',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {},
      );

      context.setVar('userName', 'Alice');

      final result = await node.execute(context);

      expect(result, 'Alice');
    });

    test('should return default value if variable not found', () async {
      final node = VariableInsertNode(
        id: 'var1',
        varName: 'missing',
        defaultValue: 'default',
      );

      final context = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/test',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {},
      );

      final result = await node.execute(context);

      expect(result, 'default');
    });

    test('should return empty string if no default and variable not found', () async {
      final node = VariableInsertNode(
        id: 'var1',
        varName: 'missing',
      );

      final context = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/test',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {},
      );

      final result = await node.execute(context);

      expect(result, '');
    });

    test('should add prefix and suffix', () async {
      final node = VariableInsertNode(
        id: 'var1',
        varName: 'code',
        prefix: '```\n',
        suffix: '\n```',
      );

      final context = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/test',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {},
      );

      context.setVar('code', 'print("hello")');

      final result = await node.execute(context);

      expect(result, '```\nprint("hello")\n```');
    });

    test('should not add prefix/suffix if value is empty', () async {
      final node = VariableInsertNode(
        id: 'var1',
        varName: 'missing',
        prefix: 'PREFIX',
        suffix: 'SUFFIX',
      );

      final context = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/test',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {},
      );

      final result = await node.execute(context);

      expect(result, '');
    });

    test('should serialize to json', () {
      final node = VariableInsertNode(
        id: 'var1',
        varName: 'userName',
        prefix: 'Hello ',
        suffix: '!',
        defaultValue: 'Guest',
      );

      final json = node.toJson();

      expect(json['id'], 'var1');
      expect(json['type'], 'variableInsert');
      expect(json['config']['var_name'], 'userName');
      expect(json['config']['prefix'], 'Hello ');
      expect(json['config']['suffix'], '!');
      expect(json['config']['default_value'], 'Guest');
    });

    test('should deserialize from json', () {
      final json = {
        'id': 'var1',
        'type': 'variableInsert',
        'config': {
          'var_name': 'userName',
          'prefix': 'Mr. ',
          'suffix': ' Esq.',
          'default_value': 'Unknown',
        },
      };

      final node = VariableInsertNode.fromJson(json);

      expect(node.id, 'var1');
      expect(node.varName, 'userName');
      expect(node.prefix, 'Mr. ');
      expect(node.suffix, ' Esq.');
      expect(node.defaultValue, 'Unknown');
    });

    test('should copyWith', () {
      final node = VariableInsertNode(
        id: 'var1',
        varName: 'original',
      );

      final updated = node.copyWith(
        varName: 'updated',
        prefix: 'NEW_',
      ) as VariableInsertNode;

      expect(updated.varName, 'updated');
      expect(updated.prefix, 'NEW_');
    });
  });

  group('ConditionalBlockNode', () {
    late RunContext context;

    setUp(() {
      context = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/test',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {},
      );
    });

    test('should return textIfTrue when condition is true (==)', () async {
      final node = ConditionalBlockNode(
        id: 'cond1',
        checkVar: 'status',
        operator: '==',
        compareValue: 'active',
        textIfTrue: 'System is active',
        textIfFalse: 'System is inactive',
      );

      context.setVar('status', 'active');

      final result = await node.execute(context);

      expect(result, 'System is active');
    });

    test('should return textIfFalse when condition is false (==)', () async {
      final node = ConditionalBlockNode(
        id: 'cond1',
        checkVar: 'status',
        operator: '==',
        compareValue: 'active',
        textIfTrue: 'System is active',
        textIfFalse: 'System is inactive',
      );

      context.setVar('status', 'disabled');

      final result = await node.execute(context);

      expect(result, 'System is inactive');
    });

    test('should return empty string if textIfFalse not provided', () async {
      final node = ConditionalBlockNode(
        id: 'cond1',
        checkVar: 'flag',
        operator: '==',
        compareValue: true,
        textIfTrue: 'Flag is true',
      );

      context.setVar('flag', false);

      final result = await node.execute(context);

      expect(result, '');
    });

    test('should handle != operator', () async {
      final node = ConditionalBlockNode(
        id: 'cond1',
        checkVar: 'mode',
        operator: '!=',
        compareValue: 'debug',
        textIfTrue: 'Production mode',
      );

      context.setVar('mode', 'production');

      final result = await node.execute(context);

      expect(result, 'Production mode');
    });

    test('should handle exists operator', () async {
      final node = ConditionalBlockNode(
        id: 'cond1',
        checkVar: 'userName',
        operator: 'exists',
        textIfTrue: 'User is logged in',
        textIfFalse: 'User is not logged in',
      );

      context.setVar('userName', 'Alice');

      final result = await node.execute(context);

      expect(result, 'User is logged in');
    });

    test('should handle notExists operator', () async {
      final node = ConditionalBlockNode(
        id: 'cond1',
        checkVar: 'error',
        operator: 'notExists',
        textIfTrue: 'No errors',
        textIfFalse: 'Errors found',
      );

      final result = await node.execute(context);

      expect(result, 'No errors');
    });

    test('should handle isEmpty operator', () async {
      final node = ConditionalBlockNode(
        id: 'cond1',
        checkVar: 'message',
        operator: 'isEmpty',
        textIfTrue: 'No message',
        textIfFalse: 'Message exists',
      );

      context.setVar('message', '');

      final result = await node.execute(context);

      expect(result, 'No message');
    });

    test('should handle isNotEmpty operator', () async {
      final node = ConditionalBlockNode(
        id: 'cond1',
        checkVar: 'content',
        operator: 'isNotEmpty',
        textIfTrue: 'Content available',
      );

      context.setVar('content', 'Some text');

      final result = await node.execute(context);

      expect(result, 'Content available');
    });

    test('should substitute variables in result text', () async {
      final node = ConditionalBlockNode(
        id: 'cond1',
        checkVar: 'hasUser',
        operator: 'exists',
        textIfTrue: 'Welcome {{userName}}!',
      );

      context.setVar('hasUser', true);
      context.setVar('userName', 'Bob');

      final result = await node.execute(context);

      expect(result, 'Welcome Bob!');
    });

    test('should throw error for unknown operator', () async {
      final node = ConditionalBlockNode(
        id: 'cond1',
        checkVar: 'x',
        operator: 'unknownOp',
        textIfTrue: 'text',
      );

      context.setVar('x', 10);

      expect(
        () => node.execute(context),
        throwsA(isA<Exception>()),
      );
    });

    test('should serialize to json', () {
      final node = ConditionalBlockNode(
        id: 'cond1',
        checkVar: 'status',
        operator: '==',
        compareValue: 'ok',
        textIfTrue: 'All good',
        textIfFalse: 'Error',
      );

      final json = node.toJson();

      expect(json['id'], 'cond1');
      expect(json['type'], 'conditionalBlock');
      expect(json['config']['check_var'], 'status');
      expect(json['config']['operator'], '==');
      expect(json['config']['compare_value'], 'ok');
      expect(json['config']['text_if_true'], 'All good');
      expect(json['config']['text_if_false'], 'Error');
    });

    test('should deserialize from json', () {
      final json = {
        'id': 'cond1',
        'type': 'conditionalBlock',
        'config': {
          'check_var': 'flag',
          'operator': 'exists',
          'text_if_true': 'Yes',
          'text_if_false': 'No',
        },
      };

      final node = ConditionalBlockNode.fromJson(json);

      expect(node.id, 'cond1');
      expect(node.checkVar, 'flag');
      expect(node.operator, 'exists');
      expect(node.textIfTrue, 'Yes');
      expect(node.textIfFalse, 'No');
    });

    test('should copyWith', () {
      final node = ConditionalBlockNode(
        id: 'cond1',
        checkVar: 'x',
        operator: '==',
        textIfTrue: 'original',
      );

      final updated = node.copyWith(
        checkVar: 'y',
        textIfTrue: 'updated',
      ) as ConditionalBlockNode;

      expect(updated.checkVar, 'y');
      expect(updated.textIfTrue, 'updated');
      expect(updated.operator, '==');
    });
  });
}
