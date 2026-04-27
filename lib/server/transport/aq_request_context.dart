// pkgs/aq_schema/lib/server/transport/aq_request_context.dart
//
// Контекст запроса — передаётся через цепочку middleware и в handler.
//
// ── Назначение ───────────────────────────────────────────────────────────────
//
// AqRequestContext — это контейнер который несёт запрос + накопленные данные
// через всю цепочку middleware. Каждый middleware может добавить атрибуты
// которые будут доступны следующим middleware и финальному handler.
//
// Это решает проблему передачи данных между middleware без глобального состояния:
//   - auth middleware добавляет 'user' атрибут
//   - следующий middleware читает 'user' и проверяет права
//   - handler читает 'user' и использует в бизнес-логике
//
// ── Сценарии использования ───────────────────────────────────────────────────
//
// СЦЕНАРИЙ 1: Auth middleware добавляет пользователя в контекст
//
//   AqMiddleware jwtMiddleware = (next) => (ctx) async {
//     final token = ctx.request.header('Authorization')?.replaceFirst('Bearer ', '');
//     if (token == null) return AqResponse.unauthorized();
//
//     final claims = await jwtService.verify(token);
//     if (claims == null) return AqResponse.unauthorized(error: 'invalid_token');
//
//     // Добавляем claims в контекст — следующие middleware и handler их увидят
//     return next(ctx.withAttribute('auth_claims', claims));
//   };
//
// СЦЕНАРИЙ 2: Handler читает атрибут добавленный middleware
//
//   AqHandler getMyProjects = (ctx) async {
//     final claims = ctx.attribute<AqApiKeyClaims>('auth_claims');
//     if (claims == null) return AqResponse.unauthorized();
//
//     final projects = await projectRepo.findByOwner(claims.userId);
//     return AqResponse.ok(body: projects.map((p) => p.toJson()).toList());
//   };
//
// СЦЕНАРИЙ 3: Logging middleware добавляет request ID
//
//   AqMiddleware requestIdMiddleware = (next) => (ctx) async {
//     final requestId = Uuid().v4();
//     final result = await next(ctx.withAttribute('request_id', requestId));
//     return result.withHeader('X-Request-Id', requestId);
//   };
//
// СЦЕНАРИЙ 4: Permission middleware читает claims и проверяет права
//
//   AqMiddleware requireAdmin = (next) => (ctx) async {
//     final claims = ctx.attribute<AqApiKeyClaims>('auth_claims');
//     if (claims == null) return AqResponse.unauthorized();
//     if (!claims.roles.contains('admin')) return AqResponse.forbidden();
//     return next(ctx);
//   };

import 'aq_request.dart';

/// Контекст запроса — иммутабельный контейнер для запроса и атрибутов.
///
/// Передаётся через всю цепочку middleware → handler.
/// Каждый [withAttribute] создаёт новый экземпляр (иммутабельность).
class AqRequestContext {
  /// Входящий запрос.
  final AqRequest request;

  /// Атрибуты накопленные middleware.
  /// Ключи — строки, значения — любые объекты.
  final Map<String, Object?> _attributes;

  AqRequestContext({
    required this.request,
    Map<String, Object?> attributes = const {},
  }) : _attributes = attributes;

  // ── Атрибуты ──────────────────────────────────────────────────────────────

  /// Получить атрибут по ключу с приведением типа.
  ///
  /// Возвращает null если атрибут не найден или тип не совпадает.
  T? attribute<T>(String key) {
    final value = _attributes[key];
    if (value is T) return value;
    return null;
  }

  /// Получить атрибут или бросить исключение если не найден.
  T requireAttribute<T>(String key) {
    final value = attribute<T>(key);
    if (value == null) {
      throw StateError(
        'Required attribute "$key" not found in request context. '
        'Make sure the middleware that sets this attribute is registered.',
      );
    }
    return value;
  }

  /// Проверить наличие атрибута.
  bool hasAttribute(String key) => _attributes.containsKey(key);

  /// Создать новый контекст с добавленным атрибутом.
  ///
  /// Не мутирует текущий контекст — возвращает новый экземпляр.
  AqRequestContext withAttribute(String key, Object? value) =>
      AqRequestContext(
        request: request,
        attributes: {..._attributes, key: value},
      );

  /// Создать новый контекст с несколькими атрибутами.
  AqRequestContext withAttributes(Map<String, Object?> attrs) =>
      AqRequestContext(
        request: request,
        attributes: {..._attributes, ...attrs},
      );

  // ── Удобные геттеры для стандартных атрибутов ─────────────────────────────

  /// Request ID (устанавливается logging/tracing middleware).
  String? get requestId => attribute<String>('request_id');

  @override
  String toString() =>
      'AqRequestContext(${request.method.name.toUpperCase()} ${request.path}, '
      'attrs: ${_attributes.keys.join(', ')})';
}
