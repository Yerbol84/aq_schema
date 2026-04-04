// pkgs/aq_schema/lib/sandbox/interfaces/i_sandbox_as_chat.dart
//
// РОЛЬ: Изолированная среда для диалоговых взаимодействий.
//
// БИЗНЕС-СМЫСЛ: AI Builder, Co-Creation, Chat — это "разговор":
// есть история сообщений, системный контекст (кто ты, что умеешь),
// прикреплённые данные (файлы, артефакты), и непрерывный обмен
// запрос-ответ. История накапливается и влияет на следующие ответы.
//
// ПРИМЕРЫ В ПРОЕКТЕ:
//   BuilderSessionSandbox  — сессия AI Builder (ИИ строит проект)
//   CoCreationSandbox      — совместное создание с агентом
//   ChatSandbox            — обычный чат
//
// КЛЮЧЕВЫЕ СВОЙСТВА:
//   - history: иммутабельная история (List<ISandboxChatMessage>)
//   - context: системный промпт и настройки (ISandboxItem)
//   - attachments: прикреплённые файлы (List<ISandboxAttachment>)
//   - send(): отправить сообщение, получить ответ
//
// В ОТЛИЧИЕ ОТ PROCESS:
//   - Нет фиксированного "результата" — разговор продолжается
//   - Состояние = история. Она только растёт, не меняется
//   - Паттерн: запрос → ответ (не событийный цикл)

import 'i_sandbox.dart';
import 'i_sandbox_item.dart';

abstract interface class ISandboxAsChat implements ISandbox {
  List<ISandboxChatMessage> get history;
  ISandboxItem get context;
  List<ISandboxAttachment> get attachments;

  Future<ISandboxChatMessage> send(ISandboxChatMessage message);
  Future<void> attach(ISandboxAttachment attachment);
  Future<void> clearHistory();

  int get estimatedTokenCount;
}

// ── Chat sub-items ─────────────────────────────────────────────────────────

abstract interface class ISandboxChatMessage implements ISandboxItem {
  /// 'user'|'assistant'|'system'|'tool'
  String get role;
  String get content;
  int get timestamp;
}

abstract interface class ISandboxAttachment implements ISandboxItem {
  String get mimeType;
  String get name;
  int get sizeBytes;
}
