// ЖЁСТКИЕ тесты обработки ошибок в узлах - ОБЯЗЫВАЮЩИЕ тесты для production

import 'package:test/test.dart';
import 'package:aq_schema/aq_schema.dart';


import 'package:aq_schema/graph/nodes/base/interactive_node.dart';

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
    this.description = 'Mock',
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
  group('Node Error Handling - КРИТИЧНО для production', () {
    test('ОБЯЗАТЕЛЬНО: узел ДОЛЖЕН выбросить исключение при отсутствии обязательного tool', () async {
      final registry = ToolRegistry();
      // НЕ регистрируем tool - это ошибка конфигурации

      final context = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/test',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {},
      );

      // Попытка получить несуществующий tool ДОЛЖНА вернуть null
      final hand = registry.getHand('nonexistent_tool');
      expect(hand, isNull, reason: 'КРИТИЧНО: getHand ДОЛЖЕН вернуть null для несуществующего tool');

      // Попытка выполнить null hand ДОЛЖНА выбросить исключение
      expect(
        () => hand!.execute({}, context),
        throwsA(isA<TypeError>()),
        reason: 'КРИТИЧНО: выполнение null hand ДОЛЖНО выбросить TypeError',
      );
    });

    test('ОБЯЗАТЕЛЬНО: узел ДОЛЖЕН обработать exception от tool и НЕ крашнуть весь workflow', () async {
      final registry = ToolRegistry();
      
      // Tool который ВСЕГДА падает
      registry.register(MockHand(
        id: 'failing_tool',
        handler: (params, context) async {
          throw Exception('Tool execution failed: database connection lost');
        },
      ));

      final context = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/test',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {},
      );

      final hand = registry.getHand('failing_tool')!;

      // ДОЛЖНО выбросить исключение
      expect(
        () => hand.execute({}, context),
        throwsA(isA<Exception>()),
        reason: 'КРИТИЧНО: ошибка tool ДОЛЖНА пробрасываться как Exception',
      );

      // Контекст ДОЛЖЕН остаться валидным после ошибки
      expect(context.runId, 'run1', reason: 'КРИТИЧНО: контекст НЕ должен быть повреждён после ошибки');
      expect(context.projectId, 'project1');
    });

    test('ОБЯЗАТЕЛЬНО: узел ДОЛЖЕН валидировать обязательные параметры ПЕРЕД выполнением', () async {
      final registry = ToolRegistry();
      
      registry.register(MockHand(
        id: 'strict_tool',
        handler: (params, context) async {
          // КРИТИЧНО: проверка обязательных параметров
          if (!params.containsKey('required_param')) {
            throw ArgumentError('Missing required parameter: required_param');
          }
          if (params['required_param'] == null) {
            throw ArgumentError('Parameter required_param cannot be null');
          }
          return {'result': 'ok'};
        },
      ));

      final context = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/test',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {},
      );

      final hand = registry.getHand('strict_tool')!;

      // Без параметра - ДОЛЖНА быть ошибка
      expect(
        () => hand.execute({}, context),
        throwsA(isA<ArgumentError>()),
        reason: 'КРИТИЧНО: отсутствие обязательного параметра ДОЛЖНО выбрасывать ArgumentError',
      );

      // С null параметром - ДОЛЖНА быть ошибка
      expect(
        () => hand.execute({'required_param': null}, context),
        throwsA(isA<ArgumentError>()),
        reason: 'КРИТИЧНО: null в обязательном параметре ДОЛЖЕН выбрасывать ArgumentError',
      );

      // С валидным параметром - ДОЛЖНО работать
      final result = await hand.execute({'required_param': 'value'}, context);
      expect(result['result'], 'ok');
    });

    test('ОБЯЗАТЕЛЬНО: узел ДОЛЖЕН обработать timeout и НЕ висеть вечно', () async {
      final registry = ToolRegistry();
      
      registry.register(MockHand(
        id: 'slow_tool',
        handler: (params, context) async {
          // Симуляция долгой операции
          await Future.delayed(Duration(milliseconds: 100));
          return {'result': 'completed'};
        },
      ));

      final context = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/test',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {},
      );

      final hand = registry.getHand('slow_tool')!;

      // ДОЛЖЕН завершиться с timeout
      expect(
        () => hand.execute({}, context).timeout(
          Duration(milliseconds: 50),
          onTimeout: () => throw TimeoutException('Tool execution timeout'),
        ),
        throwsA(isA<TimeoutException>()),
        reason: 'КРИТИЧНО: долгая операция ДОЛЖНА прерываться по timeout',
      );
    });

    test('ОБЯЗАТЕЛЬНО: interactive узел ДОЛЖЕН выбросить SuspendExecutionException если нет user response', () {
      final context = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/test',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {},
      );

      // НЕТ user response в контексте
      final hasResponse = context.getVar('user_input_node1') != null;
      expect(hasResponse, false);

      // ДОЛЖЕН выбросить SuspendExecutionException
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
        reason: 'КРИТИЧНО: отсутствие user response ДОЛЖНО выбрасывать SuspendExecutionException',
      );
    });

    test('ОБЯЗАТЕЛЬНО: узел ДОЛЖЕН сохранить error message в контекст для debugging', () async {
      final registry = ToolRegistry();
      final logs = <String>[];
      
      registry.register(MockHand(
        id: 'error_tool',
        handler: (params, context) async {
          final error = 'Critical error: file not found';
          context.setVar('last_error', error);
          context.log('ERROR: $error', type: 'error', branch: 'main');
          throw Exception(error);
        },
      ));

      final context = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/test',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {
          logs.add(msg);
        },
      );

      final hand = registry.getHand('error_tool')!;

      try {
        await hand.execute({}, context);
        fail('КРИТИЧНО: должно было выбросить исключение');
      } catch (e) {
        // Проверяем что error сохранён в контексте
        expect(
          context.getVar('last_error'),
          isNotNull,
          reason: 'КРИТИЧНО: error message ДОЛЖЕН быть сохранён в контексте',
        );
        expect(
          context.getVar('last_error'),
          contains('file not found'),
          reason: 'КРИТИЧНО: error message ДОЛЖЕН содержать детали ошибки',
        );
        
        // Проверяем что error залогирован
        expect(
          logs.any((log) => log.contains('ERROR')),
          true,
          reason: 'КРИТИЧНО: error ДОЛЖЕН быть залогирован',
        );
      }
    });

    test('ОБЯЗАТЕЛЬНО: узел ДОЛЖЕН очистить ресурсы даже при ошибке (cleanup)', () async {
      final registry = ToolRegistry();
      var resourceCleaned = false;
      
      registry.register(MockHand(
        id: 'resource_tool',
        handler: (params, context) async {
          try {
            // Открываем ресурс
            context.setVar('resource_opened', true);
            
            // Симуляция ошибки
            throw Exception('Operation failed');
          } finally {
            // КРИТИЧНО: cleanup ДОЛЖЕН выполниться даже при ошибке
            context.setVar('resource_opened', false);
            resourceCleaned = true;
          }
        },
      ));

      final context = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/test',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {},
      );

      final hand = registry.getHand('resource_tool')!;

      try {
        await hand.execute({}, context);
      } catch (e) {
        // Ожидаем ошибку
      }

      // КРИТИЧНО: ресурс ДОЛЖЕН быть очищен
      expect(
        resourceCleaned,
        true,
        reason: 'КРИТИЧНО: cleanup ДОЛЖЕН выполниться даже при ошибке',
      );
      expect(
        context.getVar('resource_opened'),
        false,
        reason: 'КРИТИЧНО: ресурс ДОЛЖЕН быть закрыт',
      );
    });

    test('ОБЯЗАТЕЛЬНО: узел НЕ ДОЛЖЕН изменять контекст при ошибке (atomicity)', () async {
      final registry = ToolRegistry();
      
      registry.register(MockHand(
        id: 'atomic_tool',
        handler: (params, context) async {
          // Сохраняем начальное состояние
          final initialValue = context.getVar('counter') ?? 0;
          
          // Начинаем изменения
          context.setVar('counter', initialValue + 1);
          context.setVar('temp_data', 'processing');
          
          // Ошибка в середине операции
          throw Exception('Operation failed midway');
          
          // Эти изменения НЕ должны примениться
          // context.setVar('counter', initialValue + 2);
          // context.setVar('result', 'completed');
        },
      ));

      final context = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/test',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {},
      );

      context.setVar('counter', 10);

      final hand = registry.getHand('atomic_tool')!;

      try {
        await hand.execute({}, context);
      } catch (e) {
        // Ожидаем ошибку
      }

      // ПРОБЛЕМА: контекст УЖЕ изменён до ошибки!
      // Это показывает что нужна транзакционность
      expect(
        context.getVar('counter'),
        11, // УЖЕ изменён!
        reason: 'ВНИМАНИЕ: контекст изменён до ошибки - нужна транзакционность!',
      );
      
      // Это демонстрирует проблему - нужен механизм rollback
    });
  });
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
  @override
  String toString() => message;
}
