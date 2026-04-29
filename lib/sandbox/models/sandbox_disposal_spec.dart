// aq_schema/lib/sandbox/models/sandbox_disposal_spec.dart

final class SandboxDisposalSpec {
  final bool cleanup;
  final bool saveArtifacts;
  final String? vaultDestination;

  const SandboxDisposalSpec({
    required this.cleanup,
    this.saveArtifacts = false,
    this.vaultDestination,
  });

  factory SandboxDisposalSpec.cleanAlways() =>
      const SandboxDisposalSpec(cleanup: true);
  factory SandboxDisposalSpec.keepOnError() =>
      const SandboxDisposalSpec(cleanup: false);
  factory SandboxDisposalSpec.saveArtifacts({required String destination}) =>
      SandboxDisposalSpec(
        cleanup: true,
        saveArtifacts: true,
        vaultDestination: destination,
      );
}
