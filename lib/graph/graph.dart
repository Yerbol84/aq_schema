// Граф-домен пакета aq_schema.
// Импортируй этот файл чтобы получить доступ ко всем граф-типам.

// Core abstractions
export 'core/graph_def.dart';

// Graph models
export 'graphs/workflow_edge.dart';
export 'graphs/typed_workflow_graph.dart';
export 'graphs/instruction_graph.dart';
export 'graphs/typed_instruction_graph.dart';
export 'graphs/prompt_graph.dart';
export 'graphs/typed_prompt_graph.dart';
export 'graphs/contract_schema.dart';

// Engine primitives (pure Dart, no Flutter)
export 'engine/run_context.dart';
export 'engine/i_hand.dart';
export 'engine/tool_registry.dart';
export 'engine/i_graph_engine_client.dart';
export 'engine/i_run_state_manager.dart';
export 'engine/i_run_repository.dart';
export 'engine/i_graph_repository.dart';
export 'engine/condition_evaluator.dart';
export 'engine/state_strategies/state_strategies.dart';

// Node state capability interfaces
export 'nodes/state/state.dart';

// Logging
export 'logging/workflow_event_logger.dart';

// Validation
export 'validation/graph_contract_validator.dart';
export 'validation/graph_validator.dart';
// Transport
export 'transport/messages/run_event.dart';
export 'transport/messages/run_request.dart';
export 'transport/messages/run_status.dart';
export 'transport/messages/run_state.dart';
export 'transport/messages/user_input_response.dart';
export 'transport/interfaces/i_engine_transport.dart';
