import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jatra_nova/app.dart';
import 'package:jatra_nova/core/database/app_database.dart';
import 'package:jatra_nova/core/di/injection.dart';
import 'package:jatra_nova/core/localization/locale_bloc.dart';
import 'package:jatra_nova/core/localization/locale_event.dart';
import 'package:jatra_nova/core/utils/session_bloc.dart';
import 'package:jatra_nova/core/utils/session_event.dart';
import 'package:jatra_nova/features/onboarding/presentation/pages/onboarding_page_1.dart';
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

  testWidgets(
      'SplashPage renders background, logo, two-tone title, tagline, and loading state',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1125, 2436);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const JatraNovaApp());
    await tester.pump();

    expect(find.byType(SplashPage), findsOneWidget);
    expect(find.byType(Image), findsNWidgets(2));
    expect(find.text('Your Journey, Connected.'), findsOneWidget);
    expect(find.text('Loading...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    final richText = tester.widget<RichText>(
      find.byWidgetPredicate(
        (widget) =>
            widget is RichText && widget.text.toPlainText() == 'JatraNova',
      ),
    );
    expect(richText.text.toPlainText(), 'JatraNova');

    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();
    expect(find.byType(SplashPage), findsNothing);
    expect(find.byType(OnboardingPage1), findsOneWidget);
  });
}
