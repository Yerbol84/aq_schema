/// Marker interface for storage implementations that act as proxies to remote servers.
///
/// When a repository detects that its storage implements [ProxyStorage], it should:
/// - Send operations to the base collection name (e.g., 'workflow_graphs')
/// - NOT use internal collection suffixes (e.g., '__nodes', '__meta')
/// - Let the remote server handle storage implementation details
///
/// This allows repositories to work seamlessly with both:
/// - Local storage (InMemory, IndexedDB) - uses internal collections
/// - Remote storage (HTTP, gRPC) - delegates to server
///
/// Example:
/// ```dart
/// if (storage is ProxyStorage) {
///   // Remote: single request to base collection
///   await storage.put('workflow_graphs', id, data);
/// } else {
///   // Local: multiple requests to internal collections
///   await storage.put('workflow_graphs__nodes', nodeId, nodeData);
///   await storage.put('workflow_graphs__meta', entityId, metaData);
/// }
/// ```
abstract interface class ProxyStorage {
  // Marker interface - no methods needed
}
