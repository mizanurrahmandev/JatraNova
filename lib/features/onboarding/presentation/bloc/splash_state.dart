import 'package:equatable/equatable.dart';

enum SplashDestination {
  onboarding,
  languageSelection,
  guestHome,
  signedInHome,
}

abstract class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => <Object?>[];
}

class SplashLoading extends SplashState {
  const SplashLoading();
}

class SplashNavigationReady extends SplashState {
  const SplashNavigationReady(this.destination);

  final SplashDestination destination;

  @override
  List<Object?> get props => <Object?>[destination];
}
