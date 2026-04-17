import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';

import '../logger.dart';

/// Reads an AI Debug Snapshot file (produced by
/// `FFSnapshotGenerator.saveToFile`) and pretty-prints it, or emits an
/// AI-ready prompt wrapping it.
class SnapshotCommand extends Command<int> {
  /// Creates the command.
  SnapshotCommand(this._logger) {
    addSubcommand(_ViewSubcommand(_logger));
    addSubcommand(_PromptSubcommand(_logger));
    addSubcommand(_SummarySubcommand(_logger));
  }

  final CliLogger _logger;

  @override
  String get name => 'snapshot';

  @override
  String get description =>
      'Inspect / transform an AI Debug Snapshot JSON file.';
}

abstract class _SnapshotSubcommand extends Command<int> {
  _SnapshotSubcommand(this._logger);

  final CliLogger _logger;

  Map<String, Object?> _loadJson() {
    final List<String> rest = argResults!.rest;
    if (rest.isEmpty) {
      _logger.error('Missing path to snapshot JSON file.');
      printUsage();
      throw const _ExitWith(64);
    }
    final File f = File(rest.first);
    if (!f.existsSync()) {
      _logger.error('File not found: ${f.path}');
      throw const _ExitWith(66);
    }
    try {
      return jsonDecode(f.readAsStringSync()) as Map<String, Object?>;
    } catch (e) {
      _logger.error('Invalid JSON in ${f.path}: $e');
      throw const _ExitWith(65);
    }
  }

  @override
  Future<int> run() async {
    try {
      return await body();
    } on _ExitWith catch (e) {
      return e.code;
    }
  }

  /// Subclasses override this instead of [run].
  Future<int> body();
}

class _ViewSubcommand extends _SnapshotSubcommand {
  _ViewSubcommand(super.logger);

  @override
  String get name => 'view';

  @override
  String get description => 'Pretty-print a snapshot JSON file.';

  @override
  String get invocation => 'flutterforge snapshot view <file.json>';

  @override
  Future<int> body() async {
    final Map<String, Object?> json = _loadJson();
    _logger.info(const JsonEncoder.withIndent('  ').convert(json));
    return 0;
  }
}

class _PromptSubcommand extends _SnapshotSubcommand {
  _PromptSubcommand(super.logger) {
    argParser.addOption(
      'problem',
      abbr: 'p',
      help: 'Optional symptom description to prepend.',
    );
  }

  @override
  String get name => 'prompt';

  @override
  String get description =>
      'Emit an AI-ready prompt wrapping the snapshot (pipe into pbcopy / xclip).';

  @override
  String get invocation =>
      'flutterforge snapshot prompt <file.json> [--problem "..."]';

  @override
  Future<int> body() async {
    final Map<String, Object?> json = _loadJson();
    final String? problem = argResults!['problem'] as String?;
    final String pretty = const JsonEncoder.withIndent('  ').convert(json);
    final String body = '''
I'm debugging a Flutter app. Here's the complete app context captured by
FlutterForge AI. Please analyse and suggest a fix.

PROBLEM: ${problem ?? json['problem'] ?? '(not specified)'}

APP CONTEXT:
```json
$pretty
```

Please:
1. Identify the root cause.
2. Suggest specific code fixes.
3. Point to the exact provider / API call / DB query that's failing.
''';
    stdout.write(body);
    return 0;
  }
}

class _SummarySubcommand extends _SnapshotSubcommand {
  _SummarySubcommand(super.logger);

  @override
  String get name => 'summary';

  @override
  String get description => 'Print a terse one-paragraph summary.';

  @override
  String get invocation => 'flutterforge snapshot summary <file.json>';

  @override
  Future<int> body() async {
    final Map<String, Object?> json = _loadJson();
    final Map<String, Object?> app =
        (json['app'] as Map<String, Object?>?) ?? const <String, Object?>{};
    final Map<String, Object?> device =
        (json['device'] as Map<String, Object?>?) ?? const <String, Object?>{};
    final Map<String, Object?> apiLogs =
        (json['api_logs'] as Map<String, Object?>?) ??
            const <String, Object?>{};
    final Map<String, Object?> logs =
        (json['logs'] as Map<String, Object?>?) ?? const <String, Object?>{};

    _logger.info(
        'FlutterForge snapshot v${json['flutterforge_version'] ?? '?'} — '
        '${app['name']} v${app['version']} '
        '(${device['platform']} ${device['os_version'] ?? ''} ${device['model'] ?? ''})');
    _logger.info(
        'API: total=${apiLogs['total_count']}, failed=${apiLogs['failed_count']} · '
        'Logs: total=${logs['total_count']}, errors=${logs['error_count']}, '
        'warnings=${logs['warning_count']}');
    if (json['problem'] != null) {
      _logger.info('Problem: ${json['problem']}');
    }
    return 0;
  }
}

class _ExitWith implements Exception {
  const _ExitWith(this.code);
  final int code;
}
