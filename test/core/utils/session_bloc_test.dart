import 'package:flutter_test/flutter_test.dart';
import 'package:jatra_nova/core/utils/preferences_service.dart';
import 'package:jatra_nova/core/utils/session_bloc.dart';
import 'package:jatra_nova/core/utils/session_event.dart';
import 'package:jatra_nova/core/utils/session_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late IPreferencesService preferencesService;
  late SessionBloc sessionBloc;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    preferencesService = PreferencesServiceImpl(prefs);
    sessionBloc = SessionBloc(preferencesService);
  });

  tearDown(() async {
    await sessionBloc.close();
  });

  group('SessionBloc', () {
    test('enters guest state when no persisted session exists', () async {
      sessionBloc.add(const SessionRestored());
      await expectLater(
        sessionBloc.stream,
        emits(const SessionState.guest()),
      );
    });

    test('persists session across restart when rememberMe is true', () async {
      sessionBloc.add(
        const SessionStarted(userId: 'rahim-1', rememberMe: true),
      );
      await expectLater(
        sessionBloc.stream,
        emits(
          const SessionState.authenticated(
            userId: 'rahim-1',
            isPersistent: true,
          ),
        ),
      );

      final restartedBloc = SessionBloc(preferencesService);
      addTearDown(restartedBloc.close);
      restartedBloc.add(const SessionRestored());
      await expectLater(
        restartedBloc.stream,
        emits(
          const SessionState.authenticated(
            userId: 'rahim-1',
            isPersistent: true,
          ),
        ),
      );
    });

    test(
        'keeps session in memory when rememberMe is false and restarts as guest',
        () async {
      sessionBloc.add(
        const SessionStarted(userId: 'karim-2', rememberMe: false),
      );
      await expectLater(
        sessionBloc.stream,
        emits(
          const SessionState.authenticated(
            userId: 'karim-2',
            isPersistent: false,
          ),
        ),
      );
      expect(preferencesService.sessionUserId, isNull);
      expect(preferencesService.rememberMe, isFalse);

      final restartedBloc = SessionBloc(preferencesService);
      addTearDown(restartedBloc.close);
      restartedBloc.add(const SessionRestored());
      await expectLater(
        restartedBloc.stream,
        emits(const SessionState.guest()),
      );
    });

    test('clears persisted session and enters guest state on SessionCleared',
        () async {
      await preferencesService.savePersistentSession(userId: 'rahim-1');
      sessionBloc.add(const SessionCleared());
      await expectLater(
        sessionBloc.stream,
        emits(const SessionState.guest()),
      );
      expect(preferencesService.sessionUserId, isNull);
      expect(preferencesService.rememberMe, isFalse);
    });
  });
}
