import 'package:aq_schema/aq_schema.dart';
import 'package:test/test.dart';

void main() {
  group('SandboxPolicy', () {
    test('permits returns true when in both lists', () {
      final policy = SandboxPolicy(
        available: ['fs.read', 'llm'],
        allowed: ['fs.read', 'llm'],
      );
      expect(policy.permits('fs.read'), isTrue);
      expect(policy.permits('llm'), isTrue);
    });

    test('permits returns false when not in available', () {
      final policy = SandboxPolicy(
        available: ['fs.read'],
        allowed: ['fs.read', 'llm'],
      );
      expect(policy.permits('llm'), isFalse);
    });

    test('permits returns false when not in allowed', () {
      final policy = SandboxPolicy(
        available: ['fs.read', 'llm'],
        allowed: ['fs.read'],
      );
      expect(policy.permits('llm'), isFalse);
    });

    test('permits returns false when dryRun', () {
      final policy = SandboxPolicy(
        available: SandboxCapabilities.all,
        allowed: SandboxCapabilities.all,
        dryRun: true,
      );
      expect(policy.permits('fs.read'), isFalse);
      expect(policy.permits('llm'), isFalse);
    });

    test('intersectWith restricts to parent', () {
      final child = SandboxPolicy(
        available: SandboxCapabilities.all,
        allowed: SandboxCapabilities.all,
      );
      final parent = SandboxPolicy(
        available: ['fs.read', 'llm'],
        allowed: ['fs.read'],
      );
      final effective = child.intersectWith(parent);
      expect(effective.available, containsAll(['fs.read', 'llm']));
      expect(effective.available, isNot(contains('fs.write')));
      expect(effective.allowed, equals(['fs.read']));
    });

    test('intersectWith: dryRun propagates from parent', () {
      final child = SandboxPolicy(
        available: SandboxCapabilities.all,
        allowed: SandboxCapabilities.all,
      );
      final parent = SandboxPolicy(
        available: SandboxCapabilities.all,
        allowed: SandboxCapabilities.all,
        dryRun: true,
      );
      final effective = child.intersectWith(parent);
      expect(effective.dryRun, isTrue);
    });

    test('toJson / fromJson roundtrip', () {
      final policy = SandboxPolicy.forWorkflow;
      final json = policy.toJson();
      final restored = SandboxPolicy.fromJson(json);
      expect(restored.available, equals(policy.available));
      expect(restored.allowed, equals(policy.allowed));
      expect(restored.dryRun, equals(policy.dryRun));
    });

    test('resolveFilePath with sessionDir', () {
      final policy = SandboxPolicy.testLab(runId: 'test123');
      expect(
        policy.resolveFilePath('/some/path/doc.docx'),
        equals('/tmp/aq_sandbox/test123/doc.docx'),
      );
    });

    test('resolveFilePath without sessionDir returns original', () {
      expect(
        SandboxPolicy.unrestricted.resolveFilePath('/some/path/doc.docx'),
        equals('/some/path/doc.docx'),
      );
    });
  });

  group('SandboxCapabilities', () {
    test('all contains all capability keys', () {
      expect(SandboxCapabilities.all, contains(SandboxCapabilities.fsRead));
      expect(SandboxCapabilities.all, contains(SandboxCapabilities.fsWrite));
      expect(SandboxCapabilities.all, contains(SandboxCapabilities.llm));
      expect(SandboxCapabilities.all, contains(SandboxCapabilities.mcp));
    });
  });
}
