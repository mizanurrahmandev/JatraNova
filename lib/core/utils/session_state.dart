import 'package:equatable/equatable.dart';

enum SessionStatus { initial, guest, authenticated }

class SessionState extends Equatable {
  const SessionState({
    required this.status,
    this.userId,
    this.isPersistent = false,
  });

  const SessionState.initial()
      : status = SessionStatus.initial,
        userId = null,
        isPersistent = false;

  const SessionState.guest()
      : status = SessionStatus.guest,
        userId = null,
        isPersistent = false;

  const SessionState.authenticated({
    required String this.userId,
    required this.isPersistent,
  }) : status = SessionStatus.authenticated;

  final SessionStatus status;
  final String? userId;
  final bool isPersistent;

  bool get isAuthenticated => status == SessionStatus.authenticated;

  @override
  List<Object?> get props => <Object?>[status, userId, isPersistent];
}
