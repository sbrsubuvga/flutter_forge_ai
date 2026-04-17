import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

/// Cross-platform detection helpers used by features that only make
/// sense on certain platforms (shake on mobile, keyboard shortcut on desktop,
/// sqflite on native, etc.).
class FFPlatformChecker {
  FFPlatformChecker._();

  /// True on web.
  static bool get isWeb => kIsWeb;

  /// True on Android native (not web-Android).
  static bool get isAndroid => !kIsWeb && _isOs(() => Platform.isAndroid);

  /// True on iOS native.
  static bool get isIOS => !kIsWeb && _isOs(() => Platform.isIOS);

  /// True on macOS native.
  static bool get isMacOS => !kIsWeb && _isOs(() => Platform.isMacOS);

  /// True on Windows native.
  static bool get isWindows => !kIsWeb && _isOs(() => Platform.isWindows);

  /// True on Linux native.
  static bool get isLinux => !kIsWeb && _isOs(() => Platform.isLinux);

  /// True on Android or iOS native devices.
  static bool get isMobile => isAndroid || isIOS;

  /// True on macOS, Windows, or Linux native.
  static bool get isDesktop => isMacOS || isWindows || isLinux;

  /// True on platforms that support `sensors_plus` (Android/iOS native).
  static bool get supportsShake => isMobile;

  /// True on platforms where hardware keyboard shortcuts are expected.
  static bool get supportsKeyboardShortcut => isDesktop;

  /// True on platforms where [sqflite] works out of the box without FFI.
  static bool get supportsNativeSqflite => isMobile || isMacOS;

  /// Returns the current platform name, safe for web.
  static String get name {
    if (kIsWeb) return 'web';
    if (isAndroid) return 'android';
    if (isIOS) return 'ios';
    if (isMacOS) return 'macos';
    if (isWindows) return 'windows';
    if (isLinux) return 'linux';
    return 'unknown';
  }

  static bool _isOs(bool Function() test) {
    try {
      return test();
    } catch (_) {
      return false;
    }
  }
}
