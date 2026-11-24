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

  /// No description provided for @app_name.
  ///
  /// In en, this message translates to:
  /// **'JatraNova'**
  String get app_name;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Your Journey, Connected'**
  String get tagline;

  /// No description provided for @demo_app_notice.
  ///
  /// In en, this message translates to:
  /// **'Local Demo Application'**
  String get demo_app_notice;

  /// No description provided for @demo_payment_notice.
  ///
  /// In en, this message translates to:
  /// **'This is a demo payment. No real money will be charged.'**
  String get demo_payment_notice;

  /// No description provided for @common_ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get common_ok;

  /// No description provided for @common_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get common_cancel;

  /// No description provided for @common_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get common_confirm;

  /// No description provided for @common_continue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get common_continue;

  /// No description provided for @common_back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get common_back;

  /// No description provided for @common_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get common_retry;

  /// No description provided for @common_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get common_save;

  /// No description provided for @common_apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get common_apply;

  /// No description provided for @common_reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get common_reset;

  /// No description provided for @common_close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get common_close;

  /// No description provided for @common_next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get common_next;

  /// No description provided for @common_skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get common_skip;

  /// No description provided for @common_get_started.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get common_get_started;

  /// No description provided for @common_login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get common_login;

  /// No description provided for @common_register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get common_register;

  /// No description provided for @common_logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get common_logout;

  /// No description provided for @common_guest.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get common_guest;

  /// No description provided for @common_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading, please wait...'**
  String get common_loading;

  /// No description provided for @common_empty.
  ///
  /// In en, this message translates to:
  /// **'No data found'**
  String get common_empty;

  /// No description provided for @common_error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get common_error;

  /// No description provided for @nav_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get nav_home;

  /// No description provided for @nav_search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get nav_search;

  /// No description provided for @nav_tickets.
  ///
  /// In en, this message translates to:
  /// **'My Tickets'**
  String get nav_tickets;

  /// No description provided for @nav_profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get nav_profile;

  /// No description provided for @onboarding_1_title.
  ///
  /// In en, this message translates to:
  /// **'Travel Smart, Travel Better'**
  String get onboarding_1_title;

  /// No description provided for @onboarding_1_desc.
  ///
  /// In en, this message translates to:
  /// **'Book your intercity bus tickets effortlessly with seat locks and fair transfers.'**
  String get onboarding_1_desc;

  /// No description provided for @onboarding_2_title.
  ///
  /// In en, this message translates to:
  /// **'Safe & Reliable Journey'**
  String get onboarding_2_title;

  /// No description provided for @onboarding_2_desc.
  ///
  /// In en, this message translates to:
  /// **'Connecting routes across all major hubs in Bangladesh with guaranteed seat confirmation.'**
  String get onboarding_2_desc;

  /// No description provided for @onboarding_3_title.
  ///
  /// In en, this message translates to:
  /// **'Smart Ticket Handover'**
  String get onboarding_3_title;

  /// No description provided for @onboarding_3_desc.
  ///
  /// In en, this message translates to:
  /// **'Plans changed? Safely transfer your ticket to another verified traveler with fair refund split.'**
  String get onboarding_3_desc;

  /// No description provided for @welcome_title.
  ///
  /// In en, this message translates to:
  /// **'Welcome to JatraNova'**
  String get welcome_title;

  /// No description provided for @welcome_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Book, connect, and manage your intercity bus journeys with confidence.'**
  String get welcome_subtitle;

  /// No description provided for @auth_login_title.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get auth_login_title;

  /// No description provided for @auth_login_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Login with your email or Bangladesh mobile number'**
  String get auth_login_subtitle;

  /// No description provided for @auth_identifier_label.
  ///
  /// In en, this message translates to:
  /// **'Email or Mobile Number'**
  String get auth_identifier_label;

  /// No description provided for @auth_identifier_hint.
  ///
  /// In en, this message translates to:
  /// **'01XXXXXXXXX or email@demo.com'**
  String get auth_identifier_hint;

  /// No description provided for @auth_password_label.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get auth_password_label;

  /// No description provided for @auth_password_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get auth_password_hint;

  /// No description provided for @auth_remember_me.
  ///
  /// In en, this message translates to:
  /// **'Remember Me'**
  String get auth_remember_me;

  /// No description provided for @auth_forgot_password_demo.
  ///
  /// In en, this message translates to:
  /// **'Demo Mode: Use password123 for seeded accounts'**
  String get auth_forgot_password_demo;

  /// No description provided for @auth_create_account_prompt.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get auth_create_account_prompt;

  /// No description provided for @auth_already_have_account.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get auth_already_have_account;

  /// No description provided for @auth_register_title.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get auth_register_title;

  /// No description provided for @auth_register_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign up for smart bus ticketing'**
  String get auth_register_subtitle;

  /// No description provided for @auth_full_name_label.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get auth_full_name_label;

  /// No description provided for @auth_full_name_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter full name'**
  String get auth_full_name_hint;

  /// No description provided for @auth_mobile_label.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get auth_mobile_label;

  /// No description provided for @auth_mobile_hint.
  ///
  /// In en, this message translates to:
  /// **'01XXXXXXXXX'**
  String get auth_mobile_hint;

  /// No description provided for @auth_email_label.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get auth_email_label;

  /// No description provided for @auth_email_hint.
  ///
  /// In en, this message translates to:
  /// **'example@demo.com'**
  String get auth_email_hint;

  /// No description provided for @auth_confirm_password_label.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get auth_confirm_password_label;

  /// No description provided for @auth_confirm_password_hint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get auth_confirm_password_hint;

  /// No description provided for @auth_terms_agree.
  ///
  /// In en, this message translates to:
  /// **'I agree to the Terms & Conditions'**
  String get auth_terms_agree;

  /// No description provided for @auth_login_required_title.
  ///
  /// In en, this message translates to:
  /// **'Login Required'**
  String get auth_login_required_title;

  /// No description provided for @auth_login_required_message.
  ///
  /// In en, this message translates to:
  /// **'Please log in to continue with this action.'**
  String get auth_login_required_message;

  /// No description provided for @auth_error_passwords_mismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get auth_error_passwords_mismatch;

  /// No description provided for @auth_error_terms_required.
  ///
  /// In en, this message translates to:
  /// **'You must accept the terms and conditions.'**
  String get auth_error_terms_required;

  /// No description provided for @auth_error_invalid_credentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email/mobile or password.'**
  String get auth_error_invalid_credentials;

  /// No description provided for @auth_error_user_exists.
  ///
  /// In en, this message translates to:
  /// **'An account with this email or mobile already exists.'**
  String get auth_error_user_exists;

  /// No description provided for @language_title.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get language_title;

  /// No description provided for @language_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred language'**
  String get language_subtitle;

  /// No description provided for @language_english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get language_english;

  /// No description provided for @language_bangla.
  ///
  /// In en, this message translates to:
  /// **'বাংলা'**
  String get language_bangla;

  /// No description provided for @error_database.
  ///
  /// In en, this message translates to:
  /// **'A database error occurred. Please try again.'**
  String get error_database;

  /// No description provided for @error_not_found.
  ///
  /// In en, this message translates to:
  /// **'The requested item was not found.'**
  String get error_not_found;

  /// No description provided for @error_validation.
  ///
  /// In en, this message translates to:
  /// **'Please check your inputs and try again.'**
  String get error_validation;

  /// No description provided for @error_conflict.
  ///
  /// In en, this message translates to:
  /// **'This item or seat is already taken. Please choose another.'**
  String get error_conflict;

  /// No description provided for @error_hold_expired.
  ///
  /// In en, this message translates to:
  /// **'Your seat hold has expired. Please select your seats again.'**
  String get error_hold_expired;

  /// No description provided for @error_not_eligible.
  ///
  /// In en, this message translates to:
  /// **'This ticket is not eligible for this operation.'**
  String get error_not_eligible;

  /// No description provided for @error_unauthorized.
  ///
  /// In en, this message translates to:
  /// **'You must be signed in to perform this action.'**
  String get error_unauthorized;

  /// No description provided for @error_unknown.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get error_unknown;
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
