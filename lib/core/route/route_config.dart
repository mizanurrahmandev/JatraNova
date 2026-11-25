import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'package:jatra_nova/core/utils/session_bloc.dart';
import 'package:jatra_nova/core/utils/session_state.dart';

/// Foundation route scaffold using `go_router`.
///
/// Feature screens will be wired here in subsequent phases.
@singleton
class AppRoute {
  AppRoute(this._sessionBloc)
      : _refreshListenable = _BlocRefreshListenable(_sessionBloc.stream) {
    router = GoRouter(
      initialLocation: RoutePath.root,
      refreshListenable: _refreshListenable,
      redirect: (BuildContext context, GoRouterState state) {
        final sessionState = _sessionBloc.state;
        final location = state.matchedLocation;

        if (sessionState.status == SessionStatus.initial) {
          return null;
        }

        if (location == RoutePath.root) {
          return sessionState.isAuthenticated
              ? RoutePath.home
              : RoutePath.guestHome;
        }

        if (!sessionState.isAuthenticated && location == RoutePath.home) {
          return RoutePath.guestHome;
        }

        return null;
      },
      routes: <RouteBase>[
        GoRoute(
          path: RoutePath.root,
          builder: (_, _) => const _FoundationPlaceholder(),
        ),
        GoRoute(
          path: RoutePath.guestHome,
          builder: (_, _) => const _FoundationPlaceholder(),
        ),
        GoRoute(
          path: RoutePath.home,
          builder: (_, _) => const _FoundationPlaceholder(),
        ),
      ],
    );
  }

  final SessionBloc _sessionBloc;
  final _BlocRefreshListenable _refreshListenable;
  late final GoRouter router;

  @disposeMethod
  void dispose() {
    _refreshListenable.dispose();
    router.dispose();
  }
}

class _FoundationPlaceholder extends StatelessWidget {
  const _FoundationPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SizedBox.shrink());
  }
}

class _BlocRefreshListenable extends ChangeNotifier {
  _BlocRefreshListenable(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Route path constants for the application.
abstract final class RoutePath {
  static const String root = '/';
  static const String guestHome = '/guest-home';
  static const String home = '/home';
}
