// aq_schema/lib/sandbox/interfaces/i_sandbox_handle.dart

import '../../tools/models/tool_capability.dart';
import '../models/run_context.dart';
import '../models/sandbox_policy.dart';
import '../models/sandbox_runtime_type.dart';

/// Handle Sandbox — управление жизненным циклом.
abstract interface class ISandboxHandle {
  String get sandboxId;
  SandboxRuntimeType get sbRuntimeType;
  SandboxStatus get status;

  /// Создать RunContext с granted capabilities.
  Future<RunContext> createContext({
    required List<ToolCapability> requestedCaps,
    required SandboxPolicy policy,
    required String runId,
  });

  Future<void> suspend();
  Future<void> resume();
  Future<void> dispose({bool saveArtifacts = true});
}

enum SandboxStatus { creating, ready, running, suspended, disposing, disposed }
