// pkgs/aq_schema/lib/sandbox/sandbox.dart

// Items & Schema
export 'interfaces/i_sandbox_item.dart';
export 'interfaces/i_sandbox_schema.dart';

// Roles
export 'interfaces/i_sandbox_context.dart'; // ← RunContext роль
export 'interfaces/i_sandbox_actor.dart'; // ← Runner роль

// Sandbox types (by interface hierarchy, not kind field)
export 'interfaces/i_sandbox.dart';
export 'interfaces/i_sandbox_as_function.dart';
export 'interfaces/i_sandbox_as_process.dart';
export 'interfaces/i_sandbox_as_chat.dart';
export 'interfaces/i_sandbox_as_environment.dart';

// Chat sub-items (из i_sandbox_as_chat.dart — re-export для удобства)
// ISandboxChatMessage, ISandboxAttachment

// Supporting
export 'interfaces/i_sandbox_registry.dart';
export 'interfaces/i_sandbox_event.dart';
export 'interfaces/i_sandbox_capable.dart';

// Policy
export 'policy/sandbox_capabilities.dart';
export 'policy/sandbox_policy.dart';
export 'policy/sandbox_policy_violation.dart';
