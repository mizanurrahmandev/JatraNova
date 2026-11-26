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

  Future<void> pumpToLoginPage(
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
  }

  testWidgets('LoginPage renders all reference elements in English', (
    WidgetTester tester,
  ) async {
    await pumpToLoginPage(tester);

    expect(find.byType(Image), findsNWidgets(2));
    expect(find.byKey(const Key('login_back_button')), findsOneWidget);
    expect(find.text('Login'), findsNWidgets(2));
    expect(find.text('Welcome back!'), findsOneWidget);
    expect(find.byKey(const Key('login_email_field')), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.byKey(const Key('login_password_field')), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(
      find.byKey(const Key('login_password_visibility_button')),
      findsOneWidget,
    );
    expect(find.text('Forgot Password?'), findsOneWidget);
    expect(find.byKey(const Key('login_submit_button')), findsOneWidget);
    expect(find.text('or continue with'), findsOneWidget);
    expect(find.byKey(const Key('login_google_button')), findsOneWidget);
    expect(find.text('Google'), findsOneWidget);
    final googleLogo = tester.widget<Image>(
      find.byKey(const Key('login_google_logo')),
    );
    expect(googleLogo.fit, BoxFit.contain);
    expect(googleLogo.width, googleLogo.height);
    expect(find.byKey(const Key('login_github_button')), findsNothing);
    expect(find.text('GitHub'), findsNothing);
    expect(find.text("Don't have an account?"), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('LoginPage renders expected localized text in Bangla', (
    WidgetTester tester,
  ) async {
    await pumpToLoginPage(tester, languageCode: 'bn');

    expect(find.text('লগইন'), findsNWidgets(2));
    expect(find.text('আবার স্বাগতম!'), findsOneWidget);
    expect(find.text('ইমেইল ঠিকানা'), findsOneWidget);
    expect(find.text('পাসওয়ার্ড'), findsOneWidget);
    expect(find.text('পাসওয়ার্ড ভুলে গেছেন?'), findsOneWidget);
    expect(find.text('অথবা চালিয়ে যান'), findsOneWidget);
    expect(find.text('অ্যাকাউন্ট নেই?'), findsOneWidget);
    expect(find.text('নিবন্ধন'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'email input, password input, and password visibility toggle work properly',
    (WidgetTester tester) async {
      await pumpToLoginPage(tester);

      await tester.enterText(
        find.byKey(const Key('login_email_field')),
        'rahim@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('login_password_field')),
        'secret123',
      );
      await tester.pump();

      expect(find.text('rahim@example.com'), findsOneWidget);
      var passwordField = tester.widget<TextField>(
        find.byKey(const Key('login_password_field')),
      );
      expect(passwordField.obscureText, isTrue);

      await tester.tap(
        find.byKey(const Key('login_password_visibility_button')),
      );
      await tester.pump();

      passwordField = tester.widget<TextField>(
        find.byKey(const Key('login_password_field')),
      );
      expect(passwordField.obscureText, isFalse);
    },
  );

  testWidgets(
    'required-field and invalid-email validation show localized errors',
    (WidgetTester tester) async {
      await pumpToLoginPage(tester);

      // Empty submit triggers required-field errors.
      await tester.tap(find.byKey(const Key('login_submit_button')));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email address.'), findsOneWidget);
      expect(find.text('Please enter your password.'), findsOneWidget);

      // Invalid email triggers invalid-email error.
      await tester.enterText(
        find.byKey(const Key('login_email_field')),
        'invalid-email',
      );
      await tester.enterText(
        find.byKey(const Key('login_password_field')),
        'secret123',
      );
      await tester.tap(find.byKey(const Key('login_submit_button')));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email address.'), findsOneWidget);
      expect(find.text('Please enter your password.'), findsNothing);
    },
  );

  testWidgets(
    'valid submit shows loading state and unimplemented notice without faking auth',
    (WidgetTester tester) async {
      await pumpToLoginPage(tester);

      await tester.enterText(
        find.byKey(const Key('login_email_field')),
        'rahim@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('login_password_field')),
        'secret123',
      );
      await tester.pump();

      await tester.tap(find.byKey(const Key('login_submit_button')));
      await tester.pump();

      expect(find.byKey(const Key('login_loading_indicator')), findsOneWidget);
      final disabledButton = tester.widget<ElevatedButton>(
        find.byKey(const Key('login_submit_button')),
      );
      expect(disabledButton.onPressed, isNull);

      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('login_loading_indicator')), findsNothing);
      expect(
        find.text('Login submission is not yet connected.'),
        findsOneWidget,
      );
      expect(
        getIt<AppRoute>().router.routeInformationProvider.value.uri.path,
        RoutePath.login,
      );
      expect(getIt<SessionBloc>().state.isAuthenticated, isFalse);
    },
  );

  testWidgets(
    'back, forgot password, register, and social buttons behave cleanly',
    (WidgetTester tester) async {
      await pumpToLoginPage(tester);

      await tester.tap(find.byKey(const Key('login_google_button')));
      await tester.pumpAndSettle();
      expect(
        find.text('Social login is not available in this offline demo.'),
        findsOneWidget,
      );
      ScaffoldMessenger.of(
        tester.element(find.byType(LoginPage)),
      ).hideCurrentSnackBar();
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('login_forgot_password_button')));
      await tester.pumpAndSettle();
      expect(
        getIt<AppRoute>().router.routeInformationProvider.value.uri.path,
        RoutePath.forgotPassword,
      );

      getIt<AppRoute>().router.go(RoutePath.login);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('login_register_link_button')));
      await tester.pumpAndSettle();
      expect(
        getIt<AppRoute>().router.routeInformationProvider.value.uri.path,
        RoutePath.register,
      );

      getIt<AppRoute>().router.go(RoutePath.login);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('login_back_button')));
      await tester.pumpAndSettle();
      expect(find.byType(WelcomePage), findsOneWidget);
    },
  );

  testWidgets(
    'LoginPage is keyboard-safe and renders without overflow on small and landscape viewports',
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
              home: const LoginPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Simulate keyboard inset.
        tester.view.viewInsets = const FakeViewPadding(bottom: 300);
        addTearDown(tester.view.resetViewInsets);
        await tester.pumpAndSettle();

        expect(find.byType(LoginPage), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    },
  );
}
