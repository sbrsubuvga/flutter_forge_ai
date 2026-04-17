import 'dart:io';

import 'package:flutterforge_ai_cli/flutterforge_cli.dart';

Future<void> main(List<String> args) async {
  exitCode = await FlutterForgeRunner().run(args) ?? 0;
}
