import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jatra_nova/l10n/app_localizations.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../../core/route/route_config.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../../core/session/session_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../auth/presentation/widgets/login_required_dialog.dart';
import '../../../search/presentation/bloc/search_bloc.dart';
import '../../../search/presentation/widgets/date_picker_sheet.dart';
import '../../../search/presentation/widgets/location_picker_sheet.dart';
import '../../../search/presentation/widgets/passenger_selector_sheet.dart';
import '../../../search/presentation/widgets/popular_route_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    // Preload locations & popular routes on app startup
    context.read<SearchBloc>().add(SearchLoadInitialData());
  }

  String _getGreeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.home_greeting_morning;
    if (hour < 17) return l10n.home_greeting_afternoon;
    return l10n.home_greeting_evening;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, searchState) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            title: Text(
              l10n.app_name,
              style: AppTextStyles.titleLarge.copyWith(color: AppColors.primary),
            ),
            actions: [
              // Language toggle button
              TextButton.icon(
                onPressed: () {
                  context.read<LocaleCubit>().toggleLocale();
                },
                icon: const Icon(Icons.language, size: 18, color: AppColors.primary),
                label: Text(
                  locale == 'bn' ? 'English' : 'বাংলা',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.notifications_none, color: AppColors.textPrimary),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notifications view opens in Phase 10')),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Demo notice banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.infoLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 18, color: AppColors.info),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.demo_app_notice,
                          style: AppTextStyles.labelSmall.copyWith(color: AppColors.info),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Greeting & Personalized User Title
                BlocBuilder<SessionCubit, SessionState>(
                  builder: (context, session) {
                    final userName = session.isAuthenticated
                        ? session.userName!
                        : l10n.home_greeting_traveler;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_getGreeting(l10n)} $userName!',
                          style: AppTextStyles.displayMedium.copyWith(
                            color: AppColors.primary,
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.home_search_title,
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Core Search Card
                _buildSearchCard(context, searchState, l10n, locale),
                const SizedBox(height: 24),

                // Popular Routes Carousel
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.home_popular_routes, style: AppTextStyles.titleMedium),
                    Text(
                      l10n.home_see_all,
                      style: AppTextStyles.labelMedium.copyWith(color: AppColors.secondary),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildPopularRoutesList(context, searchState, locale),
                const SizedBox(height: 24),

                // Innovation Feature Shortcuts
                Text('Innovation Features', style: AppTextStyles.titleMedium),
                const SizedBox(height: 12),
                _buildFeatureShortcuts(context, l10n),
                const SizedBox(height: 20),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentTabIndex,
            onTap: (index) {
              if (index == 2) {
                // My Tickets: Protected guest gate
                final session = context.read<SessionCubit>().state;
                if (!session.isAuthenticated) {
                  LoginRequiredDialog.show(context);
                  return;
                }
              }
              setState(() {
                _currentTabIndex = index;
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_outlined),
                activeIcon: const Icon(Icons.home),
                label: l10n.nav_home,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.search_outlined),
                activeIcon: const Icon(Icons.search),
                label: l10n.nav_search,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.confirmation_number_outlined),
                activeIcon: const Icon(Icons.confirmation_number),
                label: l10n.nav_tickets,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person_outline),
                activeIcon: const Icon(Icons.person),
                label: l10n.nav_profile,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchCard(
    BuildContext context,
    SearchState searchState,
    AppLocalizations l10n,
    String locale,
  ) {
    final originName = searchState.selectedOrigin?.localizedName(locale) ?? l10n.search_from_hint;
    final destName = searchState.selectedDestination?.localizedName(locale) ?? l10n.search_to_hint;
    final dateText = DateFormatter.formatFullDate(
      searchState.selectedDate.millisecondsSinceEpoch,
      locale: locale,
    );

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Origin selector
          InkWell(
            onTap: () async {
              final loc = await LocationPickerSheet.show(
                context: context,
                locations: searchState.locations,
                initialSelected: searchState.selectedOrigin,
              );
              if (loc != null && context.mounted) {
                context.read<SearchBloc>().add(SearchSelectOrigin(loc));
              }
            },
            child: Row(
              children: [
                const Icon(Icons.trip_origin, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.search_from_label, style: AppTextStyles.labelSmall),
                      Text(originName, style: AppTextStyles.titleSmall),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Swap Divider
          Stack(
            alignment: Alignment.center,
            children: [
              const Divider(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () {
                    context.read<SearchBloc>().add(SearchSwapLocations());
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: const Icon(Icons.swap_vert, size: 18, color: AppColors.primary),
                  ),
                ),
              ),
            ],
          ),

          // Destination selector
          InkWell(
            onTap: () async {
              final loc = await LocationPickerSheet.show(
                context: context,
                locations: searchState.locations,
                initialSelected: searchState.selectedDestination,
              );
              if (loc != null && context.mounted) {
                context.read<SearchBloc>().add(SearchSelectDestination(loc));
              }
            },
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined, color: AppColors.secondary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.search_to_label, style: AppTextStyles.labelSmall),
                      Text(destName, style: AppTextStyles.titleSmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Date & Passengers Row
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final date = await DatePickerSheet.show(
                      context: context,
                      initialDate: searchState.selectedDate,
                    );
                    if (date != null && context.mounted) {
                      context.read<SearchBloc>().add(SearchSelectDate(date));
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.search_date_label, style: AppTextStyles.labelSmall),
                        const SizedBox(height: 2),
                        Text(
                          dateText,
                          style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final count = await PassengerSelectorSheet.show(
                      context: context,
                      initialCount: searchState.passengerCount,
                    );
                    if (count != null && context.mounted) {
                      context.read<SearchBloc>().add(SearchUpdatePassengers(count));
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.search_passengers_label, style: AppTextStyles.labelSmall),
                        const SizedBox(height: 2),
                        Text(
                          '${searchState.passengerCount} Pax',
                          style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Search Button
          AppButton(
            text: l10n.search_action_button,
            onPressed: () {
              if (searchState.selectedOrigin?.id == searchState.selectedDestination?.id) {
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
    );
  }

  Widget _buildPopularRoutesList(
    BuildContext context,
    SearchState searchState,
    String locale,
  ) {
    if (searchState.popularRoutes.isEmpty) {
      return const SizedBox(height: 80);
    }

    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: searchState.popularRoutes.length,
        separatorBuilder: (_, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final item = searchState.popularRoutes[index];
          final originName = locale == 'bn' ? item['origin_name_bn'] : item['origin_name_en'];
          final destName = locale == 'bn' ? item['destination_name_bn'] : item['destination_name_en'];

          return PopularRouteCard(
            originName: originName as String,
            destinationName: destName as String,
            startingFare: item['starting_fare'] as int,
            dailyTrips: item['daily_trips'] as int,
            onTap: () {
              final originLoc = searchState.locations.firstWhere(
                (l) => l.id == item['origin_id'],
              );
              final destLoc = searchState.locations.firstWhere(
                (l) => l.id == item['destination_id'],
              );
              context.read<SearchBloc>().add(SearchSelectOrigin(originLoc));
              context.read<SearchBloc>().add(SearchSelectDestination(destLoc));
              context.read<SearchBloc>().add(SearchExecuteTrips());
              context.push(RoutePath.searchResults);
            },
          );
        },
      ),
    );
  }

  Widget _buildFeatureShortcuts(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        // Connecting Journeys Shortcut
        AppCard(
          padding: const EdgeInsets.all(14),
          borderColor: AppColors.connectingViolet.withValues(alpha: 0.3),
          backgroundColor: AppColors.connectingVioletLight,
          onTap: () {
            // Pre-select Dhaka -> Rangpur (the seeded connecting route pair!)
            final searchBloc = context.read<SearchBloc>();
            final locs = searchBloc.state.locations;
            if (locs.isNotEmpty) {
              final dac = locs.firstWhere((l) => l.code == 'DAC');
              final rng = locs.firstWhere((l) => l.code == 'RNG');
              searchBloc.add(SearchSelectOrigin(dac));
              searchBloc.add(SearchSelectDestination(rng));
            }
            context.push(RoutePath.searchBuses);
          },
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.connectingViolet.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.alt_route_rounded,
                  color: AppColors.connectingViolet,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.home_feature_connecting_title,
                      style: AppTextStyles.titleSmall.copyWith(color: AppColors.connectingViolet),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.home_feature_connecting_desc,
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.connectingViolet),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Ticket Handover Shortcut
        AppCard(
          padding: const EdgeInsets.all(14),
          borderColor: AppColors.handoverOrange.withValues(alpha: 0.3),
          backgroundColor: AppColors.handoverOrangeLight,
          onTap: () {
            final session = context.read<SessionCubit>().state;
            if (!session.isAuthenticated) {
              LoginRequiredDialog.show(context);
              return;
            }
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ticket Handover workflow opens in Phase 8')),
            );
          },
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.handoverOrange.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.swap_horizontal_circle_outlined,
                  color: AppColors.handoverOrange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.home_feature_handover_title,
                      style: AppTextStyles.titleSmall.copyWith(color: AppColors.handoverOrange),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.home_feature_handover_desc,
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.handoverOrange),
            ],
          ),
        ),
      ],
    );
  }
}
