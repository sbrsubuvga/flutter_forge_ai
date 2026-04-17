import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../logger/ff_logger.dart';

/// Attempts to enable the optional `sqflite_dev` web workbench.
///
/// `sqflite_dev` is an optional peer dependency — when present, its extension
/// `Database.enableWorkbench(...)` starts a localhost HTTP server exposing the
/// SQLite file. If the package is not present (or the method is missing on
/// this platform) this helper logs a warning and no-ops.
class FFDbDebugEnabler {
  FFDbDebugEnabler._();

  /// Returns true if the workbench was (probably) started successfully.
  ///
  /// The helper never throws — failures are captured and logged.
  // ignore: avoid_dynamic_calls — intentional: optional peer dependency.
  static Future<bool> enable({
    required Database database,
    required bool enabled,
    required int port,
    required String name,
  }) async {
    if (kReleaseMode || !enabled) return false;
    try {
      final dynamic db = database;
      // ignore: avoid_dynamic_calls — sqflite_dev extension method
      await db.enableWorkbench(
        webDebug: true,
        webDebugPort: port,
        webDebugName: name,
      );
      FFLogger.info(
        'sqflite_dev workbench ready at http://localhost:$port',
        tag: 'db',
      );
      return true;
    } on NoSuchMethodError {
      FFLogger.debug(
        'sqflite_dev not installed — workbench disabled. '
        'Add `sqflite_dev` to dev_dependencies to enable.',
        tag: 'db',
      );
      return false;
    } catch (e, st) {
      FFLogger.warning(
        'Could not enable sqflite_dev workbench: $e',
        tag: 'db',
      );
      FFLogger.debug(st.toString(), tag: 'db');
      return false;
    }
  }
}
