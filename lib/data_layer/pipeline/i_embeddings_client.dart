abstract interface class IEmbeddingsClient {
  String get id;
  String get version;
  int get dimensions;
  String get defaultMetric;

  Future<List<double>> embed(String text);
  Future<List<List<double>>> embedBatch(List<String> texts);
}
