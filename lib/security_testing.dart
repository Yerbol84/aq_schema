// aq_schema/lib/security_testing.dart
//
// Testing barrel для security слоя.
// Импортируй этот файл в тестах — получишь все моки и backend.
//
// Использование:
//   import 'package:aq_schema/security_testing.dart';
//
//   final backend = MockSecurityBackend.withAdmin();
//   final service  = MockSecurityService(backend);
//   final protocol = MockVaultSecurityProtocol(backend);
//   final context  = MockAuthContext(backend);

export 'security/mock/mock.dart';
