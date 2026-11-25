import 'package:flutter_test/flutter_test.dart';
import 'package:jatra_nova/core/database/app_database.dart';
import 'package:jatra_nova/core/di/injection.dart';
import 'package:jatra_nova/core/localization/locale_bloc.dart';
import 'package:jatra_nova/core/route/route_config.dart';
import 'package:jatra_nova/core/utils/preferences_service.dart';
import 'package:jatra_nova/core/utils/session_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  setUp(() async {
    await getIt.reset();
    await AppDatabase.configureForTesting(
      databaseFactory: databaseFactoryFfi,
      databasePath: inMemoryDatabasePath,
    );
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  tearDown(() async {
    await getIt.reset();
    await AppDatabase.resetConfiguration();
  });

  test('configureInjection registers Phase 1 and Phase 2 dependencies',
      () async {
    await configureInjection();

    expect(getIt.isRegistered<SharedPreferences>(), isTrue);
    expect(getIt.isRegistered<AppDatabase>(), isTrue);
    expect(getIt.isRegistered<Database>(), isTrue);
    expect(getIt.isRegistered<IPreferencesService>(), isTrue);
    expect(getIt.isRegistered<LocaleBloc>(), isTrue);
    expect(getIt.isRegistered<SessionBloc>(), isTrue);
    expect(getIt.isRegistered<AppRoute>(), isTrue);
  });
}
