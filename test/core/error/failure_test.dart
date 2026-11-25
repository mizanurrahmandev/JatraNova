import 'package:flutter_test/flutter_test.dart';
import 'package:jatra_nova/core/error/failure.dart';

void main() {
  group('Failure', () {
    test('supports value equality via Equatable', () {
      const a = Failure(
        type: FailureType.validation,
        debugMessage: 'Invalid input',
        code: 'VAL_01',
      );
      const b = Failure(
        type: FailureType.validation,
        debugMessage: 'Invalid input',
        code: 'VAL_01',
      );
      const c = Failure(
        type: FailureType.conflict,
        debugMessage: 'Invalid input',
        code: 'VAL_01',
      );

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });
}
