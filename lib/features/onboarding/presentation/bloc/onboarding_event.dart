import 'package:equatable/equatable.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Triggered when the user taps Next on an onboarding screen.
class OnboardingNextRequested extends OnboardingEvent {
  const OnboardingNextRequested({this.step = 1});

  final int step;

  @override
  List<Object?> get props => <Object?>[step];
}

/// Triggered when the user taps Skip on an onboarding screen.
class OnboardingSkipRequested extends OnboardingEvent {
  const OnboardingSkipRequested();
}

/// Triggered when the user taps Get Started on the final onboarding screen.
class OnboardingCompletedRequested extends OnboardingEvent {
  const OnboardingCompletedRequested();
}
