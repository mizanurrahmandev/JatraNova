import 'package:flutter_test/flutter_test.dart';
import 'package:jatra_nova/core/utils/money_formatter.dart';

void main() {
  group('MoneyFormatter', () {
    test('formats whole integer BDT in English', () {
      final formatted = MoneyFormatter.formatBdt(1450, locale: 'en');
      expect(formatted, contains('1,450'));
    });

    test('formats zero BDT properly', () {
      final formatted = MoneyFormatter.formatBdt(0, locale: 'en');
      expect(formatted, contains('0'));
    });

    test('formats large integer amounts with commas', () {
      final formatted = MoneyFormatter.formatBdt(100000, locale: 'en');
      expect(formatted, contains('100,000'));
    });
  });
}
