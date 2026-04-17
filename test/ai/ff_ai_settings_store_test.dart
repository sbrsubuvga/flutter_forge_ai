import 'package:flutter_test/flutter_test.dart';
import 'package:flutterforge_ai/flutterforge_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FFAiSettingsStore', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test('returns an unconfigured default when nothing stored', () async {
      final FFAiSettingsStore store = await FFAiSettingsStore.load();
      final FFAiConfig c = store.read();
      expect(c.isConfigured, isFalse);
      expect(c.provider, FFAiProvider.anthropic);
      expect(c.apiKey, '');
    });

    test('round-trips a written config', () async {
      final FFAiSettingsStore store = await FFAiSettingsStore.load();
      await store.write(
        const FFAiConfig(
          provider: FFAiProvider.openai,
          apiKey: 'sk-xyz',
          model: 'gpt-4o',
          temperature: 0.7,
          maxTokens: 512,
        ),
      );
      final FFAiConfig read = store.read();
      expect(read.provider, FFAiProvider.openai);
      expect(read.apiKey, 'sk-xyz');
      expect(read.model, 'gpt-4o');
      expect(read.temperature, 0.7);
      expect(read.maxTokens, 512);
    });

    test('clear removes everything', () async {
      final FFAiSettingsStore store = await FFAiSettingsStore.load();
      await store.write(
        const FFAiConfig(
          provider: FFAiProvider.anthropic,
          apiKey: 'sk-ant-live',
        ),
      );
      await store.clear();
      final FFAiConfig read = store.read();
      expect(read.isConfigured, isFalse);
      expect(read.apiKey, '');
    });
  });
}
