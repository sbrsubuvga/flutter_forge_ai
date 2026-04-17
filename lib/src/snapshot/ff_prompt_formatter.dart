import 'ff_snapshot_model.dart';

/// Converts an [FFSnapshot] into a prompt tuned for AI assistants.
class FFPromptFormatter {
  FFPromptFormatter._();

  /// Produces a ready-to-paste prompt containing the snapshot JSON.
  static String format(FFSnapshot snapshot) {
    final String problem =
        (snapshot.problem == null || snapshot.problem!.trim().isEmpty)
            ? '(not specified — please infer from context below)'
            : snapshot.problem!.trim();

    return '''I'm debugging a Flutter app. Here's the complete app context captured by
FlutterForge AI. Please analyse and suggest a fix.

PROBLEM: $problem

APP CONTEXT:
```json
${snapshot.toPrettyJson()}
```

Please:
1. Identify the root cause.
2. Suggest specific code fixes (include file paths if visible).
3. Point to the exact provider / API call / DB query that is failing.
4. Flag any anomalies in the logs or recent state changes.
''';
  }

  /// Short variant — metadata + stats only, no JSON dump. Useful for brief
  /// "what's going on?" questions where the full snapshot is overkill.
  static String summary(FFSnapshot snapshot) {
    final Map<String, Object?> apiLogs = snapshot.apiLogs;
    final Map<String, Object?> logs = snapshot.logs;
    return '''Flutter app summary via FlutterForge AI v${snapshot.flutterForgeVersion}

App: ${snapshot.app['name']} v${snapshot.app['version']} (${snapshot.app['package_name']})
Device: ${snapshot.device['platform']} ${snapshot.device['os_version'] ?? ''} ${snapshot.device['model'] ?? ''}

API calls: total=${apiLogs['total_count']}, failed=${apiLogs['failed_count']}
Logs:      total=${logs['total_count']}, errors=${logs['error_count']}, warnings=${logs['warning_count']}

Problem: ${snapshot.problem ?? '(not specified)'}
''';
  }
}
