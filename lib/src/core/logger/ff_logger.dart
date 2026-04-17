import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart' as pkg_logger;

import 'ff_log_level.dart';
import 'ff_log_model.dart';
import 'ff_log_store.dart';

/// Static logger facade used by the rest of the SDK and by application code.
///
/// The logger dual-writes to:
///   1. The in-app [FFLogStore] (ring buffer, drives the Log Viewer UI).
///   2. The `logger` package for colourised console output in debug builds.
class FFLogger {
  FFLogger._();

  static FFLogStore? _store;
  static pkg_logger.Logger? _console;
  static FFLogLevel _minLevel = FFLogLevel.verbose;
  static bool _initialized = false;

  /// Initialises the logger. Safe to call multiple times — subsequent calls
  /// reconfigure state in place rather than crash.
  static void init({
    required FFLogStore store,
    FFLogLevel minLevel = FFLogLevel.verbose,
  }) {
    _store = store;
    _minLevel = minLevel;
    _console ??= pkg_logger.Logger(
      printer: pkg_logger.PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 8,
        lineLength: 100,
        colors: !kReleaseMode,
        printEmojis: true,
        dateTimeFormat: pkg_logger.DateTimeFormat.onlyTimeAndSinceStart,
      ),
      level: _toLoggerLevel(minLevel),
    );
    _initialized = true;
  }

  /// Whether [init] has been called at least once.
  static bool get isInitialized => _initialized;

  /// The ring-buffer store backing the Log Viewer.
  ///
  /// Throws [StateError] before [init] is called.
  static FFLogStore get store {
    final FFLogStore? s = _store;
    if (s == null) {
      throw StateError(
          'FFLogger.store accessed before FlutterForgeAI.init() ran.');
    }
    return s;
  }

  /// Logs a verbose-level message.
  static void verbose(String message, {String? tag}) =>
      _log(FFLogLevel.verbose, message, tag: tag);

  /// Logs a debug-level message.
  static void debug(String message, {String? tag}) =>
      _log(FFLogLevel.debug, message, tag: tag);

  /// Logs an info-level message.
  static void info(String message, {String? tag}) =>
      _log(FFLogLevel.info, message, tag: tag);

  /// Logs a warning-level message.
  static void warning(String message, {String? tag}) =>
      _log(FFLogLevel.warning, message, tag: tag);

  /// Logs an error, optionally with [error] and [stackTrace].
  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String? tag,
  }) =>
      _log(FFLogLevel.error, message,
          error: error, stackTrace: stackTrace, tag: tag);

  /// Logs a fatal error.
  static void fatal(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String? tag,
  }) =>
      _log(FFLogLevel.fatal, message,
          error: error, stackTrace: stackTrace, tag: tag);

  static void _log(
    FFLogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String? tag,
  }) {
    if (!_initialized) return;
    if (!level.isAtLeast(_minLevel)) return;

    final FFLogEntry entry = FFLogEntry(
      level: level,
      message: message,
      error: error,
      stackTrace: stackTrace,
      tag: tag,
    );
    _store?.add(entry);

    if (kReleaseMode) return;
    final pkg_logger.Logger? c = _console;
    if (c == null) return;
    final String body = tag != null ? '[$tag] $message' : message;
    switch (level) {
      case FFLogLevel.verbose:
        c.t(body);
      case FFLogLevel.debug:
        c.d(body);
      case FFLogLevel.info:
        c.i(body);
      case FFLogLevel.warning:
        c.w(body);
      case FFLogLevel.error:
        c.e(body, error: error, stackTrace: stackTrace);
      case FFLogLevel.fatal:
        c.f(body, error: error, stackTrace: stackTrace);
    }
  }

  static pkg_logger.Level _toLoggerLevel(FFLogLevel level) {
    switch (level) {
      case FFLogLevel.verbose:
        return pkg_logger.Level.trace;
      case FFLogLevel.debug:
        return pkg_logger.Level.debug;
      case FFLogLevel.info:
        return pkg_logger.Level.info;
      case FFLogLevel.warning:
        return pkg_logger.Level.warning;
      case FFLogLevel.error:
        return pkg_logger.Level.error;
      case FFLogLevel.fatal:
        return pkg_logger.Level.fatal;
    }
  }

  /// Resets the logger — used by tests. Not for production code.
  @visibleForTesting
  static Future<void> reset() async {
    await _store?.dispose();
    _store = null;
    _console = null;
    _initialized = false;
    _minLevel = FFLogLevel.verbose;
  }
}
