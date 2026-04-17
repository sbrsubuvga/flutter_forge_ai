import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

import '../constants.dart';
import '../logger.dart';

/// Auditable checks that an existing Flutter project has FlutterForge AI
/// wired up correctly.
///
/// Each check prints a ✓ or ✗ line; every failure emits a hint describing
/// the specific fix. Exit code is the number of failures.
///
/// Pass `--fix` to have the doctor attempt the safe remediations (adding
/// `flutterforge_ai` to `pubspec.yaml`). Anything that requires touching
/// `main.dart` is deferred to `flutterforge init --auto-wire`.
class DoctorCommand extends Command<int> {
  /// Creates the command.
  DoctorCommand(this._logger) {
    argParser
      ..addOption(
        'path',
        abbr: 'p',
        defaultsTo: '.',
        help: 'Path to the Flutter project root (must contain pubspec.yaml).',
      )
      ..addFlag(
        'fix',
        negatable: false,
        help: 'Apply safe remediations (pubspec.yaml edits). Does not '
            'rewrite main.dart — use `flutterforge init --auto-wire` for that.',
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
    final bool fix = argResults!['fix'] as bool;
    int failures = 0;
    int fixesApplied = 0;

    final File pubspec = File(p.join(root, 'pubspec.yaml'));
    if (!pubspec.existsSync()) {
      _logger.error('pubspec.yaml not found at ${pubspec.path}');
      _logger.hint('Pass --path to point at the Flutter project root.');
      return 1;
    }
    _logger.success('pubspec.yaml exists');

    YamlMap pubspecDoc = loadYaml(pubspec.readAsStringSync()) as YamlMap;
    YamlMap? deps = pubspecDoc['dependencies'] as YamlMap?;
    bool hasPackage = deps != null && deps.containsKey(kPackageName);

    if (!hasPackage) {
      if (fix) {
        final YamlEditor editor = YamlEditor(pubspec.readAsStringSync());
        editor.update(
          <String>['dependencies', kPackageName],
          kPackageVersionConstraint,
        );
        pubspec.writeAsStringSync(editor.toString());
        _logger.success('$kPackageName added to pubspec.yaml (--fix applied)');
        fixesApplied++;
        pubspecDoc = loadYaml(pubspec.readAsStringSync()) as YamlMap;
        deps = pubspecDoc['dependencies'] as YamlMap?;
        hasPackage = deps != null && deps.containsKey(kPackageName);
      } else {
        _logger.error('$kPackageName not listed in dependencies');
        _logger.hint('Run: flutterforge init  (or doctor --fix)');
        failures++;
      }
    } else {
      _logger.success('$kPackageName listed in dependencies');
    }

    final bool hasRiverpod =
        deps != null && deps.containsKey('flutter_riverpod');
    if (!hasRiverpod) {
      _logger.warning(
          'flutter_riverpod listed (optional, for FFStateObserver) — not configured');
      _logger.hint('Add to pubspec.yaml: flutter_riverpod: ^2.5.1');
    } else {
      _logger
          .success('flutter_riverpod listed (optional, for FFStateObserver)');
    }

    final File? mainFile = _findMainFile(root);
    if (mainFile == null) {
      _logger.error('lib/main.dart not found');
      _logger.hint('Create lib/main.dart or pass --path to the right project.');
      return failures + 1;
    }
    _logger.success('lib/main.dart found');

    final String source = mainFile.readAsStringSync();

    failures += _check(
      title: 'FlutterForgeAI.init(...) called',
      ok: source.contains('FlutterForgeAI.init'),
      hint: 'See: flutterforge init --auto-wire (patches main.dart for you).',
    );

    failures += _check(
      title: 'FFDevWrapper present',
      ok: source.contains('FFDevWrapper'),
      hint:
          'Wrap inside MaterialApp.builder: builder: (ctx, c) => FFDevWrapper(child: c!)',
    );

    _check(
      title: 'FFStateObserver registered (optional)',
      ok: source.contains('FFStateObserver'),
      hint:
          'ProviderScope(observers: [FFStateObserver()], child: ...) enables the State Viewer.',
      warnOnly: true,
    );

    _logger.info('');
    if (failures == 0) {
      _logger.success(fixesApplied > 0
          ? 'All checks passed ($fixesApplied fix applied).'
          : 'All checks passed.');
    } else {
      _logger.error('$failures check(s) failed.'
          '${fixesApplied > 0 ? ' ($fixesApplied fix applied.)' : ''}');
      if (!fix) {
        _logger.hint('Re-run with --fix to apply safe remediations '
            '(pubspec edits only).');
      }
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
