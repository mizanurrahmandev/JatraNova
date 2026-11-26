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
import 'package:jatra_nova/features/authentication/presentation/pages/register_page.dart';
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

  Future<void> pumpToRegisterPage(
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

    await tester.tap(find.byKey(const Key('login_register_link_button')));
    await tester.pumpAndSettle();
    expect(find.byType(RegisterPage), findsOneWidget);
  }

  testWidgets('RegisterPage renders all reference elements in English', (
    WidgetTester tester,
  ) async {
    await pumpToRegisterPage(tester);

    expect(find.byType(Image), findsOneWidget);
    expect(find.byKey(const Key('register_back_button')), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Join JatraNova today'), findsOneWidget);
    expect(find.byKey(const Key('register_full_name_field')), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.byKey(const Key('register_email_field')), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.byKey(const Key('register_phone_field')), findsOneWidget);
    expect(find.text('Phone Number'), findsOneWidget);
    expect(find.byKey(const Key('register_password_field')), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(
      find.byKey(const Key('register_password_visibility_button')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('register_terms_checkbox')), findsOneWidget);
    expect(find.byKey(const Key('register_submit_button')), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);
    expect(find.text('Already have an account?'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('RegisterPage renders expected localized text in Bangla', (
    WidgetTester tester,
  ) async {
    await pumpToRegisterPage(tester, languageCode: 'bn');

    expect(find.text('অ্যাকাউন্ট তৈরি করুন'), findsOneWidget);
    expect(find.text('আজই যাত্রানোভায় যোগ দিন'), findsOneWidget);
    expect(find.text('পূর্ণ নাম'), findsOneWidget);
    expect(find.text('ইমেইল ঠিকানা'), findsOneWidget);
    expect(find.text('ফোন নম্বর'), findsOneWidget);
    expect(find.text('পাসওয়ার্ড'), findsOneWidget);
    expect(find.text('নিবন্ধন'), findsOneWidget);
    expect(find.text('ইতিমধ্যে অ্যাকাউন্ট আছে?'), findsOneWidget);
    expect(find.text('লগইন'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty and invalid input validation show localized errors', (
    WidgetTester tester,
  ) async {
    await pumpToRegisterPage(tester);

    await tester.tap(find.byKey(const Key('register_submit_button')));
    await tester.pumpAndSettle();

    expect(find.text('Please enter your full name.'), findsOneWidget);
    expect(find.text('Please enter your email address.'), findsOneWidget);
    expect(find.text('Please enter your phone number.'), findsOneWidget);
    expect(find.text('Please enter your password.'), findsOneWidget);
    expect(
      find.text('Please agree to the Terms & Conditions.'),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const Key('register_full_name_field')),
      'Rahim Uddin',
    );
    await tester.enterText(
      find.byKey(const Key('register_email_field')),
      'bad-email',
    );
    await tester.enterText(
      find.byKey(const Key('register_phone_field')),
      '123',
    );
    await tester.enterText(
      find.byKey(const Key('register_password_field')),
      '12345',
    );
    await tester.tap(find.byKey(const Key('register_submit_button')));
    await tester.pumpAndSettle();

    expect(find.text('Please enter a valid email address.'), findsOneWidget);
    expect(find.text('Please enter a valid phone number.'), findsOneWidget);
    expect(
      find.text('Password must be at least 6 characters.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'password visibility toggle, valid submit demo feedback, and Login/back navigation work',
    (WidgetTester tester) async {
      await pumpToRegisterPage(tester);

      await tester.enterText(
        find.byKey(const Key('register_full_name_field')),
        'Rahim Uddin',
      );
      await tester.enterText(
        find.byKey(const Key('register_email_field')),
        'rahim@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('register_phone_field')),
        '01712345678',
      );
      await tester.enterText(
        find.byKey(const Key('register_password_field')),
        'secret123',
      );
      await tester.pump();

      var passwordField = tester.widget<TextField>(
        find.byKey(const Key('register_password_field')),
      );
      expect(passwordField.obscureText, isTrue);

      await tester.tap(
        find.byKey(const Key('register_password_visibility_button')),
      );
      await tester.pump();

      passwordField = tester.widget<TextField>(
        find.byKey(const Key('register_password_field')),
      );
      expect(passwordField.obscureText, isFalse);

      await tester.tap(find.byKey(const Key('register_terms_checkbox')));
      await tester.pump();

      await tester.tap(find.byKey(const Key('register_submit_button')));
      await tester.pump();
      expect(
        find.byKey(const Key('register_loading_indicator')),
        findsOneWidget,
      );

      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('register_loading_indicator')), findsNothing);
      expect(
        find.text('Account registration is not yet connected.'),
        findsOneWidget,
      );
      expect(getIt<SessionBloc>().state.isAuthenticated, isFalse);

      ScaffoldMessenger.of(
        tester.element(find.byType(RegisterPage)),
      ).hideCurrentSnackBar();
      await tester.pumpAndSettle();

      // Footer Login link navigates to LoginPage.
      await tester.tap(find.byKey(const Key('register_login_link_button')));
      await tester.pumpAndSettle();
      expect(find.byType(LoginPage), findsOneWidget);

      // Navigate back to RegisterPage and verify top-left back returns to LoginPage.
      getIt<AppRoute>().router.go(RoutePath.register);
      await tester.pumpAndSettle();
      expect(find.byType(RegisterPage), findsOneWidget);

      await tester.tap(find.byKey(const Key('register_back_button')));
      await tester.pumpAndSettle();
      expect(find.byType(LoginPage), findsOneWidget);
    },
  );

  testWidgets(
    'RegisterPage is keyboard-safe and renders without overflow on small and landscape viewports',
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
              home: const RegisterPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        tester.view.viewInsets = const FakeViewPadding(bottom: 300);
        addTearDown(tester.view.resetViewInsets);
        await tester.pumpAndSettle();

        expect(find.byType(RegisterPage), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    },
  );
}
