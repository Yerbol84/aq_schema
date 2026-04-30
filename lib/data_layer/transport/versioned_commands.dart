import 'package:aq_schema/aq_schema.dart';

import 'i_vault_command.dart';
import 'i_vault_query.dart';

// ── Commands ──────────────────────────────────────────────────────────────────

final class CreateEntityCommand implements IVaultCommand {
  final Map<String, dynamic> data;
  const CreateEntityCommand(this.data);

  @override
  String get commandName => 'put';

  @override
  Map<String, dynamic> toArgs() => {'data': data};
}

final class CreateDraftFromCommand implements IVaultCommand {
  final String parentNodeId;
  final Map<String, dynamic> data;
  const CreateDraftFromCommand({required this.parentNodeId, required this.data});

  @override
  String get commandName => 'createDraftFrom';

  @override
  Map<String, dynamic> toArgs() => {'parentNodeId': parentNodeId, 'data': data};
}

final class UpdateDraftCommand implements IVaultCommand {
  final String nodeId;
  final Map<String, dynamic> data;
  const UpdateDraftCommand({required this.nodeId, required this.data});

  @override
  String get commandName => 'updateDraft';

  @override
  Map<String, dynamic> toArgs() => {'nodeId': nodeId, 'data': data};
}

final class PublishDraftCommand implements IVaultCommand {
  final String nodeId;
  final IncrementType increment;
  const PublishDraftCommand({required this.nodeId, this.increment = IncrementType.patch});

  @override
  String get commandName => 'publishDraft';

  @override
  Map<String, dynamic> toArgs() => {'nodeId': nodeId, 'increment': increment.name};
}

final class SnapshotVersionCommand implements IVaultCommand {
  final String nodeId;
  const SnapshotVersionCommand(this.nodeId);

  @override
  String get commandName => 'snapshotVersion';

  @override
  Map<String, dynamic> toArgs() => {'nodeId': nodeId};
}

final class CreateBranchCommand implements IVaultCommand {
  final String parentNodeId;
  final String branchName;
  final Map<String, dynamic> data;
  const CreateBranchCommand({
    required this.parentNodeId,
    required this.branchName,
    required this.data,
  });

  @override
  String get commandName => 'createBranch';

  @override
  Map<String, dynamic> toArgs() => {
        'parentNodeId': parentNodeId,
        'branchName': branchName,
        'data': data,
      };
}

final class MergeToMainCommand implements IVaultCommand {
  final String entityId;
  final String sourceBranch;
  final String requesterId;
  const MergeToMainCommand({
    required this.entityId,
    required this.sourceBranch,
    required this.requesterId,
  });

  @override
  String get commandName => 'mergeToMain';

  @override
  Map<String, dynamic> toArgs() => {
        'entityId': entityId,
        'sourceBranch': sourceBranch,
        'requesterId': requesterId,
      };
}

final class SetCurrentVersionCommand implements IVaultCommand {
  final String entityId;
  final String nodeId;
  final String requesterId;
  const SetCurrentVersionCommand({
    required this.entityId,
    required this.nodeId,
    required this.requesterId,
  });

  @override
  String get commandName => 'setCurrentVersion';

  @override
  Map<String, dynamic> toArgs() => {
        'entityId': entityId,
        'nodeId': nodeId,
        'requesterId': requesterId,
      };
}

// ── Queries ───────────────────────────────────────────────────────────────────

final class GetVersionQuery implements IVaultQuery {
  final String nodeId;
  const GetVersionQuery(this.nodeId);

  @override
  String get queryName => 'getVersionNode';

  @override
  Map<String, dynamic> toArgs() => {'nodeId': nodeId};
}

final class ListVersionsQuery implements IVaultQuery {
  final String entityId;
  final VersionStatus? status;
  final String? branch;
  const ListVersionsQuery(this.entityId, {this.status, this.branch});

  @override
  String get queryName => 'listVersions';

  @override
  Map<String, dynamic> toArgs() => {
        'entityId': entityId,
        if (status != null) 'status': status!.name,
        if (branch != null) 'branch': branch,
      };
}

final class ListBranchesQuery implements IVaultQuery {
  final String entityId;
  const ListBranchesQuery(this.entityId);

  @override
  String get queryName => 'listBranches';

  @override
  Map<String, dynamic> toArgs() => {'entityId': entityId};
}
