// pkgs/aq_schema/lib/security/interfaces/clients_protocols/noop_vault_security_protocol.dart
//
// NoOp реализация IVaultSecurityProtocol.
// Всё разрешено, ничего не проверяется.
//
// Используется по умолчанию когда security не инициализирован.

import 'package:aq_schema/aq_schema.dart';

/// NoOp реализация IVaultSecurityProtocol.
///
/// **Поведение:** Все операции разрешены, ничего не проверяется.
///
/// **Использование:**
/// - Development mode
/// - Тестирование без security
/// - Когда security не требуется
///
/// ```dart
/// void main() {
///   // Инициализировать NoOp (всё разрешено)
///   IVaultSecurityProtocol.initialize(NoOpVaultSecurityProtocol());
///
///   runApp(MyApp());
/// }
/// ```
final class NoOpVaultSecurityProtocol implements IVaultSecurityProtocol {
  const NoOpVaultSecurityProtocol();

  @override
  Future<AqTokenClaims?> extractClaims(Map<String, String> headers) async {
    // Возвращаем анонимный claims
    return AqTokenClaims(
      sub: 'anonymous',
      email: 'anonymous@example.com',
      roles: const ['user'],
      scopes: const ['*'],
      iat: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      exp: DateTime.now().add(Duration(days: 365)).millisecondsSinceEpoch ~/
          1000,
      tid: 'system',
      type: TokenType.access,
      jti: '',
      sid: '',
    );
  }

  @override
  Future<AccessDecision> canRead({
    required AqTokenClaims? claims,
    required String collection,
    String? entityId,
  }) async {
    // Всё разрешено
    return AccessDecision.allow(reason: 'NoOp: all access allowed');
  }

  @override
  Future<AccessDecision> canWrite({
    required AqTokenClaims? claims,
    required String collection,
    String? entityId,
    required Map<String, dynamic> data,
  }) async {
    // Всё разрешено
    return AccessDecision.allow(reason: 'NoOp: all access allowed');
  }

  @override
  Future<AccessDecision> canDelete({
    required AqTokenClaims? claims,
    required String collection,
    required String entityId,
  }) async {
    // Всё разрешено
    return AccessDecision.allow(reason: 'NoOp: all access allowed');
  }

  @override
  Future<AccessDecision> canPublish({
    required AqTokenClaims? claims,
    required String collection,
    required String entityId,
  }) async {
    // Всё разрешено
    return AccessDecision.allow(reason: 'NoOp: all access allowed');
  }

  @override
  Future<AccessDecision> canGrant({
    required AqTokenClaims? claims,
    required String collection,
    required String entityId,
    required String targetUserId,
    required AccessLevel level,
  }) async {
    // Всё разрешено
    return AccessDecision.allow(reason: 'NoOp: all access allowed');
  }

  @override
  Future<bool> checkRateLimit({
    required AqTokenClaims? claims,
    required String operation,
    String? ip,
  }) async {
    // Лимитов нет
    return true;
  }

  @override
  Future<List<ValidationFieldError>> validateData({
    required String collection,
    required Map<String, dynamic> data,
  }) async {
    // Всё валидно
    return [];
  }

  @override
  Future<Map<String, dynamic>> encryptSensitiveFields({
    required AqTokenClaims? claims,
    required String collection,
    required Map<String, dynamic> data,
  }) async {
    // Не шифруем
    return data;
  }

  @override
  Future<Map<String, dynamic>> decryptSensitiveFields({
    required AqTokenClaims? claims,
    required String collection,
    required Map<String, dynamic> data,
  }) async {
    // Не расшифровываем
    return data;
  }

  @override
  Future<void> logOperation({
    required AqTokenClaims? claims,
    required String operation,
    required String collection,
    String? entityId,
    required bool success,
    String? errorMessage,
  }) async {
    // Ничего не логируем
  }

  @override
  // TODO: implement resourcePermissions
  IResourcePermissionService get resourcePermissions =>
      throw UnimplementedError();
}
