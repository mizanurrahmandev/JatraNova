import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'JatraNova'**
  String get appName;

  /// No description provided for @appNameFirst.
  ///
  /// In en, this message translates to:
  /// **'Jatra'**
  String get appNameFirst;

  /// No description provided for @appNameSecond.
  ///
  /// In en, this message translates to:
  /// **'Nova'**
  String get appNameSecond;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Your Journey, Connected.'**
  String get appTagline;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @onboarding1TitlePrefix.
  ///
  /// In en, this message translates to:
  /// **'Travel Smart\nTravel '**
  String get onboarding1TitlePrefix;

  /// No description provided for @onboarding1TitleHighlight.
  ///
  /// In en, this message translates to:
  /// **'Better'**
  String get onboarding1TitleHighlight;

  /// No description provided for @onboarding1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Book your bus tickets\nwith ease and comfort.'**
  String get onboarding1Subtitle;

  /// No description provided for @onboarding2TitlePrefix.
  ///
  /// In en, this message translates to:
  /// **'Safe & Reliable\n'**
  String get onboarding2TitlePrefix;

  /// No description provided for @onboarding2TitleHighlight.
  ///
  /// In en, this message translates to:
  /// **'Journey'**
  String get onboarding2TitleHighlight;

  /// No description provided for @onboarding2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Travel with confidence\nacross Bangladesh.'**
  String get onboarding2Subtitle;

  /// No description provided for @onboarding2TrustPlatform.
  ///
  /// In en, this message translates to:
  /// **'Trusted\nPlatform'**
  String get onboarding2TrustPlatform;

  /// No description provided for @onboarding2TrustSupport.
  ///
  /// In en, this message translates to:
  /// **'24/7\nSupport'**
  String get onboarding2TrustSupport;

  /// No description provided for @onboarding2TrustPayments.
  ///
  /// In en, this message translates to:
  /// **'Secure\nPayments'**
  String get onboarding2TrustPayments;

  /// No description provided for @onboarding3TitlePrefix.
  ///
  /// In en, this message translates to:
  /// **'Flexible & Connected\n'**
  String get onboarding3TitlePrefix;

  /// No description provided for @onboarding3TitleHighlight.
  ///
  /// In en, this message translates to:
  /// **'Journeys'**
  String get onboarding3TitleHighlight;

  /// No description provided for @onboarding3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Easily exchange tickets and connect\nseamlessly across routes.'**
  String get onboarding3Subtitle;

  /// No description provided for @chooseLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get chooseLanguageTitle;

  /// No description provided for @chooseLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred language'**
  String get chooseLanguageSubtitle;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageBangla.
  ///
  /// In en, this message translates to:
  /// **'বাংলা'**
  String get languageBangla;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @welcomePlaceholderTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to JatraNova'**
  String get welcomePlaceholderTitle;

  /// No description provided for @welcomePlaceholderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome screen will be available in the next step.'**
  String get welcomePlaceholderSubtitle;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to\nJatraNova'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Book, track and manage\nyour journeys with ease.'**
  String get welcomeSubtitle;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @orDivider.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get orDivider;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get continueAsGuest;

  /// No description provided for @loginPlaceholderTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginPlaceholderTitle;

  /// No description provided for @registerPlaceholderTitle.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerPlaceholderTitle;

  /// No description provided for @guestHomePlaceholderTitle.
  ///
  /// In en, this message translates to:
  /// **'Guest Home'**
  String get guestHomePlaceholderTitle;

  /// No description provided for @comingSoonSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This screen will be implemented in the next step.'**
  String get comingSoonSubtitle;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get loginSubtitle;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailHint;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordHint;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'or continue with'**
  String get orContinueWith;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get continueWithGoogle;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @emailRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address.'**
  String get emailRequiredError;

  /// No description provided for @emailInvalidError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get emailInvalidError;

  /// No description provided for @passwordRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password.'**
  String get passwordRequiredError;

  /// No description provided for @loginNotImplementedNotice.
  ///
  /// In en, this message translates to:
  /// **'Login submission is not yet connected.'**
  String get loginNotImplementedNotice;

  /// No description provided for @socialLoginUnavailableNotice.
  ///
  /// In en, this message translates to:
  /// **'Social login is not available in this offline demo.'**
  String get socialLoginUnavailableNotice;

  /// No description provided for @forgotPasswordPlaceholderTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPasswordPlaceholderTitle;

  /// No description provided for @createAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountTitle;

  /// No description provided for @createAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join JatraNova today'**
  String get createAccountSubtitle;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullNameHint;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneHint;

  /// No description provided for @agreeTermsPrefix.
  ///
  /// In en, this message translates to:
  /// **'I agree to the '**
  String get agreeTermsPrefix;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsAndConditions;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @fullNameRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name.'**
  String get fullNameRequiredError;

  /// No description provided for @phoneRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number.'**
  String get phoneRequiredError;

  /// No description provided for @phoneInvalidError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number.'**
  String get phoneInvalidError;

  /// No description provided for @passwordMinLengthError.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get passwordMinLengthError;

  /// No description provided for @termsRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Please agree to the Terms & Conditions.'**
  String get termsRequiredError;

  /// No description provided for @registerNotImplementedNotice.
  ///
  /// In en, this message translates to:
  /// **'Account registration is not yet connected.'**
  String get registerNotImplementedNotice;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Your Password'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and\nwe\'ll send you a reset link.'**
  String get resetPasswordSubtitle;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// No description provided for @forgotPasswordNotImplementedNotice.
  ///
  /// In en, this message translates to:
  /// **'Password recovery is not implemented yet in this demo.'**
  String get forgotPasswordNotImplementedNotice;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning,'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon,'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening,'**
  String get greetingEvening;

  /// No description provided for @travelerName.
  ///
  /// In en, this message translates to:
  /// **'Traveler'**
  String get travelerName;

  /// No description provided for @homeHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Where do you want to\ngo today?'**
  String get homeHeroSubtitle;

  /// No description provided for @fromLabel.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get fromLabel;

  /// No description provided for @toLabel.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get toLabel;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @passengersLabel.
  ///
  /// In en, this message translates to:
  /// **'Passengers'**
  String get passengersLabel;

  /// No description provided for @passengerSingular.
  ///
  /// In en, this message translates to:
  /// **'{count} Passenger'**
  String passengerSingular(int count);

  /// No description provided for @passengerPlural.
  ///
  /// In en, this message translates to:
  /// **'{count} Passengers'**
  String passengerPlural(int count);

  /// No description provided for @searchBuses.
  ///
  /// In en, this message translates to:
  /// **'Search Buses'**
  String get searchBuses;

  /// No description provided for @popularRoutes.
  ///
  /// In en, this message translates to:
  /// **'Popular Routes'**
  String get popularRoutes;

  /// No description provided for @popularBuses.
  ///
  /// In en, this message translates to:
  /// **'Popular Buses'**
  String get popularBuses;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @demoBadge.
  ///
  /// In en, this message translates to:
  /// **'Demo'**
  String get demoBadge;

  /// No description provided for @fromFare.
  ///
  /// In en, this message translates to:
  /// **'From ৳{amount}'**
  String fromFare(String amount);

  /// No description provided for @seatsAvailable.
  ///
  /// In en, this message translates to:
  /// **'{count} Seats Available'**
  String seatsAvailable(int count);

  /// No description provided for @connectingJourney.
  ///
  /// In en, this message translates to:
  /// **'Connecting\nJourney'**
  String get connectingJourney;

  /// No description provided for @connectingJourneyDesc.
  ///
  /// In en, this message translates to:
  /// **'Same-operator hub transfer'**
  String get connectingJourneyDesc;

  /// No description provided for @ticketHandover.
  ///
  /// In en, this message translates to:
  /// **'Ticket\nHandover'**
  String get ticketHandover;

  /// No description provided for @ticketHandoverDesc.
  ///
  /// In en, this message translates to:
  /// **'50% back to exchanger'**
  String get ticketHandoverDesc;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// No description provided for @navMyTickets.
  ///
  /// In en, this message translates to:
  /// **'My Tickets'**
  String get navMyTickets;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @selectOriginTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Origin'**
  String get selectOriginTitle;

  /// No description provided for @selectDestinationTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Destination'**
  String get selectDestinationTitle;

  /// No description provided for @selectPassengersTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Passengers'**
  String get selectPassengersTitle;

  /// No description provided for @sameOriginDestinationError.
  ///
  /// In en, this message translates to:
  /// **'Origin and destination cannot be the same.'**
  String get sameOriginDestinationError;

  /// No description provided for @pastDateError.
  ///
  /// In en, this message translates to:
  /// **'Please select today or a future date.'**
  String get pastDateError;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @notificationsPlaceholderTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsPlaceholderTitle;

  /// No description provided for @searchResultsPlaceholderTitle.
  ///
  /// In en, this message translates to:
  /// **'Search Results'**
  String get searchResultsPlaceholderTitle;

  /// No description provided for @myTicketsPlaceholderTitle.
  ///
  /// In en, this message translates to:
  /// **'My Tickets'**
  String get myTicketsPlaceholderTitle;

  /// No description provided for @profilePlaceholderTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profilePlaceholderTitle;

  /// No description provided for @connectingJourneyPlaceholderTitle.
  ///
  /// In en, this message translates to:
  /// **'Connecting Journey'**
  String get connectingJourneyPlaceholderTitle;

  /// No description provided for @handoverPlaceholderTitle.
  ///
  /// In en, this message translates to:
  /// **'Ticket Handover'**
  String get handoverPlaceholderTitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
