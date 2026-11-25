// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:jatra_nova/core/database/app_database.dart' as _i810;
import 'package:jatra_nova/core/di/service_module.dart' as _i345;
import 'package:jatra_nova/core/localization/locale_bloc.dart' as _i953;
import 'package:jatra_nova/core/route/route_config.dart' as _i696;
import 'package:jatra_nova/core/utils/preferences_service.dart' as _i833;
import 'package:jatra_nova/core/utils/session_bloc.dart' as _i1056;
import 'package:shared_preferences/shared_preferences.dart' as _i460;
import 'package:sqflite/sqflite.dart' as _i779;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final serviceModule = _$ServiceModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => serviceModule.sharedPreferences,
      preResolve: true,
    );
    await gh.factoryAsync<_i779.Database>(
      () => serviceModule.database,
      preResolve: true,
    );
    gh.singleton<_i810.AppDatabase>(
      () => serviceModule.appDatabase,
      dispose: (i) => i.close(),
    );
    gh.lazySingleton<_i833.IPreferencesService>(
      () => _i833.PreferencesServiceImpl(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i953.LocaleBloc>(
      () => _i953.LocaleBloc(gh<_i833.IPreferencesService>()),
    );
    gh.lazySingleton<_i1056.SessionBloc>(
      () => _i1056.SessionBloc(gh<_i833.IPreferencesService>()),
    );
    gh.singleton<_i696.AppRoute>(
      () => _i696.AppRoute(gh<_i1056.SessionBloc>()),
      dispose: (i) => i.dispose(),
    );
    return this;
  }
}

class _$ServiceModule extends _i345.ServiceModule {}
