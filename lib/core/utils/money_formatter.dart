import 'package:intl/intl.dart';

class MoneyFormatter {
  MoneyFormatter._();

  /// Formats integer BDT amount (in whole Taka).
  /// [locale] defaults to 'en' or 'bn'.
  static String formatBdt(int amountInBdt, {String locale = 'en', bool showSymbol = true}) {
    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: showSymbol ? '৳ ' : '',
      decimalDigits: 0,
    );
    return formatter.format(amountInBdt).trim();
  }

  /// Returns localized digits if requested
  static String formatNumber(int number, {String locale = 'en'}) {
    final formatter = NumberFormat.decimalPattern(locale);
    return formatter.format(number);
  }
}
