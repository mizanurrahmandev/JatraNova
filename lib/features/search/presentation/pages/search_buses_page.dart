import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jatra_nova/l10n/app_localizations.dart';
import '../../../../core/route/route_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../bloc/search_bloc.dart';
import '../widgets/date_picker_sheet.dart';
import '../widgets/location_picker_sheet.dart';
import '../widgets/passenger_selector_sheet.dart';

class SearchBusesPage extends StatelessWidget {
  const SearchBusesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    return BlocConsumer<SearchBloc, SearchState>(
      listener: (context, state) {
        if (state.failure != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.failure!.toLocalizedMessage(context)),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final originName = state.selectedOrigin?.localizedName(locale) ?? l10n.search_from_hint;
        final destName = state.selectedDestination?.localizedName(locale) ?? l10n.search_to_hint;
        final dateText = DateFormatter.formatFullDate(
          state.selectedDate.millisecondsSinceEpoch,
          locale: locale,
        );

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(l10n.search_action_button),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Search Form Card
                AppCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      // Origin Field Trigger
                      InkWell(
                        onTap: () async {
                          final selected = await LocationPickerSheet.show(
                            context: context,
                            locations: state.locations,
                            initialSelected: state.selectedOrigin,
                          );
                          if (selected != null && context.mounted) {
                            context.read<SearchBloc>().add(SearchSelectOrigin(selected));
                          }
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.trip_origin, color: AppColors.primary, size: 22),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(l10n.search_from_label, style: AppTextStyles.labelSmall),
                                  const SizedBox(height: 2),
                                  Text(
                                    originName,
                                    style: AppTextStyles.titleMedium.copyWith(
                                      color: state.selectedOrigin != null
                                          ? AppColors.textPrimary
                                          : AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Swap divider
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          const Divider(height: 28),
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              onPressed: () {
                                context.read<SearchBloc>().add(SearchSwapLocations());
                              },
                              icon: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.divider),
                                ),
                                child: const Icon(
                                  Icons.swap_vert,
                                  size: 20,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Destination Field Trigger
                      InkWell(
                        onTap: () async {
                          final selected = await LocationPickerSheet.show(
                            context: context,
                            locations: state.locations,
                            initialSelected: state.selectedDestination,
                          );
                          if (selected != null && context.mounted) {
                            context.read<SearchBloc>().add(SearchSelectDestination(selected));
                          }
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.location_on_outlined, color: AppColors.secondary, size: 22),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(l10n.search_to_label, style: AppTextStyles.labelSmall),
                                  const SizedBox(height: 2),
                                  Text(
                                    destName,
                                    style: AppTextStyles.titleMedium.copyWith(
                                      color: state.selectedDestination != null
                                          ? AppColors.textPrimary
                                          : AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Date & Passenger Selectors
                Row(
                  children: [
                    // Date Selector Card
                    Expanded(
                      child: AppCard(
                        padding: const EdgeInsets.all(14),
                        onTap: () async {
                          final date = await DatePickerSheet.show(
                            context: context,
                            initialDate: state.selectedDate,
                          );
                          if (date != null && context.mounted) {
                            context.read<SearchBloc>().add(SearchSelectDate(date));
                          }
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                                const SizedBox(width: 6),
                                Text(l10n.search_date_label, style: AppTextStyles.labelSmall),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              dateText,
                              style: AppTextStyles.titleSmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Passenger Selector Card
                    Expanded(
                      child: AppCard(
                        padding: const EdgeInsets.all(14),
                        onTap: () async {
                          final count = await PassengerSelectorSheet.show(
                            context: context,
                            initialCount: state.passengerCount,
                          );
                          if (count != null && context.mounted) {
                            context.read<SearchBloc>().add(SearchUpdatePassengers(count));
                          }
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.people_outline, size: 16, color: AppColors.primary),
                                const SizedBox(width: 6),
                                Text(l10n.search_passengers_label, style: AppTextStyles.labelSmall),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${state.passengerCount} Passenger(s)',
                              style: AppTextStyles.titleSmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Submit search button
                AppButton(
                  text: l10n.search_action_button,
                  onPressed: () {
                    if (state.selectedOrigin?.id == state.selectedDestination?.id) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.search_error_same_city),
                          backgroundColor: AppColors.error,
                        ),
                      );
                      return;
                    }
                    context.read<SearchBloc>().add(SearchExecuteTrips());
                    context.push(RoutePath.searchResults);
                  },
                  variant: AppButtonVariant.primary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
