// Тесты для Transport Messages - сообщения для удалённого выполнения

import 'package:test/test.dart';
import 'package:aq_schema/graph/transport/messages/run_request.dart';
import 'package:aq_schema/graph/transport/messages/run_state.dart';
import 'package:aq_schema/graph/transport/messages/run_status.dart';
import 'package:aq_schema/graph/transport/messages/user_input_response.dart';

void main() {
  group('GraphRunRequest', () {
    test('should create new run request', () {
      final request = GraphRunRequest(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/path/to/project',
        blueprintId: 'blueprint1',
        initialVariables: {'var1': 'value1'},
      );

      expect(request.runId, 'run1');
      expect(request.projectId, 'project1');
      expect(request.projectPath, '/path/to/project');
      expect(request.blueprintId, 'blueprint1');
      expect(request.initialVariables, {'var1': 'value1'});
      expect(request.isResume, false);
    });

    test('should create resume request', () {
      final request = GraphRunRequest(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/path/to/project',
        blueprintId: 'blueprint1',
        resumeStateJson: '{"x": 10}',
        resumeFromNodeId: 'node123',
      );

      expect(request.isResume, true);
      expect(request.resumeStateJson, '{"x": 10}');
      expect(request.resumeFromNodeId, 'node123');
    });

    test('should serialize to json', () {
      final request = GraphRunRequest(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/path/to/project',
        blueprintId: 'blueprint1',
        initialVariables: {'x': 10, 'y': 20},
      );

      final json = request.toJson();

      expect(json['runId'], 'run1');
      expect(json['projectId'], 'project1');
      expect(json['projectPath'], '/path/to/project');
      expect(json['blueprintId'], 'blueprint1');
      expect(json['initialVariables'], {'x': 10, 'y': 20});
    });

    test('should deserialize from json', () {
      final json = {
        'runId': 'run1',
        'projectId': 'project1',
        'projectPath': '/path/to/project',
        'blueprintId': 'blueprint1',
        'initialVariables': {'var1': 'value1'},
      };

      final request = GraphRunRequest.fromJson(json);

      expect(request.runId, 'run1');
      expect(request.projectId, 'project1');
      expect(request.initialVariables, {'var1': 'value1'});
    });

    test('should handle round-trip serialization', () {
      final original = GraphRunRequest(
        runId: 'run1',
        projectId: 'project1',
        projectPath: '/path/to/project',
        blueprintId: 'blueprint1',
        initialVariables: {'x': 10},
        resumeStateJson: '{"saved": "state"}',
        resumeFromNodeId: 'node123',
      );

      final json = original.toJson();
      final restored = GraphRunRequest.fromJson(json);

      expect(restored.runId, original.runId);
      expect(restored.projectId, original.projectId);
      expect(restored.blueprintId, original.blueprintId);
      expect(restored.isResume, original.isResume);
      expect(restored.resumeStateJson, original.resumeStateJson);
      expect(restored.resumeFromNodeId, original.resumeFromNodeId);
    });
  });

  group('GraphRunState', () {
    test('should create new run state', () {
      final state = GraphRunState(
        runId: 'run1',
        blueprintId: 'blueprint1',
        projectId: 'project1',
        status: GraphRunStatus.running,
        currentNodeId: 'node1',
        variables: {'x': 10},
        startedAt: DateTime(2026, 4, 9, 10, 0),
      );

      expect(state.runId, 'run1');
      expect(state.blueprintId, 'blueprint1');
      expect(state.projectId, 'project1');
      expect(state.status, GraphRunStatus.running);
      expect(state.currentNodeId, 'node1');
      expect(state.variables, {'x': 10});
      expect(state.id, 'run1');
    });

    test('should serialize to json', () {
      final state = GraphRunState(
        runId: 'run1',
        blueprintId: 'blueprint1',
        projectId: 'project1',
        status: GraphRunStatus.running,
        currentNodeId: 'node1',
        variables: {'x': 10, 'y': 20},
        startedAt: DateTime(2026, 4, 9, 10, 0),
      );

      final json = state.toJson();

      expect(json['runId'], 'run1');
      expect(json['status'], 'running');
      expect(json['variables'], {'x': 10, 'y': 20});
    });

    test('should copyWith new status', () {
      final state = GraphRunState(
        runId: 'run1',
        blueprintId: 'blueprint1',
        projectId: 'project1',
        status: GraphRunStatus.running,
        startedAt: DateTime(2026, 4, 9, 10, 0),
      );

      final updated = state.copyWith(status: GraphRunStatus.completed);

      expect(updated.status, GraphRunStatus.completed);
      expect(updated.runId, state.runId);
    });
  });

  group('UserInputResponse', () {
    test('should create user input response', () {
      final response = UserInputResponse(
        runId: 'run1',
        nodeId: 'node1',
        values: {'input': 'user text'},
      );

      expect(response.runId, 'run1');
      expect(response.nodeId, 'node1');
      expect(response.values, {'input': 'user text'});
      expect(response.approved, true);
    });

    test('should serialize to json', () {
      final response = UserInputResponse(
        runId: 'run1',
        nodeId: 'node1',
        values: {'x': 10, 'y': 20},
        approved: false,
      );

      final json = response.toJson();

      expect(json['runId'], 'run1');
      expect(json['nodeId'], 'node1');
      expect(json['values'], {'x': 10, 'y': 20});
      expect(json['approved'], false);
    });

    test('should deserialize from json', () {
      final json = <String, dynamic>{
        'runId': 'run1',
        'nodeId': 'node1',
        'values': <String, dynamic>{'input': 'text'},
        'approved': true,
      };

      final response = UserInputResponse.fromJson(json);

      expect(response.runId, 'run1');
      expect(response.nodeId, 'node1');
      expect(response.values, {'input': 'text'});
      expect(response.approved, true);
    });
  });
}
