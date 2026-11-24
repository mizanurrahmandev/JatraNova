import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@injectable
class LocaleCubit extends Cubit<Locale> {
  static const String _localePrefKey = 'selected_locale';
  final SharedPreferences _preferences;

  LocaleCubit(this._preferences) : super(const Locale('bn')) {
    _loadSavedLocale();
  }

  void _loadSavedLocale() {
    final savedCode = _preferences.getString(_localePrefKey);
    if (savedCode != null && (savedCode == 'en' || savedCode == 'bn')) {
      emit(Locale(savedCode));
    } else {
      // Default locale is Bangla per AGENTS.md
      emit(const Locale('bn'));
    }
  }

  Future<void> setLocale(String languageCode) async {
    if (languageCode == 'en' || languageCode == 'bn') {
      await _preferences.setString(_localePrefKey, languageCode);
      emit(Locale(languageCode));
    }
  }

  Future<void> toggleLocale() async {
    final nextCode = state.languageCode == 'bn' ? 'en' : 'bn';
    await setLocale(nextCode);
  }
}
