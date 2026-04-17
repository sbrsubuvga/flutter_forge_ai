import 'package:flutterforge_ai_cli/flutterforge_ai_cli.dart';
import 'package:test/test.dart';

void main() {
  group('FlutterForgeRunner', () {
    late FlutterForgeRunner runner;
    setUp(() => runner = FlutterForgeRunner());

    test('--version prints and exits 0', () async {
      expect(await runner.run(<String>['--version']), 0);
    });

    test('unknown command returns 64', () async {
      expect(await runner.run(<String>['whatever']), 64);
    });

    test('version subcommand is registered', () async {
      expect(await runner.run(<String>['version']), 0);
    });

    test('help output mentions every command', () async {
      final String help = runner.usage;
      for (final String cmd in <String>['init', 'doctor', 'snapshot', 'version']) {
        expect(help, contains(cmd), reason: 'Missing $cmd in help');
      }
    });
  });
}
