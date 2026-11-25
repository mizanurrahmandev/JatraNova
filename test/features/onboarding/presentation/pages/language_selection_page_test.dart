import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jatra_nova/app.dart';
import 'package:jatra_nova/core/constants/app_constants.dart';
import 'package:jatra_nova/core/constants/preference_keys.dart';
import 'package:jatra_nova/core/database/app_database.dart';
import 'package:jatra_nova/core/di/injection.dart';
import 'package:jatra_nova/core/localization/locale_bloc.dart';
import 'package:jatra_nova/core/localization/locale_event.dart';
import 'package:jatra_nova/core/route/route_config.dart';
import 'package:jatra_nova/core/theme/app_colors.dart';
import 'package:jatra_nova/core/utils/preferences_service.dart';
import 'package:jatra_nova/core/utils/session_bloc.dart';
import 'package:jatra_nova/core/utils/session_event.dart';
import 'package:jatra_nova/features/onboarding/presentation/pages/language_selection_page.dart';
import 'package:jatra_nova/features/onboarding/presentation/pages/onboarding_page_1.dart';
import 'package:jatra_nova/features/onboarding/presentation/pages/onboarding_page_2.dart';
import 'package:jatra_nova/features/onboarding/presentation/pages/onboarding_page_3.dart';
import 'package:jatra_nova/features/onboarding/presentation/pages/splash_page.dart';
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

  Future<void> pumpAppToLanguageSelection(
    WidgetTester tester, {
    bool completedOnboarding = true,
  }) async {
    if (completedOnboarding) {
      await getIt<IPreferencesService>().setOnboardingCompleted(true);
    }
    setViewport(tester);
    await tester.pumpWidget(const JatraNovaApp());
    await tester.pump();
    expect(find.byType(SplashPage), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();

    if (!completedOnboarding) {
      expect(find.byType(OnboardingPage1), findsOneWidget);
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -120));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.byType(OnboardingPage2), findsOneWidget);
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.byType(OnboardingPage3), findsOneWidget);
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();
    }

    expect(find.byType(LanguageSelectionPage), findsOneWidget);
  }

  testWidgets(
      'LanguageSelectionPage renders reference UI with English selected by default',
      (WidgetTester tester) async {
    await pumpAppToLanguageSelection(tester);

    expect(find.byType(Image), findsOneWidget);
    expect(find.text('Choose Language'), findsOneWidget);
    expect(find.text('Select your preferred language'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('বাংলা'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(find.byIcon(Icons.language_rounded), findsNWidgets(2));
    expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);

    expect(getIt<LocaleBloc>().state.locale, const Locale('en'));

    final enAnimated = tester.widget<AnimatedContainer>(
      find.descendant(
        of: find.byKey(const Key('language_option_en')),
        matching: find.byType(AnimatedContainer),
      ),
    );
    final bnAnimated = tester.widget<AnimatedContainer>(
      find.descendant(
        of: find.byKey(const Key('language_option_bn')),
        matching: find.byType(AnimatedContainer),
      ),
    );
    expect(
      (enAnimated.decoration! as BoxDecoration).color,
      AppColors.languageCardSelectedFill,
    );
    expect(
      (bnAnimated.decoration! as BoxDecoration).color,
      AppColors.white,
    );
  });

  testWidgets(
      'selecting বাংলা and English updates locale and localized text immediately',
      (WidgetTester tester) async {
    await pumpAppToLanguageSelection(tester);

    await tester.tap(find.byKey(const Key('language_option_bn')));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 10)));
    await tester.pumpAndSettle();

    expect(getIt<LocaleBloc>().state.locale, const Locale('bn'));
    expect(find.text('ভাষা নির্বাচন করুন'), findsOneWidget);
    expect(find.text('আপনার পছন্দের ভাষা নির্বাচন করুন'), findsOneWidget);
    expect(find.text('চালিয়ে যান'), findsOneWidget);

    await tester.tap(find.byKey(const Key('language_option_en')));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 10)));
    await tester.pumpAndSettle();

    expect(getIt<LocaleBloc>().state.locale, const Locale('en'));
    expect(find.text('Choose Language'), findsOneWidget);
    expect(find.text('Select your preferred language'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets(
      'selected language persists across app restart and restores saved locale on startup',
      (WidgetTester tester) async {
    await pumpAppToLanguageSelection(tester);

    await tester.tap(find.byKey(const Key('language_option_bn')));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 10)));
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(PreferenceKeys.selectedLanguage), 'bn');

    // Simulate app restart.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.runAsync(() async {
      await getIt.reset();
      await configureInjection();
    });
    getIt<LocaleBloc>().add(const LocaleInitialized());
    getIt<SessionBloc>().add(const SessionRestored());

    await tester.pumpWidget(const JatraNovaApp());
    await tester.pump();
    expect(find.byType(SplashPage), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();

    expect(find.byType(LanguageSelectionPage), findsOneWidget);
    expect(getIt<LocaleBloc>().state.locale, const Locale('bn'));
    expect(find.text('ভাষা নির্বাচন করুন'), findsOneWidget);
    expect(find.text('চালিয়ে যান'), findsOneWidget);
  });

  testWidgets(
      'tapping Continue navigates to temporary Welcome destination and does not alter onboarding_completed',
      (WidgetTester tester) async {
    // Reach Language Selection via Skip on OnboardingPage1 so onboardingCompleted stays false.
    setViewport(tester);
    await tester.pumpWidget(const JatraNovaApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();
    expect(find.byType(OnboardingPage1), findsOneWidget);

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(find.byType(LanguageSelectionPage), findsOneWidget);
    expect(getIt<IPreferencesService>().onboardingCompleted, isFalse);

    await tester.tap(find.byKey(const Key('language_option_bn')));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 10)));
    await tester.pumpAndSettle();
    expect(getIt<IPreferencesService>().onboardingCompleted, isFalse);

    await tester.tap(find.byKey(const Key('language_continue_button')));
    await tester.pumpAndSettle();

    expect(
      getIt<AppRoute>().router.routeInformationProvider.value.uri.path,
      RoutePath.welcome,
    );
    expect(find.text('যাত্রানোভায়\nস্বাগতম'), findsOneWidget);
    expect(getIt<IPreferencesService>().onboardingCompleted, isFalse);
  });

  testWidgets(
      'first-time flow Splash -> Onboarding 1 -> 2 -> 3 -> Language Selection works and sets onboarding_completed on Screen 3',
      (WidgetTester tester) async {
    await pumpAppToLanguageSelection(tester, completedOnboarding: false);
    expect(getIt<IPreferencesService>().onboardingCompleted, isTrue);
    expect(
      getIt<AppRoute>().router.routeInformationProvider.value.uri.path,
      RoutePath.languageSelection,
    );
  });

  testWidgets(
      'LanguageSelectionPage renders without overflow on small and landscape viewports',
      (WidgetTester tester) async {
    for (final size in const <Size>[
      Size(320, 568),
      Size(800, 600),
    ]) {
      setViewport(tester, size: size, dpr: 1.0);
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(
            AppConstants.designWidth,
            AppConstants.designHeight,
          ),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, _) => const JatraNovaApp(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1600));
      await tester.pumpAndSettle();

      // Navigate to language selection via Skip if on onboarding.
      if (find.text('Skip').evaluate().isNotEmpty) {
        await tester.tap(find.text('Skip'));
        await tester.pumpAndSettle();
      }

      expect(find.byType(LanguageSelectionPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
}
