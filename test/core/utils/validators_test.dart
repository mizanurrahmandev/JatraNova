import 'package:flutter_test/flutter_test.dart';
import 'package:jatra_nova/core/utils/validators.dart';

void main() {
  group('Validators', () {
    test('validates Bangladesh mobile numbers correctly', () {
      expect(Validators.isValidBdMobile('01712345678'), isTrue);
      expect(Validators.isValidBdMobile('01812345678'), isTrue);
      expect(Validators.isValidBdMobile('+8801912345678'), isTrue);
      expect(Validators.isValidBdMobile('8801512345678'), isTrue);

      // Invalid cases
      expect(Validators.isValidBdMobile('01212345678'), isFalse); // 012 is invalid operator
      expect(Validators.isValidBdMobile('0171234567'), isFalse); // too short
      expect(Validators.isValidBdMobile('017123456789'), isFalse); // too long
      expect(Validators.isValidBdMobile('abcdefghijk'), isFalse);
    });

    test('normalizes BD mobile to 11 digits', () {
      expect(Validators.normalizeBdMobile('+8801712345678'), equals('01712345678'));
      expect(Validators.normalizeBdMobile('8801712345678'), equals('01712345678'));
      expect(Validators.normalizeBdMobile('01712-345678'), equals('01712345678'));
    });

    test('validates email addresses properly', () {
      expect(Validators.isValidEmail('user@demo.com'), isTrue);
      expect(Validators.isValidEmail('test.name@domain.co'), isTrue);
      expect(Validators.isValidEmail('invalid-email'), isFalse);
      expect(Validators.isValidEmail('@domain.com'), isFalse);
    });

    test('validates password minimum length of 6', () {
      expect(Validators.isValidPassword('123456'), isTrue);
      expect(Validators.isValidPassword('pass'), isFalse);
    });
  });
}
