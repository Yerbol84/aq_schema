// pkgs/aq_schema/lib/app.dart
//
// Набор: Application Context платформы AQ.
//
// ── Что здесь ────────────────────────────────────────────────────────────────
//
//   IAQApp           — корневой синглтон (IAQApp.init / IAQApp.instance)
//   IAQServerApp     — базовый тип серверного приложения
//   IAQResourceApp   — защищённый ресурс-сервер (auth + metrics автоматически)
//   IAQClientApp     — базовый тип клиентского приложения
//   IAQFlutterApp    — Flutter UI приложение
//   IAQCLIApp        — CLI инструмент
//
//   IMiddlewareCapable — capability: поддерживает middleware pipeline
//   IMetricsCapable    — capability: поддерживает метрики
//   IAuthCapable       — capability: требует auth защиту
//
// ── Использование ────────────────────────────────────────────────────────────
//
//   import 'package:aq_schema/app.dart';
//
//   // Серверный воркер:
//   IAQApp.init(MyResourceServerApp());
//
//   // Flutter:
//   IAQApp.init(MyFlutterApp());
//
//   // Проверка типа в сервисе:
//   if (IAQApp.instance is IAuthCapable && IAQApp.instance is IMiddlewareCapable) {
//     AqMiddlewareRegistry.register(authMiddleware, name: 'auth', ...);
//   }

export 'app/i_aq_app.dart';
