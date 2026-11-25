import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jatra_nova/core/localization/locale_bloc.dart';
import 'package:jatra_nova/core/localization/locale_event.dart';
import 'package:jatra_nova/core/localization/locale_state.dart';
import 'package:jatra_nova/core/utils/preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late IPreferencesService preferencesService;
  late LocaleBloc localeBloc;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    preferencesService = PreferencesServiceImpl(prefs);
    localeBloc = LocaleBloc(preferencesService);
  });

  tearDown(() async {
    await localeBloc.close();
  });

  group('LocaleBloc', () {
    test('defaults to English locale and disabled Bangla numerals', () {
      expect(
        localeBloc.state,
        const LocaleState(
          locale: Locale('en'),
          banglaNumeralsEnabled: false,
        ),
      );
    });

    test('loads persisted Bangla locale and numerals flag on initialization',
        () async {
      await preferencesService.setSelectedLanguage('bn');
      await preferencesService.setBanglaNumeralsEnabled(true);

      localeBloc.add(const LocaleInitialized());
      await expectLater(
        localeBloc.stream,
        emits(
          const LocaleState(
            locale: Locale('bn'),
            banglaNumeralsEnabled: true,
          ),
        ),
      );
    });

    test('persists locale and numeral changes', () async {
      localeBloc.add(const LocaleChanged('bn'));
      await expectLater(
        localeBloc.stream,
        emits(
          const LocaleState(
            locale: Locale('bn'),
            banglaNumeralsEnabled: false,
          ),
        ),
      );
      expect(preferencesService.selectedLanguage, 'bn');

      localeBloc.add(const BanglaNumeralsToggled(true));
      await expectLater(
        localeBloc.stream,
        emits(
          const LocaleState(
            locale: Locale('bn'),
            banglaNumeralsEnabled: true,
          ),
        ),
      );
      expect(preferencesService.banglaNumeralsEnabled, isTrue);
    });
  });
}
