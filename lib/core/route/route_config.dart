import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import '../../features/auth/presentation/pages/language_selection_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/welcome_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/search/presentation/pages/search_buses_page.dart';
import '../../features/search/presentation/pages/search_results_page.dart';

class RoutePath {
  RoutePath._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String languageSelection = '/language-selection';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String searchBuses = '/search-buses';
  static const String searchResults = '/search-results';
  static const String tickets = '/tickets';
  static const String profile = '/profile';
  static const String busDetails = '/bus-details';
  static const String seatSelection = '/seat-selection';
  static const String bookingReview = '/booking-review';
  static const String payment = '/payment';
  static const String eTicket = '/e-ticket';
  static const String handover = '/handover';
  static const String connectingDetails = '/connecting-details';
  static const String demoOperator = '/demo-operator';
}

@singleton
class AppRoute {
  late final GoRouter router = GoRouter(
    initialLocation: RoutePath.splash,
    routes: [
      GoRoute(
        path: RoutePath.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: RoutePath.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: RoutePath.languageSelection,
        builder: (context, state) => const LanguageSelectionPage(),
      ),
      GoRoute(
        path: RoutePath.welcome,
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: RoutePath.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RoutePath.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: RoutePath.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: RoutePath.searchBuses,
        builder: (context, state) => const SearchBusesPage(),
      ),
      GoRoute(
        path: RoutePath.searchResults,
        builder: (context, state) => const SearchResultsPage(),
      ),
    ],
  );
}
