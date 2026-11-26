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
import 'package:jatra_nova/features/onboarding/presentation/pages/onboarding_page_1.dart';
import 'package:jatra_nova/features/onboarding/presentation/pages/onboarding_page_2.dart';
import 'package:jatra_nova/features/onboarding/presentation/pages/onboarding_page_3.dart';
import 'package:jatra_nova/features/onboarding/presentation/pages/splash_page.dart';
import 'package:jatra_nova/features/onboarding/presentation/widgets/onboarding_dots_indicator.dart';
import 'package:jatra_nova/features/onboarding/presentation/widgets/onboarding_progress_capsule.dart';
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

  Future<void> pumpToOnboarding3(WidgetTester tester) async {
    setMobileViewport(tester);
    await tester.pumpWidget(const JatraNovaApp());
    await tester.pump();
    expect(find.byType(SplashPage), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();
    expect(find.byType(OnboardingPage1), findsOneWidget);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -120));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.byType(OnboardingPage2), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.byType(OnboardingPage3), findsOneWidget);
  }

  testWidgets(
    'OnboardingPage2 Next opens OnboardingPage3 and renders all reference elements',
    (WidgetTester tester) async {
      await pumpToOnboarding3(tester);

      expect(find.byType(Image), findsNWidgets(2));
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);
      expect(
        find.text(
          'Easily exchange tickets and connect\nseamlessly across routes.',
        ),
        findsOneWidget,
      );

      final richText = tester.widget<RichText>(
        find.byWidgetPredicate(
          (widget) =>
              widget is RichText &&
              widget.text.toPlainText() == 'Flexible & Connected\nJourneys',
        ),
      );
      expect(richText.text.toPlainText(), 'Flexible & Connected\nJourneys');

      final capsule = tester.widget<OnboardingProgressCapsule>(
        find.byType(OnboardingProgressCapsule),
      );
      expect(capsule.progress, 1.0);

      final dotsIndicator = tester.widget<OnboardingDotsIndicator>(
        find.byType(OnboardingDotsIndicator),
      );
      expect(dotsIndicator.totalDots, 3);
      expect(dotsIndicator.activeIndex, 2);

      final dotContainers = tester
          .widgetList<Container>(
            find.descendant(
              of: find.byType(OnboardingDotsIndicator),
              matching: find.byType(Container),
            ),
          )
          .toList();
      expect(dotContainers.length, 3);
      expect(
        (dotContainers[0].decoration! as BoxDecoration).color,
        AppColors.onboardingDotInactive,
      );
      expect(
        (dotContainers[1].decoration! as BoxDecoration).color,
        AppColors.onboardingDotInactive,
      );
      expect(
        (dotContainers[2].decoration! as BoxDecoration).color,
        AppColors.onboardingButtonNavy,
      );

      // Opening Screen 3 must not mark onboarding completed prematurely.
      expect(getIt<IPreferencesService>().onboardingCompleted, isFalse);
    },
  );

  testWidgets(
    'tapping Get Started persists onboarding_completed and returning launch routes directly to Guest Home',
    (WidgetTester tester) async {
      await pumpToOnboarding3(tester);

      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingPage3), findsNothing);
      expect(
        getIt<AppRoute>().router.routeInformationProvider.value.uri.path,
        RoutePath.languageSelection,
      );
      expect(getIt<IPreferencesService>().onboardingCompleted, isTrue);

      // Simulate app restart with persisted SharedPreferences value.
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(PreferenceKeys.onboardingCompleted), isTrue);

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
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingPage1), findsNothing);
      expect(
        getIt<AppRoute>().router.routeInformationProvider.value.uri.path,
        RoutePath.guestHome,
      );
    },
  );

  testWidgets(
    'tapping Skip persists onboarding_completed and navigates to language-selection',
    (WidgetTester tester) async {
      await pumpToOnboarding3(tester);

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingPage3), findsNothing);
      expect(
        getIt<AppRoute>().router.routeInformationProvider.value.uri.path,
        RoutePath.languageSelection,
      );
      expect(getIt<IPreferencesService>().onboardingCompleted, isTrue);
    },
  );

  testWidgets(
    'OnboardingPage3 renders cleanly in Bangla and short landscape viewports without overflow',
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
            home: const OnboardingPage3(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('এড়িয়ে যান'), findsOneWidget);
      expect(find.text('শুরু করুন'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
