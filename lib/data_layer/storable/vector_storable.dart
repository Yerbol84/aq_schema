import 'storable.dart';

/// Marker interface for vector storage.
/// Entities have an embedding vector and arbitrary metadata payload.
abstract interface class VectorStorable implements Storable {
  /// The embedding vector.
  List<double> get vector;

  /// Arbitrary metadata payload (source document ID, chunk index, text, etc.).
  Map<String, dynamic> get payload;
}
