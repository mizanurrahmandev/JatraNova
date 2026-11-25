import 'package:flutter_test/flutter_test.dart';
import 'package:jatra_nova/core/utils/preferences_service.dart';
import 'package:jatra_nova/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:jatra_nova/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:jatra_nova/features/onboarding/presentation/bloc/onboarding_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockPreferencesService extends Mock implements IPreferencesService {}

void main() {
  late OnboardingBloc onboardingBloc;
  late _MockPreferencesService preferencesService;

  setUp(() {
    preferencesService = _MockPreferencesService();
    when(() => preferencesService.onboardingCompleted).thenReturn(false);
    when(() => preferencesService.setOnboardingCompleted(any()))
        .thenAnswer((_) async => true);
    onboardingBloc = OnboardingBloc(preferencesService);
  });

  tearDown(() async {
    await onboardingBloc.close();
  });

  group('OnboardingBloc', () {
    test('initial state is OnboardingInitial', () {
      expect(onboardingBloc.state, const OnboardingInitial());
    });

    test('emits nextStep navigation on OnboardingNextRequested', () async {
      onboardingBloc.add(const OnboardingNextRequested());

      await expectLater(
        onboardingBloc.stream,
        emits(
          const OnboardingNavigationReady(OnboardingNavigationTarget.nextStep),
        ),
      );
      verifyNever(() => preferencesService.setOnboardingCompleted(any()));
    });

    test('emits step3 navigation on OnboardingNextRequested with step 2',
        () async {
      onboardingBloc.add(const OnboardingNextRequested(step: 2));

      await expectLater(
        onboardingBloc.stream,
        emits(
          const OnboardingNavigationReady(OnboardingNavigationTarget.step3),
        ),
      );
      verifyNever(() => preferencesService.setOnboardingCompleted(any()));
    });

    test('emits languageSelection navigation on OnboardingSkipRequested',
        () async {
      onboardingBloc.add(const OnboardingSkipRequested());

      await expectLater(
        onboardingBloc.stream,
        emits(
          const OnboardingNavigationReady(
            OnboardingNavigationTarget.languageSelection,
          ),
        ),
      );
      verifyNever(() => preferencesService.setOnboardingCompleted(any()));
    });

    test(
        'persists onboarding_completed once and navigates to languageSelection on OnboardingCompletedRequested',
        () async {
      onboardingBloc.add(const OnboardingCompletedRequested());

      await expectLater(
        onboardingBloc.stream,
        emits(
          const OnboardingNavigationReady(
            OnboardingNavigationTarget.languageSelection,
          ),
        ),
      );
      verify(() => preferencesService.setOnboardingCompleted(true)).called(1);
    });

    test(
        'does not rewrite onboarding_completed when already persisted',
        () async {
      when(() => preferencesService.onboardingCompleted).thenReturn(true);
      onboardingBloc.add(const OnboardingCompletedRequested());

      await expectLater(
        onboardingBloc.stream,
        emits(
          const OnboardingNavigationReady(
            OnboardingNavigationTarget.languageSelection,
          ),
        ),
      );
      verifyNever(() => preferencesService.setOnboardingCompleted(any()));
    });
  });
}
