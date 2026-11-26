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
import 'package:jatra_nova/features/onboarding/presentation/pages/onboarding_page_1.dart';
import 'package:jatra_nova/features/onboarding/presentation/pages/onboarding_page_2.dart';
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

  void setMobileViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(1125, 2436); // 375 x 812 @ 3x
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> pumpToOnboarding1(WidgetTester tester) async {
    setMobileViewport(tester);
    await tester.pumpWidget(const JatraNovaApp());
    await tester.pump();
    expect(find.byType(SplashPage), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();
    expect(find.byType(OnboardingPage1), findsOneWidget);
  }

  testWidgets(
    'Splash opens OnboardingPage1 and renders all reference elements',
    (WidgetTester tester) async {
      await pumpToOnboarding1(tester);

      expect(find.byType(Image), findsNWidgets(2));
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);
      expect(
        find.text('Book your bus tickets\nwith ease and comfort.'),
        findsOneWidget,
      );

      final richText = tester.widget<RichText>(
        find.byWidgetPredicate(
          (widget) =>
              widget is RichText &&
              widget.text.toPlainText() == 'Travel Smart\nTravel Better',
        ),
      );
      expect(richText.text.toPlainText(), 'Travel Smart\nTravel Better');
      expect(getIt<IPreferencesService>().onboardingCompleted, isFalse);
    },
  );

  testWidgets(
    'tapping Next navigates to OnboardingPage2 without completing onboarding',
    (WidgetTester tester) async {
      await pumpToOnboarding1(tester);

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -120));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingPage1), findsNothing);
      expect(find.byType(OnboardingPage2), findsOneWidget);
      expect(
        getIt<AppRoute>().router.routeInformationProvider.value.uri.path,
        RoutePath.onboardingStep2,
      );
      expect(getIt<IPreferencesService>().onboardingCompleted, isFalse);
    },
  );

  testWidgets(
    'tapping Skip persists onboarding_completed and navigates to language-selection',
    (WidgetTester tester) async {
      await pumpToOnboarding1(tester);

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingPage1), findsNothing);
      expect(
        getIt<AppRoute>().router.routeInformationProvider.value.uri.path,
        RoutePath.languageSelection,
      );
      expect(getIt<IPreferencesService>().onboardingCompleted, isTrue);
    },
  );

  testWidgets(
    'OnboardingPage1 renders cleanly in Bangla and short landscape viewports without overflow',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(
            AppConstants.designWidth,
            AppConstants.designHeight,
          ),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, _) => MaterialApp(
            locale: const Locale('bn'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: const OnboardingPage1(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('এড়িয়ে যান'), findsOneWidget);
      expect(find.text('পরবর্তী'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
