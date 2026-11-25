import 'package:equatable/equatable.dart';

abstract class SplashEvent extends Equatable {
  const SplashEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Starts splash initialization and resolves the initial destination route.
class SplashStarted extends SplashEvent {
  const SplashStarted({
    this.minimumDuration = const Duration(milliseconds: 1500),
  });

  final Duration minimumDuration;

  @override
  List<Object?> get props => <Object?>[minimumDuration];
}
