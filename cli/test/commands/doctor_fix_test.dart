import 'dart:io';

import 'package:flutterforge_ai_cli/flutterforge_cli.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  late Directory tmp;
  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('flutterforge_fix_');
    File(p.join(tmp.path, 'pubspec.yaml')).writeAsStringSync('''
name: app
environment:
  sdk: ">=3.3.0 <4.0.0"
dependencies:
  flutter:
    sdk: flutter
''');
    Directory(p.join(tmp.path, 'lib')).createSync();
    File(p.join(tmp.path, 'lib', 'main.dart'))
        .writeAsStringSync('void main() {}');
  });
  tearDown(() async {
    if (tmp.existsSync()) await tmp.delete(recursive: true);
  });

  test('doctor --fix adds flutterforge_ai to pubspec', () async {
    final int? code = await FlutterForgeRunner().run(
      <String>['doctor', '--path', tmp.path, '--fix'],
    );

    // main.dart still missing init/FFDevWrapper, so remaining failures > 0,
    // but the pubspec check should now pass after --fix.
    final String pubspec =
        File(p.join(tmp.path, 'pubspec.yaml')).readAsStringSync();
    expect(pubspec, contains('flutterforge_ai:'));
    // init + FFDevWrapper are still missing → 2 failures expected.
    expect(code, 2);
  });

  test('doctor without --fix does not modify pubspec', () async {
    await FlutterForgeRunner().run(<String>['doctor', '--path', tmp.path]);
    final String pubspec =
        File(p.join(tmp.path, 'pubspec.yaml')).readAsStringSync();
    expect(pubspec, isNot(contains('flutterforge_ai:')));
  });
}
