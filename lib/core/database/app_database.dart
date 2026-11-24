import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'migrations/migration_v1.dart';

class AppDatabase {
  AppDatabase._();

  static const String dbName = 'jatra_nova_demo.db';
  static const int dbVersion = 1;

  static Database? _instance;

  static Future<Database> get instance async {
    _instance ??= await openAppDatabase();
    return _instance!;
  }

  static Future<Database> openAppDatabase({String? overridePath}) async {
    final String dbPath;
    if (overridePath != null) {
      dbPath = overridePath;
    } else {
      final databasesPath = await getDatabasesPath();
      dbPath = p.join(databasesPath, dbName);
    }

    return await openDatabase(
      dbPath,
      version: dbVersion,
      onConfigure: (db) async {
        // Enforce SQLite Foreign Key constraints for all connections
        await db.execute('PRAGMA foreign_keys = ON;');
      },
      onCreate: (db, version) async {
        await MigrationV1.execute(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Versioned schema upgrades will be dispatched here
      },
    );
  }

  static Future<void> close() async {
    if (_instance != null && _instance!.isOpen) {
      await _instance!.close();
      _instance = null;
    }
  }
}
