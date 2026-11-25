import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:jatra_nova/core/constants/app_constants.dart';
import 'package:jatra_nova/core/localization/locale_event.dart';
import 'package:jatra_nova/core/localization/locale_state.dart';
import 'package:jatra_nova/core/utils/preferences_service.dart';

/// App-wide BLoC managing selected locale (English default, Bangla supported)
/// and optional Bangla numeral preference via [IPreferencesService].
@lazySingleton
class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  LocaleBloc(this._preferencesService) : super(LocaleState.initial()) {
    on<LocaleInitialized>(_onInitialized);
    on<LocaleChanged>(_onLocaleChanged);
    on<BanglaNumeralsToggled>(_onBanglaNumeralsToggled);
  }

  final IPreferencesService _preferencesService;

  void _onInitialized(
    LocaleInitialized event,
    Emitter<LocaleState> emit,
  ) {
    final code = _preferencesService.selectedLanguage;
    final banglaNumerals = _preferencesService.banglaNumeralsEnabled;
    emit(
      state.copyWith(
        locale: Locale(code),
        banglaNumeralsEnabled: banglaNumerals,
      ),
    );
  }

  Future<void> _onLocaleChanged(
    LocaleChanged event,
    Emitter<LocaleState> emit,
  ) async {
    final normalized =
        AppConstants.supportedLanguageCodes.contains(event.languageCode)
            ? event.languageCode
            : AppConstants.defaultLanguageCode;
    await _preferencesService.setSelectedLanguage(normalized);
    emit(state.copyWith(locale: Locale(normalized)));
  }

  Future<void> _onBanglaNumeralsToggled(
    BanglaNumeralsToggled event,
    Emitter<LocaleState> emit,
  ) async {
    await _preferencesService.setBanglaNumeralsEnabled(event.enabled);
    emit(state.copyWith(banglaNumeralsEnabled: event.enabled));
  }
}
