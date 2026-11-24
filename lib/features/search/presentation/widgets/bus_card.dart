import 'package:flutter/material.dart';
import 'package:jatra_nova/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/trip_entity.dart';

class BusCard extends StatelessWidget {
  final TripEntity trip;
  final VoidCallback onSelectSeats;

  const BusCard({
    super.key,
    required this.trip,
    required this.onSelectSeats,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Operator name, bus type & AC tag
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.localizedOperatorName(locale),
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.primary,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${trip.busName} • ${trip.busType}',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: trip.isAc
                      ? AppColors.primaryLight.withValues(alpha: 0.12)
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: trip.isAc ? AppColors.secondary : AppColors.divider,
                  ),
                ),
                child: Text(
                  trip.acType,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: trip.isAc ? AppColors.secondary : AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Journey Timeline Block: Departure -> Duration/Line -> Arrival
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Departure
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormatter.formatTime(trip.departureAt, locale: locale),
                    style: AppTextStyles.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    trip.localizedOriginName(locale),
                    style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    trip.boardingPoint,
                    style: AppTextStyles.labelSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),

              // Duration line
              Column(
                children: [
                  Text(
                    DateFormatter.formatDurationMinutes(trip.durationMinutes, locale: locale),
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                      Container(width: 44, height: 1.5, color: AppColors.divider),
                      const Icon(Icons.directions_bus, size: 14, color: AppColors.primary),
                      Container(width: 44, height: 1.5, color: AppColors.divider),
                      Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle)),
                    ],
                  ),
                ],
              ),

              // Arrival
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    DateFormatter.formatTime(trip.arrivalAt, locale: locale),
                    style: AppTextStyles.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    trip.localizedDestinationName(locale),
                    style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    trip.dropOffPoint,
                    style: AppTextStyles.labelSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Facilities row
          if (trip.facilities.isNotEmpty) ...[
            Wrap(
              spacing: 6,
              children: trip.facilities.map((fac) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Text(
                    fac,
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
          ],

          const Divider(),
          const SizedBox(height: 8),

          // Bottom Bar: Available Seats tag (No fake ratings!) + Fare + Action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Available seats badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: trip.availableSeats > 5 ? AppColors.successLight : AppColors.warningLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.event_seat,
                      size: 16,
                      color: trip.availableSeats > 5 ? AppColors.success : AppColors.warning,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.results_seats_available(trip.availableSeats),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: trip.availableSeats > 5 ? AppColors.success : AppColors.warning,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Fare & Select seats button
              Row(
                children: [
                  Text(
                    MoneyFormatter.formatBdt(trip.fareAmount, locale: locale),
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  AppButton(
                    text: l10n.results_select_seats,
                    onPressed: trip.availableSeats > 0 ? onSelectSeats : null,
                    width: 120,
                    height: 40,
                    variant: AppButtonVariant.primary,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
