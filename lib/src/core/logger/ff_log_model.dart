import 'package:flutter/foundation.dart';

import 'ff_log_level.dart';

/// A single captured log entry.
@immutable
class FFLogEntry {
  /// Creates a log entry. Timestamps default to [DateTime.now].
  FFLogEntry({
    required this.level,
    required this.message,
    DateTime? timestamp,
    this.error,
    this.stackTrace,
    this.tag,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Severity.
  final FFLogLevel level;

  /// Human-readable message.
  final String message;

  /// When the entry was captured (UTC preferred by callers).
  final DateTime timestamp;

  /// Optional associated error object.
  final Object? error;

  /// Optional stack trace.
  final StackTrace? stackTrace;

  /// Optional category tag, e.g. `api`, `db`, `state`.
  final String? tag;

  /// Serialises the entry for snapshot/export use.
  Map<String, Object?> toJson() => <String, Object?>{
        'timestamp': timestamp.toIso8601String(),
        'level': level.name,
        'tag': tag,
        'message': message,
        'error': error?.toString(),
        'stack_trace': stackTrace?.toString(),
      };

  @override
  String toString() =>
      '[${timestamp.toIso8601String()}][${level.shortLabel}] $message';
}
