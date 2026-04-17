import 'dart:async';

import 'package:flutter/foundation.dart';

import 'config/ff_config.dart';
import 'config/ff_environment.dart';
import 'core/db/ff_db_helper.dart';
import 'core/logger/ff_log_store.dart';
import 'core/logger/ff_logger.dart';
import 'core/network/ff_api_client.dart';
import 'core/state/ff_state_observer.dart';
import 'core/state/ff_state_store.dart';
import 'snapshot/ff_snapshot_generator.dart';
import 'snapshot/ff_snapshot_model.dart';
import 'utils/ff_constants.dart';

/// Main entry point to FlutterForge AI.
///
/// Typical usage:
///
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await FlutterForgeAI.init(
///     config: FFConfig(appName: 'My App', baseUrl: 'https://api.example.com'),
///   );
///   runApp(MyApp());
/// }
/// ```
class FlutterForgeAI {
  FlutterForgeAI._();

  static FFConfig? _config;
  static FFLogStore? _logStore;
  static FFStateStore? _stateStore;
  static bool _initialized = false;

  /// Whether [init] has successfully completed.
  static bool get isInitialized => _initialized;

  /// Active configuration. Throws if [init] wasn't called.
  static FFConfig get config {
    final FFConfig? c = _config;
    if (c == null) {
      throw StateError(
          'FlutterForgeAI.config accessed before FlutterForgeAI.init() ran.');
    }
    return c;
  }

  /// The log store (also exposed via `FFLogger.store`).
  static FFLogStore get logStore {
    final FFLogStore? s = _logStore;
    if (s == null) {
      throw StateError('FlutterForgeAI.logStore accessed before init().');
    }
    return s;
  }

  /// The state change store rendered by the State Viewer tab.
  static FFStateStore get stateStore {
    final FFStateStore? s = _stateStore;
    if (s == null) {
      throw StateError('FlutterForgeAI.stateStore accessed before init().');
    }
    return s;
  }

  /// True when the devtools surface should render (i.e. debug build +
  /// `config.enableDevTools`).
  static bool get showDevTools =>
      _initialized && !kReleaseMode && config.enableDevTools;

  /// Ergonomic facade over [FFSnapshotGenerator.generate].
  ///
  /// Prefer this over calling the generator directly — it keeps call sites
  /// colocated with the rest of the top-level SDK API.
  ///
  /// ```dart
  /// final snap = await FlutterForgeAI.generateSnapshot(problem: 'Login loop');
  /// ```
  static Future<FFSnapshot> generateSnapshot({String? problem}) =>
      FFSnapshotGenerator.generate(problem: problem);

  /// Initialises the SDK. Idempotent — subsequent calls return immediately.
  static Future<void> init({FFConfig? config}) async {
    if (_initialized) return;
    final FFConfig cfg = config ?? FFConfig.defaults();
    _config = cfg;

    // 1. Env.
    await FFEnvironment.load(cfg.envFile);

    // 2. Logger (first, so everything else can log).
    _logStore = FFLogStore(maxSize: cfg.maxLogsStored);
    FFLogger.init(store: _logStore!, minLevel: cfg.minLogLevel);
    FFLogger.info(
        'Initialising ${FFConstants.packageName} '
        'v${FFConstants.packageVersion} for "${cfg.appName}"',
        tag: 'core');

    // 3. State store (wired into FFStateObserver).
    _stateStore = FFStateStore(maxSize: cfg.maxStateChangesStored);
    ffStateObserverRegisterStore(_stateStore!);

    // 4. DB (best-effort: some platforms/tests don't have a DB dir).
    try {
      await FFDbHelper.instance.init(cfg);
    } catch (e, st) {
      FFLogger.warning('DB init failed (continuing without DB): $e',
          tag: 'core');
      FFLogger.debug(st.toString(), tag: 'core');
    }

    // 5. Networking.
    FFApiClient.instance.init(cfg);

    // 6. Global error handlers (only when devtools are live).
    if (cfg.shouldShowDevTools) {
      final FlutterExceptionHandler? previous = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails d) {
        FFLogger.error(
          d.exceptionAsString(),
          error: d.exception,
          stackTrace: d.stack,
          tag: 'flutter',
        );
        previous?.call(d);
      };
      PlatformDispatcher.instance.onError = (Object err, StackTrace st) {
        FFLogger.error(
          'Uncaught platform error',
          error: err,
          stackTrace: st,
          tag: 'platform',
        );
        return false;
      };
    }

    _initialized = true;
    if (!kReleaseMode) {
      // ignore: avoid_print
      print(FFConstants.banner);
    }
    FFLogger.info('FlutterForge AI ready.', tag: 'core');
  }

  /// Resets every subsystem. Chiefly for tests.
  @visibleForTesting
  static Future<void> reset() async {
    ffStateObserverClearStore();
    await FFApiClient.instance.reset();
    await FFDbHelper.instance.close();
    await _stateStore?.dispose();
    await _logStore?.dispose();
    // ignore: invalid_use_of_visible_for_testing_member
    await FFLogger.reset();
    _stateStore = null;
    _logStore = null;
    _config = null;
    _initialized = false;
    FlutterError.onError = FlutterError.presentError;
  }
}
