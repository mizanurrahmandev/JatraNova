// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get app_name => 'JatraNova';

  @override
  String get tagline => 'Your Journey, Connected';

  @override
  String get demo_app_notice => 'Local Demo Application';

  @override
  String get demo_payment_notice =>
      'This is a demo payment. No real money will be charged.';

  @override
  String get common_ok => 'OK';

  @override
  String get common_cancel => 'Cancel';

  @override
  String get common_confirm => 'Confirm';

  @override
  String get common_continue => 'Continue';

  @override
  String get common_back => 'Back';

  @override
  String get common_retry => 'Retry';

  @override
  String get common_save => 'Save';

  @override
  String get common_apply => 'Apply';

  @override
  String get common_reset => 'Reset';

  @override
  String get common_close => 'Close';

  @override
  String get common_next => 'Next';

  @override
  String get common_skip => 'Skip';

  @override
  String get common_get_started => 'Get Started';

  @override
  String get common_login => 'Login';

  @override
  String get common_register => 'Register';

  @override
  String get common_logout => 'Logout';

  @override
  String get common_guest => 'Continue as Guest';

  @override
  String get common_loading => 'Loading, please wait...';

  @override
  String get common_empty => 'No data found';

  @override
  String get common_error => 'Something went wrong';

  @override
  String get nav_home => 'Home';

  @override
  String get nav_search => 'Search';

  @override
  String get nav_tickets => 'My Tickets';

  @override
  String get nav_profile => 'Profile';

  @override
  String get onboarding_1_title => 'Travel Smart, Travel Better';

  @override
  String get onboarding_1_desc =>
      'Book your intercity bus tickets effortlessly with seat locks and fair transfers.';

  @override
  String get onboarding_2_title => 'Safe & Reliable Journey';

  @override
  String get onboarding_2_desc =>
      'Connecting routes across all major hubs in Bangladesh with guaranteed seat confirmation.';

  @override
  String get onboarding_3_title => 'Smart Ticket Handover';

  @override
  String get onboarding_3_desc =>
      'Plans changed? Safely transfer your ticket to another verified traveler with fair refund split.';

  @override
  String get welcome_title => 'Welcome to JatraNova';

  @override
  String get welcome_subtitle =>
      'Book, connect, and manage your intercity bus journeys with confidence.';

  @override
  String get auth_login_title => 'Welcome Back';

  @override
  String get auth_login_subtitle =>
      'Login with your email or Bangladesh mobile number';

  @override
  String get auth_identifier_label => 'Email or Mobile Number';

  @override
  String get auth_identifier_hint => '01XXXXXXXXX or email@demo.com';

  @override
  String get auth_password_label => 'Password';

  @override
  String get auth_password_hint => 'Enter your password';

  @override
  String get auth_remember_me => 'Remember Me';

  @override
  String get auth_forgot_password_demo =>
      'Demo Mode: Use password123 for seeded accounts';

  @override
  String get auth_create_account_prompt => 'Don\'t have an account?';

  @override
  String get auth_already_have_account => 'Already have an account?';

  @override
  String get auth_register_title => 'Create Account';

  @override
  String get auth_register_subtitle => 'Sign up for smart bus ticketing';

  @override
  String get auth_full_name_label => 'Full Name';

  @override
  String get auth_full_name_hint => 'Enter full name';

  @override
  String get auth_mobile_label => 'Mobile Number';

  @override
  String get auth_mobile_hint => '01XXXXXXXXX';

  @override
  String get auth_email_label => 'Email Address';

  @override
  String get auth_email_hint => 'example@demo.com';

  @override
  String get auth_confirm_password_label => 'Confirm Password';

  @override
  String get auth_confirm_password_hint => 'Re-enter your password';

  @override
  String get auth_terms_agree => 'I agree to the Terms & Conditions';

  @override
  String get auth_login_required_title => 'Login Required';

  @override
  String get auth_login_required_message =>
      'Please log in to continue with this action.';

  @override
  String get auth_error_passwords_mismatch => 'Passwords do not match.';

  @override
  String get auth_error_terms_required =>
      'You must accept the terms and conditions.';

  @override
  String get auth_error_invalid_credentials =>
      'Invalid email/mobile or password.';

  @override
  String get auth_error_user_exists =>
      'An account with this email or mobile already exists.';

  @override
  String get home_greeting_morning => 'Good morning,';

  @override
  String get home_greeting_afternoon => 'Good afternoon,';

  @override
  String get home_greeting_evening => 'Good evening,';

  @override
  String get home_greeting_traveler => 'Traveler';

  @override
  String get home_search_title => 'Where would you like to travel?';

  @override
  String get home_popular_routes => 'Popular Routes';

  @override
  String get home_see_all => 'See All';

  @override
  String get home_feature_connecting_title => 'Connecting Journeys';

  @override
  String get home_feature_connecting_desc =>
      'No direct bus? Transfer smoothly with same operator.';

  @override
  String get home_feature_handover_title => 'Ticket Handover';

  @override
  String get home_feature_handover_desc =>
      'Can\'t travel? Transfer your ticket and get 50% refund.';

  @override
  String get search_from_label => 'From (Origin)';

  @override
  String get search_from_hint => 'Select departure city';

  @override
  String get search_to_label => 'To (Destination)';

  @override
  String get search_to_hint => 'Select destination city';

  @override
  String get search_date_label => 'Journey Date';

  @override
  String get search_passengers_label => 'Passengers';

  @override
  String get search_action_button => 'Search Buses';

  @override
  String get search_popular_cities => 'Popular Cities';

  @override
  String get search_all_cities => 'All Cities';

  @override
  String get search_select_city_title => 'Select Location';

  @override
  String get search_city_search_hint => 'Search city name...';

  @override
  String get search_select_date_title => 'Select Travel Date';

  @override
  String get search_passenger_counter_title => 'Number of Passengers';

  @override
  String get search_passenger_limit_note =>
      'Maximum 4 passengers per booking in demo';

  @override
  String get search_error_same_city =>
      'Origin and destination cities cannot be the same.';

  @override
  String get search_error_empty_cities =>
      'Please select both origin and destination.';

  @override
  String get results_title => 'Available Buses';

  @override
  String results_count_format(int count) {
    return '$count buses available';
  }

  @override
  String get results_tab_all => 'All Buses';

  @override
  String get results_tab_direct => 'Direct Trips';

  @override
  String get results_tab_connecting => 'Connecting (2-Leg)';

  @override
  String results_seats_available(int count) {
    return '$count Seats Left';
  }

  @override
  String get results_starting_from => 'Starting from';

  @override
  String get results_select_seats => 'Select Seats';

  @override
  String get results_no_buses_found => 'No buses found for this date & route.';

  @override
  String get results_change_search => 'Change Search';

  @override
  String get filter_title => 'Filter & Sort';

  @override
  String get filter_sort_by => 'Sort By';

  @override
  String get filter_sort_earliest => 'Earliest Departure';

  @override
  String get filter_sort_lowest_fare => 'Lowest Fare';

  @override
  String get filter_sort_duration => 'Fastest Journey';

  @override
  String get filter_bus_type => 'Bus Type';

  @override
  String get filter_ac => 'AC Coach';

  @override
  String get filter_non_ac => 'Non-AC Coach';

  @override
  String get filter_operator => 'Bus Operator';

  @override
  String get filter_apply => 'Apply Filters';

  @override
  String get filter_reset => 'Reset Filters';

  @override
  String get language_title => 'Choose Language';

  @override
  String get language_subtitle => 'Select your preferred language';

  @override
  String get language_english => 'English';

  @override
  String get language_bangla => 'বাংলা';

  @override
  String get error_database => 'A database error occurred. Please try again.';

  @override
  String get error_not_found => 'The requested item was not found.';

  @override
  String get error_validation => 'Please check your inputs and try again.';

  @override
  String get error_conflict =>
      'This item or seat is already taken. Please choose another.';

  @override
  String get error_hold_expired =>
      'Your seat hold has expired. Please select your seats again.';

  @override
  String get error_not_eligible =>
      'This ticket is not eligible for this operation.';

  @override
  String get error_unauthorized =>
      'You must be signed in to perform this action.';

  @override
  String get error_unknown => 'An unexpected error occurred. Please try again.';
}
