// aq_schema/lib/security/interfaces/i_mfa_service.dart
//
// Порт MFA механики.
// Реализация: aq_security/lib/src/server/mfa_service.dart
//
// Поток:
//   1. initiate(sessionId, userId) → MfaChallenge (secret + QR URI)
//   2. verify(sessionId, code)     → MfaVerifyResult (success/fail)
//   3. При success: SessionService.markMfaVerified(sessionId)

/// Метод MFA.
enum MfaMethod {
  totp, // Time-based One-Time Password (Google Authenticator, Authy)
}

/// Challenge — что отдать клиенту для прохождения MFA.
final class MfaChallenge {
  const MfaChallenge({
    required this.sessionId,
    required this.method,
    required this.totpUri,   // otpauth://totp/... для QR кода
    required this.expiresAt, // Unix seconds
  });

  final String sessionId;
  final MfaMethod method;

  /// otpauth URI для генерации QR кода.
  /// Формат: otpauth://totp/{issuer}:{email}?secret={base32}&issuer={issuer}
  final String totpUri;

  final int expiresAt;
}

/// Результат верификации MFA кода.
final class MfaVerifyResult {
  const MfaVerifyResult({required this.success, this.reason});

  final bool success;
  final String? reason; // причина при failure

  static const MfaVerifyResult ok = MfaVerifyResult(success: true);
  static MfaVerifyResult fail(String reason) =>
      MfaVerifyResult(success: false, reason: reason);
}

/// Порт MFA сервиса.
///
/// ## Использование
///
/// ```dart
/// // 1. Инициировать MFA challenge
/// final challenge = await mfaService.initiate(
///   sessionId: session.id,
///   userId: user.id,
///   userEmail: user.email,
/// );
/// // Отдать challenge.totpUri клиенту для показа QR кода
///
/// // 2. Клиент вводит код из приложения
/// final result = await mfaService.verify(
///   sessionId: session.id,
///   code: '123456',
/// );
///
/// if (result.success) {
///   await sessionService.markMfaVerified(session.id);
/// }
/// ```
abstract interface class IMfaService {
  /// Инициировать MFA challenge для сессии.
  ///
  /// Генерирует TOTP secret, сохраняет в pending store.
  /// Возвращает challenge с URI для QR кода.
  Future<MfaChallenge> initiate({
    required String sessionId,
    required String userId,
    required String userEmail,
  });

  /// Верифицировать код из приложения.
  ///
  /// Проверяет TOTP код против pending secret.
  /// При успехе — pending запись удаляется.
  Future<MfaVerifyResult> verify({
    required String sessionId,
    required String code,
  });

  /// Проверить есть ли активный pending challenge для сессии.
  Future<bool> hasPendingChallenge(String sessionId);

  /// Отменить pending challenge (например при logout).
  Future<void> cancel(String sessionId);
}
