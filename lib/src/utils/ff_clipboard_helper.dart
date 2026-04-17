import 'package:flutter/services.dart';

/// Thin wrapper over [Clipboard] that never throws.
///
/// The clipboard is unreliable on some web / server-render contexts, so the
/// devtools UI never lets a failed copy crash the app.
class FFClipboardHelper {
  FFClipboardHelper._();

  /// Copies [text] to the clipboard. Returns true on success.
  static Future<bool> copy(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Reads the current clipboard text, or null if unavailable.
  static Future<String?> read() async {
    try {
      final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
      return data?.text;
    } catch (_) {
      return null;
    }
  }
}
