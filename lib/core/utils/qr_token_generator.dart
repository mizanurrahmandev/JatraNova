import 'package:uuid/uuid.dart';

class QrTokenGenerator {
  static const _uuid = Uuid();

  /// Generates a unique, opaque token for ticket QR representation.
  /// Never embeds PII (name, phone, national ID).
  static String generate() {
    return 'JN-${_uuid.v4()}';
  }
}
