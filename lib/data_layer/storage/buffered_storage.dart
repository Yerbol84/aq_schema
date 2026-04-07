// pkgs/aq_schema/lib/data_layer/storage/buffered_storage.dart
//
// Интерфейс локального буфера записей.
// LocalBufferVaultStorage в dart_vault реализует этот интерфейс.
// Приложение получает Vault.instance.buffer и через него управляет буфером.
library;

import 'package:aq_schema/aq_schema.dart';

import 'vault_storage.dart';

// ══════════════════════════════════════════════════════════════════════════════
// VaultRecordState — состояние конкретной записи
// ══════════════════════════════════════════════════════════════════════════════

/// Состояние записи в буфере.
enum VaultRecordState {
  /// Запись получена из удалённого хранилища, локальных изменений нет.
  /// Хранится в буфере как кэш для быстрого доступа.
  synced,

  /// Запись есть в удалённом хранилище, но была изменена локально.
  /// Flush отправит изменения в удалённое хранилище.
  dirty,

  /// Запись существует только локально, в удалённом хранилище её нет.
  /// Flush создаст её в удалённом хранилище.
  localOnly,
}

// ══════════════════════════════════════════════════════════════════════════════
// IBufferedStorage — публичный интерфейс буфера
// ══════════════════════════════════════════════════════════════════════════════

/// Расширение [VaultStorage] с поддержкой локального рабочего буфера.
///
/// ## Принцип работы
///
/// Все записи читаются и пишутся через буфер (InMemoryVaultStorage).
/// Запись в удалённое хранилище происходит только по команде [flush].
///
/// Чтение: буфер → удалённое (с кэшированием в буфере как [VaultRecordState.synced]).
/// Запись: только в буфер, метка [VaultRecordState.dirty] или [localOnly].
/// Flush: dirty/localOnly → удалённое хранилище.
/// Discard: сбросить локальные изменения, восстановить из удалённого.
///
/// ## Состояние записи
///
/// Каждая запись в буфере несёт ключ [kStateKey] со значением из [VaultRecordState].
/// [VersionNode.fromMap] читает это поле и выставляет [VersionNode.localState].
/// Domain-модели (WorkflowGraph и т.д.) поле игнорируют — они не знают о нём.
///
/// ## Использование
///
/// ```dart
/// // Проверить есть ли несохранённые изменения
/// final unsaved = Vault.instance.buffer?.isDirty(WorkflowGraph.kCollection, graphId) ?? false;
///
/// // Сохранить в удалённую БД
/// await Vault.instance.buffer?.flush(WorkflowGraph.kCollection, id: graphId);
///
/// // Отбросить локальные изменения
/// await Vault.instance.buffer?.discard(WorkflowGraph.kCollection, id: graphId);
///
/// // Узнать оригинал до локальных изменений
/// final original = Vault.instance.buffer?.getOriginal(WorkflowGraph.kCollection, graphId);
/// ```
abstract interface class IBufferedStorage implements VaultStorage {
  /// Ключ, добавляемый в raw Map для передачи состояния.
  /// Значение — строка из [VaultRecordState.name].
  /// Используется [VersionNode.fromMap] и другими внутренними читателями.
  /// Domain-модели этот ключ игнорируют.
  static const kStateKey = '_ls';

  // ── Состояние ─────────────────────────────────────────────────────────────

  /// true если запись изменена или создана локально (dirty или localOnly).
  bool isDirty(String collection, String id);

  /// Состояние конкретной записи. null если записи нет в буфере.
  VaultRecordState? stateOf(String collection, String id);

  /// Все ID с несохранёнными изменениями в коллекции.
  Set<String> dirtyIds(String collection);

  /// Данные записи до локальных изменений.
  /// null если запись не менялась или была создана только локально.
  Map<String, dynamic>? getOriginal(String collection, String id);

  // ── Команды ───────────────────────────────────────────────────────────────

  /// Записать dirty/localOnly записи в удалённое хранилище.
  /// [id] = null → всю коллекцию.
  Future<void> flush(String collection, {String? id});

  /// Сбросить локальные изменения. Восстанавливает оригинал из удалённого.
  /// [id] = null → всю коллекцию.
  Future<void> discard(String collection, {String? id});

  /// Предзагрузить запись из удалённого хранилища в буфер.
  /// После warmup запись доступна мгновенно без обращения к сети.
  Future<void> warmup(String collection, String id);

  /// Предзагрузить несколько записей одним запросом.
  Future<void> warmupAll(String collection, {VaultQuery? query});
}
