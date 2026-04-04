/// A single page of query results with pagination metadata.
final class PageResult<T> {
  /// Items on this page.
  final List<T> items;

  /// Total number of records matching the query (across all pages).
  final int total;

  /// The offset used to produce this page.
  final int offset;

  /// The limit used to produce this page.
  final int limit;

  const PageResult({
    required this.items,
    required this.total,
    required this.offset,
    required this.limit,
  });

  /// Whether there is a next page available.
  bool get hasMore => offset + items.length < total;

  /// Current page number (1-based).
  int get page => limit > 0 ? (offset ~/ limit) + 1 : 1;

  /// Total number of pages.
  int get totalPages => limit > 0 ? (total / limit).ceil() : 1;

  PageResult<R> map<R>(R Function(T) convert) => PageResult(
        items: items.map(convert).toList(),
        total: total,
        offset: offset,
        limit: limit,
      );

  @override
  String toString() =>
      'PageResult(page=$page/$totalPages, items=${items.length}, total=$total)';
}
