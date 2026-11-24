import 'package:flutter_test/flutter_test.dart';
import 'package:jatra_nova/core/error/failure.dart';

void main() {
  group('Failure', () {
    test('supports value comparisons via Equatable', () {
      const failure1 = Failure(type: FailureType.database, debugMessage: 'DB error');
      const failure2 = Failure(type: FailureType.database, debugMessage: 'DB error');
      const failure3 = Failure(type: FailureType.notFound, debugMessage: 'Not found');

      expect(failure1, equals(failure2));
      expect(failure1, isNot(equals(failure3)));
    });

    test('props includes type and debugMessage', () {
      const failure = Failure(type: FailureType.conflict, debugMessage: 'conflict');
      expect(failure.props, [FailureType.conflict, 'conflict']);
    });
  });
}
