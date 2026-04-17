import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../../config/ff_config.dart';
import '../../utils/ff_sensitive_data_masker.dart';
import 'ff_api_interceptor.dart';
import 'ff_api_store.dart';

/// Singleton Dio client configured by [FFConfig].
///
/// Interceptor chain (order matters):
///   1. [FFApiInterceptor]       — captures & masks into [FFApiStore]
///   2. [PrettyDioLogger]        — console output (debug only, optional)
///   3. `config.additionalInterceptors` — user extensions
class FFApiClient {
  FFApiClient._();

  static final FFApiClient _instance = FFApiClient._();

  /// Global singleton.
  static FFApiClient get instance => _instance;

  Dio? _dio;
  FFApiStore? _store;

  /// The configured Dio instance. Call [init] first.
  Dio get dio {
    final Dio? d = _dio;
    if (d == null) {
      throw StateError(
          'FFApiClient.dio accessed before FlutterForgeAI.init() ran.');
    }
    return d;
  }

  /// The API call store backing the API Inspector UI.
  FFApiStore get store {
    final FFApiStore? s = _store;
    if (s == null) {
      throw StateError(
          'FFApiClient.store accessed before FlutterForgeAI.init() ran.');
    }
    return s;
  }

  /// Whether [init] has completed.
  bool get isInitialized => _dio != null;

  /// Configures Dio and installs interceptors.
  void init(FFConfig config) {
    _store ??= FFApiStore(maxSize: config.maxApiCallsStored);

    final BaseOptions baseOptions = BaseOptions(
      baseUrl: config.baseUrl ?? '',
      connectTimeout: config.apiTimeout,
      receiveTimeout: config.apiTimeout,
      sendTimeout: config.apiTimeout,
      headers: <String, Object?>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    final Dio dio = Dio(baseOptions);

    final FFSensitiveDataMasker masker = FFSensitiveDataMasker(
      sensitiveHeaders: config.sensitiveHeaders,
      sensitiveBodyKeys: config.sensitiveBodyKeys,
    );

    // 1. Capture layer.
    dio.interceptors.add(
      FFApiInterceptor(store: _store!, masker: masker),
    );

    // 2. Pretty console logger (opt-in, debug-only via config flag).
    if (config.enablePrettyDioLogger && config.shouldShowDevTools) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 100,
        ),
      );
    }

    // 3. User-supplied interceptors.
    dio.interceptors.addAll(config.additionalInterceptors);

    _dio = dio;
  }

  /// Replaces the active store (used by tests).
  // ignore: use_setters_to_change_properties
  void overrideStoreForTesting(FFApiStore store) => _store = store;

  /// Closes the Dio instance. Chiefly used by tests.
  Future<void> reset() async {
    _dio?.close();
    await _store?.dispose();
    _dio = null;
    _store = null;
  }
}
