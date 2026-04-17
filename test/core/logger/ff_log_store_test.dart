import 'package:flutter_test/flutter_test.dart';
import 'package:flutterforge_ai/flutterforge_ai.dart';

void main() {
  group('FFLogStore', () {
    late FFLogStore store;

    setUp(() => store = FFLogStore(maxSize: 3));
    tearDown(() async => store.dispose());

    FFLogEntry e(FFLogLevel l, String m, {String? tag}) =>
        FFLogEntry(level: l, message: m, tag: tag);

    test('retains in insertion order', () {
      store
        ..add(e(FFLogLevel.info, 'a'))
        ..add(e(FFLogLevel.info, 'b'));
      expect(
          store.getAll().map((FFLogEntry x) => x.message), <String>['a', 'b']);
    });

    test('evicts oldest when full', () {
      store
        ..add(e(FFLogLevel.info, 'a'))
        ..add(e(FFLogLevel.info, 'b'))
        ..add(e(FFLogLevel.info, 'c'))
        ..add(e(FFLogLevel.info, 'd'));
      expect(store.getAll().map((FFLogEntry x) => x.message),
          <String>['b', 'c', 'd']);
    });

    test('filters by level', () {
      store
        ..add(e(FFLogLevel.info, 'i'))
        ..add(e(FFLogLevel.error, 'er'))
        ..add(e(FFLogLevel.warning, 'w'));
      expect(store.getByLevel(FFLogLevel.error).single.message, 'er');
      expect(store.getErrors().single.message, 'er');
      expect(store.getWarnings().single.message, 'w');
    });

    test('search matches message, tag, and error', () {
      store
        ..add(e(FFLogLevel.info, 'user login', tag: 'auth'))
        ..add(FFLogEntry(
            level: FFLogLevel.error, message: 'other', error: 'oops'));
      expect(store.search('LOGIN').length, 1);
      expect(store.search('auth').length, 1);
      expect(store.search('oops').length, 1);
      expect(store.search('missing').isEmpty, true);
    });

    test('clear empties the store', () {
      store.add(e(FFLogLevel.info, 'a'));
      store.clear();
      expect(store.getAll(), isEmpty);
    });
  });
}
