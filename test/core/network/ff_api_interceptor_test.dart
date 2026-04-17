import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterforge_ai/flutterforge_ai.dart';
import 'package:mocktail/mocktail.dart';

class _MockRequestHandler extends Mock implements RequestInterceptorHandler {}

class _MockResponseHandler extends Mock implements ResponseInterceptorHandler {}

class _MockErrorHandler extends Mock implements ErrorInterceptorHandler {}

void main() {
  setUpAll(() {
    registerFallbackValue(RequestOptions(path: '/x'));
    registerFallbackValue(
        Response<dynamic>(requestOptions: RequestOptions(path: '/x')));
  });

  group('FFApiInterceptor', () {
    late FFApiStore store;
    late FFApiInterceptor interceptor;

    setUp(() {
      store = FFApiStore(maxSize: 10);
      interceptor = FFApiInterceptor(
        store: store,
        masker: FFSensitiveDataMasker(),
      );
    });

    tearDown(() async => store.dispose());

    test('onRequest adds a pending call with masked headers', () {
      final RequestOptions opts = RequestOptions(
        path: '/users?token=secret',
        method: 'GET',
        baseUrl: 'https://ex.com',
        headers: <String, dynamic>{'Authorization': 'Bearer abc'},
      );
      final _MockRequestHandler handler = _MockRequestHandler();
      interceptor.onRequest(opts, handler);
      expect(store.getAll().length, 1);
      final FFApiCall c = store.getAll().single;
      expect(c.method, 'GET');
      expect(c.url, contains('token=***'));
      expect(c.requestHeaders['Authorization'], '***');
      verify(() => handler.next(opts)).called(1);
    });

    test('onResponse marks call completed with status code', () {
      final RequestOptions opts =
          RequestOptions(path: '/x', method: 'GET', baseUrl: 'https://ex.com');
      interceptor.onRequest(opts, _MockRequestHandler());
      final Response<dynamic> resp = Response<dynamic>(
        requestOptions: opts,
        statusCode: 200,
        data: <String, Object?>{'ok': true, 'password': 'x'},
      );
      final _MockResponseHandler handler = _MockResponseHandler();
      interceptor.onResponse(resp, handler);
      final FFApiCall c = store.getAll().single;
      expect(c.status, FFApiCallStatus.completed);
      expect(c.statusCode, 200);
      final Map<String, Object?> body = c.responseBody! as Map<String, Object?>;
      expect(body['password'], '***');
    });

    test('onError marks call failed', () {
      final RequestOptions opts =
          RequestOptions(path: '/x', method: 'POST', baseUrl: 'https://ex.com');
      interceptor.onRequest(opts, _MockRequestHandler());
      final DioException err = DioException(
        requestOptions: opts,
        type: DioExceptionType.connectionError,
        message: 'Network down',
      );
      final _MockErrorHandler handler = _MockErrorHandler();
      interceptor.onError(err, handler);
      final FFApiCall c = store.getAll().single;
      expect(c.status, FFApiCallStatus.failed);
      expect(c.error, contains('Network down'));
    });
  });
}
