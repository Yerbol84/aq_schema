import 'package:aq_schema/aq_schema.dart';

/// A single vector entry stored in a [VectorStorage] collection.
final class VectorEntry {
  /// Unique ID within the collection (maps back to a source document chunk).
  final String id;

  /// The embedding vector.
  final List<double> vector;

  /// Arbitrary metadata payload (source document ID, chunk index, text, etc.).
  final Map<String, dynamic> payload;

  const VectorEntry({
    required this.id,
    required this.vector,
    required this.payload,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'vector': vector,
        'payload': payload,
      };

  factory VectorEntry.fromMap(Map<String, dynamic> m) => VectorEntry(
        id: m['id'] as String,
        vector: ((m['vector'] as List?) ?? []).cast<double>(),
        payload: (m['payload'] as Map<String, dynamic>?) ?? {},
      );
}

/// Result of a vector similarity search.
final class VectorSearchResult {
  final String id;
  final double score; // cosine similarity in [0, 1]
  final Map<String, dynamic> payload;

  const VectorSearchResult({
    required this.id,
    required this.score,
    required this.payload,
  });

  @override
  String toString() =>
      'VectorSearchResult(id:$id score:${score.toStringAsFixed(4)})';
}

/// Backend interface for approximate-nearest-neighbour (ANN) vector search.
///
/// dart_vault keeps this separate from [VaultStorage] because vector databases
/// have fundamentally different query semantics (ANN, cosine distance, filters
/// on payload) that do not map cleanly to the key-value query DSL.
///
/// Implementations:
/// - [InMemoryVectorStorage]   — brute-force cosine search, no index (dev/test)
/// - `QdrantVectorStorage`     — Qdrant HTTP API (production, recommended)
/// - `PgVectorStorage`         — Supabase/pgvector via RPC (production)
///
/// ## Multi-tenancy
///
/// Pass a [tenantId]-prefixed collection name (handled by [KnowledgeVault]):
///   `alice__documents_vectors`
abstract interface class VectorStorage {
  // ── Collections ────────────────────────────────────────────────────────────

  /// Ensure the named collection exists with the given [vectorSize].
  /// The [distance] metric is backend-specific; pass `"cosine"` by default.
  Future<void> ensureCollection(
    String collection, {
    required int vectorSize,
    String distance = 'cosine',
  });

  Future<void> deleteCollection(String collection);

  // ── Write ──────────────────────────────────────────────────────────────────

  /// Insert or update a single vector entry.
  Future<void> upsert(String collection, VectorEntry entry);

  /// Batch upsert — more efficient than multiple [upsert] calls.
  Future<void> upsertAll(String collection, List<VectorEntry> entries);

  Future<void> delete(String collection, String id);

  /// Delete all entries whose payload matches [filter].
  Future<void> deleteWhere(String collection, VaultQuery filter);

  // ── Search ─────────────────────────────────────────────────────────────────

  /// ANN search: find the [limit] entries most similar to [queryVector].
  ///
  /// [filter] optionally restricts the search to entries whose payload
  /// satisfies the filter predicates (payload pushdown when supported).
  Future<List<VectorSearchResult>> search(
    String collection,
    List<double> queryVector, {
    int limit = 10,
    double scoreThreshold = 0.0,
    VaultQuery? filter,
  });

  // ── Read ───────────────────────────────────────────────────────────────────

  Future<VectorEntry?> getById(String collection, String id);
  Future<List<VectorEntry>> getAll(String collection, {VaultQuery? filter});
  Future<int> count(String collection, {VaultQuery? filter});

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  Future<void> dispose();
}
