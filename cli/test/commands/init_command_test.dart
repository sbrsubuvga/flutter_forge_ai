import 'dart:io';

import 'package:flutterforge_ai_cli/flutterforge_ai_cli.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  late Directory tmp;
  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('flutterforge_cli_init_');
  });
  tearDown(() async {
    if (tmp.existsSync()) await tmp.delete(recursive: true);
  });

  const String validFlutterPubspec = '''
name: test_app
environment:
  sdk: ">=3.3.0 <4.0.0"
dependencies:
  flutter:
    sdk: flutter
''';

  test('adds flutterforge_ai to dependencies', () async {
    File(p.join(tmp.path, 'pubspec.yaml'))
        .writeAsStringSync(validFlutterPubspec);

    final FlutterForgeRunner runner = FlutterForgeRunner();
    final int? code = await runner.run(<String>[
      'init',
      '--path',
      tmp.path,
      '--no-include-riverpod',
    ]);

    expect(code, 0);
    final String updated =
        File(p.join(tmp.path, 'pubspec.yaml')).readAsStringSync();
    expect(updated, contains('flutterforge_ai:'));
  });

  test('refuses to run outside a Flutter project', () async {
    File(p.join(tmp.path, 'pubspec.yaml')).writeAsStringSync('''
name: not_a_flutter_app
environment:
  sdk: ">=3.3.0 <4.0.0"
dependencies: {}
''');
    final FlutterForgeRunner runner = FlutterForgeRunner();
    expect(await runner.run(<String>['init', '--path', tmp.path]), 1);
  });

  test('errors if pubspec.yaml is missing', () async {
    final FlutterForgeRunner runner = FlutterForgeRunner();
    expect(await runner.run(<String>['init', '--path', tmp.path]), 1);
  });

  test('--dry-run leaves pubspec untouched', () async {
    final File pubspec = File(p.join(tmp.path, 'pubspec.yaml'))
      ..writeAsStringSync(validFlutterPubspec);
    final FlutterForgeRunner runner = FlutterForgeRunner();
    await runner.run(<String>[
      'init',
      '--path',
      tmp.path,
      '--dry-run',
      '--no-include-riverpod',
    ]);
    expect(pubspec.readAsStringSync(), equals(validFlutterPubspec));
  });
}
