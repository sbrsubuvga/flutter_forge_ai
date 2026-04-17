import 'package:flutter/foundation.dart';

/// Type of state-change event captured by [FFStateObserver].
enum FFStateChangeType {
  /// Provider was first listened to.
  added,

  /// Provider value changed.
  updated,

  /// Provider was disposed.
  disposed,

  /// Provider threw.
  failed,
}

/// A single captured state-change event.
@immutable
class FFStateChange {
  /// Creates a state change event.
  FFStateChange({
    required this.type,
    required this.providerName,
    required this.providerType,
    this.previousValue,
    this.newValue,
    this.error,
    this.stackTrace,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Event type.
  final FFStateChangeType type;

  /// Provider's display name (name parameter or runtimeType).
  final String providerName;

  /// Provider's runtimeType as a string.
  final String providerType;

  /// Previous value, truncated.
  final String? previousValue;

  /// New value, truncated.
  final String? newValue;

  /// Error (for `failed` events).
  final Object? error;

  /// Stack trace (for `failed` events).
  final StackTrace? stackTrace;

  /// When the event occurred.
  final DateTime timestamp;

  /// JSON form for snapshots.
  Map<String, Object?> toJson() => <String, Object?>{
        'timestamp': timestamp.toIso8601String(),
        'type': type.name,
        'provider': providerName,
        'provider_type': providerType,
        'previous': previousValue,
        'new': newValue,
        'error': error?.toString(),
        'stack_trace': stackTrace?.toString(),
      };

  @override
  String toString() =>
      '[${timestamp.toIso8601String()}] ${type.name} $providerName';
}
