import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:jatra_nova/core/di/injection.config.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit()
Future<void> configureInjection() => getIt.init();
