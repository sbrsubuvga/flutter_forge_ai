import 'package:dio/dio.dart';

import '../../utils/ff_sensitive_data_masker.dart';
import '../logger/ff_logger.dart';
import 'ff_api_call_model.dart';
import 'ff_api_store.dart';
import 'ff_curl_exporter.dart';

/// Dio interceptor that captures every request/response/error into
/// [FFApiStore].
///
/// All captured data is passed through the configured [FFSensitiveDataMasker]
/// before storage, so the in-app devtools never see raw tokens/cookies.
class FFApiInterceptor extends Interceptor {
  /// Creates an interceptor.
  FFApiInterceptor({
    required this.store,
    required this.masker,
    FFCurlExporter? curlExporter,
  }) : _curl = curlExporter ?? FFCurlExporter(masker);

  /// Destination store for captured calls.
  final FFApiStore store;

  /// Data masker applied to headers, bodies, URLs.
  final FFSensitiveDataMasker masker;

  final FFCurlExporter _curl;

  int _idCounter = 0;
  static const String _extraKey = '__ff_api_id__';

  String _nextId() {
    _idCounter += 1;
    return 'ff-$_idCounter';
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    try {
      final String id = _nextId();
      options.extra[_extraKey] = id;

      final FFApiCall call = FFApiCall(
        id: id,
        method: options.method,
        url: masker.maskUrl(options.uri.toString()),
        requestTime: DateTime.now(),
        requestHeaders:
            masker.maskHeaders(options.headers.cast<String, dynamic>()),
        requestBody: masker.maskBody(options.data),
        queryParameters: <String, Object?>{
          ...options.queryParameters,
        },
        curl: _curl.fromRequest(options),
      );
      store.add(call);
      FFLogger.debug(
        '→ ${options.method} ${options.uri}',
        tag: 'api',
      );
    } catch (e, st) {
      FFLogger.warning('FFApiInterceptor.onRequest failed: $e', tag: 'api');
      FFLogger.debug(st.toString(), tag: 'api');
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    try {
      final String? id = response.requestOptions.extra[_extraKey] as String?;
      if (id != null) {
        final FFApiCall? existing = store
            .getAll()
            .cast<FFApiCall?>()
            .firstWhere((FFApiCall? c) => c?.id == id, orElse: () => null);
        if (existing != null) {
          store.update(
            existing.copyWith(
              status: FFApiCallStatus.completed,
              statusCode: response.statusCode,
              responseBody: masker.maskBody(response.data),
              responseHeaders: <String, Object?>{
                for (final MapEntry<String, List<String>> e
                    in response.headers.map.entries)
                  e.key: e.value.join(', '),
              },
              responseTime: DateTime.now(),
            ),
          );
        }
      }
      FFLogger.debug(
        '← ${response.statusCode} ${response.requestOptions.uri}',
        tag: 'api',
      );
    } catch (e, st) {
      FFLogger.warning('FFApiInterceptor.onResponse failed: $e', tag: 'api');
      FFLogger.debug(st.toString(), tag: 'api');
    }
    handler.next(response);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    try {
      final String? id = err.requestOptions.extra[_extraKey] as String?;
      if (id != null) {
        final FFApiCall? existing = store
            .getAll()
            .cast<FFApiCall?>()
            .firstWhere((FFApiCall? c) => c?.id == id, orElse: () => null);
        if (existing != null) {
          store.update(
            existing.copyWith(
              status: FFApiCallStatus.failed,
              statusCode: err.response?.statusCode,
              responseBody: err.response?.data == null
                  ? null
                  : masker.maskBody(err.response!.data),
              responseHeaders: err.response == null
                  ? <String, Object?>{}
                  : <String, Object?>{
                      for (final MapEntry<String, List<String>> e
                          in err.response!.headers.map.entries)
                        e.key: e.value.join(', '),
                    },
              responseTime: DateTime.now(),
              error: err.message ?? err.type.name,
              stackTrace: err.stackTrace.toString(),
            ),
          );
        }
      }
      FFLogger.error(
        '✗ ${err.requestOptions.method} ${err.requestOptions.uri}',
        error: err,
        stackTrace: err.stackTrace,
        tag: 'api',
      );
    } catch (e, st) {
      FFLogger.warning('FFApiInterceptor.onError failed: $e', tag: 'api');
      FFLogger.debug(st.toString(), tag: 'api');
    }
    handler.next(err);
  }
}
