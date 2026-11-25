import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:jatra_nova/core/utils/preferences_service.dart';
import 'package:jatra_nova/core/utils/session_bloc.dart';
import 'package:jatra_nova/core/utils/session_event.dart';
import 'package:jatra_nova/core/utils/session_state.dart';
import 'package:jatra_nova/features/onboarding/presentation/bloc/splash_event.dart';
import 'package:jatra_nova/features/onboarding/presentation/bloc/splash_state.dart';

/// Determines the post-splash route strictly according to Project Flow v1.1:
/// - First launch (`!onboardingCompleted`) -> Onboarding
/// - Returning launch with valid session -> Signed-in Home
/// - Returning launch without signed-in session -> Guest Home
@injectable
class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc(
    this._preferencesService,
    this._sessionBloc,
  ) : super(const SplashLoading()) {
    on<SplashStarted>(_onSplashStarted);
  }

  final IPreferencesService _preferencesService;
  final SessionBloc _sessionBloc;

  Future<void> _onSplashStarted(
    SplashStarted event,
    Emitter<SplashState> emit,
  ) async {
    if (event.minimumDuration > Duration.zero) {
      await Future<void>.delayed(event.minimumDuration);
    }

    if (!_preferencesService.onboardingCompleted) {
      emit(const SplashNavigationReady(SplashDestination.onboarding));
      return;
    }

    if (_sessionBloc.state.status == SessionStatus.initial) {
      _sessionBloc.add(const SessionRestored());
      await _sessionBloc.stream.firstWhere(
        (state) => state.status != SessionStatus.initial,
      );
    }

    if (_sessionBloc.state.isAuthenticated) {
      emit(const SplashNavigationReady(SplashDestination.signedInHome));
    } else {
      emit(const SplashNavigationReady(SplashDestination.languageSelection));
    }
  }
}
