import 'package:flutter_test/flutter_test.dart';
import 'package:jatra_nova/core/utils/qr_token_generator.dart';

void main() {
  group('QrTokenGenerator', () {
    test('generates opaque token with JN- prefix', () {
      final token = QrTokenGenerator.generate();
      expect(token, startsWith('JN-'));
      expect(token.length, greaterThan(20));
    });

    test('generates unique tokens on repeated calls', () {
      final token1 = QrTokenGenerator.generate();
      final token2 = QrTokenGenerator.generate();
      expect(token1, isNot(equals(token2)));
    });
  });
}
