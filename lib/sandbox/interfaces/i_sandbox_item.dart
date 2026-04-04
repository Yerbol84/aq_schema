/// Корневой тип для всех данных проходящих через sandbox.
///
/// Всё что входит, выходит или хранится внутри sandbox —
/// реализует этот интерфейс. Никаких голых Map<String, dynamic>.
///
/// Конкретные sub-интерфейсы:
///   ISandboxChatMessage   — сообщение в чат-sandbox
///   ISandboxAttachment    — вложение
///   ISandboxEvent         — событие потока
abstract interface class ISandboxItem {
  /// Уникальный ID этого элемента данных
  String get itemId;

  /// Дискриминатор типа — строка-токен.
  /// Примеры: 'chat_message' | 'file_attachment' | 'sandbox_event'
  String get itemType;
}
