// aq_schema/lib/sandbox/interfaces/i_net_context.dart

/// Сетевой доступ (фильтрованный).
abstract interface class INetContext {
  Future<HttpResponse> get(String url, {Map<String, String>? headers});
  Future<HttpResponse> post(String url,
      {Object? body, Map<String, String>? headers});
}

final class HttpResponse {
  final int statusCode;
  final Map<String, String> headers;
  final String body;
  const HttpResponse(this.statusCode, this.headers, this.body);
}
