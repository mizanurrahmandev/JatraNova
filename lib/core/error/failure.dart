import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:jatra_nova/l10n/app_localizations.dart';

enum FailureType {
  database,
  notFound,
  validation,
  conflict,
  holdExpired,
  notEligible,
  unauthorized,
  unknown,
}

class Failure extends Equatable {
  final FailureType type;
  final String debugMessage;

  const Failure({
    required this.type,
    this.debugMessage = '',
  });

  String toLocalizedMessage(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return debugMessage.isNotEmpty ? debugMessage : type.name;

    switch (type) {
      case FailureType.database:
        return l10n.error_database;
      case FailureType.notFound:
        return l10n.error_not_found;
      case FailureType.validation:
        return l10n.error_validation;
      case FailureType.conflict:
        return l10n.error_conflict;
      case FailureType.holdExpired:
        return l10n.error_hold_expired;
      case FailureType.notEligible:
        return l10n.error_not_eligible;
      case FailureType.unauthorized:
        return l10n.error_unauthorized;
      case FailureType.unknown:
        return l10n.error_unknown;
    }
  }

  @override
  List<Object?> get props => [type, debugMessage];

  @override
  String toString() => 'Failure(type: $type, message: $debugMessage)';
}
