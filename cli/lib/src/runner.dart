import 'package:args/command_runner.dart';

import 'commands/doctor_command.dart';
import 'commands/init_command.dart';
import 'commands/snapshot_command.dart';
import 'commands/version_command.dart';
import 'constants.dart';
import 'logger.dart';

/// `flutterforge` CLI entry.
class FlutterForgeRunner extends CommandRunner<int> {
  /// Creates a runner. Optional [logger] lets tests inject capture.
  FlutterForgeRunner({CliLogger? logger})
      : _logger = logger ?? CliLogger(),
        super(
          'flutterforge',
          'FlutterForge AI command-line companion (v$kCliVersion).',
        ) {
    argParser
      ..addFlag('verbose',
          abbr: 'v', negatable: false, help: 'Emit debug output.')
      ..addFlag('version',
          negatable: false, help: 'Print the CLI version and exit.');
    addCommand(InitCommand(_logger));
    addCommand(DoctorCommand(_logger));
    addCommand(SnapshotCommand(_logger));
    addCommand(VersionCommand(_logger));
  }

  final CliLogger _logger;

  @override
  Future<int?> run(Iterable<String> args) async {
    try {
      final results = parse(args);
      if (results['version'] == true) {
        _logger.info('flutterforge $kCliVersion');
        return 0;
      }
      return await runCommand(results) ?? 0;
    } on UsageException catch (e) {
      _logger.error(e.message);
      _logger.info('');
      _logger.info(e.usage);
      return 64;
    }
  }
}
