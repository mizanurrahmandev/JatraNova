import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/db_tables.dart';
import '../../../../core/database/seed/seed_data.dart';
import '../models/user_model.dart';

abstract class IAuthLocalDataSource {
  Future<UserModel?> findByIdentifier(String identifier);
  Future<UserModel?> findById(String id);
  Future<UserModel> createUser({
    required String fullName,
    required String mobile,
    required String email,
    required String password,
  });
  Future<bool> verifyCredentials({
    required String identifier,
    required String password,
  });
}

@Injectable(as: IAuthLocalDataSource)
class AuthLocalDataSourceImpl implements IAuthLocalDataSource {
  final Database _db;
  static const _uuid = Uuid();

  AuthLocalDataSourceImpl(this._db);

  @override
  Future<UserModel?> findByIdentifier(String identifier) async {
    final rows = await _db.query(
      DbTables.users,
      where: '${UserColumns.email} = ? OR ${UserColumns.mobile} = ?',
      whereArgs: [identifier, identifier],
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return UserModel.fromMap(rows.first);
  }

  @override
  Future<UserModel?> findById(String id) async {
    final rows = await _db.query(
      DbTables.users,
      where: '${UserColumns.id} = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return UserModel.fromMap(rows.first);
  }

  @override
  Future<bool> verifyCredentials({
    required String identifier,
    required String password,
  }) async {
    final expectedHash = SeedData.hashPassword(password);
    final rows = await _db.query(
      DbTables.users,
      columns: [UserColumns.id],
      where: '(${UserColumns.email} = ? OR ${UserColumns.mobile} = ?) AND ${UserColumns.passwordHash} = ?',
      whereArgs: [identifier, identifier, expectedHash],
      limit: 1,
    );

    return rows.isNotEmpty;
  }

  @override
  Future<UserModel> createUser({
    required String fullName,
    required String mobile,
    required String email,
    required String password,
  }) async {
    final nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;
    final userId = 'user_${_uuid.v4().substring(0, 8)}';
    final passwordHash = SeedData.hashPassword(password);

    final userMap = {
      UserColumns.id: userId,
      UserColumns.fullName: fullName,
      UserColumns.mobile: mobile,
      UserColumns.email: email,
      UserColumns.passwordHash: passwordHash,
      UserColumns.avatarPath: null,
      UserColumns.isActive: 1,
      UserColumns.createdAt: nowMs,
      UserColumns.updatedAt: nowMs,
    };

    await _db.insert(DbTables.users, userMap);
    return UserModel.fromMap(userMap);
  }
}
