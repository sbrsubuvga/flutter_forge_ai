import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import '../constants.dart';
import '../logger.dart';

/// Auditable checks that an existing Flutter project has FlutterForge AI
/// wired up correctly.
///
/// Each check prints a ✓ or ✗ line; every failure emits a hint describing
/// the specific fix. Exit code is the number of failures.
class DoctorCommand extends Command<int> {
  /// Creates the command.
  DoctorCommand(this._logger) {
    argParser.addOption(
      'path',
      abbr: 'p',
      defaultsTo: '.',
      help: 'Path to the Flutter project root (must contain pubspec.yaml).',
    );
  }

  final CliLogger _logger;

  @override
  String get name => 'doctor';

  @override
  String get description =>
      'Check that the current Flutter project is wired up correctly.';

  @override
  Future<int> run() async {
    final String root = argResults!['path'] as String;
    int failures = 0;

    failures += _check(
      title: 'pubspec.yaml exists',
      ok: File(p.join(root, 'pubspec.yaml')).existsSync(),
      hint: 'Pass --path to point at the Flutter project root.',
    );

    if (failures > 0) return failures;

    final YamlMap pubspec = loadYaml(
      File(p.join(root, 'pubspec.yaml')).readAsStringSync(),
    ) as YamlMap;

    final YamlMap? deps = pubspec['dependencies'] as YamlMap?;
    final bool hasPackage =
        deps != null && deps.containsKey(kPackageName);
    failures += _check(
      title: '$kPackageName listed in dependencies',
      ok: hasPackage,
      hint: 'Run: flutterforge init',
    );

    final bool hasRiverpod =
        deps != null && deps.containsKey('flutter_riverpod');
    failures += _check(
      title: 'flutter_riverpod listed (optional, for FFStateObserver)',
      ok: hasRiverpod,
      hint: 'Add to pubspec.yaml: flutter_riverpod: ^2.5.1',
      warnOnly: true,
    );

    final File? mainFile = _findMainFile(root);
    failures += _check(
      title: 'lib/main.dart found',
      ok: mainFile != null,
      hint: 'Create lib/main.dart or pass --path to the right project.',
    );
    if (mainFile == null) return failures;

    final String source = mainFile.readAsStringSync();

    failures += _check(
      title: 'FlutterForgeAI.init(...) called',
      ok: source.contains('FlutterForgeAI.init'),
      hint: 'See: flutterforge init (prints the snippet).',
    );

    failures += _check(
      title: 'FFDevWrapper present',
      ok: source.contains('FFDevWrapper'),
      hint:
          'Wrap inside MaterialApp.builder: builder: (ctx, c) => FFDevWrapper(child: c!)',
    );

    failures += _check(
      title: 'FFStateObserver registered (optional)',
      ok: source.contains('FFStateObserver'),
      hint:
          'ProviderScope(observers: [FFStateObserver()], child: ...) enables the State Viewer.',
      warnOnly: true,
    );

    _logger.info('');
    if (failures == 0) {
      _logger.success('All checks passed.');
    } else {
      _logger.error('$failures check(s) failed.');
    }
    return failures;
  }

  int _check({
    required String title,
    required bool ok,
    required String hint,
    bool warnOnly = false,
  }) {
    if (ok) {
      _logger.success(title);
      return 0;
    }
    if (warnOnly) {
      _logger.warning('$title — not configured (optional)');
      _logger.hint(hint);
      return 0;
    }
    _logger.error(title);
    _logger.hint(hint);
    return 1;
  }

  File? _findMainFile(String root) {
    final File candidate = File(p.join(root, 'lib', 'main.dart'));
    return candidate.existsSync() ? candidate : null;
  }
}
