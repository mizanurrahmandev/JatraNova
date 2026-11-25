import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'package:jatra_nova/core/constants/app_spacing.dart';
import 'package:jatra_nova/core/theme/app_colors.dart';
import 'package:jatra_nova/core/utils/session_bloc.dart';
import 'package:jatra_nova/core/utils/session_state.dart';
import 'package:jatra_nova/features/authentication/presentation/pages/forgot_password_page.dart';
import 'package:jatra_nova/features/authentication/presentation/pages/login_page.dart';
import 'package:jatra_nova/features/authentication/presentation/pages/register_page.dart';
import 'package:jatra_nova/features/authentication/presentation/pages/welcome_page.dart';
import 'package:jatra_nova/features/home/presentation/pages/home_page.dart';
import 'package:jatra_nova/features/onboarding/presentation/pages/language_selection_page.dart';
import 'package:jatra_nova/features/onboarding/presentation/pages/onboarding_page_1.dart';
import 'package:jatra_nova/features/onboarding/presentation/pages/onboarding_page_2.dart';
import 'package:jatra_nova/features/onboarding/presentation/pages/onboarding_page_3.dart';
import 'package:jatra_nova/features/onboarding/presentation/pages/splash_page.dart';
import 'package:jatra_nova/l10n/app_localizations.dart';

/// Foundation route configuration using `go_router`.
///
/// Splash Screen and Onboarding Screens 1–3 are implemented; remaining
/// destinations remain isolated placeholder routes until requested.
@singleton
class AppRoute {
  AppRoute(this._sessionBloc)
      : _refreshListenable = _BlocRefreshListenable(_sessionBloc.stream) {
    router = GoRouter(
      initialLocation: RoutePath.splash,
      refreshListenable: _refreshListenable,
      redirect: (BuildContext context, GoRouterState state) {
        final sessionState = _sessionBloc.state;
        final location = state.matchedLocation;

        if (sessionState.status == SessionStatus.initial) {
          return null;
        }

        if (!sessionState.isAuthenticated &&
            (location == RoutePath.home ||
                location == RoutePath.myTickets ||
                location == RoutePath.profile)) {
          return RoutePath.login;
        }

        return null;
      },
      routes: <RouteBase>[
        GoRoute(
          path: RoutePath.splash,
          builder: (_, _) => const SplashPage(),
        ),
        GoRoute(
          path: RoutePath.onboarding,
          builder: (_, _) => const OnboardingPage1(),
        ),
        GoRoute(
          path: RoutePath.onboardingStep2,
          builder: (_, _) => const OnboardingPage2(),
        ),
        GoRoute(
          path: RoutePath.onboardingStep3,
          builder: (_, _) => const OnboardingPage3(),
        ),
        GoRoute(
          path: RoutePath.languageSelection,
          builder: (_, _) => const LanguageSelectionPage(),
        ),
        GoRoute(
          path: RoutePath.welcome,
          builder: (_, _) => const WelcomePage(),
        ),
        GoRoute(
          path: RoutePath.login,
          builder: (_, _) => const LoginPage(),
        ),
        GoRoute(
          path: RoutePath.forgotPassword,
          builder: (_, _) => const ForgotPasswordPage(),
        ),
        GoRoute(
          path: RoutePath.register,
          builder: (_, _) => const RegisterPage(),
        ),
        GoRoute(
          path: RoutePath.guestHome,
          builder: (_, _) => const HomePage(),
        ),
        GoRoute(
          path: RoutePath.home,
          builder: (_, _) => const HomePage(),
        ),
        GoRoute(
          path: RoutePath.search,
          builder: (BuildContext context, _) => _TemporaryDestinationPage(
            title: AppLocalizations.of(context)!.navSearch,
          ),
        ),
        GoRoute(
          path: RoutePath.searchResults,
          builder: (BuildContext context, _) => _TemporaryDestinationPage(
            title: AppLocalizations.of(context)!.searchResultsPlaceholderTitle,
          ),
        ),
        GoRoute(
          path: RoutePath.myTickets,
          builder: (BuildContext context, _) => _TemporaryDestinationPage(
            title: AppLocalizations.of(context)!.myTicketsPlaceholderTitle,
          ),
        ),
        GoRoute(
          path: RoutePath.profile,
          builder: (BuildContext context, _) => _TemporaryDestinationPage(
            title: AppLocalizations.of(context)!.profilePlaceholderTitle,
          ),
        ),
        GoRoute(
          path: RoutePath.notifications,
          builder: (BuildContext context, _) => _TemporaryDestinationPage(
            title: AppLocalizations.of(context)!.notificationsPlaceholderTitle,
          ),
        ),
        GoRoute(
          path: RoutePath.connectingJourney,
          builder: (BuildContext context, _) => _TemporaryDestinationPage(
            title:
                AppLocalizations.of(context)!.connectingJourneyPlaceholderTitle,
          ),
        ),
        GoRoute(
          path: RoutePath.handover,
          builder: (BuildContext context, _) => _TemporaryDestinationPage(
            title: AppLocalizations.of(context)!.handoverPlaceholderTitle,
          ),
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

class _TemporaryDestinationPage extends StatelessWidget {
  const _TemporaryDestinationPage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.onboardingBackgroundFallback,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.onboardingHeadingNavy,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                AppSpacing.verticalSm,
                Text(
                  l10n.comingSoonSubtitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onboardingSubtitleSlate,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String onboardingStep2 = '/onboarding/step-2';
  static const String onboardingStep3 = '/onboarding/step-3';
  static const String languageSelection = '/language-selection';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String register = '/register';
  static const String guestHome = '/guest-home';
  static const String home = '/home';
  static const String search = '/search';
  static const String searchResults = '/search-results';
  static const String myTickets = '/my-tickets';
  static const String profile = '/profile';
  static const String notifications = '/notifications';
  static const String connectingJourney = '/connecting-journey';
  static const String handover = '/handover';
}
