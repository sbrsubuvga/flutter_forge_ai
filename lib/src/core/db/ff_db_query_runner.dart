import 'package:sqflite/sqflite.dart';

import '../logger/ff_logger.dart';

/// Result of running a raw SQL query through [FFDbQueryRunner].
class FFDbQueryResult {
  /// Creates a result.
  const FFDbQueryResult({
    required this.sql,
    required this.durationMs,
    this.rows,
    this.rowsAffected,
    this.error,
  });

  /// The SQL that was executed.
  final String sql;

  /// Wall-clock duration of the execution.
  final int durationMs;

  /// Rows returned by a SELECT.
  final List<Map<String, Object?>>? rows;

  /// Number of rows affected by UPDATE/DELETE.
  final int? rowsAffected;

  /// Non-null if the query failed.
  final String? error;

  /// Whether execution succeeded.
  bool get isSuccess => error == null;

  /// JSON representation (for snapshots).
  Map<String, Object?> toJson() => <String, Object?>{
        'sql': sql,
        'duration_ms': durationMs,
        'rows': rows,
        'rows_affected': rowsAffected,
        'error': error,
      };
}

/// Safely runs arbitrary SQL provided from the devtools UI.
///
/// Treats everything as a raw query and captures errors so an invalid
/// statement never crashes the app.
class FFDbQueryRunner {
  /// Creates a runner bound to [db].
  const FFDbQueryRunner(this.db);

  /// Database to run statements against.
  final Database db;

  /// Executes [sql]. If the statement is a SELECT, [FFDbQueryResult.rows] is
  /// populated; otherwise [FFDbQueryResult.rowsAffected] reflects the change.
  Future<FFDbQueryResult> run(
    String sql, {
    List<Object?>? arguments,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final Stopwatch sw = Stopwatch()..start();
    try {
      final String trimmed = sql.trim();
      if (trimmed.isEmpty) {
        return FFDbQueryResult(
          sql: sql,
          durationMs: 0,
          error: 'Empty SQL statement',
        );
      }
      final bool isSelect = trimmed.toUpperCase().startsWith('SELECT') ||
          trimmed.toUpperCase().startsWith('PRAGMA') ||
          trimmed.toUpperCase().startsWith('EXPLAIN');

      if (isSelect) {
        final List<Map<String, Object?>> rows =
            await db.rawQuery(sql, arguments).timeout(timeout);
        sw.stop();
        FFLogger.debug(
          'query (${sw.elapsedMilliseconds}ms, ${rows.length} rows): $sql',
          tag: 'db',
        );
        return FFDbQueryResult(
          sql: sql,
          durationMs: sw.elapsedMilliseconds,
          rows: rows,
        );
      } else {
        final int changes = await db.rawUpdate(sql, arguments).timeout(timeout);
        sw.stop();
        FFLogger.debug(
          'mutation (${sw.elapsedMilliseconds}ms, $changes rows): $sql',
          tag: 'db',
        );
        return FFDbQueryResult(
          sql: sql,
          durationMs: sw.elapsedMilliseconds,
          rowsAffected: changes,
        );
      }
    } catch (e, st) {
      sw.stop();
      FFLogger.error(
        'SQL failed: $sql',
        error: e,
        stackTrace: st,
        tag: 'db',
      );
      return FFDbQueryResult(
        sql: sql,
        durationMs: sw.elapsedMilliseconds,
        error: e.toString(),
      );
    }
  }
}
