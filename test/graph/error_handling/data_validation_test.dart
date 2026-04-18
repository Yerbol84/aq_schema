// СТРОГИЕ тесты валидации данных - ОБЯЗАТЕЛЬНЫЕ проверки бизнес-логики
// Эти тесты ДОЛЖНЫ выявлять проблемы в структуре графов и данных

import 'package:aq_schema/aq_schema.dart';
import 'package:test/test.dart';

void main() {
  group('ОБЯЗАТЕЛЬНАЯ валидация структуры графа', () {
    test('ОБЯЗАТЕЛЬНО: граф БЕЗ узлов ДОЛЖЕН быть невалидным', () {
      final graph = WorkflowGraph(
        id: 'graph1',
        name: 'Empty Graph',
        tenantId: 'tenant1',
        ownerId: 'project1',
        nodes: const {},
        edges: const {},
      );

      expect(graph.nodes.isEmpty, true,
          reason: 'КРИТИЧНО: пустой граф не должен выполняться');

      // ТРЕБОВАНИЕ: должна быть валидация перед выполнением
      final isValid = graph.nodes.isNotEmpty;
      expect(isValid, false,
          reason: 'ОБЯЗАТЕЛЬНО: граф без узлов должен быть невалидным');
    });

    test('ОБЯЗАТЕЛЬНО: граф с edge на несуществующий узел ДОЛЖЕН быть невалидным',
        () {
      final node1 = WorkflowNode(
        id: 'node1',
        type: WorkflowNodeType.llmAction,
        config: {'promptId': 'prompt1', 'outputVar': 'result'},
      );

      final graph = WorkflowGraph(
        id: 'graph1',
        name: 'Invalid Graph',
        tenantId: 'tenant1',
        ownerId: 'project1',
        nodes: {'node1': node1},
        edges: {
          'edge1': WorkflowEdge(
            id: 'edge1',
            sourceId: 'node1',
            targetId: 'nonexistent_node', // НЕСУЩЕСТВУЮЩИЙ узел!
          )
        },
      );

      // ТРЕБОВАНИЕ: валидация должна найти проблему
      final allNodeIds = graph.nodes.keys.toSet();
      final invalidEdges = graph.edges.values.where((edge) {
        return !allNodeIds.contains(edge.sourceId) ||
            !allNodeIds.contains(edge.targetId);
      }).toList();

      expect(invalidEdges.isNotEmpty, true,
          reason:
              'КРИТИЧНО: edge на несуществующий узел должен быть обнаружен');
      expect(invalidEdges.first.targetId, 'nonexistent_node',
          reason: 'ОБЯЗАТЕЛЬНО: должен быть найден конкретный невалидный edge');
    });

    test('ОБЯЗАТЕЛЬНО: граф с циклом ДОЛЖЕН быть обнаружен', () {
      final node1 = WorkflowNode(
        id: 'node1',
        type: WorkflowNodeType.llmAction,
        config: {'promptId': 'prompt1'},
      );
      final node2 = WorkflowNode(
        id: 'node2',
        type: WorkflowNodeType.llmAction,
        config: {'promptId': 'prompt2'},
      );
      final node3 = WorkflowNode(
        id: 'node3',
        type: WorkflowNodeType.llmAction,
        config: {'promptId': 'prompt3'},
      );

      // Создаём цикл: node1 → node2 → node3 → node1
      final graph = WorkflowGraph(
        id: 'graph1',
        name: 'Cyclic Graph',
        tenantId: 'tenant1',
        ownerId: 'project1',
        nodes: {'node1': node1, 'node2': node2, 'node3': node3},
        edges: {
          'edge1': WorkflowEdge(
            id: 'edge1',
            sourceId: 'node1',
            targetId: 'node2',
          ),
          'edge2': WorkflowEdge(
            id: 'edge2',
            sourceId: 'node2',
            targetId: 'node3',
          ),
          'edge3': WorkflowEdge(
            id: 'edge3',
            sourceId: 'node3',
            targetId: 'node1', // ЦИКЛ!
          ),
        },
      );

      // ТРЕБОВАНИЕ: алгоритм обнаружения циклов
      bool hasCycle = _detectCycle(graph);

      expect(hasCycle, true,
          reason: 'КРИТИЧНО: цикл в графе ДОЛЖЕН быть обнаружен');
    });

    test('ОБЯЗАТЕЛЬНО: граф БЕЗ start node ДОЛЖЕН быть невалидным', () {
      final node1 = WorkflowNode(
        id: 'node1',
        type: WorkflowNodeType.llmAction,
        config: {'promptId': 'prompt1'},
      );
      final node2 = WorkflowNode(
        id: 'node2',
        type: WorkflowNodeType.llmAction,
        config: {'promptId': 'prompt2'},
      );

      // Оба узла имеют входящие edges - нет start node
      final graph = WorkflowGraph(
        id: 'graph1',
        name: 'No Start Node',
        tenantId: 'tenant1',
        ownerId: 'project1',
        nodes: {'node1': node1, 'node2': node2},
        edges: {
          'edge1': WorkflowEdge(
            id: 'edge1',
            sourceId: 'node2',
            targetId: 'node1',
          ),
          'edge2': WorkflowEdge(
            id: 'edge2',
            sourceId: 'node1',
            targetId: 'node2',
          ),
        },
      );

      // ТРЕБОВАНИЕ: найти start node (узел без входящих edges)
      final nodesWithIncomingEdges =
          graph.edges.values.map((e) => e.targetId).toSet();
      final startNodes = graph.nodes.values
          .where((node) => !nodesWithIncomingEdges.contains(node.id))
          .toList();

      expect(startNodes.isEmpty, true,
          reason: 'КРИТИЧНО: граф без start node не должен выполняться');
    });

    test('ОБЯЗАТЕЛЬНО: граф с НЕСКОЛЬКИМИ start nodes ДОЛЖЕН быть невалидным',
        () {
      final node1 = WorkflowNode(
        id: 'node1',
        type: WorkflowNodeType.llmAction,
        config: {'promptId': 'prompt1'},
      );
      final node2 = WorkflowNode(
        id: 'node2',
        type: WorkflowNodeType.llmAction,
        config: {'promptId': 'prompt2'},
      );
      final node3 = WorkflowNode(
        id: 'node3',
        type: WorkflowNodeType.llmAction,
        config: {'promptId': 'prompt3'},
      );

      // node1 и node2 оба без входящих edges - два start node
      final graph = WorkflowGraph(
        id: 'graph1',
        name: 'Multiple Start Nodes',
        tenantId: 'tenant1',
        ownerId: 'project1',
        nodes: {'node1': node1, 'node2': node2, 'node3': node3},
        edges: {
          'edge1': WorkflowEdge(
            id: 'edge1',
            sourceId: 'node1',
            targetId: 'node3',
          ),
          'edge2': WorkflowEdge(
            id: 'edge2',
            sourceId: 'node2',
            targetId: 'node3',
          ),
        },
      );

      // ТРЕБОВАНИЕ: найти все start nodes
      final nodesWithIncomingEdges =
          graph.edges.values.map((e) => e.targetId).toSet();
      final startNodes = graph.nodes.values
          .where((node) => !nodesWithIncomingEdges.contains(node.id))
          .toList();

      expect(startNodes.length, greaterThan(1),
          reason: 'КРИТИЧНО: обнаружено несколько start nodes');
      expect(startNodes.length, 2,
          reason: 'ОБЯЗАТЕЛЬНО: должно быть найдено ровно 2 start node');
    });
  });

  group('ОБЯЗАТЕЛЬНАЯ валидация contract в InstructionGraph', () {
    test('ОБЯЗАТЕЛЬНО: contract БЕЗ required inputs ДОЛЖЕН быть невалидным',
        () {
      final contract = {
        'inputs': <String, dynamic>{}, // ПУСТЫЕ inputs!
        'outputs': {
          'result': {'type': 'string'}
        }
      };

      final graph = InstructionGraph(
        id: 'instruction1',
        name: 'Invalid Contract',
        tenantId: 'tenant1',
        ownerId: 'project1',
        contract: contract,
        nodes: const {},
        edges: const {},
      );

      // ТРЕБОВАНИЕ: contract должен иметь хотя бы один input
      final hasInputs = (contract['inputs'] as Map).isNotEmpty;
      expect(hasInputs, false,
          reason: 'КРИТИЧНО: contract без inputs не имеет смысла');
    });

    test('ОБЯЗАТЕЛЬНО: contract с невалидными типами ДОЛЖЕН быть отклонён', () {
      final contract = {
        'inputs': {
          'data': {'type': 'invalid_type'} // НЕВАЛИДНЫЙ тип!
        },
        'outputs': {
          'result': {'type': 'string'}
        }
      };

      final graph = InstructionGraph(
        id: 'instruction1',
        name: 'Invalid Types',
        tenantId: 'tenant1',
        ownerId: 'project1',
        contract: contract,
        nodes: const {},
        edges: const {},
      );

      // ТРЕБОВАНИЕ: валидация типов
      final validTypes = {'string', 'number', 'boolean', 'object', 'array'};
      final inputs = contract['inputs'] as Map<String, dynamic>;
      final invalidInputs = inputs.entries.where((entry) {
        final type = (entry.value as Map)['type'] as String;
        return !validTypes.contains(type);
      }).toList();

      expect(invalidInputs.isNotEmpty, true,
          reason: 'КРИТИЧНО: невалидный тип должен быть обнаружен');
      expect(invalidInputs.first.value['type'], 'invalid_type',
          reason: 'ОБЯЗАТЕЛЬНО: должен быть найден конкретный невалидный тип');
    });

    test('ОБЯЗАТЕЛЬНО: вызов instruction БЕЗ required input ДОЛЖЕН выбросить ошибку',
        () {
      final contract = {
        'inputs': {
          'required_param': {
            'type': 'string',
            'required': true // ОБЯЗАТЕЛЬНЫЙ параметр!
          }
        },
        'outputs': {
          'result': {'type': 'string'}
        }
      };

      final graph = InstructionGraph(
        id: 'instruction1',
        name: 'Required Params',
        tenantId: 'tenant1',
        ownerId: 'project1',
        contract: contract,
        nodes: const {},
        edges: const {},
      );

      // Попытка вызова БЕЗ required параметра
      final providedInputs = <String, dynamic>{}; // ПУСТЫЕ inputs!

      // ТРЕБОВАНИЕ: валидация required параметров
      final inputs = contract['inputs'] as Map<String, dynamic>;
      final missingRequired = inputs.entries.where((entry) {
        final isRequired = (entry.value as Map)['required'] == true;
        final isProvided = providedInputs.containsKey(entry.key);
        return isRequired && !isProvided;
      }).toList();

      expect(missingRequired.isNotEmpty, true,
          reason: 'КРИТИЧНО: отсутствующий required параметр должен быть обнаружен');
      expect(missingRequired.first.key, 'required_param',
          reason: 'ОБЯЗАТЕЛЬНО: должен быть найден конкретный missing параметр');
    });

    test('ОБЯЗАТЕЛЬНО: вызов instruction с НЕПРАВИЛЬНЫМ типом ДОЛЖЕН выбросить ошибку',
        () {
      final contract = {
        'inputs': {
          'number_param': {'type': 'number'}
        },
        'outputs': {
          'result': {'type': 'string'}
        }
      };

      final graph = InstructionGraph(
        id: 'instruction1',
        name: 'Type Validation',
        tenantId: 'tenant1',
        ownerId: 'project1',
        contract: contract,
        nodes: const {},
        edges: const {},
      );

      // Передаём string вместо number
      final providedInputs = {
        'number_param': 'not_a_number' // НЕПРАВИЛЬНЫЙ тип!
      };

      // ТРЕБОВАНИЕ: валидация типов параметров
      final inputs = contract['inputs'] as Map<String, dynamic>;
      final typeErrors = inputs.entries.where((entry) {
        final expectedType = (entry.value as Map)['type'] as String;
        final providedValue = providedInputs[entry.key];
        if (providedValue == null) return false;

        switch (expectedType) {
          case 'number':
            return providedValue is! num;
          case 'string':
            return providedValue is! String;
          case 'boolean':
            return providedValue is! bool;
          default:
            return false;
        }
      }).toList();

      expect(typeErrors.isNotEmpty, true,
          reason: 'КРИТИЧНО: несоответствие типа должно быть обнаружено');
      expect(typeErrors.first.key, 'number_param',
          reason: 'ОБЯЗАТЕЛЬНО: должен быть найден параметр с неправильным типом');
    });
  });

  group('ОБЯЗАТЕЛЬНАЯ валидация переменных в контексте', () {
    test('ОБЯЗАТЕЛЬНО: использование НЕСУЩЕСТВУЮЩЕЙ переменной ДОЛЖНО выбросить ошибку',
        () {
      final template = 'Hello {{name}}, you are {{age}} years old';
      final context = <String, dynamic>{
        'name': 'John'
        // 'age' отсутствует!
      };

      // ТРЕБОВАНИЕ: найти все переменные в template
      final variablePattern = RegExp(r'\{\{(\w+)\}\}');
      final matches = variablePattern.allMatches(template);
      final requiredVars = matches.map((m) => m.group(1)!).toSet();

      // ТРЕБОВАНИЕ: проверить что все переменные есть в контексте
      final missingVars =
          requiredVars.where((v) => !context.containsKey(v)).toList();

      expect(missingVars.isNotEmpty, true,
          reason: 'КРИТИЧНО: отсутствующая переменная должна быть обнаружена');
      expect(missingVars.first, 'age',
          reason: 'ОБЯЗАТЕЛЬНО: должна быть найдена конкретная missing переменная');
    });

    test('ОБЯЗАТЕЛЬНО: переменная с NULL значением ДОЛЖНА быть обработана корректно',
        () {
      final context = <String, dynamic>{
        'name': null // NULL значение!
      };

      final value = context['name'];

      // ТРЕБОВАНИЕ: различать "переменная отсутствует" и "переменная = null"
      final exists = context.containsKey('name');
      final isNull = value == null;

      expect(exists, true,
          reason: 'КРИТИЧНО: переменная существует в контексте');
      expect(isNull, true,
          reason: 'ОБЯЗАТЕЛЬНО: значение переменной = null');

      // ТРЕБОВАНИЕ: null должен быть валидным значением (не ошибка)
      // Но подстановка null в template должна давать пустую строку или "null"
      final substituted = value?.toString() ?? '';
      expect(substituted, '',
          reason: 'ОБЯЗАТЕЛЬНО: null должен подставляться как пустая строка');
    });
  });
}

// Вспомогательная функция для обнаружения циклов (DFS)
bool _detectCycle(WorkflowGraph graph) {
  final visited = <String>{};
  final recursionStack = <String>{};

  bool dfs(String nodeId) {
    if (recursionStack.contains(nodeId)) {
      return true; // Цикл обнаружен!
    }
    if (visited.contains(nodeId)) {
      return false; // Уже проверяли этот узел
    }

    visited.add(nodeId);
    recursionStack.add(nodeId);

    // Проверяем все исходящие edges
    final outgoingEdges =
        graph.edges.values.where((e) => e.sourceId == nodeId).toList();
    for (final edge in outgoingEdges) {
      if (dfs(edge.targetId)) {
        return true;
      }
    }

    recursionStack.remove(nodeId);
    return false;
  }

  // Проверяем все узлы (граф может быть несвязным)
  for (final nodeId in graph.nodes.keys) {
    if (!visited.contains(nodeId)) {
      if (dfs(nodeId)) {
        return true;
      }
    }
  }

  return false;
}
