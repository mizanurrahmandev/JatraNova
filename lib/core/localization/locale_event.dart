import 'package:equatable/equatable.dart';

abstract class LocaleEvent extends Equatable {
  const LocaleEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Loads persisted language and numeral preferences at startup.
class LocaleInitialized extends LocaleEvent {
  const LocaleInitialized();
}

/// Updates the active application locale (`en` or `bn`) and persists it.
class LocaleChanged extends LocaleEvent {
  const LocaleChanged(this.languageCode);

  final String languageCode;

  @override
  List<Object?> get props => <Object?>[languageCode];
}

/// Toggles optional Bangla numeral formatting and persists the setting.
class BanglaNumeralsToggled extends LocaleEvent {
  const BanglaNumeralsToggled(this.enabled);

  final bool enabled;

  @override
  List<Object?> get props => <Object?>[enabled];
}
