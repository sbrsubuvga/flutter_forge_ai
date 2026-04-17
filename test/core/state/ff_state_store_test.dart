import 'package:flutter_test/flutter_test.dart';
import 'package:flutterforge_ai/flutterforge_ai.dart';

void main() {
  group('FFStateStore', () {
    late FFStateStore store;

    setUp(() => store = FFStateStore(maxSize: 4));
    tearDown(() async => store.dispose());

    FFStateChange added(String name, {String value = 'v'}) => FFStateChange(
          type: FFStateChangeType.added,
          providerName: name,
          providerType: 'T',
          newValue: value,
        );

    FFStateChange updated(String name,
            {String prev = 'a', String next = 'b'}) =>
        FFStateChange(
          type: FFStateChangeType.updated,
          providerName: name,
          providerType: 'T',
          previousValue: prev,
          newValue: next,
        );

    FFStateChange disposed(String name) => FFStateChange(
          type: FFStateChangeType.disposed,
          providerName: name,
          providerType: 'T',
        );

    test('tracks active providers, removes on dispose', () {
      store.add(added('auth'));
      store.add(added('prefs'));
      expect(
          store.activeProviders.keys, containsAll(<String>['auth', 'prefs']));
      store.add(disposed('auth'));
      expect(store.activeProviders.keys, <String>['prefs']);
    });

    test('history filters by provider name', () {
      store.add(added('auth'));
      store.add(updated('auth'));
      store.add(added('other'));
      expect(store.getHistory('auth').length, 2);
    });

    test('search matches name/type substrings case-insensitively', () {
      store.add(added('authProvider'));
      expect(store.search('auth').length, 1);
      expect(store.search('AUTH').length, 1);
      expect(store.search('missing'), isEmpty);
    });
  });
}
