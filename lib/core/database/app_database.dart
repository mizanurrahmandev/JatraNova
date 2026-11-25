import 'package:injectable/injectable.dart';
import 'package:jatra_nova/core/database/migrations/migration_v1.dart';
import 'package:jatra_nova/core/database/seed/seed_data.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Singleton SQLite database manager for JatraNova.
///
/// Enforces `PRAGMA foreign_keys = ON` on every connection via [onConfigure],
/// separates DDL creation (`MigrationV1`) from deterministic seeding
/// (`SeedData`), and guards against repeated initialization.
class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static const int databaseVersion = 1;
  static const String databaseName = 'jatranova.db';

  Database? _database;
  Future<Database>? _openingFuture;

  DatabaseFactory? _factoryOverride;
  String? _pathOverride;
  bool _seedOnCreate = true;

  /// Configures database factory/path overrides (primarily for `sqflite_common_ffi`
  /// in-memory tests). Resets any open instance cleanly.
  static Future<void> configureForTesting({
    DatabaseFactory? databaseFactory,
    String? databasePath,
    bool seedOnCreate = true,
  }) async {
    await instance.close();
    instance._factoryOverride = databaseFactory;
    instance._pathOverride = databasePath;
    instance._seedOnCreate = seedOnCreate;
  }

  /// Restores default platform `sqflite` configuration after tests.
  static Future<void> resetConfiguration() async {
    await instance.close();
    instance._factoryOverride = null;
    instance._pathOverride = null;
    instance._seedOnCreate = true;
  }

  /// Returns the singleton [Database], initializing once safely under concurrent
  /// or repeated calls.
  Future<Database> get database {
    final existing = _database;
    if (existing != null && existing.isOpen) {
      return Future<Database>.value(existing);
    }
    return _openingFuture ??= _open();
  }

  Future<Database> _open() async {
    try {
      final dbPath = _pathOverride ??
          p.join(await getDatabasesPath(), databaseName);
      final factory = _factoryOverride;

      final options = OpenDatabaseOptions(
        version: databaseVersion,
        onConfigure: _onConfigure,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );

      final db = factory != null
          ? await factory.openDatabase(dbPath, options: options)
          : await openDatabase(
              dbPath,
              version: options.version,
              onConfigure: options.onConfigure,
              onCreate: options.onCreate,
              onUpgrade: options.onUpgrade,
            );

      _database = db;
      return db;
    } catch (_) {
      _openingFuture = null;
      rethrow;
    }
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    await MigrationV1.up(db);
    if (_seedOnCreate) {
      await SeedData.seed(db);
    }
  }

  Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    for (var targetVersion = oldVersion + 1;
        targetVersion <= newVersion;
        targetVersion++) {
      // Sequential v2+ migrations will be dispatched here without modifying v1.
    }
  }

  @disposeMethod
  Future<void> close() async {
    final db = _database;
    _database = null;
    _openingFuture = null;
    if (db != null && db.isOpen) {
      await db.close();
    }
  }
}
