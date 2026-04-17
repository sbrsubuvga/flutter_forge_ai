import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../utils/ff_constants.dart';

/// The structured output of [FFSnapshotGenerator.generate].
///
/// A snapshot bundles every useful piece of runtime context into a single
/// JSON-encodable object that can be copied/pasted to an AI assistant.
@immutable
class FFSnapshot {
  /// Creates a snapshot.
  const FFSnapshot({
    required this.flutterForgeVersion,
    required this.generatedAt,
    required this.app,
    required this.device,
    required this.database,
    required this.apiLogs,
    required this.appState,
    required this.logs,
    this.problem,
  });

  /// Package version that produced the snapshot.
  final String flutterForgeVersion;

  /// UTC timestamp of generation.
  final DateTime generatedAt;

  /// Free-form user-provided problem description.
  final String? problem;

  /// App identity section.
  final Map<String, Object?> app;

  /// Device identity section.
  final Map<String, Object?> device;

  /// Database schema / row counts / sample rows.
  final Map<String, Object?> database;

  /// Recent API calls and summary stats.
  final Map<String, Object?> apiLogs;

  /// Active providers + recent state changes.
  final Map<String, Object?> appState;

  /// Recent logs and summary stats.
  final Map<String, Object?> logs;

  /// Converts this snapshot to a JSON-serialisable map.
  Map<String, Object?> toJson() => <String, Object?>{
        'flutterforge_version': flutterForgeVersion,
        'generated_at': generatedAt.toUtc().toIso8601String(),
        'problem': problem,
        'app': app,
        'device': device,
        'database': database,
        'api_logs': apiLogs,
        'app_state': appState,
        'logs': logs,
      };

  /// Pretty-printed JSON string.
  String toPrettyJson() => const JsonEncoder.withIndent('  ').convert(toJson());

  /// Constructs a minimal empty snapshot — useful when the SDK has not been
  /// initialised but a snapshot is still requested.
  factory FFSnapshot.empty({String? problem}) => FFSnapshot(
        flutterForgeVersion: FFConstants.packageVersion,
        generatedAt: DateTime.now().toUtc(),
        problem: problem,
        app: const <String, Object?>{'name': 'Unknown'},
        device: const <String, Object?>{'platform': 'unknown'},
        database: const <String, Object?>{'tables': <Object?>[]},
        apiLogs: const <String, Object?>{
          'total_count': 0,
          'failed_count': 0,
          'recent_calls': <Object?>[],
        },
        appState: const <String, Object?>{
          'active_providers': <Object?>[],
          'recent_changes': <Object?>[],
        },
        logs: const <String, Object?>{
          'total_count': 0,
          'error_count': 0,
          'warning_count': 0,
          'recent_entries': <Object?>[],
        },
      );
}
