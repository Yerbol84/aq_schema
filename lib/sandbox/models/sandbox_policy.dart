// aq_schema/lib/sandbox/models/sandbox_policy.dart

import '../../tools/models/tool_capability.dart';
import 'sandbox_disposal_spec.dart';
import 'sandbox_network_policy.dart';
import 'sandbox_resource_budget.dart';
import 'sandbox_runtime_type.dart';

/// Политика Sandbox — что разрешено.
final class SandboxPolicy {
  final bool forceAll;
  final SandboxRuntimeType? preferredRuntime;
  final SandboxResourceBudget budget;
  final SandboxNetworkPolicy? network;
  final SandboxDisposalSpec disposal;
  final List<ToolCapability> allowedCaps;
  final Set<String>? allowedBinaries;

  const SandboxPolicy({
    this.forceAll = false,
    this.preferredRuntime,
    required this.budget,
    this.network,
    required this.disposal,
    this.allowedCaps = const [],
    this.allowedBinaries,
  });

  factory SandboxPolicy.strict() => SandboxPolicy(
        forceAll: true,
        preferredRuntime: SandboxRuntimeType.docker,
        budget: SandboxResourceBudget.defaults(),
        network: SandboxNetworkPolicy.none(),
        disposal: SandboxDisposalSpec.cleanAlways(),
        allowedCaps: [],
      );

  factory SandboxPolicy.development() => SandboxPolicy(
        forceAll: false,
        preferredRuntime: SandboxRuntimeType.localFs,
        budget: SandboxResourceBudget.generous(),
        network: SandboxNetworkPolicy.all(),
        disposal: SandboxDisposalSpec.keepOnError(),
        allowedCaps: [
          FsReadCap('**'),
          FsWriteCap('**'),
          NetOutCap('*'),
        ],
        allowedBinaries: {'git', 'node', 'python3', 'dart'},
      );
}

// aq_schema/lib/sandbox/models/sandbox_spec.dart
