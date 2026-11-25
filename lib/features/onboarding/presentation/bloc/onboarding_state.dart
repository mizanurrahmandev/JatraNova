import 'package:equatable/equatable.dart';

enum OnboardingNavigationTarget {
  nextStep,
  step3,
  languageSelection,
}

abstract class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => <Object?>[];
}

class OnboardingInitial extends OnboardingState {
  const OnboardingInitial();
}

class OnboardingNavigationReady extends OnboardingState {
  const OnboardingNavigationReady(this.target);

  final OnboardingNavigationTarget target;

  @override
  List<Object?> get props => <Object?>[target];
}
