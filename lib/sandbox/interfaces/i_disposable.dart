abstract interface class IDisposable {
  Future<void> dispose();
  bool get isDisposed;
}
