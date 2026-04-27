// pkgs/aq_schema/lib/server/transport/aq_request.dart
//
// Входящий HTTP запрос — транспортная сущность.
//
// ── Назначение ───────────────────────────────────────────────────────────────
//
// AqRequest — иммутабельное представление входящего HTTP запроса.
// Не зависит ни от Shelf, ни от dart:io, ни от любого другого HTTP фреймворка.
// Адаптер в реализации (ShelfAdapter) конвертирует нативный запрос в AqRequest.
//
// ── Сценарии использования ───────────────────────────────────────────────────
//
// СЦЕНАРИЙ 1: Чтение параметров в handler
//
//   AqHandler getUser = (ctx) async {
//     final id = ctx.request.pathParam('id');        // /users/:id
//     final page = ctx.request.queryParam('page');   // ?page=2
//     final auth = ctx.request.header('Authorization');
//     return AqResponse.ok(body: {'id': id});
//   };
//
// СЦЕНАРИЙ 2: Чтение тела запроса
//
//   AqHandler createProject = (ctx) async {
//     final body = await ctx.request.bodyAsJson();
//     final name = body['name'] as String;
//     return AqResponse.created(body: {'id': 'new-id', 'name': name});
//   };
//
// СЦЕНАРИЙ 3: В middleware — проверка заголовка
//
//   AqMiddleware authMiddleware = (next) => (ctx) async {
//     final token = ctx.request.header('Authorization')?.replaceFirst('Bearer ', '');
//     if (token == null) return AqResponse.unauthorized();
//     return next(ctx);
//   };

import 'dart:convert';

/// HTTP метод запроса.
enum AqHttpMethod { get, post, put, patch, delete, head, options }

/// Иммутабельное представление входящего HTTP запроса.
class AqRequest {
  /// HTTP метод.
  final AqHttpMethod method;

  /// Путь запроса без query string. Например: '/api/v1/runs/abc123'
  final String path;

  /// Path параметры извлечённые из шаблона маршрута.
  /// Для маршрута '/runs/:id' и пути '/runs/abc' → {'id': 'abc'}
  final Map<String, String> pathParams;

  /// Query параметры из URL. Для '?page=2&limit=10' → {'page': '2', 'limit': '10'}
  final Map<String, String> queryParams;

  /// HTTP заголовки (ключи в нижнем регистре для регистронезависимого поиска).
  final Map<String, String> headers;

  /// Сырое тело запроса в байтах.
  final List<int> _body;

  /// Кэш распарсенного JSON тела.
  Map<String, dynamic>? _cachedJson;

  AqRequest({
    required this.method,
    required this.path,
    this.pathParams = const {},
    this.queryParams = const {},
    this.headers = const {},
    List<int> body = const [],
  }) : _body = body;

  // ── Заголовки ─────────────────────────────────────────────────────────────

  /// Получить заголовок по имени (регистронезависимо).
  String? header(String name) => headers[name.toLowerCase()];

  /// Content-Type заголовок.
  String? get contentType => header('content-type');

  /// true если запрос содержит JSON тело.
  bool get isJson => contentType?.contains('application/json') ?? false;

  // ── Path / Query параметры ────────────────────────────────────────────────

  /// Получить path параметр. Бросает [ArgumentError] если не найден.
  String pathParam(String name) {
    final value = pathParams[name];
    if (value == null) throw ArgumentError('Path param "$name" not found');
    return value;
  }

  /// Получить path параметр или null.
  String? pathParamOrNull(String name) => pathParams[name];

  /// Получить query параметр или null.
  String? queryParam(String name) => queryParams[name];

  /// Получить query параметр или значение по умолчанию.
  String queryParamOr(String name, String defaultValue) =>
      queryParams[name] ?? defaultValue;

  // ── Тело запроса ──────────────────────────────────────────────────────────

  /// Прочитать тело как строку (UTF-8).
  String bodyAsString() => utf8.decode(_body);

  /// Прочитать тело как JSON Map.
  /// Кэшируется — повторный вызов возвращает тот же объект.
  Map<String, dynamic> bodyAsJson() {
    if (_cachedJson != null) return _cachedJson!;
    final str = bodyAsString();
    if (str.isEmpty) return {};
    try {
      _cachedJson = (jsonDecode(str) as Map).cast<String, dynamic>();
      return _cachedJson!;
    } catch (e) {
      throw FormatException('Invalid JSON body: $e');
    }
  }

  /// Прочитать тело как список JSON объектов.
  List<Map<String, dynamic>> bodyAsJsonList() {
    final str = bodyAsString();
    if (str.isEmpty) return [];
    try {
      final list = jsonDecode(str) as List;
      return list.map((e) => (e as Map).cast<String, dynamic>()).toList();
    } catch (e) {
      throw FormatException('Invalid JSON array body: $e');
    }
  }

  /// Сырые байты тела.
  List<int> get bodyBytes => List.unmodifiable(_body);

  @override
  String toString() =>
      'AqRequest(${method.name.toUpperCase()} $path)';
}
