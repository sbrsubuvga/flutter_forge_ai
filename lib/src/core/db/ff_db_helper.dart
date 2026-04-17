import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../../config/ff_config.dart';
import '../logger/ff_logger.dart';
import 'ff_db_debug_enabler.dart';

/// Callback signature for `onCreate`, `onUpgrade`, etc.
typedef FFDbMigrationCallback = Future<void> Function(
  Database db,
  int oldVersion,
  int newVersion,
);

/// Callback signature for `onCreate` which only receives the new version.
typedef FFDbCreateCallback = Future<void> Function(Database db, int version);

/// Singleton wrapper around `sqflite` that automatically:
///   * opens the DB at `getDatabasesPath()/config.dbName`
///   * starts the optional `sqflite_dev` web workbench in debug mode
///   * logs every mutation via [FFLogger] at debug level
class FFDbHelper {
  FFDbHelper._();

  static final FFDbHelper _instance = FFDbHelper._();

  /// Global singleton.
  static FFDbHelper get instance => _instance;

  Database? _db;
  FFConfig? _config;
  final Map<String, Database> _named = <String, Database>{};

  /// Returns the primary database. Must call [init] first.
  Database get database {
    final Database? db = _db;
    if (db == null) {
      throw StateError(
          'FFDbHelper.database accessed before FlutterForgeAI.init() ran.');
    }
    return db;
  }

  /// Whether the primary DB has been opened.
  bool get isInitialized => _db != null;

  /// Returns a previously registered named DB, or null.
  Database? named(String name) => _named[name];

  /// Opens the DB using [config], optionally starting the debug workbench.
  ///
  /// [onCreate], [onUpgrade], [onDowngrade] mirror `sqflite`'s callbacks.
  Future<Database> init(
    FFConfig config, {
    FFDbCreateCallback? onCreate,
    FFDbMigrationCallback? onUpgrade,
    FFDbMigrationCallback? onDowngrade,
  }) async {
    if (_db != null) return _db!;
    _config = config;
    final String dbDir = await getDatabasesPath();
    final String path = p.join(dbDir, config.dbName);

    FFLogger.debug('Opening database at $path', tag: 'db');
    final Database db = await openDatabase(
      path,
      version: config.dbVersion,
      onCreate: onCreate == null
          ? null
          : (Database db, int v) async => onCreate(db, v),
      onUpgrade: onUpgrade == null
          ? null
          : (Database db, int old, int now) async => onUpgrade(db, old, now),
      onDowngrade: onDowngrade == null
          ? null
          : (Database db, int old, int now) async => onDowngrade(db, old, now),
    );

    _db = db;

    await FFDbDebugEnabler.enable(
      database: db,
      enabled: config.enableDbWorkbench && config.shouldShowDevTools,
      port: config.dbWorkbenchPort,
      name: config.appName,
    );

    FFLogger.info('Database ready (${config.dbName} v${config.dbVersion})',
        tag: 'db');
    return db;
  }

  /// Registers an additional named [db] instance (multi-db apps).
  void registerDatabase(String name, Database db) {
    _named[name] = db;
    FFLogger.debug('Registered extra database "$name"', tag: 'db');
  }

  /// Thin wrappers that log every mutation via [FFLogger].
  Future<int> insert(
    String table,
    Map<String, Object?> values, {
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    FFLogger.debug('INSERT INTO $table -> keys=${values.keys.toList()}',
        tag: 'db');
    return database.insert(table, values, conflictAlgorithm: conflictAlgorithm);
  }

  /// Updates rows and logs the operation.
  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    FFLogger.debug('UPDATE $table where=$where', tag: 'db');
    return database.update(table, values, where: where, whereArgs: whereArgs);
  }

  /// Deletes rows and logs the operation.
  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    FFLogger.debug('DELETE FROM $table where=$where', tag: 'db');
    return database.delete(table, where: where, whereArgs: whereArgs);
  }

  /// Queries rows. Logging is kept at verbose level to avoid noise.
  Future<List<Map<String, Object?>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    FFLogger.verbose('SELECT $table where=$where limit=$limit', tag: 'db');
    return database.query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  /// Executes a raw SQL SELECT/UPDATE returning a list of rows.
  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    FFLogger.verbose('rawQuery: $sql', tag: 'db');
    return database.rawQuery(sql, arguments);
  }

  /// Closes the primary DB. Chiefly used by tests.
  Future<void> close() async {
    await _db?.close();
    _db = null;
    _config = null;
    _named.clear();
  }

  /// Config last used during [init], or null if never initialised.
  FFConfig? get config => _config;
}
