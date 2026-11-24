class Validators {
  Validators._();

  static final RegExp _mobileRegex = RegExp(r'^(?:\+88|88)?(01[3-9]\d{8})$');
  static final RegExp _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  /// Validates Bangladesh 11-digit mobile number format
  static bool isValidBdMobile(String value) {
    final cleanValue = value.replaceAll(RegExp(r'[\s-]'), '');
    return _mobileRegex.hasMatch(cleanValue);
  }

  /// Normalizes BD phone to standard 11-digit 01XXXXXXXXX format
  static String normalizeBdMobile(String value) {
    final cleanValue = value.replaceAll(RegExp(r'[\s-]'), '');
    final match = _mobileRegex.firstMatch(cleanValue);
    if (match != null && match.groupCount >= 1) {
      return match.group(1)!;
    }
    return cleanValue;
  }

  /// Validates standard email address format
  static bool isValidEmail(String value) {
    return _emailRegex.hasMatch(value.trim());
  }

  /// Validates password strength (minimum 6 characters for demo)
  static bool isValidPassword(String value) {
    return value.length >= 6;
  }

  /// Validates non-empty string
  static bool isNotEmpty(String? value) {
    return value != null && value.trim().isNotEmpty;
  }
}
