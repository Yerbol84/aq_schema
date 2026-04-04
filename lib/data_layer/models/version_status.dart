/// Lifecycle state of a [VersionNode].
///
/// Allowed transitions:
///   draft → published  (via publishDraft)
///   published → snapshot (via snapshotVersion)
///   any → deleted      (via deleteVersion)
enum VersionStatus {
  draft,
  published,
  snapshot,
  deleted;

  static VersionStatus fromString(String s) =>
      VersionStatus.values.firstWhere(
        (v) => v.name == s,
        orElse: () => VersionStatus.draft,
      );

  bool get isDraft => this == draft;
  bool get isPublished => this == published;
  bool get isSnapshot => this == snapshot;
  bool get isDeleted => this == deleted;
  bool get isEditable => this == draft;
}
