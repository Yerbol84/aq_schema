import 'i_vault_command.dart';
import 'i_vault_query.dart';

// ── Commands ──────────────────────────────────────────────────────────────────

final class RollbackToCommand implements IVaultCommand {
  final String entityId;
  final String entryId;
  final String actorId;
  const RollbackToCommand({
    required this.entityId,
    required this.entryId,
    required this.actorId,
  });

  @override
  String get commandName => 'rollbackTo';

  @override
  Map<String, dynamic> toArgs() => {
        'entityId': entityId,
        'entryId': entryId,
        'actorId': actorId,
      };
}

// ── Queries ───────────────────────────────────────────────────────────────────

final class GetHistoryQuery implements IVaultQuery {
  final String entityId;
  const GetHistoryQuery(this.entityId);

  @override
  String get queryName => 'getHistory';

  @override
  Map<String, dynamic> toArgs() => {'entityId': entityId};
}
