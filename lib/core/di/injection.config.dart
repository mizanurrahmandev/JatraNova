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
import 'package:jatra_nova/features/authentication/presentation/bloc/forgot_password_bloc.dart'
    as _i568;
import 'package:jatra_nova/features/authentication/presentation/bloc/login_bloc.dart'
    as _i654;
import 'package:jatra_nova/features/authentication/presentation/bloc/register_bloc.dart'
    as _i14;
import 'package:jatra_nova/features/home/data/datasources/home_local_datasource.dart'
    as _i336;
import 'package:jatra_nova/features/home/data/repositories/home_repository_impl.dart'
    as _i679;
import 'package:jatra_nova/features/home/domain/repositories/i_home_repository.dart'
    as _i518;
import 'package:jatra_nova/features/home/domain/usecases/get_home_data_usecase_impl.dart'
    as _i167;
import 'package:jatra_nova/features/home/domain/usecases/i_get_home_data_usecase.dart'
    as _i825;
import 'package:jatra_nova/features/home/presentation/bloc/home_bloc.dart'
    as _i926;
import 'package:jatra_nova/features/onboarding/presentation/bloc/onboarding_bloc.dart'
    as _i95;
import 'package:jatra_nova/features/onboarding/presentation/bloc/splash_bloc.dart'
    as _i1039;
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
    gh.factory<_i568.ForgotPasswordBloc>(() => _i568.ForgotPasswordBloc());
    gh.factory<_i654.LoginBloc>(() => _i654.LoginBloc());
    gh.factory<_i14.RegisterBloc>(() => _i14.RegisterBloc());
    gh.singleton<_i810.AppDatabase>(
      () => serviceModule.appDatabase,
      dispose: (i) => i.close(),
    );
    gh.lazySingleton<_i833.IPreferencesService>(
      () => _i833.PreferencesServiceImpl(gh<_i460.SharedPreferences>()),
    );
    gh.factory<_i95.OnboardingBloc>(
      () => _i95.OnboardingBloc(gh<_i833.IPreferencesService>()),
    );
    gh.lazySingleton<_i953.LocaleBloc>(
      () => _i953.LocaleBloc(gh<_i833.IPreferencesService>()),
    );
    gh.lazySingleton<_i1056.SessionBloc>(
      () => _i1056.SessionBloc(gh<_i833.IPreferencesService>()),
    );
    gh.factory<_i336.IHomeLocalDataSource>(
      () => _i336.HomeLocalDataSourceImpl(gh<_i779.Database>()),
    );
    gh.factory<_i518.IHomeRepository>(
      () => _i679.HomeRepositoryImpl(gh<_i336.IHomeLocalDataSource>()),
    );
    gh.factory<_i825.IGetHomeDataUsecase>(
      () => _i167.GetHomeDataUsecaseImpl(gh<_i518.IHomeRepository>()),
    );
    gh.singleton<_i696.AppRoute>(
      () => _i696.AppRoute(gh<_i1056.SessionBloc>()),
      dispose: (i) => i.dispose(),
    );
    gh.factory<_i1039.SplashBloc>(
      () => _i1039.SplashBloc(
        gh<_i833.IPreferencesService>(),
        gh<_i1056.SessionBloc>(),
      ),
    );
    gh.factory<_i926.HomeBloc>(
      () => _i926.HomeBloc(gh<_i825.IGetHomeDataUsecase>()),
    );
    return this;
  }
}

class _$ServiceModule extends _i345.ServiceModule {}
