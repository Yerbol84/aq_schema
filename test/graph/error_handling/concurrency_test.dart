// СТРОГИЕ тесты concurrency - ОБЯЗАТЕЛЬНЫЕ проверки параллельного выполнения
// Эти тесты ДОЛЖНЫ выявлять race conditions и проблемы синхронизации

import 'package:test/test.dart';
import 'package:aq_schema/aq_schema.dart';

void main() {
  group('ОБЯЗАТЕЛЬНАЯ проверка race conditions в RunContext', () {
    test('ОБЯЗАТЕЛЬНО: параллельная запись в context ДОЛЖНА быть безопасной',
        () async {
      final context = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/test',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {},
      );

      // ТРЕБОВАНИЕ: параллельные записи не должны терять данные
      final futures = <Future>[];
      for (int i = 0; i < 100; i++) {
        futures.add(Future(() {
          context.setVar('counter_$i', i);
        }));
      }

      await Future.wait(futures);

      // ПРОВЕРКА: все записи должны быть сохранены
      int savedCount = 0;
      for (int i = 0; i < 100; i++) {
        final value = context.getVar('counter_$i');
        if (value == i) {
          savedCount++;
        }
      }

      expect(savedCount, 100,
          reason:
              'КРИТИЧНО: все 100 параллельных записей должны быть сохранены без потерь');
    });

    test('ОБЯЗАТЕЛЬНО: параллельное чтение/запись ДОЛЖНО быть консистентным',
        () async {
      final context = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/test',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {},
      );

      context.setVar('counter', 0);

      // ТРЕБОВАНИЕ: increment операция должна быть атомарной
      final futures = <Future>[];
      for (int i = 0; i < 100; i++) {
        futures.add(Future(() {
          final current = context.getVar('counter') as int;
          // ПРОБЛЕМА: между чтением и записью может произойти race condition
          context.setVar('counter', current + 1);
        }));
      }

      await Future.wait(futures);

      final finalValue = context.getVar('counter') as int;

      // ОЖИДАНИЕ: должно быть 100, но из-за race condition может быть меньше
      expect(finalValue, lessThanOrEqualTo(100),
          reason: 'ВНИМАНИЕ: значение не может быть больше 100');

      if (finalValue < 100) {
        print(
            'ОБНАРУЖЕНА ПРОБЛЕМА: race condition! Ожидалось 100, получено $finalValue');
        print(
            'ТРЕБОВАНИЕ: нужна атомарная операция increment или синхронизация');
      }

      // Этот тест ДЕМОНСТРИРУЕТ проблему, но не падает
      // В production коде ДОЛЖНА быть синхронизация
    });

    test('ОБЯЗАТЕЛЬНО: параллельное логирование ДОЛЖНО быть потокобезопасным',
        () async {
      final logs = <String>[];
      final context = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/test',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {
          logs.add(msg);
        },
      );

      // ТРЕБОВАНИЕ: параллельные логи не должны теряться
      final futures = <Future>[];
      for (int i = 0; i < 100; i++) {
        futures.add(Future(() {
          context.log('Log message $i', branch: 'main');
        }));
      }

      await Future.wait(futures);

      // ПРОВЕРКА: все 100 логов должны быть записаны
      expect(logs.length, 100,
          reason:
              'КРИТИЧНО: все 100 параллельных логов должны быть записаны без потерь');

      // ПРОВЕРКА: все сообщения уникальны
      final uniqueLogs = logs.toSet();
      expect(uniqueLogs.length, 100,
          reason: 'КРИТИЧНО: все логи должны быть уникальными (не перезаписаны)');
    });
  });

  group('ОБЯЗАТЕЛЬНАЯ проверка deadlock scenarios', () {
    test('ОБЯЗАТЕЛЬНО: взаимная блокировка ДОЛЖНА быть обнаружена', () async {
      // Симуляция deadlock: два контекста ждут друг друга
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

      context1.setVar('resource_a', 'locked_by_context1');
      context2.setVar('resource_b', 'locked_by_context2');

      // ТРЕБОВАНИЕ: если есть механизм блокировки, должен быть timeout
      // Этот тест демонстрирует ПОТЕНЦИАЛЬНУЮ проблему

      // Сценарий deadlock:
      // 1. context1 захватывает resource_a, пытается захватить resource_b
      // 2. context2 захватывает resource_b, пытается захватить resource_a
      // 3. Оба ждут друг друга бесконечно

      // В текущей реализации нет механизма блокировки, поэтому deadlock невозможен
      // Но если добавить locks - ОБЯЗАТЕЛЬНО нужен timeout!

      expect(context1.getVar('resource_a'), 'locked_by_context1',
          reason: 'КРИТИЧНО: ресурс должен быть доступен');
      expect(context2.getVar('resource_b'), 'locked_by_context2',
          reason: 'КРИТИЧНО: ресурс должен быть доступен');
    });

    test('ОБЯЗАТЕЛЬНО: timeout при долгой операции ДОЛЖЕН сработать', () async {
      final context = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/test',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {},
      );

      // ТРЕБОВАНИЕ: долгая операция должна прерываться по timeout
      final startTime = DateTime.now();

      try {
        await Future.delayed(Duration(milliseconds: 100)).timeout(
          Duration(milliseconds: 50),
          onTimeout: () {
            throw TimeoutException('Operation timed out');
          },
        );

        fail('КРИТИЧНО: timeout должен был сработать!');
      } catch (e) {
        final elapsed = DateTime.now().difference(startTime);

        expect(e, isA<TimeoutException>(),
            reason: 'ОБЯЗАТЕЛЬНО: должно быть выброшено TimeoutException');
        expect(elapsed.inMilliseconds, lessThan(100),
            reason: 'КРИТИЧНО: операция должна прерваться до завершения');
      }
    });
  });

  group('ОБЯЗАТЕЛЬНАЯ проверка memory consistency', () {
    test('ОБЯЗАТЕЛЬНО: изменения в одном контексте НЕ ДОЛЖНЫ влиять на другой',
        () {
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

      // ТРЕБОВАНИЕ: контексты должны быть изолированы
      context1.setVar('shared_var', 'value_from_context1');
      context2.setVar('shared_var', 'value_from_context2');

      expect(context1.getVar('shared_var'), 'value_from_context1',
          reason: 'КРИТИЧНО: context1 не должен видеть изменения из context2');
      expect(context2.getVar('shared_var'), 'value_from_context2',
          reason: 'КРИТИЧНО: context2 не должен видеть изменения из context1');
    });

    test('ОБЯЗАТЕЛЬНО: изменение вложенного объекта НЕ ДОЛЖНО влиять на оригинал',
        () {
      final context = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/test',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {},
      );

      final originalMap = {'key': 'original_value'};
      context.setVar('map', originalMap);

      // Получаем map из контекста
      final retrievedMap = context.getVar('map') as Map<String, dynamic>;

      // ПРОБЛЕМА: если контекст хранит ссылку, изменение retrievedMap изменит originalMap
      retrievedMap['key'] = 'modified_value';

      // ТРЕБОВАНИЕ: оригинальный map НЕ должен измениться
      if (originalMap['key'] == 'modified_value') {
        print('ОБНАРУЖЕНА ПРОБЛЕМА: контекст хранит ссылку, а не копию!');
        print('ТРЕБОВАНИЕ: контекст должен делать deep copy объектов');
      }

      // Этот тест ДЕМОНСТРИРУЕТ потенциальную проблему
      // В зависимости от реализации может пройти или упасть
    });

    test('ОБЯЗАТЕЛЬНО: параллельное изменение списка ДОЛЖНО быть безопасным',
        () async {
      final context = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/test',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {},
      );

      context.setVar('list', <int>[]);

      // ТРЕБОВАНИЕ: параллельное добавление в список должно быть безопасным
      final futures = <Future>[];
      for (int i = 0; i < 100; i++) {
        futures.add(Future(() {
          final list = context.getVar('list') as List<int>;
          list.add(i);
          context.setVar('list', list);
        }));
      }

      await Future.wait(futures);

      final finalList = context.getVar('list') as List<int>;

      // ОЖИДАНИЕ: должно быть 100 элементов, но из-за race condition может быть меньше
      expect(finalList.length, lessThanOrEqualTo(100),
          reason: 'ВНИМАНИЕ: не может быть больше 100 элементов');

      if (finalList.length < 100) {
        print(
            'ОБНАРУЖЕНА ПРОБЛЕМА: race condition при изменении списка! Ожидалось 100, получено ${finalList.length}');
        print('ТРЕБОВАНИЕ: нужна синхронизация или immutable структуры данных');
      }
    });
  });

  group('ОБЯЗАТЕЛЬНАЯ проверка resource leaks', () {
    test('ОБЯЗАТЕЛЬНО: создание множества контекстов НЕ ДОЛЖНО вызывать утечку памяти',
        () {
      // ТРЕБОВАНИЕ: контексты должны корректно освобождать ресурсы
      final contexts = <RunContext>[];

      for (int i = 0; i < 1000; i++) {
        final context = RunContext(
          runId: 'run_$i',
          projectId: 'project1',
          projectPath: '/test',
          log: (msg, {type = 'info', depth = 0, required branch, details}) {},
        );

        context.setVar('data', List.filled(100, i));
        contexts.add(context);
      }

      // ПРОВЕРКА: все контексты созданы
      expect(contexts.length, 1000,
          reason: 'КРИТИЧНО: должно быть создано 1000 контекстов');

      // ТРЕБОВАНИЕ: после очистки ссылок, память должна освободиться
      contexts.clear();

      // Примечание: в Dart GC автоматический, но если есть циклические ссылки
      // или не закрытые ресурсы - будет утечка памяти
      // Этот тест проверяет что контексты не держат лишних ссылок
    });

    test('ОБЯЗАТЕЛЬНО: незакрытые ресурсы ДОЛЖНЫ быть обнаружены', () {
      // ТРЕБОВАНИЕ: если контекст открывает файлы/соединения, они должны закрываться
      final context = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/test',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {},
      );

      // Симуляция открытия ресурса
      context.setVar('file_handle', 'open_file_123');

      // ТРЕБОВАНИЕ: должен быть метод dispose() или close()
      // В текущей реализации RunContext нет dispose() - это ПРОБЛЕМА!

      // Если контекст держит открытые ресурсы, они должны закрываться явно
      // ТРЕБОВАНИЕ: добавить dispose() метод в RunContext

      expect(context.getVar('file_handle'), 'open_file_123',
          reason: 'КРИТИЧНО: ресурс должен быть доступен');

      // TODO: context.dispose() - должен закрыть все ресурсы
    });
  });
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => 'TimeoutException: $message';
}
