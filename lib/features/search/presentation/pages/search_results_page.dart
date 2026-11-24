import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jatra_nova/l10n/app_localizations.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../auth/presentation/widgets/login_required_dialog.dart';
import '../bloc/search_bloc.dart';
import '../widgets/bus_card.dart';
import '../widgets/filter_sort_sheet.dart';

class SearchResultsPage extends StatefulWidget {
  const SearchResultsPage({super.key});

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  int _selectedTab = 0; // 0: All, 1: Direct, 2: Connecting

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        final originName = state.selectedOrigin?.localizedName(locale) ?? '';
        final destName = state.selectedDestination?.localizedName(locale) ?? '';
        final dateText = DateFormatter.formatShortDate(
          state.selectedDate.millisecondsSinceEpoch,
          locale: locale,
        );

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text('$originName → $destName'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.tune),
                tooltip: l10n.filter_title,
                onPressed: () async {
                  final newFilters = await FilterSortSheet.show(
                    context: context,
                    currentFilters: state.filters,
                  );
                  if (newFilters != null && context.mounted) {
                    context.read<SearchBloc>().add(SearchApplyFilters(newFilters));
                  }
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // Search Criteria Summary Card
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(dateText, style: AppTextStyles.labelMedium),
                        const SizedBox(width: 12),
                        const Icon(Icons.person, size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text('${state.passengerCount} Pax', style: AppTextStyles.labelMedium),
                      ],
                    ),
                    TextButton(
                      onPressed: () => context.pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        l10n.results_change_search,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Filter Tabs (All, Direct, Connecting)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _buildTabPill(0, l10n.results_tab_all),
                    const SizedBox(width: 8),
                    _buildTabPill(1, l10n.results_tab_direct),
                    const SizedBox(width: 8),
                    _buildTabPill(2, l10n.results_tab_connecting),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Results List / State View
              Expanded(
                child: _buildResultsContent(context, state, l10n),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabPill(int index, String label) {
    final isSelected = _selectedTab == index;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.background,
      labelStyle: AppTextStyles.labelSmall.copyWith(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.divider,
        ),
      ),
      onSelected: (_) {
        setState(() {
          _selectedTab = index;
        });
      },
    );
  }

  Widget _buildResultsContent(
    BuildContext context,
    SearchState state,
    AppLocalizations l10n,
  ) {
    if (state.isSearchingTrips) {
      return const LoadingView();
    }

    if (state.failure != null) {
      return ErrorView(
        failure: state.failure,
        onRetry: () => context.read<SearchBloc>().add(SearchExecuteTrips()),
      );
    }

    if (state.trips.isEmpty) {
      return EmptyView(
        icon: Icons.directions_bus_outlined,
        title: l10n.results_no_buses_found,
        message: 'Try searching for an alternative date or location.',
        actionText: l10n.results_change_search,
        onAction: () => context.pop(),
      );
    }

    // Filter by tab: If Connecting tab is selected, notify user that Phase 9 powers connecting journeys
    if (_selectedTab == 2) {
      return EmptyView(
        icon: Icons.alt_route_rounded,
        title: 'Connecting Trips Available',
        message: 'Two-leg connecting options on the same operator via transfer hubs are powered in Phase 9.',
        actionText: 'View Direct Trips',
        onAction: () {
          setState(() {
            _selectedTab = 1;
          });
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: state.trips.length,
      itemBuilder: (context, index) {
        final trip = state.trips[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: BusCard(
            trip: trip,
            onSelectSeats: () {
              final session = context.read<SessionCubit>().state;
              if (session.isGuest || !session.isAuthenticated) {
                LoginRequiredDialog.show(context);
                return;
              }
              // In Phase 5, opens SeatSelectionPage with trip
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Selected ${trip.busName}. Seat selection opens in Phase 5.'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
