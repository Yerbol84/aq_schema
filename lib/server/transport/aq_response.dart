// pkgs/aq_schema/lib/server/transport/aq_response.dart
//
// Исходящий HTTP ответ — транспортная сущность.
//
// ── Назначение ───────────────────────────────────────────────────────────────
//
// AqResponse — иммутабельное представление HTTP ответа.
// Создаётся в handler или middleware, конвертируется адаптером
// в нативный ответ фреймворка (Shelf Response, dart:io HttpResponse и т.д.)
//
// ── Сценарии использования ───────────────────────────────────────────────────
//
// СЦЕНАРИЙ 1: Фабричные методы (предпочтительный способ)
//
//   return AqResponse.ok(body: {'runs': runs});
//   return AqResponse.created(body: {'id': newId});
//   return AqResponse.noContent();
//   return AqResponse.badRequest(error: 'name is required');
//   return AqResponse.unauthorized();
//   return AqResponse.forbidden(error: 'insufficient permissions');
//   return AqResponse.notFound(error: 'Run not found');
//   return AqResponse.internalError(error: 'Unexpected error');
//
// СЦЕНАРИЙ 2: С заголовками
//
//   return AqResponse.ok(
//     body: data,
//     headers: {'X-Request-Id': requestId},
//   );
//
// СЦЕНАРИЙ 3: Произвольный статус
//
//   return AqResponse(
//     statusCode: 429,
//     body: {'error': 'rate_limit_exceeded', 'retry_after': 60},
//     headers: {'Retry-After': '60'},
//   );
//
// СЦЕНАРИЙ 4: В middleware — добавить заголовок к ответу
//
//   AqMiddleware corsMiddleware = (next) => (ctx) async {
//     final response = await next(ctx);
//     return response.withHeader('Access-Control-Allow-Origin', '*');
//   };

import 'dart:convert';

/// Иммутабельное представление HTTP ответа.
class AqResponse {
  /// HTTP статус код.
  final int statusCode;

  /// Тело ответа в байтах.
  final List<int> _body;

  /// HTTP заголовки ответа.
  final Map<String, String> headers;

  AqResponse._({
    required this.statusCode,
    required List<int> body,
    Map<String, String>? headers,
  })  : _body = body,
        headers = {
          'content-type': 'application/json; charset=utf-8',
          ...?headers,
        };

  // ── Фабричные методы ──────────────────────────────────────────────────────

  /// 200 OK с JSON телом.
  factory AqResponse.ok({
    dynamic body,
    Map<String, String>? headers,
  }) =>
      AqResponse._(
        statusCode: 200,
        body: _encodeBody(body),
        headers: headers,
      );

  /// 201 Created с JSON телом.
  factory AqResponse.created({
    dynamic body,
    Map<String, String>? headers,
  }) =>
      AqResponse._(
        statusCode: 201,
        body: _encodeBody(body),
        headers: headers,
      );

  /// 204 No Content.
  factory AqResponse.noContent() =>
      AqResponse._(statusCode: 204, body: const []);

  /// 400 Bad Request.
  factory AqResponse.badRequest({
    String? error,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) =>
      AqResponse._(
        statusCode: 400,
        body: _encodeBody(body ?? {'error': error ?? 'bad_request'}),
        headers: headers,
      );

  /// 401 Unauthorized.
  factory AqResponse.unauthorized({
    String error = 'unauthorized',
    Map<String, String>? headers,
  }) =>
      AqResponse._(
        statusCode: 401,
        body: _encodeBody({'error': error}),
        headers: headers,
      );

  /// 403 Forbidden.
  factory AqResponse.forbidden({
    String error = 'forbidden',
    Map<String, String>? headers,
  }) =>
      AqResponse._(
        statusCode: 403,
        body: _encodeBody({'error': error}),
        headers: headers,
      );

  /// 404 Not Found.
  factory AqResponse.notFound({
    String? error,
    Map<String, String>? headers,
  }) =>
      AqResponse._(
        statusCode: 404,
        body: _encodeBody({'error': error ?? 'not_found'}),
        headers: headers,
      );

  /// 409 Conflict.
  factory AqResponse.conflict({
    String? error,
    Map<String, String>? headers,
  }) =>
      AqResponse._(
        statusCode: 409,
        body: _encodeBody({'error': error ?? 'conflict'}),
        headers: headers,
      );

  /// 422 Unprocessable Entity — ошибки валидации.
  factory AqResponse.unprocessable({
    required Map<String, dynamic> errors,
    Map<String, String>? headers,
  }) =>
      AqResponse._(
        statusCode: 422,
        body: _encodeBody({'errors': errors}),
        headers: headers,
      );

  /// 500 Internal Server Error.
  factory AqResponse.internalError({
    String error = 'internal_server_error',
    Map<String, String>? headers,
  }) =>
      AqResponse._(
        statusCode: 500,
        body: _encodeBody({'error': error}),
        headers: headers,
      );

  /// Произвольный ответ с байтовым телом (для файлов, бинарных данных).
  factory AqResponse.bytes({
    required int statusCode,
    required List<int> bytes,
    String contentType = 'application/octet-stream',
    Map<String, String>? headers,
  }) =>
      AqResponse._(
        statusCode: statusCode,
        body: bytes,
        headers: {'content-type': contentType, ...?headers},
      );

  // ── Мутирующие методы (возвращают новый экземпляр) ────────────────────────

  /// Вернуть новый ответ с добавленным заголовком.
  AqResponse withHeader(String name, String value) => AqResponse._(
        statusCode: statusCode,
        body: _body,
        headers: {...headers, name.toLowerCase(): value},
      );

  /// Вернуть новый ответ с добавленными заголовками.
  AqResponse withHeaders(Map<String, String> extra) => AqResponse._(
        statusCode: statusCode,
        body: _body,
        headers: {...headers, ...extra.map((k, v) => MapEntry(k.toLowerCase(), v))},
      );

  // ── Доступ к телу ─────────────────────────────────────────────────────────

  /// Тело ответа в байтах.
  List<int> get bodyBytes => List.unmodifiable(_body);

  /// Тело ответа как строка (UTF-8).
  String get bodyAsString => utf8.decode(_body);

  /// true если ответ успешный (2xx).
  bool get isSuccess => statusCode >= 200 && statusCode < 300;

  @override
  String toString() => 'AqResponse($statusCode)';

  // ── Внутренние утилиты ────────────────────────────────────────────────────

  static List<int> _encodeBody(dynamic body) {
    if (body == null) return const [];
    if (body is List<int>) return body;
    if (body is String) return utf8.encode(body);
    return utf8.encode(jsonEncode(body));
  }
}
