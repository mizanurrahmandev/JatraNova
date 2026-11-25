import 'package:flutter_test/flutter_test.dart';
import 'package:jatra_nova/features/authentication/presentation/bloc/forgot_password_bloc.dart';
import 'package:jatra_nova/features/authentication/presentation/bloc/forgot_password_event.dart';
import 'package:jatra_nova/features/authentication/presentation/bloc/forgot_password_state.dart';

void main() {
  late ForgotPasswordBloc bloc;

  setUp(() {
    bloc = ForgotPasswordBloc();
  });

  tearDown(() async {
    await bloc.close();
  });

  group('ForgotPasswordBloc', () {
    test('initial state has empty email and idle status', () {
      expect(bloc.state, const ForgotPasswordState());
      expect(bloc.state.email, '');
      expect(bloc.state.status, ForgotPasswordStatus.idle);
    });

    test('emits required error when submitting empty email', () async {
      bloc.add(const ForgotPasswordSubmitted());

      await expectLater(
        bloc.stream,
        emits(
          isA<ForgotPasswordState>()
              .having(
                (s) => s.emailError,
                'emailError',
                ForgotPasswordEmailError.required,
              )
              .having((s) => s.status, 'status', ForgotPasswordStatus.idle),
        ),
      );
    });

    test('emits invalid error when submitting malformed email', () async {
      bloc
        ..add(const ForgotPasswordEmailChanged('not-an-email'))
        ..add(const ForgotPasswordSubmitted());

      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<ForgotPasswordState>()
              .having(
                (s) => s.emailError,
                'emailError',
                ForgotPasswordEmailError.invalid,
              )
              .having((s) => s.status, 'status', ForgotPasswordStatus.idle),
        ),
      );
    });

    test(
        'emits submitting, unimplementedNotice, and returns to idle on valid email',
        () async {
      bloc
        ..add(const ForgotPasswordEmailChanged('rahim@example.com'))
        ..add(const ForgotPasswordSubmitted());

      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<ForgotPasswordState>()
              .having((s) => s.status, 'status', ForgotPasswordStatus.submitting),
        ),
      );

      await expectLater(
        bloc.stream,
        emits(
          isA<ForgotPasswordState>().having(
            (s) => s.status,
            'status',
            ForgotPasswordStatus.unimplementedNotice,
          ),
        ),
      );

      bloc.add(const ForgotPasswordNoticeDismissed());
      await expectLater(
        bloc.stream,
        emits(
          isA<ForgotPasswordState>()
              .having((s) => s.status, 'status', ForgotPasswordStatus.idle),
        ),
      );
    });
  });
}
