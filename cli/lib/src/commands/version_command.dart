import 'package:args/command_runner.dart';

import '../constants.dart';
import '../logger.dart';

/// Prints CLI version.
class VersionCommand extends Command<int> {
  /// Creates the command.
  VersionCommand(this._logger);

  final CliLogger _logger;

  @override
  String get name => 'version';

  @override
  String get description => 'Print the CLI version and exit.';

  @override
  Future<int> run() async {
    _logger.info('flutterforge $kCliVersion');
    _logger.dim('targets $kPackageName $kPackageVersionConstraint');
    return 0;
  }
}
