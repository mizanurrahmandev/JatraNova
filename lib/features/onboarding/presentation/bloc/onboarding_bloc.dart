import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:jatra_nova/core/utils/preferences_service.dart';
import 'package:jatra_nova/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:jatra_nova/features/onboarding/presentation/bloc/onboarding_state.dart';

/// Handles onboarding navigation and completion persistence.
@injectable
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc(this._preferencesService) : super(const OnboardingInitial()) {
    on<OnboardingNextRequested>(_onNextRequested);
    on<OnboardingSkipRequested>(_onSkipRequested);
    on<OnboardingCompletedRequested>(_onCompletedRequested);
  }

  final IPreferencesService _preferencesService;

  void _onNextRequested(
    OnboardingNextRequested event,
    Emitter<OnboardingState> emit,
  ) {
    final target = event.step == 2
        ? OnboardingNavigationTarget.step3
        : OnboardingNavigationTarget.nextStep;
    emit(OnboardingNavigationReady(target));
  }

  void _onSkipRequested(
    OnboardingSkipRequested event,
    Emitter<OnboardingState> emit,
  ) {
    emit(
      const OnboardingNavigationReady(
        OnboardingNavigationTarget.languageSelection,
      ),
    );
  }

  Future<void> _onCompletedRequested(
    OnboardingCompletedRequested event,
    Emitter<OnboardingState> emit,
  ) async {
    if (!_preferencesService.onboardingCompleted) {
      await _preferencesService.setOnboardingCompleted(true);
    }
    emit(
      const OnboardingNavigationReady(
        OnboardingNavigationTarget.languageSelection,
      ),
    );
  }
}
