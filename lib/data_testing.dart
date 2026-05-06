// aq_schema/lib/data_testing.dart
//
// Testing barrel для data layer.
// Импортируй этот файл в тестах — получишь все моки.
//
// Использование:
//   import 'package:aq_schema/data_testing.dart';
//
//   // Пустое состояние
//   MockDataLayer.register(MockDataBackend.empty());
//
//   // Предзагруженные данные
//   MockDataLayer.register(MockDataBackend.withData(
//     collection: WorkflowGraph.kCollection,
//     entities: [graph1, graph2],
//   ));
//
//   // IDataLayer.instance теперь работает без сервера
//   final repo = IDataLayer.instance.versioned<WorkflowGraph>(...);

export 'data_layer/mock/mock.dart';
