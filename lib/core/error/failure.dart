import 'package:equatable/equatable.dart';

/// Categories of domain and data failures used for branching in UI and BLoCs.
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

/// Base failure value object returned inside `Either<Failure, T>`.
class Failure extends Equatable {
  const Failure({
    required this.type,
    this.debugMessage,
    this.code,
  });

  final FailureType type;
  final String? debugMessage;
  final String? code;

  @override
  List<Object?> get props => <Object?>[type, debugMessage, code];
}
