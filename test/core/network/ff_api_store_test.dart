import 'package:flutter_test/flutter_test.dart';
import 'package:flutterforge_ai/flutterforge_ai.dart';

FFApiCall call({
  required String id,
  int? status,
  String url = 'https://example.com/x',
  FFApiCallStatus lifecycle = FFApiCallStatus.completed,
}) =>
    FFApiCall(
      id: id,
      method: 'GET',
      url: url,
      requestTime: DateTime.now(),
      status: lifecycle,
      statusCode: status,
    );

void main() {
  group('FFApiStore', () {
    late FFApiStore store;

    setUp(() => store = FFApiStore(maxSize: 3));
    tearDown(() async => store.dispose());

    test('stores in insertion order', () {
      store
        ..add(call(id: '1'))
        ..add(call(id: '2'));
      expect(store.getAll().map((FFApiCall c) => c.id), <String>['1', '2']);
    });

    test('evicts oldest when full', () {
      store
        ..add(call(id: '1'))
        ..add(call(id: '2'))
        ..add(call(id: '3'))
        ..add(call(id: '4'));
      expect(
          store.getAll().map((FFApiCall c) => c.id), <String>['2', '3', '4']);
    });

    test('update replaces call by id in place', () {
      store
        ..add(call(id: '1', status: 200))
        ..add(call(id: '2', status: 200));
      store.update(
          call(id: '1', status: 500, lifecycle: FFApiCallStatus.failed));
      expect(
          store.getAll().map((FFApiCall c) => c.statusCode), <int?>[500, 200]);
      expect(store.getFailedCalls().single.id, '1');
    });

    test('filters by status code', () {
      store
        ..add(call(id: '1', status: 200))
        ..add(call(id: '2', status: 404))
        ..add(call(id: '3', status: 500));
      expect(store.getByStatusCode(404).single.id, '2');
    });

    test('search matches url and status code', () {
      store
        ..add(call(id: '1', url: 'https://ex.com/users', status: 200))
        ..add(call(id: '2', url: 'https://ex.com/posts', status: 404));
      expect(store.search('users').single.id, '1');
      expect(store.search('404').single.id, '2');
    });

    test('clear empties the store', () {
      store.add(call(id: '1'));
      store.clear();
      expect(store.getAll(), isEmpty);
    });
  });
}
