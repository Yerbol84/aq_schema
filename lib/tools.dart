// pkgs/aq_schema/lib/tools.dart
//
// Набор: протокол сервиса инструментов.
//
// Импортируй этот файл чтобы получить доступ к контракту IToolService.
//
// Использование в движке:
//   import 'package:aq_schema/tools.dart';
//   // получаешь: IToolService, ToolCallResult, ToolDescriptor
//
// Реализация (в aq_tool_service):
//   import 'package:aq_schema/tools.dart';
//   class AQToolServiceImpl implements IToolService { ... }

export 'tools/i_tool_service.dart';
export 'tools/tool_call_result.dart';
export 'tools/tool_descriptor.dart';
