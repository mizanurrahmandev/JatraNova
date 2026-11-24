import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'session_state.dart';

@injectable
class SessionCubit extends Cubit<SessionState> {
  static const String _userIdKey = 'session_user_id';
  static const String _userNameKey = 'session_user_name';
  static const String _userMobileKey = 'session_user_mobile';
  static const String _isGuestKey = 'session_is_guest';

  final SharedPreferences _preferences;

  SessionCubit(this._preferences) : super(const SessionState.unauthenticated()) {
    _loadSavedSession();
  }

  void _loadSavedSession() {
    final isGuest = _preferences.getBool(_isGuestKey) ?? false;
    if (isGuest) {
      emit(const SessionState.guest());
      return;
    }

    final userId = _preferences.getString(_userIdKey);
    final userName = _preferences.getString(_userNameKey);
    final userMobile = _preferences.getString(_userMobileKey);

    if (userId != null && userName != null) {
      emit(SessionState.authenticated(
        userId: userId,
        userName: userName,
        userMobile: userMobile,
      ));
    } else {
      emit(const SessionState.unauthenticated());
    }
  }

  Future<void> login({
    required String userId,
    required String userName,
    String? userMobile,
  }) async {
    await _preferences.setString(_userIdKey, userId);
    await _preferences.setString(_userNameKey, userName);
    if (userMobile != null) {
      await _preferences.setString(_userMobileKey, userMobile);
    }
    await _preferences.setBool(_isGuestKey, false);

    emit(SessionState.authenticated(
      userId: userId,
      userName: userName,
      userMobile: userMobile,
    ));
  }

  Future<void> continueAsGuest() async {
    await _preferences.remove(_userIdKey);
    await _preferences.remove(_userNameKey);
    await _preferences.remove(_userMobileKey);
    await _preferences.setBool(_isGuestKey, true);

    emit(const SessionState.guest());
  }

  Future<void> logout() async {
    await _preferences.remove(_userIdKey);
    await _preferences.remove(_userNameKey);
    await _preferences.remove(_userMobileKey);
    await _preferences.remove(_isGuestKey);

    emit(const SessionState.unauthenticated());
  }
}
