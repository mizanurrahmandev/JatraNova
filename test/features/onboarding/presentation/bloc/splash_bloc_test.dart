import 'package:flutter_test/flutter_test.dart';
import 'package:jatra_nova/core/utils/preferences_service.dart';
import 'package:jatra_nova/core/utils/session_bloc.dart';
import 'package:jatra_nova/core/utils/session_event.dart';
import 'package:jatra_nova/features/onboarding/presentation/bloc/splash_bloc.dart';
import 'package:jatra_nova/features/onboarding/presentation/bloc/splash_event.dart';
import 'package:jatra_nova/features/onboarding/presentation/bloc/splash_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late IPreferencesService preferencesService;
  late SessionBloc sessionBloc;
  late SplashBloc splashBloc;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    preferencesService = PreferencesServiceImpl(prefs);
    sessionBloc = SessionBloc(preferencesService);
    splashBloc = SplashBloc(preferencesService, sessionBloc);
  });

  tearDown(() async {
    await splashBloc.close();
    await sessionBloc.close();
  });

  group('SplashBloc', () {
    test(
      'routes to onboarding on first launch when onboardingCompleted is false',
      () async {
        splashBloc.add(const SplashStarted(minimumDuration: Duration.zero));

        await expectLater(
          splashBloc.stream,
          emits(const SplashNavigationReady(SplashDestination.onboarding)),
        );
      },
    );

    test(
      'routes to guestHome on returning launch with no persistent session',
      () async {
        await preferencesService.setOnboardingCompleted(true);
        sessionBloc.add(const SessionRestored());
        await sessionBloc.stream.first;

        splashBloc.add(const SplashStarted(minimumDuration: Duration.zero));

        await expectLater(
          splashBloc.stream,
          emits(const SplashNavigationReady(SplashDestination.guestHome)),
        );
      },
    );

    test(
      'routes to signedInHome on returning launch with persistent session',
      () async {
        await preferencesService.setOnboardingCompleted(true);
        await preferencesService.savePersistentSession(userId: 'rahim-1');
        sessionBloc.add(const SessionRestored());
        await sessionBloc.stream.first;

        splashBloc.add(const SplashStarted(minimumDuration: Duration.zero));

        await expectLater(
          splashBloc.stream,
          emits(const SplashNavigationReady(SplashDestination.signedInHome)),
        );
      },
    );
  });
}
