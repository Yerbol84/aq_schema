import 'i_hand.dart';

class ToolRegistry {
  final Map<String, IHand> _hands = {};

  /// Регистрация нового инструмента при старте приложения
  void register(IHand hand) {
    _hands[hand.id] = hand;
  }

  List<IHand> get registeredHands => _hands.values.toList();

  /// Получить инструмент по ID
  IHand? getHand(String id) => _hands[id];

  /// Получить список всех схем (для отправки в промпт LLM)
  List<Map<String, dynamic>> getAllSchemas() {
    return _hands.values.map((h) => h.toolSchema).toList();
  }

  /// Получить схемы только определенной категории (по префиксу, например 'fs_')
  List<Map<String, dynamic>> getSchemasByCategory(String prefix) {
    return _hands.values
        .where((h) => h.id.startsWith(prefix))
        .map((h) => h.toolSchema)
        .toList();
  }
}
