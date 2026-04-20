import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../core/db/ff_db_helper.dart';
import '../core/db/ff_db_schema_reader.dart';
import '../core/logger/ff_log_model.dart';
import '../core/logger/ff_logger.dart';
import '../core/network/ff_api_call_model.dart';
import '../core/network/ff_api_client.dart';
import '../core/state/ff_state_change_model.dart';
import '../core/state/ff_state_store.dart';
import '../flutterforge_core.dart';
import '../utils/ff_clipboard_helper.dart';
import '../utils/ff_constants.dart';
import '../utils/ff_platform_checker.dart';
import 'ff_device_info_collector.dart';
import 'ff_package_info_collector.dart';
import 'ff_snapshot_model.dart';

/// Generates a full runtime snapshot of the app for AI debugging.
///
/// A snapshot contains:
///   * app identity (name, version, build, bundle ID)
///   * device info (platform, model, OS version)
///   * DB schema with sample rows
///   * recent API calls (masked)
///   * active Riverpod providers + recent changes
///   * recent logs (levels, messages, errors)
///
/// All work is best-effort — failures in one section never block the others.
class FFSnapshotGenerator {
  FFSnapshotGenerator._();

  /// Key used when [FFConfig.persistSnapshots] is true.
  static const String _prefsKey = 'flutterforge_ai.last_snapshot';

  /// Generates a snapshot. Safe to call from any isolate-free context.
  ///
  /// When called in release mode with [FFConfig.shouldShowDevTools] == false,
  /// returns [FFSnapshot.empty] to prevent data leakage.
  static Future<FFSnapshot> generate({String? problem}) async {
    if (!FlutterForgeAI.isInitialized) {
      return FFSnapshot.empty(problem: problem);
    }
    if (!FlutterForgeAI.config.shouldShowDevTools) {
      return FFSnapshot.empty(problem: problem);
    }

    final FFPackageInfo pkg = await _safe(
      () => FFPackageInfoCollector.collect(
          fallbackName: FlutterForgeAI.config.appName),
      FFPackageInfo(
        name: FlutterForgeAI.config.appName,
        version: '0.0.0',
        buildNumber: '0',
        packageName: 'unknown',
      ),
    );
    final FFDeviceInfo device = await _safe(
        FFDeviceInfoCollector.collect, const FFDeviceInfo(platform: 'unknown'));

    final Map<String, Object?> databaseSection = await _collectDb();
    final Map<String, Object?> apiSection = _collectApi();
    final Map<String, Object?> stateSection = _collectState();
    final Map<String, Object?> logSection = _collectLogs();

    final FFSnapshot snapshot = FFSnapshot(
      flutterForgeVersion: FFConstants.packageVersion,
      generatedAt: DateTime.now().toUtc(),
      problem: problem,
      app: <String, Object?>{
        ...pkg.toJson(),
        'debug_mode': FlutterForgeAI.config.isDebug,
        'configured_base_url': FlutterForgeAI.config.baseUrl,
      },
      device: <String, Object?>{
        ...device.toJson(),
        'platform_name': FFPlatformChecker.name,
      },
      database: databaseSection,
      apiLogs: apiSection,
      appState: stateSection,
      logs: logSection,
    );

    if (FlutterForgeAI.config.persistSnapshots) {
      await _persist(snapshot);
    }

    FFLogger.info(
        'Snapshot generated (${snapshot.toPrettyJson().length} chars)',
        tag: 'snapshot');
    return snapshot;
  }

  static Future<Map<String, Object?>> _collectDb() async {
    try {
      if (!FFDbHelper.instance.isInitialized) {
        return const <String, Object?>{'initialized': false};
      }
      final Database db = FFDbHelper.instance.database;
      final FFDbSchemaReader reader = FFDbSchemaReader(db);
      final List<String> tables = await reader.getAllTables();
      final List<Map<String, Object?>> describe = <Map<String, Object?>>[];
      for (final String t in tables) {
        final List<FFDbColumn> columns = await reader.getColumns(t);
        final int count = await reader.getRowCount(t);
        final List<Map<String, Object?>> sample = await reader.getSampleRows(t);
        describe.add(<String, Object?>{
          'name': t,
          'columns':
              columns.map((FFDbColumn c) => c.toJson()).toList(growable: false),
          'row_count': count,
          'sample_rows': sample,
        });
      }
      return <String, Object?>{
        'name': FlutterForgeAI.config.dbName,
        'version': FlutterForgeAI.config.dbVersion,
        'tables': describe,
      };
    } catch (e) {
      return <String, Object?>{'error': e.toString()};
    }
  }

  static Map<String, Object?> _collectApi() {
    try {
      if (!FFApiClient.instance.isInitialized) {
        return const <String, Object?>{'initialized': false};
      }
      final List<FFApiCall> all = FFApiClient.instance.store.getAll();
      final List<FFApiCall> failed =
          FFApiClient.instance.store.getFailedCalls();
      // Keep only the 25 most recent to avoid bloat.
      final List<FFApiCall> recent = all.reversed.take(25).toList();
      return <String, Object?>{
        'total_count': all.length,
        'failed_count': failed.length,
        'recent_calls': recent.map((FFApiCall c) => c.toJson()).toList(),
      };
    } catch (e) {
      return <String, Object?>{'error': e.toString()};
    }
  }

  static Map<String, Object?> _collectState() {
    try {
      final FFStateStore store = FlutterForgeAI.stateStore;
      final Map<String, FFStateChange> active = store.activeProviders;
      final List<FFStateChange> recent =
          store.getAllNewestFirst().take(40).toList();
      return <String, Object?>{
        'active_providers': active.values
            .map((FFStateChange c) => <String, Object?>{
                  'name': c.providerName,
                  'type': c.providerType,
                  'current_value': c.newValue,
                  'last_updated': c.timestamp.toIso8601String(),
                })
            .toList(growable: false),
        'recent_changes': recent.map((FFStateChange c) => c.toJson()).toList(),
      };
    } catch (e) {
      return <String, Object?>{'error': e.toString()};
    }
  }

  static Map<String, Object?> _collectLogs() {
    try {
      if (!FFLogger.isInitialized) {
        return const <String, Object?>{'initialized': false};
      }
      final List<FFLogEntry> all = FFLogger.store.getAll();
      return <String, Object?>{
        'total_count': all.length,
        'error_count': FFLogger.store.getErrors().length,
        'warning_count': FFLogger.store.getWarnings().length,
        'recent_entries':
            all.reversed.take(60).map((FFLogEntry e) => e.toJson()).toList(),
      };
    } catch (e) {
      return <String, Object?>{'error': e.toString()};
    }
  }

  /// Copies [snapshot] to the system clipboard as pretty JSON.
  static Future<bool> copyToClipboard(FFSnapshot snapshot) =>
      FFClipboardHelper.copy(snapshot.toPrettyJson());

  /// Writes the snapshot to a temp file and returns the [File].
  ///
  /// Unsupported on web; returns null there.
  static Future<File?> saveToFile(FFSnapshot snapshot) async {
    if (FFPlatformChecker.isWeb) return null;
    try {
      final Directory dir = Directory.systemTemp;
      final String name =
          'flutterforge_snapshot_${snapshot.generatedAt.millisecondsSinceEpoch}.json';
      final File file = File(p.join(dir.path, name));
      await file.writeAsString(snapshot.toPrettyJson());
      FFLogger.info('Snapshot written to ${file.path}', tag: 'snapshot');
      return file;
    } catch (e, st) {
      FFLogger.error('Snapshot save failed',
          error: e, stackTrace: st, tag: 'snapshot');
      return null;
    }
  }

  /// Shares the snapshot via the platform share sheet.
  static Future<void> share(FFSnapshot snapshot, {String? subject}) async {
    try {
      final String resolvedSubject = subject ?? 'FlutterForge AI Debug Snapshot';
      final File? file = await saveToFile(snapshot);
      final ShareParams params = file != null
          ? ShareParams(
              subject: resolvedSubject,
              files: <XFile>[XFile(file.path)],
            )
          : ShareParams(
              subject: resolvedSubject,
              text: snapshot.toPrettyJson(),
            );
      await SharePlus.instance.share(params);
    } catch (e, st) {
      FFLogger.error('Snapshot share failed',
          error: e, stackTrace: st, tag: 'snapshot');
    }
  }

  /// Reads the last persisted snapshot, if any.
  static Future<String?> lastPersistedJson() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString(_prefsKey);
    } catch (_) {
      return null;
    }
  }

  static Future<void> _persist(FFSnapshot snapshot) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, snapshot.toPrettyJson());
    } catch (_) {
      // Persistence is best-effort.
    }
  }

  static Future<T> _safe<T>(Future<T> Function() body, T fallback) async {
    try {
      return await body();
    } catch (_) {
      return fallback;
    }
  }
}
