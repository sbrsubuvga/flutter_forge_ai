import 'dart:convert';

import 'package:dio/dio.dart';

import '../../utils/ff_sensitive_data_masker.dart';

/// Converts a Dio [RequestOptions] into an equivalent `curl` command.
///
/// Sensitive headers and body keys are masked via [FFSensitiveDataMasker].
class FFCurlExporter {
  /// Creates an exporter.
  const FFCurlExporter(this.masker);

  /// Data masker applied to headers and JSON body keys.
  final FFSensitiveDataMasker masker;

  /// Returns a multi-line `curl` command that reproduces the request.
  String fromRequest(RequestOptions options) {
    final StringBuffer buf = StringBuffer('curl');

    buf.write(" -X '${_escape(options.method)}'");

    // URL including query parameters.
    final Uri uri = Uri.parse(options.uri.toString());
    final String maskedUrl = masker.maskUrl(uri.toString());
    buf.write(" '${_escape(maskedUrl)}'");

    // Headers.
    final Map<String, dynamic> masked =
        masker.maskHeaders(options.headers.cast<String, dynamic>());
    masked.forEach((String key, Object? value) {
      buf.write(" \\\n  -H '${_escape(key)}: ${_escape(value.toString())}'");
    });

    // Body.
    final Object? data = options.data;
    if (data != null) {
      final Object? maskedBody = masker.maskBody(data);
      final String bodyString =
          maskedBody is String ? maskedBody : jsonEncode(maskedBody);
      buf.write(" \\\n  -d '${_escape(bodyString)}'");
    }

    return buf.toString();
  }

  /// Returns a `curl` command for a fully-captured [call].
  String fromParts({
    required String method,
    required String url,
    required Map<String, Object?> headers,
    Object? body,
  }) {
    final StringBuffer buf = StringBuffer('curl');
    buf.write(" -X '${_escape(method)}'");
    buf.write(" '${_escape(url)}'");
    headers.forEach((String key, Object? value) {
      buf.write(" \\\n  -H '${_escape(key)}: ${_escape(value.toString())}'");
    });
    if (body != null) {
      final String bodyString = body is String ? body : jsonEncode(body);
      buf.write(" \\\n  -d '${_escape(bodyString)}'");
    }
    return buf.toString();
  }

  static String _escape(String value) => value.replaceAll("'", r"'\''");
}
