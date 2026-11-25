import 'package:injectable/injectable.dart';
import 'package:jatra_nova/core/database/app_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

/// Registers external asynchronous dependencies for `get_it`.
@module
abstract class ServiceModule {
  @preResolve
  Future<SharedPreferences> get sharedPreferences =>
      SharedPreferences.getInstance();

  @preResolve
  Future<Database> get database => AppDatabase.instance.database;

  @singleton
  AppDatabase get appDatabase => AppDatabase.instance;
}
