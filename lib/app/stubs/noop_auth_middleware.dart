import '../../server/routing/aq_handler.dart';
// pkgs/aq_schema/lib/app/stubs/noop_auth_middleware.dart
//
// Заглушка auth middleware — логирует что защита не активна.
//
// ── Назначение ───────────────────────────────────────────────────────────────
//
// Используется пока IResourceAuthClient не реализован в слое безопасности.
// Пропускает все запросы, но логирует предупреждение.
//
// ── Замена ───────────────────────────────────────────────────────────────────
//
// Когда слой безопасности будет готов:
//   IResourceAuthClient.init(JwtResourceClient(secret: jwtSecret));
//   // ↑ автоматически зарегистрирует реальный authMiddleware
//   // ↑ эта заглушка больше не нужна

/// Заглушка auth middleware.
///
/// Пропускает все запросы без проверки токена.
/// Логирует предупреждение при каждом запросе.
///
/// TODO: Заменить на реальный middleware от IResourceAuthClient.
final AqMiddleware noopAuthMiddleware = (next) => (ctx) async {
      // ignore: avoid_print
      print(
        '[STUB] Auth middleware: no token validation. '
        'TODO: init IResourceAuthClient to enable auth protection.',
      );
      return next(ctx);
    };

/// Зарегистрировать заглушку auth middleware в реестре.
///
/// Вызывается из main() пока реальный auth не подключён.
/// Когда IResourceAuthClient.init() будет вызван — он перезапишет эту запись.
void registerNoopAuthMiddleware() {
  // Импортируется в main() и регистрируется явно
  // чтобы в pipeline было видно что auth — заглушка
  print(
    '[STUB] Auth middleware registered as NOOP. '
    'All requests will pass without token validation.',
  );
}
