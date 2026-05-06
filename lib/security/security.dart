// pkgs/aq_schema/lib/security/security.dart
// AQ Security domain — barrel export.

// ── Models ────────────────────────────────────────────────────────────────────
export 'models/aq_tenant.dart';
export 'models/aq_user.dart';
export 'models/aq_profile.dart';
export 'models/aq_role.dart';
export 'models/aq_session.dart';
export 'models/security_mode.dart';
export 'models/aq_token_claims.dart';
export 'models/credentials.dart'
    show
        Credentials,
        GoogleOAuthCredentials,
        EmailPasswordCredentials,
        ApiKeyCredentials,
        ServiceTokenCredentials;
export 'models/aq_scope.dart';
export 'models/aq_revoked_token.dart';
export 'models/aq_resource_permission.dart';
export 'models/aq_policy.dart';
export 'models/aq_api_key.dart'
    show
        AqApiKey,
        AuthRequest,
        ApiAuthResponse,
        ValidateTokenRequest,
        ValidateTokenResponse,
        SecurityError;
export 'models/aq_access_log.dart';
export 'models/aq_audit_trail.dart';

// ── RBAC Models (новые) ───────────────────────────────────────────────────────
export 'models/access_decision.dart';
export 'models/access_context.dart';
export 'models/aq_permission.dart';
export 'models/rbac_metrics.dart';
export 'models/access_alert.dart';

// ── Repository interfaces ─────────────────────────────────────────────────────
export 'interfaces/i_user_repository.dart';
export 'interfaces/i_session_repository.dart';

// ── Service interfaces (для UI пакетов) ───────────────────────────────────────
export 'interfaces/i_security_service.dart';
export 'interfaces/i_mfa_service.dart';
export 'interfaces/i_auth_transport.dart';
export 'interfaces/i_session_store.dart';
export 'interfaces/i_role_management_service.dart';
export 'interfaces/i_policy_service.dart';
export 'interfaces/i_audit_service.dart';
export 'interfaces/i_resource_permission_service.dart';

// ── Data Layer Security Protocol ──────────────────────────────────────────────
export 'interfaces/clients_protocols/i_vault_security_protocol.dart';
export 'interfaces/clients_protocols/i_auth_context.dart';

// ── Shared token logic (pure Dart) ────────────────────────────────────────────
export 'token/token_codec.dart';
export 'token/token_validator.dart';

// ── Storable wrappers ─────────────────────────────────────────────────────────
export 'storable/security_storables.dart';

// ── Domain descriptors (для VaultRegistry на сервере) ─────────────────────────
export 'storable/security_domains.dart';

// ── Mock implementations (ТОЛЬКО для тестов!) ─────────────────────────────────
export 'mock/mock.dart';
export 'interfaces/clients_protocols/mocks/mock_vault_security_protocol.dart';
export 'interfaces/clients_protocols/mocks/test_tokens.dart';
export 'interfaces/clients_protocols/noop_vault_security_protocol.dart';
