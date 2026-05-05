// aq_schema/lib/security/models/security_mode.dart
//
// Два режима работы security layer.
// Выбирается при инициализации через AqSecurity.init().

/// Режим работы security layer.
///
/// ## Mode A: embedded
/// Security и data layer в одном процессе.
/// IVaultSecurityProtocol проверяет права in-process (< 1ms).
/// Используется в Flutter-приложениях и монолитных серверах.
///
/// ## Mode B: distributed
/// Security как отдельный HTTP сервис.
/// Data layer вызывает introspection endpoint для каждого запроса.
/// Используется в микросервисной архитектуре.
enum SecurityMode {
  /// Security и data layer в одном процессе.
  embedded,

  /// Security как отдельный HTTP сервис.
  distributed,
}
