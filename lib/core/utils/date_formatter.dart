import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  /// Formats UTC epoch milliseconds to human date e.g. "Sat, 26 Apr 2025"
  static String formatFullDate(int epochMs, {String locale = 'en'}) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(epochMs, isUtc: true).toLocal();
    final formatter = DateFormat('EEE, d MMM yyyy', locale);
    return formatter.format(dateTime);
  }

  /// Formats UTC epoch milliseconds to short date e.g. "26 Apr 2025"
  static String formatShortDate(int epochMs, {String locale = 'en'}) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(epochMs, isUtc: true).toLocal();
    final formatter = DateFormat('d MMM yyyy', locale);
    return formatter.format(dateTime);
  }

  /// Formats UTC epoch milliseconds to time e.g. "08:00 AM"
  static String formatTime(int epochMs, {String locale = 'en'}) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(epochMs, isUtc: true).toLocal();
    final formatter = DateFormat('hh:mm a', locale);
    return formatter.format(dateTime);
  }

  /// Formats UTC epoch milliseconds to date and time e.g. "26 Apr 2025, 08:00 AM"
  static String formatDateTime(int epochMs, {String locale = 'en'}) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(epochMs, isUtc: true).toLocal();
    final formatter = DateFormat('d MMM yyyy, hh:mm a', locale);
    return formatter.format(dateTime);
  }

  /// Formats duration in minutes to e.g. "4h 30m"
  static String formatDurationMinutes(int minutes, {String locale = 'en'}) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0 && mins > 0) {
      return '${hours}h ${mins}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${mins}m';
    }
  }
}
