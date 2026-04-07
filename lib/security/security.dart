// pkgs/aq_schema/lib/security/security.dart
// AQ Security domain — barrel export.

// ── Models ────────────────────────────────────────────────────────────────────
export 'models/aq_tenant.dart';
export 'models/aq_user.dart';
export 'models/aq_profile.dart';
export 'models/aq_role.dart';
export 'models/aq_session.dart';
export 'models/aq_token_claims.dart';
export 'models/aq_api_key.dart'
    show
        AqApiKey,
        AuthRequest,
        AuthResponse,
        ValidateTokenRequest,
        ValidateTokenResponse,
        SecurityError;

// ── Repository interfaces ─────────────────────────────────────────────────────
export 'interfaces/i_user_repository.dart';
export 'interfaces/i_session_repository.dart';

// ── Shared token logic (pure Dart) ────────────────────────────────────────────
export 'token/token_codec.dart';
export 'token/token_validator.dart';

// ── Storable wrappers ─────────────────────────────────────────────────────────
export 'storable/security_storables.dart';

// ── Domain descriptors (для VaultRegistry на сервере) ─────────────────────────
export 'storable/security_domains.dart';
