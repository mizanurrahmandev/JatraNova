// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'JatraNova';

  @override
  String get appNameFirst => 'Jatra';

  @override
  String get appNameSecond => 'Nova';

  @override
  String get appTagline => 'Your Journey, Connected.';

  @override
  String get loading => 'Loading...';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Get Started';

  @override
  String get onboarding1TitlePrefix => 'Travel Smart\nTravel ';

  @override
  String get onboarding1TitleHighlight => 'Better';

  @override
  String get onboarding1Subtitle =>
      'Book your bus tickets\nwith ease and comfort.';

  @override
  String get onboarding2TitlePrefix => 'Safe & Reliable\n';

  @override
  String get onboarding2TitleHighlight => 'Journey';

  @override
  String get onboarding2Subtitle =>
      'Travel with confidence\nacross Bangladesh.';

  @override
  String get onboarding2TrustPlatform => 'Trusted\nPlatform';

  @override
  String get onboarding2TrustSupport => '24/7\nSupport';

  @override
  String get onboarding2TrustPayments => 'Secure\nPayments';

  @override
  String get onboarding3TitlePrefix => 'Flexible & Connected\n';

  @override
  String get onboarding3TitleHighlight => 'Journeys';

  @override
  String get onboarding3Subtitle =>
      'Easily exchange tickets and connect\nseamlessly across routes.';

  @override
  String get chooseLanguageTitle => 'Choose Language';

  @override
  String get chooseLanguageSubtitle => 'Select your preferred language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageBangla => 'বাংলা';

  @override
  String get continueLabel => 'Continue';

  @override
  String get welcomePlaceholderTitle => 'Welcome to JatraNova';

  @override
  String get welcomePlaceholderSubtitle =>
      'Welcome screen will be available in the next step.';

  @override
  String get welcomeTitle => 'Welcome to\nJatraNova';

  @override
  String get welcomeSubtitle =>
      'Book, track and manage\nyour journeys with ease.';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get orDivider => 'or';

  @override
  String get continueAsGuest => 'Continue as Guest';

  @override
  String get loginPlaceholderTitle => 'Login';

  @override
  String get registerPlaceholderTitle => 'Register';

  @override
  String get guestHomePlaceholderTitle => 'Guest Home';

  @override
  String get comingSoonSubtitle =>
      'This screen will be implemented in the next step.';

  @override
  String get loginTitle => 'Login';

  @override
  String get loginSubtitle => 'Welcome back!';

  @override
  String get emailHint => 'Email Address';

  @override
  String get passwordHint => 'Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get orContinueWith => 'or continue with';

  @override
  String get continueWithGoogle => 'Google';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get emailRequiredError => 'Please enter your email address.';

  @override
  String get emailInvalidError => 'Please enter a valid email address.';

  @override
  String get passwordRequiredError => 'Please enter your password.';

  @override
  String get loginNotImplementedNotice =>
      'Login submission is not yet connected.';

  @override
  String get socialLoginUnavailableNotice =>
      'Social login is not available in this offline demo.';

  @override
  String get forgotPasswordPlaceholderTitle => 'Forgot Password';

  @override
  String get createAccountTitle => 'Create Account';

  @override
  String get createAccountSubtitle => 'Join JatraNova today';

  @override
  String get fullNameHint => 'Full Name';

  @override
  String get phoneHint => 'Phone Number';

  @override
  String get agreeTermsPrefix => 'I agree to the ';

  @override
  String get termsAndConditions => 'Terms & Conditions';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get fullNameRequiredError => 'Please enter your full name.';

  @override
  String get phoneRequiredError => 'Please enter your phone number.';

  @override
  String get phoneInvalidError => 'Please enter a valid phone number.';

  @override
  String get passwordMinLengthError =>
      'Password must be at least 6 characters.';

  @override
  String get termsRequiredError => 'Please agree to the Terms & Conditions.';

  @override
  String get registerNotImplementedNotice =>
      'Account registration is not yet connected.';

  @override
  String get resetPasswordTitle => 'Reset Your Password';

  @override
  String get resetPasswordSubtitle =>
      'Password recovery is not active in this\nlocal demo. Enter your email to preview.';

  @override
  String get sendResetLink => 'Continue (Demo)';

  @override
  String get backToLogin => 'Back to Login';

  @override
  String get forgotPasswordNotImplementedNotice =>
      'Password recovery is not available in this offline demo. No email was sent.';

  @override
  String get greetingMorning => 'Good morning,';

  @override
  String get greetingAfternoon => 'Good afternoon,';

  @override
  String get greetingEvening => 'Good evening,';

  @override
  String get travelerName => 'Traveler';

  @override
  String get homeHeroSubtitle => 'Where do you want to\ngo today?';

  @override
  String get fromLabel => 'From';

  @override
  String get toLabel => 'To';

  @override
  String get dateLabel => 'Date';

  @override
  String get passengersLabel => 'Passengers';

  @override
  String passengerSingular(int count) {
    return '$count Passenger';
  }

  @override
  String passengerPlural(int count) {
    return '$count Passengers';
  }

  @override
  String get searchBuses => 'Search Buses';

  @override
  String get popularRoutes => 'Popular Routes';

  @override
  String get popularBuses => 'Popular Buses';

  @override
  String get seeAll => 'See All';

  @override
  String get demoBadge => 'Demo';

  @override
  String fromFare(String amount) {
    return 'From ৳$amount';
  }

  @override
  String seatsAvailable(int count) {
    return '$count Seats Available';
  }

  @override
  String get connectingJourney => 'Connecting\nJourney';

  @override
  String get connectingJourneyDesc => 'Same-operator hub transfer';

  @override
  String get ticketHandover => 'Ticket\nExchange';

  @override
  String get ticketHandoverDesc => '50% back to exchanger';

  @override
  String get navHome => 'Home';

  @override
  String get navSearch => 'Search';

  @override
  String get navMyTickets => 'My Tickets';

  @override
  String get navProfile => 'Profile';

  @override
  String get selectOriginTitle => 'Select Origin';

  @override
  String get selectDestinationTitle => 'Select Destination';

  @override
  String get selectPassengersTitle => 'Select Passengers';

  @override
  String get sameOriginDestinationError =>
      'Origin and destination cannot be the same.';

  @override
  String get pastDateError => 'Please select today or a future date.';

  @override
  String get retry => 'Retry';

  @override
  String get done => 'Done';

  @override
  String get notificationsPlaceholderTitle => 'Notifications';

  @override
  String get searchResultsPlaceholderTitle => 'Search Results';

  @override
  String get myTicketsPlaceholderTitle => 'My Tickets';

  @override
  String get profilePlaceholderTitle => 'Profile';

  @override
  String get connectingJourneyPlaceholderTitle => 'Connecting Journey';

  @override
  String get handoverPlaceholderTitle => 'Ticket Exchange';
}
