import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:jatra_nova/core/utils/preferences_service.dart';
import 'package:jatra_nova/core/utils/session_event.dart';
import 'package:jatra_nova/core/utils/session_state.dart';

/// App-wide session BLoC handling Guest vs signed-in session pointers.
///
/// When `rememberMe` is true, `session_user_id` is persisted via
/// [IPreferencesService]. When false, the session stays in memory for the
/// current app run only and restarts as Guest.
@lazySingleton
class SessionBloc extends Bloc<SessionEvent, SessionState> {
  SessionBloc(this._preferencesService) : super(const SessionState.initial()) {
    on<SessionRestored>(_onRestored);
    on<SessionStarted>(_onStarted);
    on<SessionCleared>(_onCleared);
  }

  final IPreferencesService _preferencesService;

  Future<void> _onRestored(
    SessionRestored event,
    Emitter<SessionState> emit,
  ) async {
    final rememberMe = _preferencesService.rememberMe;
    final storedUserId = _preferencesService.sessionUserId;

    if (rememberMe && storedUserId != null && storedUserId.isNotEmpty) {
      emit(
        SessionState.authenticated(
          userId: storedUserId,
          isPersistent: true,
        ),
      );
      return;
    }

    if (storedUserId != null || rememberMe) {
      await _preferencesService.clearSession();
    }
    emit(const SessionState.guest());
  }

  Future<void> _onStarted(
    SessionStarted event,
    Emitter<SessionState> emit,
  ) async {
    if (event.rememberMe) {
      await _preferencesService.savePersistentSession(userId: event.userId);
    } else {
      await _preferencesService.clearSession();
    }

    emit(
      SessionState.authenticated(
        userId: event.userId,
        isPersistent: event.rememberMe,
      ),
    );
  }

  Future<void> _onCleared(
    SessionCleared event,
    Emitter<SessionState> emit,
  ) async {
    await _preferencesService.clearSession();
    emit(const SessionState.guest());
  }
}
