import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:jatra_nova/core/constants/app_constants.dart';

class LocaleState extends Equatable {
  const LocaleState({
    required this.locale,
    required this.banglaNumeralsEnabled,
  });

  factory LocaleState.initial() => const LocaleState(
        locale: Locale(AppConstants.defaultLanguageCode),
        banglaNumeralsEnabled: false,
      );

  final Locale locale;
  final bool banglaNumeralsEnabled;

  LocaleState copyWith({
    Locale? locale,
    bool? banglaNumeralsEnabled,
  }) =>
      LocaleState(
        locale: locale ?? this.locale,
        banglaNumeralsEnabled:
            banglaNumeralsEnabled ?? this.banglaNumeralsEnabled,
      );

  @override
  List<Object?> get props => <Object?>[locale, banglaNumeralsEnabled];
}
