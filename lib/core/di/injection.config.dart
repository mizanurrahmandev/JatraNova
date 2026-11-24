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
import 'package:shared_preferences/shared_preferences.dart' as _i460;
import 'package:sqflite/sqflite.dart' as _i779;

import '../../features/auth/data/datasources/auth_local_data_source.dart'
    as _i852;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/domain/repositories/i_auth_repository.dart'
    as _i589;
import '../../features/auth/domain/usecases/login_usecase.dart' as _i188;
import '../../features/auth/domain/usecases/register_usecase.dart' as _i941;
import '../../features/auth/presentation/bloc/auth_bloc.dart' as _i797;
import '../../features/search/data/datasources/search_local_data_source.dart'
    as _i163;
import '../../features/search/data/repositories/search_repository_impl.dart'
    as _i1017;
import '../../features/search/domain/repositories/i_search_repository.dart'
    as _i835;
import '../../features/search/domain/usecases/get_locations_usecase.dart'
    as _i321;
import '../../features/search/domain/usecases/get_popular_routes_usecase.dart'
    as _i881;
import '../../features/search/domain/usecases/search_trips_usecase.dart'
    as _i356;
import '../../features/search/presentation/bloc/search_bloc.dart' as _i552;
import '../localization/locale_cubit.dart' as _i960;
import '../route/route_config.dart' as _i479;
import '../session/session_cubit.dart' as _i796;
import 'service_module.dart' as _i180;

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
    gh.singleton<_i479.AppRoute>(() => _i479.AppRoute());
    gh.factory<_i163.ISearchLocalDataSource>(
      () => _i163.SearchLocalDataSourceImpl(gh<_i779.Database>()),
    );
    gh.factory<_i852.IAuthLocalDataSource>(
      () => _i852.AuthLocalDataSourceImpl(gh<_i779.Database>()),
    );
    gh.factory<_i960.LocaleCubit>(
      () => _i960.LocaleCubit(gh<_i460.SharedPreferences>()),
    );
    gh.factory<_i796.SessionCubit>(
      () => _i796.SessionCubit(gh<_i460.SharedPreferences>()),
    );
    gh.factory<_i589.IAuthRepository>(
      () => _i153.AuthRepositoryImpl(gh<_i852.IAuthLocalDataSource>()),
    );
    gh.factory<_i188.ILoginUsecase>(
      () => _i188.LoginUsecase(gh<_i589.IAuthRepository>()),
    );
    gh.factory<_i941.IRegisterUsecase>(
      () => _i941.RegisterUsecase(gh<_i589.IAuthRepository>()),
    );
    gh.factory<_i835.ISearchRepository>(
      () => _i1017.SearchRepositoryImpl(gh<_i163.ISearchLocalDataSource>()),
    );
    gh.factory<_i356.ISearchTripsUsecase>(
      () => _i356.SearchTripsUsecase(gh<_i835.ISearchRepository>()),
    );
    gh.factory<_i321.IGetLocationsUsecase>(
      () => _i321.GetLocationsUsecase(gh<_i835.ISearchRepository>()),
    );
    gh.factory<_i881.IGetPopularRoutesUsecase>(
      () => _i881.GetPopularRoutesUsecase(gh<_i835.ISearchRepository>()),
    );
    gh.factory<_i552.SearchBloc>(
      () => _i552.SearchBloc(
        getLocationsUsecase: gh<_i321.IGetLocationsUsecase>(),
        searchTripsUsecase: gh<_i356.ISearchTripsUsecase>(),
        getPopularRoutesUsecase: gh<_i881.IGetPopularRoutesUsecase>(),
      ),
    );
    gh.factory<_i797.AuthBloc>(
      () => _i797.AuthBloc(
        loginUsecase: gh<_i188.ILoginUsecase>(),
        registerUsecase: gh<_i941.IRegisterUsecase>(),
      ),
    );
    return this;
  }
}

class _$ServiceModule extends _i180.ServiceModule {}
