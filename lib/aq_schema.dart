/// aq_schema — Core JSON schemas, Dart models, validators and abstract interfaces.
///
/// This is the single source of truth for the MCP Dart Ecosystem.
/// All other packages (aq_mcp_core, aq_queue, aq_auth, aq_mcp_adapter, aq_worker)
/// depend ONLY on this package — never on each other except through this.
///
/// Domains:
///   mcp/    — MCP protocol types (tools, requests, responses, errors)
///   worker/ — Worker protocol types (jobs, results, registration, health)
///   queue/  — Queue abstractions (job status, JobQueue, WorkerRegistry interfaces)
///   auth/   — Auth types (token payload, context, result, provider interface)
///   http/   — HTTP protocol (responses, errors, validation) for all services
library aq_schema;

// ── HTTP Protocol (для всех сервисов) ────────────────────────
export 'http/responses/error_response.dart';
export 'http/responses/validation_field_error.dart';
export 'http/error_codes.dart';
export 'http/validation/field_type.dart';
export 'http/validation/request_schema.dart';

// ── MCP domain ────────────────────────────────────────────

export 'worker/models/worker_models.dart';
export 'worker/models/worker_validation_result.dart';
export 'mcp/models/mcp_capabilities.dart';
export 'mcp/models/mcp_error.dart';
export 'mcp/models/mcp_request.dart';
export 'mcp/models/mcp_tool.dart';
export 'mcp/validators/mcp_validator.dart';
export 'auth/models/auth_context.dart';
export 'auth/i_auth_client.dart';
export 'auth/test_auth_client.dart';
export 'worker/validators/worker_validator.dart';
export 'queue/models/queue_job_status.dart';
export 'queue/job_queue.dart';
export 'queue/roles/job_consumer.dart';
export 'queue/roles/job_worker_client.dart';

export 'graph/graph.dart';
export 'graph/graphs/workflow/i_workflow_run.dart';
export 'graph/transport/messages/run_state.dart';
export 'graph/transport/messages/run_status.dart';
export 'graph/engine/workflow_run.dart';
export 'studio_project/aq_studio_project.dart';
export 'data_layer/models/query/vault_query.dart';
export 'data_layer/models/query/vault_sort.dart';
export 'data_layer/models/query/vault_operator.dart';
export 'data_layer/models/query/vault_index.dart';
export 'data_layer/models/query/vault_filter.dart';
export 'data_layer/models/query/page_result.dart';
export 'data_layer/models/field_diff.dart';
export 'data_layer/models/increment_type.dart';
export 'data_layer/models/log_entry.dart';
export 'data_layer/models/log_operation.dart';
export 'data_layer/models/semver.dart';
export 'data_layer/models/version_node.dart';
export 'data_layer/models/version_status.dart';
export 'data_layer/storable/artifact_entry.dart';
export 'data_layer/storable/stored_artifact.dart';
export 'data_layer/storable/document_annotation.dart';
export 'data_layer/storage/artifact_storage.dart';
export 'data_layer/storable/direct_storable.dart';
export 'data_layer/storable/logged_storable.dart';
export 'data_layer/storable/sharable.dart';
export 'data_layer/storable/versionable.dart';
export 'data_layer/storable/sql_query_translator.dart';
export 'data_layer/storable/storable.dart';
export 'data_layer/storage/vault_storage.dart';
export 'data_layer/storage/proxy_storage.dart';
export 'data_layer/storage/vector_storage.dart';
export 'data_layer/storable/versioned_storable.dart';
export 'data_layer/aq_domains.dart';
export 'data_layer/storage/buffered_storage.dart';
// Transport layer — typed commands and queries
export 'data_layer/transport/i_vault_command.dart';
export 'data_layer/transport/i_vault_query.dart';
export 'data_layer/transport/versioned_commands.dart';
export 'data_layer/transport/logged_commands.dart';

// Data Layer Client Protocol
export 'data_layer/i_data_layer.dart';

// Repository Interfaces
export 'data_layer/repositories/direct_repository.dart';
export 'data_layer/repositories/versioned_repository.dart';
export 'data_layer/repositories/logged_repository.dart';
export 'data_layer/repositories/i_artifact_repository.dart';
export 'data_layer/repositories/i_vector_repository.dart';
export 'data_layer/repositories/i_knowledge_repository.dart';

// Storable — extended
export 'data_layer/storable/vector_storable.dart';
export 'data_layer/storable/knowledge_document.dart';

// API Contracts (Single Source of Truth for HTTP routes)
export 'core/interfaces/i_aq_api_contract.dart';
export 'core/models/route_spec.dart';
export 'data_layer/api_contract/vault_api_contract.dart';
export 'data_layer/api_contract/vault_api_route_builder.dart';

// Security & RBAC
export 'security/security.dart';
export 'security/models/api_key_claims.dart';
export 'security/interfaces/clients_protocols/i_auth_context.dart';

// Cache domain
export 'cache/cache.dart';

// Test domains (for migration testing)
export 'test/test_document.dart';
export 'sandbox/interfaces/i_fs_context.dart';

// ── Vector layer models ───────────────────────────────────────
export 'data_layer/vector/chunk_span.dart';
export 'data_layer/vector/pipeline_stamp.dart';
export 'data_layer/vector/extracted_content.dart';
export 'data_layer/vector/content_chunk.dart';
export 'data_layer/vector/vector_point_payload.dart';
export 'data_layer/vector/indexing_result.dart';

// ── Pipeline interfaces ───────────────────────────────────────
export 'data_layer/pipeline/i_content_extractor.dart';
export 'data_layer/pipeline/i_modality_transformer.dart';
export 'data_layer/pipeline/i_chunker.dart';
export 'data_layer/pipeline/i_embeddings_client.dart';
export 'data_layer/pipeline/i_reranker.dart';
export 'data_layer/pipeline/i_vector_store_registry.dart';
export 'data_layer/pipeline/indexing_pipeline.dart';

// ── Vector storable records ───────────────────────────────────
export 'data_layer/storable/indexing_pipeline_record.dart';
export 'data_layer/storable/vector_store_record.dart';
