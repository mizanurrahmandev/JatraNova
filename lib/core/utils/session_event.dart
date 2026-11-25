import 'package:equatable/equatable.dart';

abstract class SessionEvent extends Equatable {
  const SessionEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Restores a persisted session only if Remember Me was enabled; otherwise
/// enters Guest mode.
class SessionRestored extends SessionEvent {
  const SessionRestored();
}

/// Establishes a signed-in session pointer in memory and optionally persists it
/// when [rememberMe] is true.
class SessionStarted extends SessionEvent {
  const SessionStarted({
    required this.userId,
    required this.rememberMe,
  });

  final String userId;
  final bool rememberMe;

  @override
  List<Object?> get props => <Object?>[userId, rememberMe];
}

/// Clears both in-memory and persisted session state, returning to Guest mode.
class SessionCleared extends SessionEvent {
  const SessionCleared();
}
