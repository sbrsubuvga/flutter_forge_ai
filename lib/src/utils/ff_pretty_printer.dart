import 'dart:convert';

/// Pretty-prints JSON-like objects with stable indentation.
class FFPrettyPrinter {
  FFPrettyPrinter._();

  static const JsonEncoder _encoder = JsonEncoder.withIndent('  ');

  /// Pretty-prints any JSON-encodable [value].
  ///
  /// If encoding fails (e.g. circular references) the original `toString()` is
  /// returned, so this helper never throws.
  static String json(Object? value) {
    if (value == null) return 'null';
    try {
      if (value is String) {
        return _encoder.convert(jsonDecode(value));
      }
      return _encoder.convert(value);
    } catch (_) {
      return value.toString();
    }
  }

  /// Truncates [value] to [maxLength] chars with a " …truncated" suffix.
  static String truncate(String value, {int maxLength = 500}) {
    if (value.length <= maxLength) return value;
    return '${value.substring(0, maxLength)}…truncated';
  }
}
