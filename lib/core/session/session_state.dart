import 'package:equatable/equatable.dart';

enum SessionStatus { unauthenticated, authenticated, guest }

class SessionState extends Equatable {
  final SessionStatus status;
  final String? userId;
  final String? userName;
  final String? userMobile;

  const SessionState({
    required this.status,
    this.userId,
    this.userName,
    this.userMobile,
  });

  const SessionState.unauthenticated()
      : status = SessionStatus.unauthenticated,
        userId = null,
        userName = null,
        userMobile = null;

  const SessionState.guest()
      : status = SessionStatus.guest,
        userId = null,
        userName = 'Guest Traveler',
        userMobile = null;

  const SessionState.authenticated({
    required this.userId,
    required this.userName,
    this.userMobile,
  }) : status = SessionStatus.authenticated;

  bool get isAuthenticated => status == SessionStatus.authenticated;
  bool get isGuest => status == SessionStatus.guest;

  @override
  List<Object?> get props => [status, userId, userName, userMobile];
}
