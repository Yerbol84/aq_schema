// Тесты для WorkflowRun - модель состояния выполнения workflow

import 'package:test/test.dart';
import 'package:aq_schema/aq_schema.dart';

void main() {
  group('WorkflowRun - Creation', () {
    test('should create new run with required fields', () {
      final run = WorkflowRun(
        id: 'run1',
        projectId: 'project1',
        blueprintId: 'blueprint1',
        graphSnapshot: {'nodes': [], 'edges': []},
        status: WorkflowRunStatus.running,
        logsJson: '[]',
        createdAt: DateTime(2026, 4, 9),
      );

      expect(run.id, 'run1');
      expect(run.projectId, 'project1');
      expect(run.blueprintId, 'blueprint1');
      expect(run.status, WorkflowRunStatus.running);
      expect(run.logsJson, '[]');
      expect(run.createdAt, DateTime(2026, 4, 9));
    });

    test('should create run with optional fields', () {
      final run = WorkflowRun(
        id: 'run1',
        projectId: 'project1',
        blueprintId: 'blueprint1',
        graphSnapshot: {},
        status: WorkflowRunStatus.suspended,
        logsJson: '["log1", "log2"]',
        contextJson: '{"var1": "value1"}',
        suspendedNodeId: 'node123',
        createdAt: DateTime.now(),
      );

      expect(run.contextJson, '{"var1": "value1"}');
      expect(run.suspendedNodeId, 'node123');
    });
  });

  group('WorkflowRun - Status', () {
    test('should support all status values', () {
      expect(WorkflowRunStatus.running.value, 'running');
      expect(WorkflowRunStatus.suspended.value, 'suspended');
      expect(WorkflowRunStatus.completed.value, 'completed');
      expect(WorkflowRunStatus.failed.value, 'failed');
      expect(WorkflowRunStatus.cancelled.value, 'cancelled');
    });

    test('should parse status from string', () {
      expect(WorkflowRunStatus.fromString('running'), WorkflowRunStatus.running);
      expect(WorkflowRunStatus.fromString('suspended'), WorkflowRunStatus.suspended);
      expect(WorkflowRunStatus.fromString('completed'), WorkflowRunStatus.completed);
      expect(WorkflowRunStatus.fromString('failed'), WorkflowRunStatus.failed);
      expect(WorkflowRunStatus.fromString('cancelled'), WorkflowRunStatus.cancelled);
    });

    test('should default to running for unknown status', () {
      expect(WorkflowRunStatus.fromString('unknown'), WorkflowRunStatus.running);
    });
  });

  group('WorkflowRun - Serialization', () {
    test('should serialize to map', () {
      final run = WorkflowRun(
        id: 'run1',
        projectId: 'project1',
        blueprintId: 'blueprint1',
        graphSnapshot: {'nodes': [], 'edges': []},
        status: WorkflowRunStatus.running,
        logsJson: '["log1"]',
        contextJson: '{"x": 10}',
        suspendedNodeId: 'node1',
        createdAt: DateTime(2026, 4, 9, 10, 30),
      );

      final map = run.toMap();

      expect(map['id'], 'run1');
      expect(map['projectId'], 'project1');
      expect(map['blueprintId'], 'blueprint1');
      expect(map['graphSnapshot'], {'nodes': [], 'edges': []});
      expect(map['status'], 'running');
      expect(map['logsJson'], '["log1"]');
      expect(map['contextJson'], '{"x": 10}');
      expect(map['suspendedNodeId'], 'node1');
      expect(map['createdAt'], '2026-04-09T10:30:00.000');
    });

    test('should deserialize from map', () {
      final map = {
        'id': 'run1',
        'projectId': 'project1',
        'blueprintId': 'blueprint1',
        'graphSnapshot': {'nodes': [], 'edges': []},
        'status': 'completed',
        'logsJson': '["log1", "log2"]',
        'contextJson': '{"result": "success"}',
        'suspendedNodeId': null,
        'createdAt': '2026-04-09T10:30:00.000',
      };

      final run = WorkflowRun.fromMap(map);

      expect(run.id, 'run1');
      expect(run.projectId, 'project1');
      expect(run.blueprintId, 'blueprint1');
      expect(run.status, WorkflowRunStatus.completed);
      expect(run.logsJson, '["log1", "log2"]');
      expect(run.contextJson, '{"result": "success"}');
      expect(run.suspendedNodeId, null);
    });

    test('should handle round-trip serialization', () {
      final original = WorkflowRun(
        id: 'run1',
        projectId: 'project1',
        blueprintId: 'blueprint1',
        graphSnapshot: {'test': 'data'},
        status: WorkflowRunStatus.suspended,
        logsJson: '[]',
        contextJson: '{"var": "value"}',
        suspendedNodeId: 'node123',
        createdAt: DateTime(2026, 4, 9),
      );

      final map = original.toMap();
      final restored = WorkflowRun.fromMap(map);

      expect(restored.id, original.id);
      expect(restored.projectId, original.projectId);
      expect(restored.blueprintId, original.blueprintId);
      expect(restored.status, original.status);
      expect(restored.logsJson, original.logsJson);
      expect(restored.contextJson, original.contextJson);
      expect(restored.suspendedNodeId, original.suspendedNodeId);
    });
  });

  group('WorkflowRun - copyWith', () {
    test('should copy with new status', () {
      final run = WorkflowRun(
        id: 'run1',
        projectId: 'project1',
        blueprintId: 'blueprint1',
        graphSnapshot: {},
        status: WorkflowRunStatus.running,
        logsJson: '[]',
        createdAt: DateTime.now(),
      );

      final updated = run.copyWith(status: WorkflowRunStatus.completed);

      expect(updated.status, WorkflowRunStatus.completed);
      expect(updated.id, run.id);
      expect(updated.projectId, run.projectId);
    });

    test('should copy with new logs', () {
      final run = WorkflowRun(
        id: 'run1',
        projectId: 'project1',
        blueprintId: 'blueprint1',
        graphSnapshot: {},
        status: WorkflowRunStatus.running,
        logsJson: '["log1"]',
        createdAt: DateTime.now(),
      );

      final updated = run.copyWith(logsJson: '["log1", "log2", "log3"]');

      expect(updated.logsJson, '["log1", "log2", "log3"]');
    });

    test('should copy with suspended state', () {
      final run = WorkflowRun(
        id: 'run1',
        projectId: 'project1',
        blueprintId: 'blueprint1',
        graphSnapshot: {},
        status: WorkflowRunStatus.running,
        logsJson: '[]',
        createdAt: DateTime.now(),
      );

      final updated = run.copyWith(
        status: WorkflowRunStatus.suspended,
        suspendedNodeId: 'node123',
        contextJson: '{"saved": "state"}',
      );

      expect(updated.status, WorkflowRunStatus.suspended);
      expect(updated.suspendedNodeId, 'node123');
      expect(updated.contextJson, '{"saved": "state"}');
    });
  });

  group('WorkflowRun - Storable Interface', () {
    test('should return correct collection name', () {
      final run = WorkflowRun(
        id: 'run1',
        projectId: 'project1',
        blueprintId: 'blueprint1',
        graphSnapshot: {},
        status: WorkflowRunStatus.running,
        logsJson: '[]',
        createdAt: DateTime.now(),
      );

      expect(run.collectionName, 'workflow_runs');
    });

    test('should return index fields', () {
      final run = WorkflowRun(
        id: 'run1',
        projectId: 'project1',
        blueprintId: 'blueprint1',
        graphSnapshot: {},
        status: WorkflowRunStatus.completed,
        logsJson: '[]',
        createdAt: DateTime(2026, 4, 9, 10, 30),
      );

      final indexFields = run.indexFields;

      expect(indexFields['projectId'], 'project1');
      expect(indexFields['blueprintId'], 'blueprint1');
      expect(indexFields['status'], 'completed');
      expect(indexFields['createdAt'], '2026-04-09T10:30:00.000');
    });

    test('should return json schema', () {
      final run = WorkflowRun(
        id: 'run1',
        projectId: 'project1',
        blueprintId: 'blueprint1',
        graphSnapshot: {},
        status: WorkflowRunStatus.running,
        logsJson: '[]',
        createdAt: DateTime.now(),
      );

      final schema = run.jsonSchema;

      expect(schema['type'], 'object');
      expect(schema['properties'], isA<Map>());
      expect(schema['required'], contains('id'));
      expect(schema['required'], contains('projectId'));
      expect(schema['required'], contains('blueprintId'));
    });
  });

  group('WorkflowRun - LoggedStorable Interface', () {
    test('should track specific fields', () {
      final run = WorkflowRun(
        id: 'run1',
        projectId: 'project1',
        blueprintId: 'blueprint1',
        graphSnapshot: {},
        status: WorkflowRunStatus.running,
        logsJson: '[]',
        createdAt: DateTime.now(),
      );

      final trackedFields = run.trackedFields;

      expect(trackedFields, contains('status'));
      expect(trackedFields, contains('logsJson'));
      expect(trackedFields, contains('contextJson'));
      expect(trackedFields, contains('suspendedNodeId'));
    });
  });

  group('WorkflowRun - Real-world Scenarios', () {
    test('should track workflow lifecycle', () {
      // Create
      var run = WorkflowRun(
        id: 'run1',
        projectId: 'project1',
        blueprintId: 'blueprint1',
        graphSnapshot: {'nodes': [], 'edges': []},
        status: WorkflowRunStatus.running,
        logsJson: '["Started"]',
        createdAt: DateTime.now(),
      );

      expect(run.status, WorkflowRunStatus.running);

      // Suspend
      run = run.copyWith(
        status: WorkflowRunStatus.suspended,
        suspendedNodeId: 'user_input_node',
        logsJson: '["Started", "Suspended at user_input_node"]',
      );

      expect(run.status, WorkflowRunStatus.suspended);
      expect(run.suspendedNodeId, 'user_input_node');

      // Resume
      run = run.copyWith(
        status: WorkflowRunStatus.running,
        logsJson: '["Started", "Suspended at user_input_node", "Resumed"]',
      );

      expect(run.status, WorkflowRunStatus.running);

      // Complete
      run = run.copyWith(
        status: WorkflowRunStatus.completed,
        logsJson: '["Started", "Suspended at user_input_node", "Resumed", "Completed"]',
      );

      expect(run.status, WorkflowRunStatus.completed);
    });

    test('should handle failure scenario', () {
      var run = WorkflowRun(
        id: 'run1',
        projectId: 'project1',
        blueprintId: 'blueprint1',
        graphSnapshot: {},
        status: WorkflowRunStatus.running,
        logsJson: '["Started"]',
        createdAt: DateTime.now(),
      );

      // Fail
      run = run.copyWith(
        status: WorkflowRunStatus.failed,
        logsJson: '["Started", "Error: Node execution failed"]',
      );

      expect(run.status, WorkflowRunStatus.failed);
    });
  });
}
