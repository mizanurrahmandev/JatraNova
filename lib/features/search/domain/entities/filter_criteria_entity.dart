import 'package:equatable/equatable.dart';

enum SortOption { earliestDeparture, lowestFare, fastest }

class FilterCriteriaEntity extends Equatable {
  final SortOption sortBy;
  final bool? onlyAc;
  final String? operatorId;

  const FilterCriteriaEntity({
    this.sortBy = SortOption.earliestDeparture,
    this.onlyAc,
    this.operatorId,
  });

  FilterCriteriaEntity copyWith({
    SortOption? sortBy,
    bool? onlyAc,
    String? operatorId,
    bool clearAc = false,
    bool clearOperator = false,
  }) {
    return FilterCriteriaEntity(
      sortBy: sortBy ?? this.sortBy,
      onlyAc: clearAc ? null : (onlyAc ?? this.onlyAc),
      operatorId: clearOperator ? null : (operatorId ?? this.operatorId),
    );
  }

  @override
  List<Object?> get props => [sortBy, onlyAc, operatorId];
}
