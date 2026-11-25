import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jatra_nova/app.dart';
import 'package:jatra_nova/core/database/app_database.dart';
import 'package:jatra_nova/core/database/db_tables.dart';
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

  Future<void> pumpToHomePage(
    WidgetTester tester, {
    String languageCode = 'en',
    Size size = const Size(1125, 2436),
    double dpr = 3.0,
  }) async {
    await getIt<IPreferencesService>().setOnboardingCompleted(true);
    await getIt<IPreferencesService>().setSelectedLanguage(languageCode);
    getIt<LocaleBloc>().add(const LocaleInitialized());
    setViewport(tester, size: size, dpr: dpr);

    await tester.pumpWidget(const JatraNovaApp());
    await tester.pump();
    expect(find.byType(SplashPage), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();
    expect(find.byType(LanguageSelectionPage), findsOneWidget);

    await tester.tap(find.byKey(const Key('language_continue_button')));
    await tester.pumpAndSettle();
    expect(find.byType(WelcomePage), findsOneWidget);

    await tester.tap(find.byKey(const Key('welcome_guest_button')));
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);
  }

  testWidgets(
      'HomePage renders guest greeting, search card, popular routes, popular buses with seats, feature cards, and 4-tab bottom nav in English',
      (WidgetTester tester) async {
    await pumpToHomePage(tester);

    expect(find.byKey(const Key('home_greeting_text')), findsOneWidget);
    expect(
      find.byKey(const Key('home_hero_bus_illustration')),
      findsOneWidget,
    );
    final busTopLeft = tester.getTopLeft(
      find.byKey(const Key('home_hero_bus_illustration')),
    );
    final searchCardTopLeft = tester.getTopLeft(
      find.byKey(const Key('home_from_field')),
    );
    expect(busTopLeft.dy, lessThan(searchCardTopLeft.dy));
    expect(find.textContaining('Traveler!'), findsOneWidget);
    expect(find.byKey(const Key('home_from_field')), findsOneWidget);
    expect(find.byKey(const Key('home_to_field')), findsOneWidget);
    expect(find.text('Dhaka'), findsOneWidget);
    expect(find.text('Chattogram'), findsOneWidget);
    expect(find.byKey(const Key('home_swap_button')), findsOneWidget);
    expect(find.byKey(const Key('home_date_field')), findsOneWidget);
    expect(find.byKey(const Key('home_passengers_field')), findsOneWidget);
    expect(find.text('1 Passenger'), findsOneWidget);
    expect(find.byKey(const Key('home_search_button')), findsOneWidget);
    expect(find.text('Search Buses'), findsOneWidget);

    expect(find.text('Popular Routes'), findsOneWidget);
    expect(find.text('Popular Buses'), findsOneWidget);
    expect(find.text('Demo'), findsOneWidget);
    expect(find.textContaining('Seats Available'), findsWidgets);

    expect(find.byKey(const Key('home_connecting_journey_card')), findsOneWidget);
    expect(find.byKey(const Key('home_ticket_handover_card')), findsOneWidget);

    expect(find.byKey(const Key('home_bottom_nav')), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('My Tickets'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('HomePage renders expected localized text in Bangla',
      (WidgetTester tester) async {
    await pumpToHomePage(tester, languageCode: 'bn');

    expect(find.textContaining('ভ্রমণকারী!'), findsOneWidget);
    expect(find.text('ঢাকা'), findsOneWidget);
    expect(find.text('চট্টগ্রাম'), findsOneWidget);
    expect(find.text('1 জন যাত্রী'), findsOneWidget);
    expect(find.text('বাস খুঁজুন'), findsOneWidget);
    expect(find.text('জনপ্রিয় রুট'), findsOneWidget);
    expect(find.text('জনপ্রিয় বাস'), findsOneWidget);
    expect(find.text('ডেমো'), findsOneWidget);
    expect(find.text('হোম'), findsOneWidget);
    expect(find.text('খুঁজুন'), findsOneWidget);
    expect(find.text('আমার টিকিট'), findsOneWidget);
    expect(find.text('প্রোফাইল'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('HomePage displays authenticated passenger name when signed in',
      (WidgetTester tester) async {
    final db = getIt<Database>();
    await tester.runAsync(() async {
      await db.insert(DbTables.users, <String, Object?>{
        UsersCols.id: 'user_rahim',
        UsersCols.fullName: 'Rahim Uddin',
        UsersCols.mobile: '01712345678',
        UsersCols.email: 'rahim@example.com',
        UsersCols.credentialHash: 'demo_hash',
        UsersCols.avatarKey: 'initials',
        UsersCols.createdAt: 1000,
        UsersCols.updatedAt: 1000,
      });
    });
    getIt<SessionBloc>().add(
      const SessionStarted(userId: 'user_rahim', rememberMe: false),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump();

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
    expect(find.textContaining('Rahim Uddin!'), findsOneWidget);
  });

  testWidgets('swapping locations and selecting passengers update search card',
      (WidgetTester tester) async {
    await pumpToHomePage(tester);

    await tester.tap(find.byKey(const Key('home_swap_button')));
    await tester.pumpAndSettle();

    // After swap, From is Chattogram and To is Dhaka.
    expect(
      find.descendant(
        of: find.byKey(const Key('home_from_field')),
        matching: find.text('Chattogram'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('home_to_field')),
        matching: find.text('Dhaka'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('home_passengers_field')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('passenger_increment_button')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('passenger_done_button')));
    await tester.pumpAndSettle();

    expect(find.text('2 Passengers'), findsOneWidget);
  });

  testWidgets(
      'guest tapping My Tickets or Profile redirects to LoginPage; Search and feature cards navigate cleanly',
      (WidgetTester tester) async {
    await pumpToHomePage(tester);

    await tester.tap(find.text('My Tickets'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);

    getIt<AppRoute>().router.go(RoutePath.guestHome);
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);

    getIt<AppRoute>().router.go(RoutePath.guestHome);
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();
    expect(
      getIt<AppRoute>().router.routeInformationProvider.value.uri.path,
      RoutePath.search,
    );

    getIt<AppRoute>().router.go(RoutePath.guestHome);
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('home_search_button')));
    await tester.pumpAndSettle();
    expect(
      getIt<AppRoute>().router.routeInformationProvider.value.uri.path,
      RoutePath.searchResults,
    );
  });

  testWidgets('HomePage renders without overflow on small and landscape viewports',
      (WidgetTester tester) async {
    for (final size in const <Size>[
      Size(320, 568),
      Size(800, 600),
    ]) {
      setViewport(tester, size: size, dpr: 1.0);
      await tester.pumpWidget(
        const JatraNovaApp(),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1600));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 250)),
      );
      getIt<AppRoute>().router.go(RoutePath.guestHome);
      await tester.pump();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 250)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
}
