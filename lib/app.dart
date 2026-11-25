import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jatra_nova/core/constants/app_constants.dart';
import 'package:jatra_nova/core/di/injection.dart';
import 'package:jatra_nova/core/localization/locale_bloc.dart';
import 'package:jatra_nova/core/localization/locale_state.dart';
import 'package:jatra_nova/core/route/route_config.dart';
import 'package:jatra_nova/core/theme/app_theme.dart';
import 'package:jatra_nova/core/utils/session_bloc.dart';
import 'package:jatra_nova/l10n/app_localizations.dart';

class JatraNovaApp extends StatelessWidget {
  const JatraNovaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<LocaleBloc>.value(value: getIt<LocaleBloc>()),
        BlocProvider<SessionBloc>.value(value: getIt<SessionBloc>()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(
          AppConstants.designWidth,
          AppConstants.designHeight,
        ),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (BuildContext context, Widget? child) {
          return BlocBuilder<LocaleBloc, LocaleState>(
            builder: (BuildContext context, LocaleState localeState) {
              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                onGenerateTitle: (BuildContext ctx) =>
                    AppLocalizations.of(ctx)?.appName ?? 'JatraNova',
                theme: AppTheme.light,
                themeMode: ThemeMode.light,
                locale: localeState.locale,
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                routerConfig: getIt<AppRoute>().router,
              );
            },
          );
        },
      ),
    );
  }
}
