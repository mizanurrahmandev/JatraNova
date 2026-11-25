import 'package:flutter_test/flutter_test.dart';
import 'package:jatra_nova/features/authentication/presentation/bloc/register_bloc.dart';
import 'package:jatra_nova/features/authentication/presentation/bloc/register_event.dart';
import 'package:jatra_nova/features/authentication/presentation/bloc/register_state.dart';

void main() {
  late RegisterBloc registerBloc;

  setUp(() {
    registerBloc = RegisterBloc();
  });

  tearDown(() async {
    await registerBloc.close();
  });

  group('RegisterBloc', () {
    test('initial state has empty fields, obscured password, and idle status',
        () {
      expect(registerBloc.state, const RegisterState());
      expect(registerBloc.state.obscurePassword, isTrue);
      expect(registerBloc.state.agreedToTerms, isFalse);
      expect(registerBloc.state.status, RegisterStatus.idle);
    });

    test('toggles password visibility and terms agreement', () async {
      registerBloc.add(const RegisterPasswordVisibilityToggled());
      registerBloc.add(const RegisterTermsToggled(true));

      await expectLater(
        registerBloc.stream,
        emitsInOrder(<Matcher>[
          isA<RegisterState>()
              .having((s) => s.obscurePassword, 'obscurePassword', isFalse),
          isA<RegisterState>()
              .having((s) => s.agreedToTerms, 'agreedToTerms', isTrue),
        ]),
      );
    });

    test('emits required errors when submitting empty form', () async {
      registerBloc.add(const RegisterSubmitted());

      await expectLater(
        registerBloc.stream,
        emits(
          isA<RegisterState>()
              .having(
                (s) => s.fullNameError,
                'fullNameError',
                RegisterFullNameError.required,
              )
              .having(
                (s) => s.emailError,
                'emailError',
                RegisterEmailError.required,
              )
              .having(
                (s) => s.phoneError,
                'phoneError',
                RegisterPhoneError.required,
              )
              .having(
                (s) => s.passwordError,
                'passwordError',
                RegisterPasswordError.required,
              )
              .having(
                (s) => s.termsError,
                'termsError',
                RegisterTermsError.required,
              )
              .having((s) => s.status, 'status', RegisterStatus.idle),
        ),
      );
    });

    test('emits invalid email, invalid phone, and short password errors',
        () async {
      registerBloc
        ..add(const RegisterFullNameChanged('Rahim Uddin'))
        ..add(const RegisterEmailChanged('bad-email'))
        ..add(const RegisterPhoneChanged('12345'))
        ..add(const RegisterPasswordChanged('123'))
        ..add(const RegisterTermsToggled(true))
        ..add(const RegisterSubmitted());

      await expectLater(
        registerBloc.stream,
        emitsThrough(
          isA<RegisterState>()
              .having((s) => s.fullNameError, 'fullNameError', isNull)
              .having(
                (s) => s.emailError,
                'emailError',
                RegisterEmailError.invalid,
              )
              .having(
                (s) => s.phoneError,
                'phoneError',
                RegisterPhoneError.invalid,
              )
              .having(
                (s) => s.passwordError,
                'passwordError',
                RegisterPasswordError.tooShort,
              )
              .having((s) => s.termsError, 'termsError', isNull),
        ),
      );
    });

    test(
        'emits submitting then unimplementedNotice on valid submission without faking registration',
        () async {
      registerBloc
        ..add(const RegisterFullNameChanged('Rahim Uddin'))
        ..add(const RegisterEmailChanged('rahim@example.com'))
        ..add(const RegisterPhoneChanged('+8801712345678'))
        ..add(const RegisterPasswordChanged('secret123'))
        ..add(const RegisterTermsToggled(true))
        ..add(const RegisterSubmitted());

      await expectLater(
        registerBloc.stream,
        emitsThrough(
          isA<RegisterState>()
              .having((s) => s.status, 'status', RegisterStatus.submitting),
        ),
      );

      await expectLater(
        registerBloc.stream,
        emits(
          isA<RegisterState>().having(
            (s) => s.status,
            'status',
            RegisterStatus.unimplementedNotice,
          ),
        ),
      );
    });
  });
}
