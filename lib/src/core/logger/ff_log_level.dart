import 'package:flutter/material.dart';

/// Log severity levels.
///
/// Ordered from least to most severe so comparisons work:
/// `FFLogLevel.warning.index > FFLogLevel.info.index`.
enum FFLogLevel {
  /// Chatty, only useful while reproducing a bug.
  verbose,

  /// Developer diagnostic messages.
  debug,

  /// Normal lifecycle events.
  info,

  /// Recoverable misbehaviour worth attention.
  warning,

  /// Errors — the caller is expected to supply `error` + `stackTrace`.
  error,

  /// Unrecoverable errors — same as error, but surfaced more aggressively.
  fatal,
}

/// Convenience helpers for the [FFLogLevel] enum.
extension FFLogLevelX on FFLogLevel {
  /// Short one-letter tag for compact output.
  String get shortLabel {
    switch (this) {
      case FFLogLevel.verbose:
        return 'V';
      case FFLogLevel.debug:
        return 'D';
      case FFLogLevel.info:
        return 'I';
      case FFLogLevel.warning:
        return 'W';
      case FFLogLevel.error:
        return 'E';
      case FFLogLevel.fatal:
        return 'F';
    }
  }

  /// UI label, capitalised.
  String get label {
    switch (this) {
      case FFLogLevel.verbose:
        return 'Verbose';
      case FFLogLevel.debug:
        return 'Debug';
      case FFLogLevel.info:
        return 'Info';
      case FFLogLevel.warning:
        return 'Warning';
      case FFLogLevel.error:
        return 'Error';
      case FFLogLevel.fatal:
        return 'Fatal';
    }
  }

  /// Colour used in chips and log rows.
  Color get color {
    switch (this) {
      case FFLogLevel.verbose:
        return Colors.grey;
      case FFLogLevel.debug:
        return Colors.blue;
      case FFLogLevel.info:
        return Colors.green;
      case FFLogLevel.warning:
        return Colors.orange;
      case FFLogLevel.error:
        return Colors.red;
      case FFLogLevel.fatal:
        return const Color(0xFF7F0000);
    }
  }

  /// True if this level is at least as severe as [min].
  bool isAtLeast(FFLogLevel min) => index >= min.index;
}
