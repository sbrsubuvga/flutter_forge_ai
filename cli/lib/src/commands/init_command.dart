import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

import '../constants.dart';
import '../logger.dart';

/// Adds `flutterforge_ai` to an existing Flutter project's `pubspec.yaml`
/// and prints the minimal wiring snippet the developer needs to paste into
/// `main.dart`.
///
/// Does NOT rewrite `main.dart` automatically — too many project-specific
/// shapes (MaterialApp vs GoRouter, ProviderScope placement, etc.) to do
/// that safely.
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

    final File pubspec = File(p.join(root, 'pubspec.yaml'));
    if (!pubspec.existsSync()) {
      _logger.error('pubspec.yaml not found at ${pubspec.path}');
      _logger.hint('Pass --path to point at your Flutter project root.');
      return 1;
    }

    final String original = pubspec.readAsStringSync();
    final YamlEditor editor = YamlEditor(original);
    final YamlMap doc = loadYaml(original) as YamlMap;

    if (_isFlutterProject(doc) == false) {
      _logger.error('pubspec.yaml at ${pubspec.path} is not a Flutter app.');
      _logger.hint('dependencies must include `flutter: sdk: flutter`.');
      return 1;
    }

    final YamlMap? deps = doc['dependencies'] as YamlMap?;
    final bool hasFlutterforge =
        deps != null && deps.containsKey(kPackageName);
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

    if (editor.toString() == original) {
      _logger.info('pubspec.yaml already has everything it needs.');
    } else if (dryRun) {
      _logger.warning('--dry-run — pubspec.yaml NOT written.');
      _logger.dim('');
      _logger.dim('Diff preview (first 40 changed lines):');
      _printDiff(original, editor.toString());
    } else {
      pubspec.writeAsStringSync(editor.toString());
      _logger.success('wrote ${pubspec.path}');
    }

    _logger.info('');
    _logger.info('Next steps:');
    _logger.hint('flutter pub get');
    _logger.hint(
        'Paste the snippet below into your `lib/main.dart` or equivalent.');
    _logger.info('');
    _logger.info(_mainSnippet());
    return 0;
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

  String _mainSnippet() => '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:$kPackageName/$kPackageName.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterForgeAI.init(
    config: const FFConfig(appName: 'My App'),
  );
  runApp(
    ProviderScope(
      observers: [FFStateObserver()],
      child: MaterialApp(
        builder: (ctx, child) =>
            FFDevWrapper(child: child ?? const SizedBox.shrink()),
        home: const MyHomePage(),
      ),
    ),
  );
}
''';
}
