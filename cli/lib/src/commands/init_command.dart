import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

import '../constants.dart';
import '../logger.dart';
import '../main_dart_wiring.dart';

/// Adds `flutterforge_ai` to an existing Flutter project's `pubspec.yaml`,
/// optionally patches `lib/main.dart` when it matches a known template, and
/// optionally runs `flutter pub get`.
class InitCommand extends Command<int> {
  /// Creates the command.
  InitCommand(this._logger) {
    argParser
      ..addOption(
        'path',
        abbr: 'p',
        defaultsTo: '.',
        help: 'Path to the Flutter project root (must contain pubspec.yaml).',
      )
      ..addFlag(
        'include-riverpod',
        defaultsTo: true,
        help: 'Add flutter_riverpod if not already present.',
      )
      ..addFlag(
        'run-pub-get',
        defaultsTo: true,
        help: 'Run `flutter pub get` after editing pubspec.yaml.',
      )
      ..addFlag(
        'auto-wire',
        negatable: false,
        help: 'Patch lib/main.dart when it matches a known template. A '
            'backup of the original is written to lib/main.dart.bak.',
      )
      ..addOption(
        'app-name',
        help: 'Used inside the generated main.dart (auto-wire mode). '
            'Defaults to the pubspec `name` field.',
      )
      ..addFlag(
        'dry-run',
        negatable: false,
        help: 'Print what would change without writing files.',
      );
  }

  final CliLogger _logger;

  @override
  String get name => 'init';

  @override
  String get description =>
      'Scaffold FlutterForge AI into an existing Flutter project.';

  @override
  Future<int> run() async {
    final String root = argResults!['path'] as String;
    final bool dryRun = argResults!['dry-run'] as bool;
    final bool includeRiverpod = argResults!['include-riverpod'] as bool;
    final bool runPubGet = argResults!['run-pub-get'] as bool;
    final bool autoWire = argResults!['auto-wire'] as bool;
    final String? appNameArg = argResults!['app-name'] as String?;

    final File pubspec = File(p.join(root, 'pubspec.yaml'));
    if (!pubspec.existsSync()) {
      _logger.error('pubspec.yaml not found at ${pubspec.path}');
      _logger.hint('Pass --path to point at your Flutter project root.');
      return 1;
    }

    final String original = pubspec.readAsStringSync();
    final YamlEditor editor = YamlEditor(original);
    final YamlMap doc = loadYaml(original) as YamlMap;

    if (!_isFlutterProject(doc)) {
      _logger.error('pubspec.yaml at ${pubspec.path} is not a Flutter app.');
      _logger.hint('dependencies must include `flutter: sdk: flutter`.');
      return 1;
    }

    final String appName = appNameArg ?? doc['name']?.toString() ?? 'My App';

    final YamlMap? deps = doc['dependencies'] as YamlMap?;
    final bool hasFlutterforge = deps != null && deps.containsKey(kPackageName);
    final bool hasRiverpod =
        deps != null && deps.containsKey('flutter_riverpod');

    if (!hasFlutterforge) {
      editor.update(
        <String>['dependencies', kPackageName],
        kPackageVersionConstraint,
      );
      _logger.success('adding $kPackageName: $kPackageVersionConstraint');
    } else {
      _logger.dim('$kPackageName already listed — leaving untouched.');
    }

    if (includeRiverpod && !hasRiverpod) {
      editor.update(
        <String>['dependencies', 'flutter_riverpod'],
        '^2.5.1',
      );
      _logger.success('adding flutter_riverpod: ^2.5.1');
    }

    final String updatedPubspec = editor.toString();
    final bool pubspecChanged = updatedPubspec != original;

    if (!pubspecChanged) {
      _logger.info('pubspec.yaml already has everything it needs.');
    } else if (dryRun) {
      _logger.warning('--dry-run — pubspec.yaml NOT written.');
      _printDiff(original, updatedPubspec);
    } else {
      pubspec.writeAsStringSync(updatedPubspec);
      _logger.success('wrote ${pubspec.path}');
    }

    if (autoWire) {
      final int wireResult = await _autoWire(
        root: root,
        appName: appName,
        dryRun: dryRun,
      );
      if (wireResult != 0) return wireResult;
    }

    if (runPubGet && !dryRun) {
      await _runPubGet(root);
    }

    if (!autoWire) {
      _logger.info('');
      _logger.info('Next steps:');
      if (!runPubGet) _logger.hint('flutter pub get');
      _logger
          .hint('Paste the snippet below into `lib/main.dart` or equivalent.');
      _logger.info('');
      _logger.info(_mainSnippet(appName));
    }
    return 0;
  }

  /// Tries to patch `lib/main.dart`. Returns 0 on success / no-op, non-zero
  /// on failure.
  Future<int> _autoWire({
    required String root,
    required String appName,
    required bool dryRun,
  }) async {
    final File mainFile = File(p.join(root, 'lib', 'main.dart'));
    if (!mainFile.existsSync()) {
      _logger.warning('--auto-wire: lib/main.dart not found — skipping.');
      return 0;
    }
    final String original = mainFile.readAsStringSync();
    final WiringShape shape = MainDartWiring.classify(original);

    switch (shape) {
      case WiringShape.alreadyWired:
        _logger.dim('lib/main.dart already references FlutterForge — '
            'skipping auto-wire.');
        return 0;
      case WiringShape.unknown:
        _logger.warning(
          '--auto-wire: lib/main.dart does not match a known template. '
          'Refusing to modify it automatically.',
        );
        _logger.hint('Paste the snippet at the end of this output '
            'into main.dart manually.');
        return 0;
      case WiringShape.counterTemplate:
      case WiringShape.minimalMyApp:
        break;
    }

    final String wired;
    try {
      wired = MainDartWiring.wire(original, appName: appName);
    } on StateError catch (e) {
      _logger.error('Auto-wire failed: ${e.message}');
      return 1;
    }

    if (dryRun) {
      _logger.warning(
          '--dry-run — lib/main.dart NOT written. Preview of first 20 changed lines:');
      _printDiff(original, wired);
      return 0;
    }

    final File backup = File('${mainFile.path}.bak');
    backup.writeAsStringSync(original);
    mainFile.writeAsStringSync(wired);
    _logger.success('wrote ${mainFile.path}');
    _logger.dim('original backed up to ${backup.path}');
    return 0;
  }

  Future<void> _runPubGet(String root) async {
    _logger.info('');
    _logger.info('Running `flutter pub get`…');
    try {
      final ProcessResult result = await Process.run(
        'flutter',
        <String>['pub', 'get'],
        workingDirectory: root,
      );
      if (result.exitCode == 0) {
        _logger.success('flutter pub get OK');
      } else {
        _logger.warning('flutter pub get exited ${result.exitCode}. '
            'Run it manually to see the error.');
        final String stderr = result.stderr.toString();
        if (stderr.isNotEmpty) _logger.dim(stderr);
      }
    } catch (e) {
      _logger.warning('Could not run flutter: $e');
      _logger.hint('Run `flutter pub get` manually in $root.');
    }
  }

  bool _isFlutterProject(YamlMap doc) {
    final YamlMap? deps = doc['dependencies'] as YamlMap?;
    if (deps == null) return false;
    final Object? flutter = deps['flutter'];
    if (flutter is! YamlMap) return false;
    return flutter['sdk']?.toString() == 'flutter';
  }

  void _printDiff(String before, String after) {
    final List<String> a = before.split('\n');
    final List<String> b = after.split('\n');
    int shown = 0;
    for (int i = 0; i < b.length && shown < 40; i++) {
      if (i >= a.length || a[i] != b[i]) {
        _logger.dim('  ${b[i]}');
        shown++;
      }
    }
  }

  String _mainSnippet(String appName) => '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:$kPackageName/$kPackageName.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterForgeAI.init(
    config: const FFConfig(appName: '$appName'),
  );
  runApp(
    ProviderScope(
      observers: [FFStateObserver()],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (ctx, child) =>
          FFDevWrapper(child: child ?? const SizedBox.shrink()),
      home: const MyHomePage(),
    );
  }
}
''';
}
