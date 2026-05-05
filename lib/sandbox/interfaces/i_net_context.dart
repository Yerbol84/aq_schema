// aq_schema/lib/sandbox/interfaces/i_net_context.dart

import 'i_disposable.dart';

/// Сетевой доступ (фильтрованный).
abstract interface class INetContext implements IDisposable {
  Future<HttpResponse> get(String url, {Map<String, String>? headers});
  Future<HttpResponse> post(String url,
      {Object? body, Map<String, String>? headers});

  /// SSE streaming POST — эмитит строки по мере получения.
  Stream<String> postStream(String url,
      {Object? body, Map<String, String>? headers});
}

final class HttpResponse {
  final int statusCode;
  final Map<String, String> headers;
  final String body;
  const HttpResponse(this.statusCode, this.headers, this.body);
}
