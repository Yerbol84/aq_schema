// pkgs/aq_schema/lib/security/interfaces/i_session_repository.dart

import '../models/aq_session.dart';
import '../models/aq_api_key.dart';
import '../models/aq_tenant.dart';

abstract interface class ISessionRepository {
  Future<AqSession?> findById(String id);
  Future<AqSession> create(AqSession session);
  Future<AqSession> update(AqSession session);
  Future<void> touch(String sessionId, int lastSeenAt);
  Future<void> revoke(String sessionId, String reason);
  Future<void> revokeAllForUser(String userId);
  Future<List<AqSession>> listActiveByUser(String userId);

  /// Used on startup: purge expired sessions.
  Future<int> purgeExpired();
}

abstract interface class IApiKeyRepository {
  Future<AqApiKey?> findByHash(String keyHash);
  Future<AqApiKey?> findById(String id);
  Future<AqApiKey> create(AqApiKey apiKey);
  Future<void> revoke(String id);
  Future<void> updateLastUsed(String id, int timestamp);
  Future<List<AqApiKey>> listByUser(String userId);
}

abstract interface class ITenantRepository {
  Future<AqTenant?> findById(String id);
  Future<AqTenant?> findBySlug(String slug);
  Future<AqTenant> create(AqTenant tenant);
  Future<AqTenant> update(AqTenant tenant);
  Future<List<AqTenant>> list();
}
