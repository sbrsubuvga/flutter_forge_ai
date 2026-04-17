import 'package:flutter_test/flutter_test.dart';
import 'package:flutterforge_ai/flutterforge_ai.dart';

void main() {
  group('FFLogger', () {
    tearDown(() async => FFLogger.reset());

    test('throws before init', () {
      expect(() => FFLogger.store, throwsStateError);
    });

    test('captures info/debug/warning/error/fatal to store', () {
      final FFLogStore store = FFLogStore(maxSize: 10);
      FFLogger.init(store: store);
      FFLogger.info('i');
      FFLogger.debug('d');
      FFLogger.warning('w');
      FFLogger.error('e', error: Exception('x'));
      FFLogger.fatal('f');
      expect(store.length, 5);
      expect(store.getByLevel(FFLogLevel.info).single.message, 'i');
      expect(store.getErrors().map((FFLogEntry e) => e.message),
          containsAll(<String>['e', 'f']));
    });

    test('respects minLogLevel filter', () {
      final FFLogStore store = FFLogStore(maxSize: 10);
      FFLogger.init(store: store, minLevel: FFLogLevel.warning);
      FFLogger.info('skipped');
      FFLogger.warning('kept');
      FFLogger.error('kept2');
      expect(store.length, 2);
    });

    test('does nothing before init', () {
      // Unlike `store`, calling log methods before init is a no-op.
      FFLogger.info('silent'); // must not throw
    });
  });
}
