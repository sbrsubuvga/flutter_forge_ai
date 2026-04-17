import 'package:sqflite/sqflite.dart';

/// One column description returned by [FFDbSchemaReader.getColumns].
class FFDbColumn {
  /// Creates a column descriptor.
  const FFDbColumn({
    required this.name,
    required this.type,
    required this.notNull,
    required this.primaryKey,
    this.defaultValue,
  });

  /// Column name.
  final String name;

  /// Declared SQLite type (INTEGER, TEXT, REAL, ...).
  final String type;

  /// Whether NOT NULL is set.
  final bool notNull;

  /// Whether the column is part of the primary key.
  final bool primaryKey;

  /// Default value as declared in `CREATE TABLE`.
  final Object? defaultValue;

  /// JSON representation for snapshots.
  Map<String, Object?> toJson() => <String, Object?>{
        'name': name,
        'type': type,
        'nullable': !notNull,
        'primaryKey': primaryKey,
        if (defaultValue != null) 'default': defaultValue,
      };
}

/// Reads tables, columns, and row counts from a `sqflite` [Database].
///
/// All methods are read-only and safe to call on a production DB.
class FFDbSchemaReader {
  /// Creates a reader bound to [db].
  const FFDbSchemaReader(this.db);

  /// The database to inspect.
  final Database db;

  /// All user tables (excludes sqlite_* internals).
  Future<List<String>> getAllTables() async {
    final List<Map<String, Object?>> rows = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table' "
      "AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'android_metadata' "
      'ORDER BY name',
    );
    return rows
        .map((Map<String, Object?> r) => r['name']?.toString() ?? '')
        .where((String s) => s.isNotEmpty)
        .toList(growable: false);
  }

  /// All columns for [table].
  Future<List<FFDbColumn>> getColumns(String table) async {
    final List<Map<String, Object?>> rows =
        await db.rawQuery('PRAGMA table_info(${_quote(table)})');
    return rows
        .map((Map<String, Object?> r) => FFDbColumn(
              name: r['name']?.toString() ?? '',
              type: r['type']?.toString() ?? 'UNKNOWN',
              notNull: (r['notnull'] as int? ?? 0) == 1,
              primaryKey: (r['pk'] as int? ?? 0) > 0,
              defaultValue: r['dflt_value'],
            ))
        .toList(growable: false);
  }

  /// Row count of [table]. Returns -1 if the count query fails.
  Future<int> getRowCount(String table) async {
    try {
      final List<Map<String, Object?>> rows =
          await db.rawQuery('SELECT COUNT(*) AS c FROM ${_quote(table)}');
      return (rows.first['c'] as int?) ?? 0;
    } catch (_) {
      return -1;
    }
  }

  /// Returns up to [limit] rows from [table] (defaults to 10).
  Future<List<Map<String, Object?>>> getSampleRows(
    String table, {
    int limit = 10,
  }) async {
    try {
      return await db.rawQuery(
        'SELECT * FROM ${_quote(table)} LIMIT ?',
        <Object?>[limit],
      );
    } catch (_) {
      return const <Map<String, Object?>>[];
    }
  }

  /// SQLite double-quotes the identifier to protect against reserved words.
  static String _quote(String identifier) =>
      '"${identifier.replaceAll('"', '""')}"';
}
