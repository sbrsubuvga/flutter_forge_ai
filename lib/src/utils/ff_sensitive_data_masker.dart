import 'dart:convert';

import 'ff_constants.dart';

/// Utilities for redacting sensitive data before it is shown in the
/// devtools UI or exported in an AI snapshot.
///
/// All comparisons are case-insensitive.
class FFSensitiveDataMasker {
  /// Creates a new masker with the given sensitive sets.
  FFSensitiveDataMasker({
    Set<String>? sensitiveHeaders,
    Set<String>? sensitiveBodyKeys,
    Set<String>? sensitiveQueryParams,
    String mask = FFConstants.redactionMask,
  })  : _headers = _lowered(
          sensitiveHeaders ?? FFConstants.defaultSensitiveHeaders,
        ),
        _bodyKeys = _lowered(
          sensitiveBodyKeys ?? FFConstants.defaultSensitiveBodyKeys,
        ),
        _queryParams = _lowered(
          sensitiveQueryParams ?? FFConstants.sensitiveQueryParams,
        ),
        _mask = mask;

  final Set<String> _headers;
  final Set<String> _bodyKeys;
  final Set<String> _queryParams;
  final String _mask;

  static Set<String> _lowered(Set<String> v) =>
      v.map((String s) => s.toLowerCase()).toSet();

  /// Returns a new map with sensitive header values replaced by the mask.
  Map<String, dynamic> maskHeaders(Map<String, dynamic>? headers) {
    if (headers == null || headers.isEmpty) {
      return <String, dynamic>{};
    }
    return <String, dynamic>{
      for (final MapEntry<String, dynamic> e in headers.entries)
        e.key: _headers.contains(e.key.toLowerCase()) ? _mask : e.value,
    };
  }

  /// Recursively masks values whose keys match [_bodyKeys].
  ///
  /// Accepts Map / List / primitive / JSON string. Returns an object of the
  /// same shape with sensitive leaf values replaced.
  Object? maskBody(Object? body) {
    if (body == null) return null;
    if (body is String) {
      // If the string is JSON, mask it structurally; otherwise return as-is.
      try {
        final Object? decoded = jsonDecode(body);
        final Object? masked = maskBody(decoded);
        return jsonEncode(masked);
      } on FormatException {
        return body;
      }
    }
    if (body is Map) {
      return <String, Object?>{
        for (final MapEntry<Object?, Object?> e in body.entries)
          e.key.toString(): _bodyKeys.contains(e.key.toString().toLowerCase())
              ? _mask
              : maskBody(e.value),
      };
    }
    if (body is List) {
      return body.map<Object?>(maskBody).toList();
    }
    return body;
  }

  /// Returns a Uri with sensitive query parameters masked.
  ///
  /// `Uri.replace` URL-encodes the replacement value; we reverse that so the
  /// mask appears literally in the devtools UI.
  String maskUrl(String url) {
    try {
      final Uri uri = Uri.parse(url);
      if (uri.queryParameters.isEmpty) return url;
      final Map<String, String> masked = <String, String>{
        for (final MapEntry<String, String> e in uri.queryParameters.entries)
          e.key: _queryParams.contains(e.key.toLowerCase()) ? _mask : e.value,
      };
      final String encoded = uri.replace(queryParameters: masked).toString();
      return encoded.replaceAll(Uri.encodeQueryComponent(_mask), _mask);
    } on FormatException {
      return url;
    }
  }
}
