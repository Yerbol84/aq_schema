import 'i_sandbox_item.dart';

/// Валидатор — проверяет ISandboxItem на соответствие схеме.
///
/// Реализации:
///   JsonSandboxSchema   — валидация через json_schema пакет
///   AnyAcceptSchema     — принимает всё (для unrestricted)
///   NullRejectSchema    — отклоняет всё (для isolated)
abstract interface class ISandboxSchema {
  /// Уникальный ID схемы (например: 'aq:instruction:input:v1')
  String get schemaId;

  /// Соответствует ли item этой схеме
  bool validate(ISandboxItem item);

  /// Список ошибок валидации. Пустой список = успех.
  List<String> errors(ISandboxItem item);
}
