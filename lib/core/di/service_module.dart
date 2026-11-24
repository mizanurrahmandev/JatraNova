import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../database/app_database.dart';

@module
abstract class ServiceModule {
  @preResolve
  Future<SharedPreferences> get sharedPreferences => SharedPreferences.getInstance();

  @preResolve
  Future<Database> get database => AppDatabase.openAppDatabase();
}
