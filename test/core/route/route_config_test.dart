import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jatra_nova/app.dart';
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

  void setViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(1125, 2436);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets(
    'returning unauthenticated user skips Language Selection and Welcome and lands on Guest Home',
    (WidgetTester tester) async {
      await getIt<IPreferencesService>().setOnboardingCompleted(true);
      setViewport(tester);

      await tester.pumpWidget(const JatraNovaApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1600));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(LanguageSelectionPage), findsNothing);
      expect(find.byType(WelcomePage), findsNothing);
      expect(
        getIt<AppRoute>().router.routeInformationProvider.value.uri.path,
        RoutePath.guestHome,
      );
    },
  );

  Future<void> bootPastSplash(WidgetTester tester) async {
    setViewport(tester);
    await tester.pumpWidget(const JatraNovaApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'guest can access public Guest Home, Search, and Search Results routes without redirect',
    (WidgetTester tester) async {
      await bootPastSplash(tester);

      final router = getIt<AppRoute>().router;

      router.go(RoutePath.guestHome);
      await tester.pump();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 400)),
      );
      await tester.pumpAndSettle();
      expect(
        router.routeInformationProvider.value.uri.path,
        RoutePath.guestHome,
      );
      expect(find.byType(HomePage), findsOneWidget);

      router.go(RoutePath.search);
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, RoutePath.search);

      router.go(RoutePath.searchResults);
      await tester.pumpAndSettle();
      expect(
        router.routeInformationProvider.value.uri.path,
        RoutePath.searchResults,
      );
    },
  );

  testWidgets(
    'guest attempting My Tickets, Profile, Notifications, or signed-in Home is redirected to Login without loops',
    (WidgetTester tester) async {
      await bootPastSplash(tester);

      final router = getIt<AppRoute>().router;

      for (final protectedPath in const <String>[
        RoutePath.myTickets,
        RoutePath.profile,
        RoutePath.notifications,
        RoutePath.home,
      ]) {
        router.go(protectedPath);
        await tester.pumpAndSettle();
        expect(
          router.routeInformationProvider.value.uri.path,
          RoutePath.login,
          reason: 'Guest accessing $protectedPath should redirect to Login',
        );
        expect(find.byType(LoginPage), findsOneWidget);
      }
    },
  );

  testWidgets(
    'authenticated user can access protected routes without redirect',
    (WidgetTester tester) async {
      await getIt<IPreferencesService>().setOnboardingCompleted(true);
      getIt<SessionBloc>().add(
        const SessionStarted(userId: 'user_rahim', rememberMe: false),
      );
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );

      await bootPastSplash(tester);

      final router = getIt<AppRoute>().router;

      for (final protectedPath in const <String>[
        RoutePath.home,
        RoutePath.myTickets,
        RoutePath.profile,
        RoutePath.notifications,
      ]) {
        router.go(protectedPath);
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 200)),
        );
        await tester.pumpAndSettle();
        expect(
          router.routeInformationProvider.value.uri.path,
          protectedPath,
          reason: 'Authenticated user should stay on $protectedPath',
        );
      }
    },
  );
}
