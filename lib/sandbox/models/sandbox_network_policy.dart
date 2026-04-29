// aq_schema/lib/sandbox/models/sandbox_network_policy.dart

final class SandboxNetworkPolicy {
  final List<String> allowedHosts;
  const SandboxNetworkPolicy(this.allowedHosts);
  factory SandboxNetworkPolicy.none() => const SandboxNetworkPolicy([]);
  factory SandboxNetworkPolicy.all() => const SandboxNetworkPolicy(['*']);
  factory SandboxNetworkPolicy.whitelist(List<String> hosts) =>
      SandboxNetworkPolicy(hosts);
}
