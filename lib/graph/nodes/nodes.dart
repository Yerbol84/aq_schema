// Экспорт всех узлов графов

// Базовые интерфейсы
export 'base/i_workflow_node.dart';
export 'base/i_instruction_node.dart';
export 'base/i_prompt_node.dart';
export 'base/automatic_node.dart';
export 'base/interactive_node.dart';
export 'base/composite_node.dart';

// WorkflowGraph узлы - Automatic
export 'workflow/automatic/llm_action_node.dart';
export 'workflow/automatic/file_read_node.dart';
export 'workflow/automatic/file_write_node.dart';
export 'workflow/automatic/git_commit_node.dart';

// WorkflowGraph узлы - Interactive
export 'workflow/interactive/user_input_node.dart';
export 'workflow/interactive/manual_review_node.dart';
export 'workflow/interactive/file_upload_node.dart';
export 'workflow/interactive/co_creation_chat_node.dart';

// WorkflowGraph узлы - Composite
export 'workflow/composite/sub_graph_node.dart';
export 'workflow/composite/run_instruction_node.dart';

// InstructionGraph узлы
export 'instruction/tool_call_node.dart';
export 'instruction/llm_query_node.dart';
export 'instruction/condition_node.dart';
export 'instruction/transform_node.dart';

// PromptGraph узлы
export 'prompt/text_block_node.dart';
export 'prompt/variable_insert_node.dart';
export 'prompt/conditional_block_node.dart';
export 'prompt/file_context_node.dart';
