import 'package:flutter_test/flutter_test.dart';
import 'package:flutterforge_ai/flutterforge_ai.dart';

void main() {
  group('FFConfig', () {
    test('defaults() uses safe defaults', () {
      final FFConfig c = FFConfig.defaults();
      expect(c.appName, 'MyApp');
      expect(c.enableDevTools, true);
      expect(c.maxLogsStored, FFConstants.defaultMaxLogs);
      expect(c.sensitiveHeaders, contains('authorization'));
    });

    test('production() disables everything observable', () {
      final FFConfig c = FFConfig.production(appName: 'X');
      expect(c.enableDevTools, false);
      expect(c.enableAiDebugButton, false);
      expect(c.enableShakeToOpen, false);
      expect(c.enablePrettyDioLogger, false);
    });

    test('copyWith overrides individual fields', () {
      final FFConfig c = FFConfig.defaults().copyWith(
        appName: 'Override',
        dbName: 'alt.db',
      );
      expect(c.appName, 'Override');
      expect(c.dbName, 'alt.db');
      // Unchanged fields retained.
      expect(c.enableDevTools, true);
    });
  });
}
