import 'package:flutter/widgets.dart';
import 'package:jatra_nova/app.dart';
import 'package:jatra_nova/core/di/injection.dart';
import 'package:jatra_nova/core/localization/locale_bloc.dart';
import 'package:jatra_nova/core/localization/locale_event.dart';
import 'package:jatra_nova/core/utils/session_bloc.dart';
import 'package:jatra_nova/core/utils/session_event.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureInjection();
  getIt<LocaleBloc>().add(const LocaleInitialized());
  getIt<SessionBloc>().add(const SessionRestored());
  runApp(const JatraNovaApp());
}
