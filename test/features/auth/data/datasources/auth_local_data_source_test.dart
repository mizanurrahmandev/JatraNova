import 'package:flutter_test/flutter_test.dart';
import 'package:jatra_nova/core/database/migrations/migration_v1.dart';
import 'package:jatra_nova/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Database db;
  late AuthLocalDataSourceImpl dataSource;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON;');
        },
        onCreate: (db, version) async {
          await MigrationV1.execute(db);
        },
      ),
    );
    dataSource = AuthLocalDataSourceImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('AuthLocalDataSourceImpl', () {
    test('finds seeded user by mobile number', () async {
      final user = await dataSource.findByIdentifier('01712345678');
      expect(user, isNotNull);
      expect(user!.fullName, equals('Rahim Ahmed'));
    });

    test('finds seeded user by email address', () async {
      final user = await dataSource.findByIdentifier('rahim@demo.com');
      expect(user, isNotNull);
      expect(user!.fullName, equals('Rahim Ahmed'));
    });

    test('verifies correct credentials successfully', () async {
      final isValid = await dataSource.verifyCredentials(
        identifier: '01712345678',
        password: 'password123',
      );
      expect(isValid, isTrue);
    });

    test('rejects incorrect password', () async {
      final isValid = await dataSource.verifyCredentials(
        identifier: '01712345678',
        password: 'wrong_password',
      );
      expect(isValid, isFalse);
    });

    test('creates new user and persists in database', () async {
      final newUser = await dataSource.createUser(
        fullName: 'Tanvir Hasan',
        mobile: '01912345678',
        email: 'tanvir@demo.com',
        password: 'myPassword123',
      );

      expect(newUser.id, startsWith('user_'));
      expect(newUser.fullName, equals('Tanvir Hasan'));

      // Check credential verification on newly created user
      final canLogin = await dataSource.verifyCredentials(
        identifier: '01912345678',
        password: 'myPassword123',
      );
      expect(canLogin, isTrue);
    });
  });
}
