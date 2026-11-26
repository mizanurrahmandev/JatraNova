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
import 'package:jatra_nova/features/authentication/presentation/pages/forgot_password_page.dart';
import 'package:jatra_nova/features/authentication/presentation/pages/login_page.dart';
import 'package:jatra_nova/features/authentication/presentation/pages/welcome_page.dart';
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

  Future<void> pumpToForgotPasswordPage(
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

    await tester.tap(find.byKey(const Key('welcome_login_button')));
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);

    await tester.tap(find.byKey(const Key('login_forgot_password_button')));
    await tester.pumpAndSettle();
    expect(find.byType(ForgotPasswordPage), findsOneWidget);
  }

  testWidgets('ForgotPasswordPage renders all reference elements in English', (
    WidgetTester tester,
  ) async {
    await pumpToForgotPasswordPage(tester);

    expect(find.byType(Image), findsNWidgets(2));
    expect(
      find.byKey(const Key('forgot_password_back_button')),
      findsOneWidget,
    );
    expect(find.text('Reset Your Password'), findsOneWidget);
    expect(
      find.text(
        'Password recovery is not active in this\nlocal demo. Enter your email to preview.',
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('forgot_password_email_field')),
      findsOneWidget,
    );
    expect(find.text('Email Address'), findsOneWidget);
    expect(
      find.byKey(const Key('forgot_password_submit_button')),
      findsOneWidget,
    );
    expect(find.text('Continue (Demo)'), findsOneWidget);
    expect(
      find.byKey(const Key('forgot_password_back_to_login_button')),
      findsOneWidget,
    );
    expect(find.text('Back to Login'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ForgotPasswordPage renders expected localized text in Bangla', (
    WidgetTester tester,
  ) async {
    await pumpToForgotPasswordPage(tester, languageCode: 'bn');

    expect(find.text('পাসওয়ার্ড রিসেট করুন'), findsOneWidget);
    expect(
      find.text(
        'এই স্থানীয় ডেমোতে পাসওয়ার্ড পুনরুদ্ধার\nসক্রিয় নয়। প্রিভিউ দেখতে ইমেইল দিন।',
      ),
      findsOneWidget,
    );
    expect(find.text('ইমেইল ঠিকানা'), findsOneWidget);
    expect(find.text('চালিয়ে যান (ডেমো)'), findsOneWidget);
    expect(find.text('লগইনে ফিরে যান'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty and invalid email validation show localized errors', (
    WidgetTester tester,
  ) async {
    await pumpToForgotPasswordPage(tester);

    await tester.tap(find.byKey(const Key('forgot_password_submit_button')));
    await tester.pumpAndSettle();
    expect(find.text('Please enter your email address.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('forgot_password_email_field')),
      'invalid-email',
    );
    await tester.tap(find.byKey(const Key('forgot_password_submit_button')));
    await tester.pumpAndSettle();
    expect(find.text('Please enter a valid email address.'), findsOneWidget);
  });

  testWidgets(
    'valid email shows loading, unimplemented notice, and returns to idle; back navigation returns to LoginPage',
    (WidgetTester tester) async {
      await pumpToForgotPasswordPage(tester);

      await tester.enterText(
        find.byKey(const Key('forgot_password_email_field')),
        'rahim@example.com',
      );
      await tester.pump();

      await tester.tap(find.byKey(const Key('forgot_password_submit_button')));
      await tester.pump();
      expect(
        find.byKey(const Key('forgot_password_loading_indicator')),
        findsOneWidget,
      );

      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('forgot_password_loading_indicator')),
        findsNothing,
      );
      expect(
        find.text(
          'Password recovery is not available in this offline demo. No email was sent.',
        ),
        findsOneWidget,
      );
      final enabledButton = tester.widget<ElevatedButton>(
        find.byKey(const Key('forgot_password_submit_button')),
      );
      expect(enabledButton.onPressed, isNotNull);

      ScaffoldMessenger.of(
        tester.element(find.byType(ForgotPasswordPage)),
      ).hideCurrentSnackBar();
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const Key('forgot_password_back_to_login_button')),
      );
      await tester.pumpAndSettle();
      expect(find.byType(LoginPage), findsOneWidget);

      getIt<AppRoute>().router.go(RoutePath.forgotPassword);
      await tester.pumpAndSettle();
      expect(find.byType(ForgotPasswordPage), findsOneWidget);

      await tester.tap(find.byKey(const Key('forgot_password_back_button')));
      await tester.pumpAndSettle();
      expect(find.byType(LoginPage), findsOneWidget);
    },
  );

  testWidgets(
    'ForgotPasswordPage is keyboard-safe and renders without overflow on small and landscape viewports',
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
              home: const ForgotPasswordPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        tester.view.viewInsets = const FakeViewPadding(bottom: 300);
        addTearDown(tester.view.resetViewInsets);
        await tester.pumpAndSettle();

        expect(find.byType(ForgotPasswordPage), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    },
  );
}
