import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jatra_nova/app.dart';
import 'package:jatra_nova/core/constants/app_constants.dart';
import 'package:jatra_nova/core/database/app_database.dart';
import 'package:jatra_nova/core/di/injection.dart';
import 'package:jatra_nova/core/localization/locale_bloc.dart';
import 'package:jatra_nova/core/localization/locale_event.dart';
import 'package:jatra_nova/core/route/route_config.dart';
import 'package:jatra_nova/core/utils/preferences_service.dart';
import 'package:jatra_nova/core/utils/session_bloc.dart';
import 'package:jatra_nova/core/utils/session_event.dart';
import 'package:jatra_nova/features/authentication/presentation/pages/login_page.dart';
import 'package:jatra_nova/features/authentication/presentation/pages/welcome_page.dart';
import 'package:jatra_nova/features/home/presentation/pages/home_page.dart';
import 'package:jatra_nova/features/onboarding/presentation/pages/language_selection_page.dart';
import 'package:jatra_nova/features/onboarding/presentation/pages/splash_page.dart';
import 'package:jatra_nova/l10n/app_localizations.dart';
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
    await configureInjection();
    getIt<LocaleBloc>().add(const LocaleInitialized());
    getIt<SessionBloc>().add(const SessionRestored());
  });

  tearDown(() async {
    await getIt.reset();
    await AppDatabase.resetConfiguration();
  });

  void setViewport(
    WidgetTester tester, {
    Size size = const Size(1125, 2436),
    double dpr = 3.0,
  }) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = dpr;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> pumpToWelcomePage(
    WidgetTester tester, {
    String languageCode = 'en',
  }) async {
    await getIt<IPreferencesService>().setSelectedLanguage(languageCode);
    getIt<LocaleBloc>().add(const LocaleInitialized());
    setViewport(tester);

    await tester.pumpWidget(const JatraNovaApp());
    await tester.pump();
    expect(find.byType(SplashPage), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();
    await tester.tap(find.text(languageCode == 'bn' ? 'এড়িয়ে যান' : 'Skip'));
    await tester.pumpAndSettle();
    expect(find.byType(LanguageSelectionPage), findsOneWidget);

    await tester.tap(find.byKey(const Key('language_continue_button')));
    await tester.pumpAndSettle();
    expect(find.byType(WelcomePage), findsOneWidget);
  }

  testWidgets(
    'WelcomePage renders all reference elements, assets, and buttons in English',
    (WidgetTester tester) async {
      await pumpToWelcomePage(tester);

      expect(find.byType(Image), findsNWidgets(2));
      final brandText = tester.widget<RichText>(
        find.byWidgetPredicate(
          (widget) =>
              widget is RichText && widget.text.toPlainText() == 'JatraNova',
        ),
      );
      expect(brandText.text.toPlainText(), 'JatraNova');

      expect(find.text('Your Journey, Connected.'), findsOneWidget);
      expect(find.text('Welcome to\nJatraNova'), findsOneWidget);
      expect(
        find.text('Book, track and manage\nyour journeys with ease.'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('welcome_login_button')), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.byKey(const Key('welcome_register_button')), findsOneWidget);
      expect(find.text('Register'), findsOneWidget);
      expect(find.text('or'), findsOneWidget);
      expect(find.byKey(const Key('welcome_guest_button')), findsOneWidget);
      expect(find.text('Continue as Guest'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('WelcomePage renders expected localized text in Bangla', (
    WidgetTester tester,
  ) async {
    await pumpToWelcomePage(tester, languageCode: 'bn');

    final brandText = tester.widget<RichText>(
      find.byWidgetPredicate(
        (widget) =>
            widget is RichText && widget.text.toPlainText() == 'যাত্রানোভা',
      ),
    );
    expect(brandText.text.toPlainText(), 'যাত্রানোভা');

    expect(find.text('আপনার যাত্রা, সংযুক্ত।'), findsOneWidget);
    expect(find.text('যাত্রানোভায়\nস্বাগতম'), findsOneWidget);
    expect(
      find.text('সহজেই আপনার যাত্রা বুক,\nট্র্যাক ও পরিচালনা করুন।'),
      findsOneWidget,
    );
    expect(find.text('লগইন'), findsOneWidget);
    expect(find.text('নিবন্ধন'), findsOneWidget);
    expect(find.text('অথবা'), findsOneWidget);
    expect(find.text('অতিথি হিসেবে চালিয়ে যান'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Login, Register, and Continue as Guest navigate to expected routes',
    (WidgetTester tester) async {
      await pumpToWelcomePage(tester);
      await tester.tap(find.byKey(const Key('welcome_login_button')));
      await tester.pumpAndSettle();
      expect(
        getIt<AppRoute>().router.routeInformationProvider.value.uri.path,
        RoutePath.login,
      );
      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.text('Welcome back!'), findsOneWidget);

      getIt<AppRoute>().router.go(RoutePath.welcome);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('welcome_register_button')));
      await tester.pumpAndSettle();
      expect(
        getIt<AppRoute>().router.routeInformationProvider.value.uri.path,
        RoutePath.register,
      );
      expect(find.text('Register'), findsOneWidget);

      getIt<AppRoute>().router.go(RoutePath.welcome);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('welcome_guest_button')));
      await tester.pump();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)),
      );
      await tester.pumpAndSettle();
      expect(
        getIt<AppRoute>().router.routeInformationProvider.value.uri.path,
        RoutePath.guestHome,
      );
      expect(find.byType(HomePage), findsOneWidget);
    },
  );

  testWidgets(
    'WelcomePage renders without overflow on small and landscape viewports',
    (WidgetTester tester) async {
      for (final size in const <Size>[Size(320, 568), Size(800, 600)]) {
        setViewport(tester, size: size, dpr: 1.0);
        await tester.pumpWidget(
          ScreenUtilInit(
            designSize: const Size(
              AppConstants.designWidth,
              AppConstants.designHeight,
            ),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (_, _) => MaterialApp(
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              home: const WelcomePage(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(WelcomePage), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    },
  );
}
