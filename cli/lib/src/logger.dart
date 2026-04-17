import 'dart:io';

/// Minimal stdout logger with ANSI colour support.
///
/// Automatically strips colours when stdout is not a TTY (e.g. piped to a
/// file or CI output) so log files stay clean.
class CliLogger {
  /// Creates a logger. Set [verbose] to emit `debug()` output.
  CliLogger({this.verbose = false});

  /// Whether `debug` lines are emitted.
  final bool verbose;

  static const String _reset = '\x1B[0m';
  static const String _red = '\x1B[31m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
  static const String _blue = '\x1B[34m';
  static const String _dim = '\x1B[2m';

  bool get _ansi => stdout.supportsAnsiEscapes;

  String _wrap(String text, String code) =>
      _ansi ? '$code$text$_reset' : text;

  /// Prints an info line.
  void info(String message) => stdout.writeln(message);

  /// Prints a success ✓ line in green.
  void success(String message) =>
      stdout.writeln(_wrap('✓ $message', _green));

  /// Prints a warning ⚠ line in yellow.
  void warning(String message) =>
      stdout.writeln(_wrap('⚠ $message', _yellow));

  /// Prints an error ✗ line in red.
  void error(String message) =>
      stderr.writeln(_wrap('✗ $message', _red));

  /// Prints a blue [hint] (used by `doctor` for fix suggestions).
  void hint(String message) =>
      stdout.writeln(_wrap('  → $message', _blue));

  /// Prints [message] in dim text (used for background detail).
  void dim(String message) => stdout.writeln(_wrap(message, _dim));

  /// Prints [message] only when [verbose] is true.
  void debug(String message) {
    if (verbose) stdout.writeln(_wrap('· $message', _dim));
  }
}
