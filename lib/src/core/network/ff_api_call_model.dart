import 'package:flutter/foundation.dart';

/// Status of a captured API call.
enum FFApiCallStatus {
  /// The request was sent; no response yet.
  pending,

  /// The response was received (regardless of status code).
  completed,

  /// The request threw — e.g. timeout, DNS, parse.
  failed,
}

/// A single captured HTTP request + response pair.
@immutable
class FFApiCall {
  /// Creates a call. [id] is client-generated so it can be referenced in
  /// UI updates before the response arrives.
  const FFApiCall({
    required this.id,
    required this.method,
    required this.url,
    required this.requestTime,
    this.requestHeaders = const <String, Object?>{},
    this.requestBody,
    this.queryParameters = const <String, Object?>{},
    this.status = FFApiCallStatus.pending,
    this.statusCode,
    this.responseHeaders = const <String, Object?>{},
    this.responseBody,
    this.responseTime,
    this.error,
    this.stackTrace,
    this.curl,
  });

  /// Stable ID (monotonic int as string).
  final String id;

  /// HTTP method (GET, POST, ...).
  final String method;

  /// Absolute URL, with sensitive query params masked.
  final String url;

  /// Time the request was sent.
  final DateTime requestTime;

  /// Masked request headers.
  final Map<String, Object?> requestHeaders;

  /// Masked request body.
  final Object? requestBody;

  /// Masked query parameters.
  final Map<String, Object?> queryParameters;

  /// Current lifecycle state.
  final FFApiCallStatus status;

  /// HTTP status code, if available.
  final int? statusCode;

  /// Response headers.
  final Map<String, Object?> responseHeaders;

  /// Response body.
  final Object? responseBody;

  /// Time the response arrived, if any.
  final DateTime? responseTime;

  /// Error message if the call failed.
  final String? error;

  /// Stack trace if the call failed.
  final String? stackTrace;

  /// cURL reproduction of the request.
  final String? curl;

  /// Duration in milliseconds, or null while pending.
  int? get durationMs => responseTime?.difference(requestTime).inMilliseconds;

  /// Whether the call has a 2xx response.
  bool get isSuccess =>
      status == FFApiCallStatus.completed &&
      (statusCode ?? 0) >= 200 &&
      (statusCode ?? 0) < 300;

  /// Whether the call failed (non-2xx, or exception).
  bool get isFailed =>
      status == FFApiCallStatus.failed ||
      (status == FFApiCallStatus.completed &&
          ((statusCode ?? 0) < 200 || (statusCode ?? 0) >= 300));

  /// Returns a new call with the given fields replaced.
  FFApiCall copyWith({
    FFApiCallStatus? status,
    int? statusCode,
    Map<String, Object?>? responseHeaders,
    Object? responseBody,
    DateTime? responseTime,
    String? error,
    String? stackTrace,
    String? curl,
  }) =>
      FFApiCall(
        id: id,
        method: method,
        url: url,
        requestTime: requestTime,
        requestHeaders: requestHeaders,
        requestBody: requestBody,
        queryParameters: queryParameters,
        status: status ?? this.status,
        statusCode: statusCode ?? this.statusCode,
        responseHeaders: responseHeaders ?? this.responseHeaders,
        responseBody: responseBody ?? this.responseBody,
        responseTime: responseTime ?? this.responseTime,
        error: error ?? this.error,
        stackTrace: stackTrace ?? this.stackTrace,
        curl: curl ?? this.curl,
      );

  /// JSON representation suitable for AI snapshots.
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'method': method,
        'url': url,
        'request_time': requestTime.toIso8601String(),
        'request_headers': requestHeaders,
        'request_body': requestBody,
        'query_parameters': queryParameters,
        'status': status.name,
        'status_code': statusCode,
        'response_headers': responseHeaders,
        'response_body': responseBody,
        'response_time': responseTime?.toIso8601String(),
        'duration_ms': durationMs,
        'error': error,
        'curl': curl,
      };
}
