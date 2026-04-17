import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/logger/ff_log_level.dart';
import '../utils/ff_constants.dart';

/// Immutable configuration object passed to [FlutterForgeAI.init].
///
/// Use [copyWith] to tweak individual fields, or the [FFConfig.defaults] /
/// [FFConfig.production] factories for common presets.
@immutable
class FFConfig {
  /// Creates a config. Only [appName] is required.
  const FFConfig({
    required this.appName,
    this.dbName = FFConstants.defaultDbName,
    this.dbVersion = 1,
    this.baseUrl,
    this.envFile,
    this.enableDevTools = true,
    this.enableDbWorkbench = true,
    this.dbWorkbenchPort = FFConstants.defaultWorkbenchPort,
    this.enableAiDebugButton = true,
    this.enableShakeToOpen = true,
    this.shakeThreshold = FFConstants.defaultShakeThreshold,
    this.enableKeyboardShortcut = true,
    this.maxApiCallsStored = FFConstants.defaultMaxApiCalls,
    this.maxLogsStored = FFConstants.defaultMaxLogs,
    this.maxStateChangesStored = FFConstants.defaultMaxStateChanges,
    this.sensitiveHeaders = FFConstants.defaultSensitiveHeaders,
    this.sensitiveBodyKeys = FFConstants.defaultSensitiveBodyKeys,
    this.apiTimeout = FFConstants.defaultApiTimeout,
    this.enablePrettyDioLogger = true,
    this.persistSnapshots = false,
    this.minLogLevel = FFLogLevel.verbose,
    this.primaryColor = const Color(0xFF6366F1),
    this.devToolsTheme = ThemeMode.system,
    this.additionalInterceptors = const <Interceptor>[],
    this.stateTrackingPrefixes = const <String>[],
    this.maxStateValueLength = FFConstants.defaultMaxStateValueLength,
  });

  /// Safe defaults — equivalent to `const FFConfig(appName: 'MyApp')`.
  factory FFConfig.defaults({String appName = 'MyApp'}) =>
      FFConfig(appName: appName);

  /// Minimal-features preset suitable for release tuning.
  ///
  /// Even with these flags on, all devtools stay disabled in release mode via
  /// the `kReleaseMode` gate; this factory simply keeps things quiet in debug.
  factory FFConfig.production({required String appName}) => FFConfig(
        appName: appName,
        enableDevTools: false,
        enableDbWorkbench: false,
        enableAiDebugButton: false,
        enableShakeToOpen: false,
        enableKeyboardShortcut: false,
        enablePrettyDioLogger: false,
        minLogLevel: FFLogLevel.warning,
      );

  /// Human-readable app name, surfaced in logs and snapshots.
  final String appName;

  /// SQLite database file name (no path, just the file).
  final String dbName;

  /// Database schema version passed to [openDatabase].
  final int dbVersion;

  /// Base URL injected into the Dio client, e.g. `https://api.example.com`.
  final String? baseUrl;

  /// Optional dotenv file (defaults to `.env` when set by
  /// `FFConfig.copyWith(envFile: '.env')`).
  final String? envFile;

  /// Master switch for every devtools feature.
  ///
  /// Even when true, everything is silently suppressed if the app is built in
  /// release mode (see [FlutterForgeAI.showDevTools]).
  final bool enableDevTools;

  /// Whether the `sqflite_dev` web workbench should start in debug mode.
  final bool enableDbWorkbench;

  /// TCP port bound by the dev workbench.
  final int dbWorkbenchPort;

  /// Whether to show the green 🤖 FAB in debug mode.
  final bool enableAiDebugButton;

  /// Whether shake-to-open (mobile) is enabled.
  final bool enableShakeToOpen;

  /// Shake acceleration threshold in m/s^2.
  final double shakeThreshold;

  /// Whether the Alt+F12 desktop shortcut is enabled.
  final bool enableKeyboardShortcut;

  /// Max retained API calls in the ring buffer.
  final int maxApiCallsStored;

  /// Max retained log entries in the ring buffer.
  final int maxLogsStored;

  /// Max retained state-change events in the ring buffer.
  final int maxStateChangesStored;

  /// Lowercase header names whose values should be masked in UI/snapshots.
  final Set<String> sensitiveHeaders;

  /// Lowercase body keys whose values should be masked recursively.
  final Set<String> sensitiveBodyKeys;

  /// Timeout for each HTTP request issued by `FFApiClient`.
  final Duration apiTimeout;

  /// Whether `pretty_dio_logger` should dump requests to stdout.
  final bool enablePrettyDioLogger;

  /// Whether the latest snapshot should be persisted via `SharedPreferences`.
  final bool persistSnapshots;

  /// The minimum log level that will be persisted into the log store.
  final FFLogLevel minLogLevel;

  /// Accent colour used throughout the devtools UI.
  final Color primaryColor;

  /// Devtools theme mode.
  final ThemeMode devToolsTheme;

  /// Extra Dio interceptors added AFTER FlutterForge's own capture layer.
  final List<Interceptor> additionalInterceptors;

  /// Optional list of string prefixes; if non-empty, the state observer only
  /// reports providers whose `runtimeType` starts with one of the entries.
  ///
  /// Use this to filter noise from framework/packages.
  final List<String> stateTrackingPrefixes;

  /// Max length of a stringified provider value before it is truncated.
  final int maxStateValueLength;

  /// Whether the SDK is currently running in debug (i.e. `!kReleaseMode`).
  bool get isDebug => !kReleaseMode;

  /// Whether the visible devtools surface should render.
  bool get shouldShowDevTools => isDebug && enableDevTools;

  /// Returns a copy of this config with the given fields replaced.
  FFConfig copyWith({
    String? appName,
    String? dbName,
    int? dbVersion,
    String? baseUrl,
    String? envFile,
    bool? enableDevTools,
    bool? enableDbWorkbench,
    int? dbWorkbenchPort,
    bool? enableAiDebugButton,
    bool? enableShakeToOpen,
    double? shakeThreshold,
    bool? enableKeyboardShortcut,
    int? maxApiCallsStored,
    int? maxLogsStored,
    int? maxStateChangesStored,
    Set<String>? sensitiveHeaders,
    Set<String>? sensitiveBodyKeys,
    Duration? apiTimeout,
    bool? enablePrettyDioLogger,
    bool? persistSnapshots,
    FFLogLevel? minLogLevel,
    Color? primaryColor,
    ThemeMode? devToolsTheme,
    List<Interceptor>? additionalInterceptors,
    List<String>? stateTrackingPrefixes,
    int? maxStateValueLength,
  }) =>
      FFConfig(
        appName: appName ?? this.appName,
        dbName: dbName ?? this.dbName,
        dbVersion: dbVersion ?? this.dbVersion,
        baseUrl: baseUrl ?? this.baseUrl,
        envFile: envFile ?? this.envFile,
        enableDevTools: enableDevTools ?? this.enableDevTools,
        enableDbWorkbench: enableDbWorkbench ?? this.enableDbWorkbench,
        dbWorkbenchPort: dbWorkbenchPort ?? this.dbWorkbenchPort,
        enableAiDebugButton: enableAiDebugButton ?? this.enableAiDebugButton,
        enableShakeToOpen: enableShakeToOpen ?? this.enableShakeToOpen,
        shakeThreshold: shakeThreshold ?? this.shakeThreshold,
        enableKeyboardShortcut:
            enableKeyboardShortcut ?? this.enableKeyboardShortcut,
        maxApiCallsStored: maxApiCallsStored ?? this.maxApiCallsStored,
        maxLogsStored: maxLogsStored ?? this.maxLogsStored,
        maxStateChangesStored:
            maxStateChangesStored ?? this.maxStateChangesStored,
        sensitiveHeaders: sensitiveHeaders ?? this.sensitiveHeaders,
        sensitiveBodyKeys: sensitiveBodyKeys ?? this.sensitiveBodyKeys,
        apiTimeout: apiTimeout ?? this.apiTimeout,
        enablePrettyDioLogger:
            enablePrettyDioLogger ?? this.enablePrettyDioLogger,
        persistSnapshots: persistSnapshots ?? this.persistSnapshots,
        minLogLevel: minLogLevel ?? this.minLogLevel,
        primaryColor: primaryColor ?? this.primaryColor,
        devToolsTheme: devToolsTheme ?? this.devToolsTheme,
        additionalInterceptors:
            additionalInterceptors ?? this.additionalInterceptors,
        stateTrackingPrefixes:
            stateTrackingPrefixes ?? this.stateTrackingPrefixes,
        maxStateValueLength: maxStateValueLength ?? this.maxStateValueLength,
      );

  @override
  String toString() => 'FFConfig(appName: $appName, db: $dbName, '
      'devtools: $enableDevTools, release: $kReleaseMode)';
}
