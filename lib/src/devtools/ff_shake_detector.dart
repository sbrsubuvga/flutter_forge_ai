import 'dart:async';
import 'dart:math' as math;

import 'package:sensors_plus/sensors_plus.dart';

import '../core/logger/ff_logger.dart';
import '../utils/ff_platform_checker.dart';

/// Fires [onShake] when the device is shaken.
///
/// Uses `sensors_plus`' accelerometer. No-op on platforms without motion
/// sensors (web/desktop) — the helper degrades gracefully.
class FFShakeDetector {
  /// Creates a detector. Call [start] to subscribe.
  FFShakeDetector({
    required this.onShake,
    this.threshold = 15.0,
    this.cooldown = const Duration(milliseconds: 750),
  });

  /// Callback fired on shake.
  final void Function() onShake;

  /// Acceleration threshold in m/s^2.
  final double threshold;

  /// Minimum delay between successive fires.
  final Duration cooldown;

  StreamSubscription<AccelerometerEvent>? _sub;
  DateTime _lastFire = DateTime.fromMillisecondsSinceEpoch(0);
  bool _started = false;

  /// True when the detector is actively subscribed.
  bool get isRunning => _started;

  /// Starts listening. No-op on unsupported platforms.
  void start() {
    if (_started) return;
    if (!FFPlatformChecker.supportsShake) {
      FFLogger.debug('Shake detection skipped on ${FFPlatformChecker.name}',
          tag: 'shake');
      return;
    }
    try {
      _sub = accelerometerEventStream().listen(_onEvent, onError: (Object e) {
        FFLogger.warning('Shake sensor error: $e', tag: 'shake');
      });
      _started = true;
    } catch (e) {
      FFLogger.warning('Could not start shake detector: $e', tag: 'shake');
    }
  }

  void _onEvent(AccelerometerEvent e) {
    final double magnitude =
        math.sqrt(e.x * e.x + e.y * e.y + e.z * e.z) - 9.81;
    if (magnitude.abs() < threshold) return;
    final DateTime now = DateTime.now();
    if (now.difference(_lastFire) < cooldown) return;
    _lastFire = now;
    try {
      onShake();
    } catch (err, st) {
      FFLogger.error('Shake callback failed',
          error: err, stackTrace: st, tag: 'shake');
    }
  }

  /// Stops listening.
  Future<void> stop() async {
    _started = false;
    await _sub?.cancel();
    _sub = null;
  }
}
