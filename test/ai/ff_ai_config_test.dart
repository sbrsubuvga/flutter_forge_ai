import 'package:flutter_test/flutter_test.dart';
import 'package:flutterforge_ai/flutterforge_ai.dart';

void main() {
  group('FFAiConfig', () {
    test('effectiveModel falls back to provider default', () {
      const FFAiConfig c = FFAiConfig(
        provider: FFAiProvider.anthropic,
        apiKey: 'k',
      );
      expect(c.effectiveModel, FFAiProvider.anthropic.defaultModel);
    });

    test('effectiveBaseUrl falls back to provider default', () {
      const FFAiConfig c = FFAiConfig(
        provider: FFAiProvider.openai,
        apiKey: 'k',
      );
      expect(c.effectiveBaseUrl, FFAiProvider.openai.defaultBaseUrl);
    });

    test('isConfigured reflects the api key', () {
      expect(
        const FFAiConfig(provider: FFAiProvider.anthropic, apiKey: '')
            .isConfigured,
        isFalse,
      );
      expect(
        const FFAiConfig(provider: FFAiProvider.anthropic, apiKey: 'k')
            .isConfigured,
        isTrue,
      );
      expect(
        const FFAiConfig(provider: FFAiProvider.anthropic, apiKey: '  ')
            .isConfigured,
        isFalse,
      );
    });

    test('copyWith replaces fields', () {
      const FFAiConfig base = FFAiConfig(
        provider: FFAiProvider.anthropic,
        apiKey: 'k',
      );
      final FFAiConfig c = base.copyWith(
        apiKey: 'new',
        temperature: 0.9,
        maxTokens: 256,
      );
      expect(c.apiKey, 'new');
      expect(c.temperature, 0.9);
      expect(c.maxTokens, 256);
      expect(c.provider, FFAiProvider.anthropic);
    });

    test('toJsonSansKey never contains the api key', () {
      const FFAiConfig c = FFAiConfig(
        provider: FFAiProvider.openai,
        apiKey: 'very-secret-key-123',
      );
      final Map<String, Object?> json = c.toJsonSansKey();
      expect(json.values.any((Object? v) => v.toString().contains('secret')),
          isFalse);
      expect(json['provider'], 'openai');
    });
  });

  group('FFAiProviderX', () {
    test('label and defaults are defined', () {
      for (final FFAiProvider p in FFAiProvider.values) {
        expect(p.label, isNotEmpty);
        expect(p.defaultModel, isNotEmpty);
        expect(p.defaultBaseUrl, startsWith('https://'));
      }
    });
  });
}
