// test/credentials_test.dart
//
// Unit тесты для системы Credentials

import 'package:test/test.dart';
import 'package:aq_schema/security/security.dart';

void main() {
  group('Credentials', () {
    group('GoogleOAuthCredentials', () {
      test('создание и сериализация', () {
        final creds = GoogleOAuthCredentials(
          code: 'test_code_123',
          redirectUri: 'http://localhost:3000/callback',
        );

        expect(creds.type, 'google_oauth');
        expect(creds.code, 'test_code_123');
        expect(creds.redirectUri, 'http://localhost:3000/callback');
      });

      test('toJson / fromJson', () {
        final original = GoogleOAuthCredentials(
          code: 'test_code',
          redirectUri: 'http://localhost/callback',
        );

        final json = original.toJson();
        final restored = Credentials.fromJson(json) as GoogleOAuthCredentials;

        expect(restored.type, original.type);
        expect(restored.code, original.code);
        expect(restored.redirectUri, original.redirectUri);
      });
    });

    group('EmailPasswordCredentials', () {
      test('создание и сериализация', () {
        final creds = EmailPasswordCredentials(
          email: 'test@example.com',
          password: 'secret123',
        );

        expect(creds.type, 'email_password');
        expect(creds.email, 'test@example.com');
        expect(creds.password, 'secret123');
      });

      test('toJson / fromJson', () {
        final original = EmailPasswordCredentials(
          email: 'user@test.com',
          password: 'pass123',
        );

        final json = original.toJson();
        final restored = Credentials.fromJson(json) as EmailPasswordCredentials;

        expect(restored.type, original.type);
        expect(restored.email, original.email);
        expect(restored.password, original.password);
      });
    });

    group('ApiKeyCredentials', () {
      test('создание и сериализация', () {
        final creds = ApiKeyCredentials(
          apiKey: 'aq_live_1234567890abcdef',
        );

        expect(creds.type, 'api_key');
        expect(creds.apiKey, 'aq_live_1234567890abcdef');
      });

      test('toJson / fromJson', () {
        final original = ApiKeyCredentials(
          apiKey: 'aq_test_abcdef123456',
        );

        final json = original.toJson();
        final restored = Credentials.fromJson(json) as ApiKeyCredentials;

        expect(restored.type, original.type);
        expect(restored.apiKey, original.apiKey);
      });
    });

    group('ServiceTokenCredentials', () {
      test('создание и сериализация', () {
        final creds = ServiceTokenCredentials(
          token: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
        );

        expect(creds.type, 'service_token');
        expect(creds.token, startsWith('eyJhbGciOiJIUzI1NiIs'));
      });

      test('toJson / fromJson', () {
        final original = ServiceTokenCredentials(
          token: 'test_token_123',
        );

        final json = original.toJson();
        final restored = Credentials.fromJson(json) as ServiceTokenCredentials;

        expect(restored.type, original.type);
        expect(restored.token, original.token);
      });
    });

    group('Полиморфная десериализация', () {
      test('определяет тип по discriminator', () {
        final googleJson = {
          'type': 'google_oauth',
          'code': 'code123',
          'redirectUri': 'http://localhost/callback',
        };

        final apiKeyJson = {
          'type': 'api_key',
          'apiKey': 'aq_live_123',
        };

        final googleCreds = Credentials.fromJson(googleJson);
        final apiKeyCreds = Credentials.fromJson(apiKeyJson);

        expect(googleCreds, isA<GoogleOAuthCredentials>());
        expect(apiKeyCreds, isA<ApiKeyCredentials>());
      });

      test('выбрасывает ошибку для неизвестного типа', () {
        final invalidJson = {
          'type': 'unknown_type',
          'data': 'test',
        };

        expect(
          () => Credentials.fromJson(invalidJson),
          throwsA(isA<Exception>()),
        );
      });
    });
  });

  group('AuthRequest', () {
    test('создание с Credentials', () {
      final creds = GoogleOAuthCredentials(
        code: 'test_code',
        redirectUri: 'http://localhost/callback',
      );

      final request = AuthRequest(credentials: creds);

      expect(request.credentials, isA<GoogleOAuthCredentials>());
      expect(request.credentials.type, 'google_oauth');
    });

    test('toJson / fromJson', () {
      final creds = ApiKeyCredentials(apiKey: 'aq_test_123');
      final original = AuthRequest(credentials: creds);

      final json = original.toJson();
      final restored = AuthRequest.fromJson(json);

      expect(restored.credentials, isA<ApiKeyCredentials>());
      expect(
        (restored.credentials as ApiKeyCredentials).apiKey,
        'aq_test_123',
      );
    });
  });
}
