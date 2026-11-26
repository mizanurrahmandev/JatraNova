import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:jatra_nova/core/constants/app_assets.dart';
import 'package:jatra_nova/core/constants/app_constants.dart';
import 'package:jatra_nova/core/constants/app_spacing.dart';
import 'package:jatra_nova/core/di/injection.dart';
import 'package:jatra_nova/core/localization/locale_bloc.dart';
import 'package:jatra_nova/core/localization/locale_state.dart';
import 'package:jatra_nova/core/route/route_config.dart';
import 'package:jatra_nova/core/theme/app_colors.dart';
import 'package:jatra_nova/core/utils/session_bloc.dart';
import 'package:jatra_nova/features/home/domain/entities/home_entities.dart';
import 'package:jatra_nova/features/home/presentation/bloc/home_bloc.dart';
import 'package:jatra_nova/features/home/presentation/bloc/home_event.dart';
import 'package:jatra_nova/features/home/presentation/bloc/home_state.dart';
import 'package:jatra_nova/l10n/app_localizations.dart';

/// Passenger Home Screen recreated from `references/home/home_screen.jpg`.
///
/// Supports both Guest and Authenticated passenger sessions, reading stops,
/// popular routes, and popular demo buses from the local SQLite database.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final languageCode = context.read<LocaleBloc>().state.locale.languageCode;
    final userId = context.read<SessionBloc>().state.userId;

    return BlocProvider<HomeBloc>(
      create: (_) => getIt<HomeBloc>()
        ..add(HomeStarted(languageCode: languageCode, userId: userId)),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  String _greetingText(AppLocalizations l10n, DateTime now) {
    final hour = now.hour;
    if (hour < 12) {
      return l10n.greetingMorning;
    }
    if (hour < 17) {
      return l10n.greetingAfternoon;
    }
    return l10n.greetingEvening;
  }

  String _formatBdt(int fareMinor, String localeCode) {
    final taka = fareMinor ~/ AppConstants.poishaPerTaka;
    return NumberFormat('#,##0', localeCode).format(taka);
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _pickStop({
    required BuildContext context,
    required String title,
    required List<StopEntity> stops,
    required String? selectedId,
    required ValueChanged<StopEntity> onSelected,
  }) async {
    if (stops.isEmpty) {
      return;
    }
    final picked = await showModalBottomSheet<StopEntity>(
      context: context,
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.onboardingHeadingNavy,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                AppSpacing.verticalMd,
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: stops.length,
                    separatorBuilder: (_, _) => const Divider(
                      color: AppColors.homeSurfaceBorder,
                      height: 1,
                    ),
                    itemBuilder: (_, int index) {
                      final stop = stops[index];
                      final isSelected = stop.id == selectedId;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.location_on_rounded,
                          color: isSelected
                              ? AppColors.secondary
                              : AppColors.homeTextMuted,
                        ),
                        title: Text(
                          stop.name,
                          style: TextStyle(
                            color: AppColors.onboardingHeadingNavy,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.secondary,
                              )
                            : null,
                        onTap: () => Navigator.of(ctx).pop(stop),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (picked != null) {
      onSelected(picked);
    }
  }

  Future<void> _pickDate(BuildContext context, DateTime? current) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final initial =
        (current != null && !current.isBefore(today)) ? current : today;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: today,
      lastDate: today.add(const Duration(days: 30)),
    );
    if (picked != null && context.mounted) {
      context.read<HomeBloc>().add(HomeDateSelected(picked));
    }
  }

  Future<void> _pickPassengers(BuildContext context, int currentCount) async {
    final l10n = AppLocalizations.of(context)!;
    var tempCount = currentCount;
    final selected = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (BuildContext _, StateSetter setSheetState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      l10n.selectPassengersTitle,
                      style: TextStyle(
                        color: AppColors.onboardingHeadingNavy,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    AppSpacing.verticalXl,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        IconButton.filledTonal(
                          key: const Key('passenger_decrement_button'),
                          onPressed: tempCount > HomeBloc.minPassengers
                              ? () => setSheetState(() => tempCount--)
                              : null,
                          icon: const Icon(Icons.remove_rounded),
                        ),
                        SizedBox(width: 24.w),
                        Text(
                          '$tempCount',
                          key: const Key('passenger_picker_count'),
                          style: TextStyle(
                            color: AppColors.onboardingHeadingNavy,
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(width: 24.w),
                        IconButton.filledTonal(
                          key: const Key('passenger_increment_button'),
                          onPressed: tempCount < HomeBloc.maxPassengers
                              ? () => setSheetState(() => tempCount++)
                              : null,
                          icon: const Icon(Icons.add_rounded),
                        ),
                      ],
                    ),
                    AppSpacing.verticalXl,
                    SizedBox(
                      width: double.infinity,
                      height: 48.h,
                      child: ElevatedButton(
                        key: const Key('passenger_done_button'),
                        onPressed: () => Navigator.of(ctx).pop(tempCount),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.onboardingButtonNavy,
                          foregroundColor: AppColors.white,
                          shape: const StadiumBorder(),
                        ),
                        child: Text(l10n.done),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    if (selected != null && context.mounted) {
      context.read<HomeBloc>().add(HomePassengerCountChanged(selected));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return MultiBlocListener(
      listeners: <BlocListener<dynamic, dynamic>>[
        BlocListener<LocaleBloc, LocaleState>(
          listenWhen: (LocaleState prev, LocaleState curr) =>
              prev.locale.languageCode != curr.locale.languageCode,
          listener: (BuildContext context, LocaleState localeState) {
            final userId = context.read<SessionBloc>().state.userId;
            context.read<HomeBloc>().add(
                  HomeStarted(
                    languageCode: localeState.locale.languageCode,
                    userId: userId,
                  ),
                );
          },
        ),
        BlocListener<HomeBloc, HomeState>(
          listenWhen: (HomeState prev, HomeState curr) =>
              curr.validationError != null &&
              prev.validationError != curr.validationError,
          listener: (BuildContext context, HomeState state) {
            final error = state.validationError;
            if (error == null) {
              return;
            }
            final msg = error == HomeValidationError.sameOriginDestination
                ? l10n.sameOriginDestinationError
                : l10n.pastDateError;
            _showSnack(context, msg);
            context.read<HomeBloc>().add(const HomeValidationCleared());
          },
        ),
        BlocListener<HomeBloc, HomeState>(
          listenWhen: (HomeState prev, HomeState curr) =>
              curr.searchCriteria != null &&
              prev.searchCriteria != curr.searchCriteria,
          listener: (BuildContext context, HomeState state) {
            final criteria = state.searchCriteria;
            if (criteria == null) {
              return;
            }
            context.read<HomeBloc>().add(const HomeSearchNavigationHandled());
            context.go(RoutePath.searchResults, extra: criteria);
          },
        ),
      ],
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: AppColors.onboardingBackgroundFallback,
          bottomNavigationBar: const _HomeBottomNavBar(),
          body: BlocBuilder<HomeBloc, HomeState>(
            builder: (BuildContext context, HomeState state) {
              if (state.status == HomeStatus.initial ||
                  state.status == HomeStatus.loading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                );
              }

              if (state.status == HomeStatus.failure) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          l10n.errorGeneric,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.onboardingHeadingNavy,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        AppSpacing.verticalLg,
                        ElevatedButton(
                          onPressed: () {
                            final lang = context
                                .read<LocaleBloc>()
                                .state
                                .locale
                                .languageCode;
                            final userId =
                                context.read<SessionBloc>().state.userId;
                            context.read<HomeBloc>().add(
                                  HomeStarted(
                                    languageCode: lang,
                                    userId: userId,
                                  ),
                                );
                          },
                          child: Text(l10n.retry),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final localeCode =
                  context.watch<LocaleBloc>().state.locale.languageCode;
              final sessionState = context.watch<SessionBloc>().state;
              final displayName =
                  (sessionState.isAuthenticated && state.passengerName != null)
                      ? state.passengerName!
                      : l10n.travelerName;
              final greeting = _greetingText(l10n, DateTime.now());
              final dateText = state.journeyDate != null
                  ? DateFormat('EEE, MMM d, y', localeCode)
                      .format(state.journeyDate!)
                  : '';
              final passengerLabel = state.passengerCount == 1
                  ? l10n.passengerSingular(state.passengerCount)
                  : l10n.passengerPlural(state.passengerCount);

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          bottom: 120.h,
                          child: const _HomeHeroBackground(),
                        ),
                        SafeArea(
                          bottom: false,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              _HomeHeroContent(
                                greeting: greeting,
                                displayName: displayName,
                                isAuthenticated: sessionState.isAuthenticated,
                                onNotificationTap: () =>
                                    context.go(RoutePath.notifications),
                                onProfileTap: () {
                                  if (sessionState.isAuthenticated) {
                                    context.go(RoutePath.profile);
                                  } else {
                                    context.go(RoutePath.login);
                                  }
                                },
                              ),
                              SizedBox(height: 18.h),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.w),
                                child: _HomeSearchCard(
                                  fromName: state.originStop?.name ?? '',
                                  toName: state.destinationStop?.name ?? '',
                                  dateText: dateText,
                                  passengerText: passengerLabel,
                                  onFromTap: () => _pickStop(
                                    context: context,
                                    title: l10n.selectOriginTitle,
                                    stops: state.stops,
                                    selectedId: state.originStop?.id,
                                    onSelected: (StopEntity s) => context
                                        .read<HomeBloc>()
                                        .add(HomeOriginSelected(s)),
                                  ),
                                  onToTap: () => _pickStop(
                                    context: context,
                                    title: l10n.selectDestinationTitle,
                                    stops: state.stops,
                                    selectedId: state.destinationStop?.id,
                                    onSelected: (StopEntity s) => context
                                        .read<HomeBloc>()
                                        .add(HomeDestinationSelected(s)),
                                  ),
                                  onSwapTap: () => context
                                      .read<HomeBloc>()
                                      .add(const HomeLocationsSwapped()),
                                  onDateTap: () =>
                                      _pickDate(context, state.journeyDate),
                                  onPassengersTap: () => _pickPassengers(
                                    context,
                                    state.passengerCount,
                                  ),
                                  onSearchTap: () => context
                                      .read<HomeBloc>()
                                      .add(const HomeSearchSubmitted()),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.verticalXl,
                    if (state.popularRoutes.isNotEmpty) ...<Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                l10n.popularRoutes,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.onboardingHeadingNavy,
                                  fontSize: 19.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            TextButton(
                              key: const Key('home_see_all_routes_button'),
                              onPressed: () => context.go(RoutePath.search),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.secondary,
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppSpacing.xs,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                l10n.seeAll,
                                style: TextStyle(
                                  color: AppColors.secondary,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppSpacing.verticalSm,
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            for (var i = 0;
                                i < state.popularRoutes.length;
                                i++) ...<Widget>[
                              if (i > 0) AppSpacing.horizontalMd,
                              _PopularRouteCard(
                                route: state.popularRoutes[i],
                                fareText: state.popularRoutes[i].minFareMinor !=
                                        null
                                    ? l10n.fromFare(
                                        _formatBdt(
                                          state.popularRoutes[i].minFareMinor!,
                                          localeCode,
                                        ),
                                      )
                                    : null,
                                onTap: () => context.read<HomeBloc>().add(
                                      HomePopularRouteSelected(
                                        state.popularRoutes[i],
                                      ),
                                    ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      AppSpacing.verticalLg,
                    ],
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: _FeatureShortcutCard(
                              cardKey: const Key(
                                'home_connecting_journey_card',
                              ),
                              icon: Icons.link_rounded,
                              iconColor: AppColors.secondary,
                              iconBg: AppColors.homeIconBgBlue,
                              title: l10n.connectingJourney,
                              subtitle: l10n.connectingJourneyDesc,
                              onTap: () =>
                                  context.go(RoutePath.connectingJourney),
                            ),
                          ),
                          AppSpacing.horizontalMd,
                          Expanded(
                            child: _FeatureShortcutCard(
                              cardKey: const Key('home_ticket_exchange_card'),
                              icon: Icons.handshake_rounded,
                              iconColor: AppColors.accent,
                              iconBg: AppColors.homeIconBgTeal,
                              title: l10n.ticketHandover,
                              subtitle: l10n.ticketHandoverDesc,
                              onTap: () => context.go(RoutePath.exchange),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (state.popularBuses.isNotEmpty) ...<Widget>[
                      AppSpacing.verticalXl,
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Row(
                          children: <Widget>[
                            Flexible(
                              child: Text(
                                l10n.popularBuses,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.onboardingHeadingNavy,
                                  fontSize: 19.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            AppSpacing.horizontalSm,
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.homeDemoBadgeBg,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                l10n.demoBadge,
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppSpacing.verticalSm,
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            for (var i = 0;
                                i < state.popularBuses.length;
                                i++) ...<Widget>[
                              if (i > 0) AppSpacing.horizontalMd,
                              _PopularBusCard(
                                bus: state.popularBuses[i],
                                fareFormatted:
                                    '৳${_formatBdt(state.popularBuses[i].fareMinor, localeCode)}',
                                departureFormatted:
                                    DateFormat('hh:mm a', localeCode).format(
                                  state.popularBuses[i].departureAt,
                                ),
                                seatsText: l10n.seatsAvailable(
                                  state.popularBuses[i].availableSeats,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                    AppSpacing.verticalXl,
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HomeHeroBackground extends StatelessWidget {
  const _HomeHeroBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppColors.homeHeroStart,
            AppColors.homeHeroEnd,
          ],
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.elliptical(220.w, 34.h),
        ),
      ),
    );
  }
}

class _HomeHeroContent extends StatelessWidget {
  const _HomeHeroContent({
    required this.greeting,
    required this.displayName,
    required this.isAuthenticated,
    required this.onNotificationTap,
    required this.onProfileTap,
  });

  final String greeting;
  final String displayName;
  final bool isAuthenticated;
  final VoidCallback onNotificationTap;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 6.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                  children: <InlineSpan>[
                    TextSpan(
                      text: l10n.appNameFirst,
                      style: const TextStyle(color: AppColors.white),
                    ),
                    TextSpan(
                      text: l10n.appNameSecond,
                      style: const TextStyle(color: AppColors.accent),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(
                    key: const Key('home_profile_avatar_button'),
                    onPressed: onProfileTap,
                    icon: CircleAvatar(
                      radius: 15.r,
                      backgroundColor: AppColors.white.withValues(alpha: 0.2),
                      child: isAuthenticated
                          ? Text(
                              displayName.isNotEmpty
                                  ? displayName[0].toUpperCase()
                                  : 'P',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          : Icon(
                              Icons.person_outline_rounded,
                              color: AppColors.white,
                              size: 18.sp,
                            ),
                    ),
                  ),
                  Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      IconButton(
                        key: const Key('home_notification_button'),
                        onPressed: onNotificationTap,
                        icon: Icon(
                          Icons.notifications_rounded,
                          color: AppColors.white,
                          size: 24.sp,
                        ),
                      ),
                      Positioned(
                        right: 11.w,
                        top: 10.h,
                        child: Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '$greeting\n$displayName!',
                      key: const Key('home_greeting_text'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 27.sp,
                        fontWeight: FontWeight.w800,
                        height: 1.12,
                        letterSpacing: -0.4,
                      ),
                    ),
                    AppSpacing.verticalSm,
                    Text(
                      l10n.homeHeroSubtitle,
                      style: TextStyle(
                        color: AppColors.white.withValues(alpha: 0.9),
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w400,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.horizontalSm,
              Image.asset(
                AppAssets.busIllustration,
                key: const Key('home_hero_bus_illustration'),
                width: 148.w,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeSearchCard extends StatelessWidget {
  const _HomeSearchCard({
    required this.fromName,
    required this.toName,
    required this.dateText,
    required this.passengerText,
    required this.onFromTap,
    required this.onToTap,
    required this.onSwapTap,
    required this.onDateTap,
    required this.onPassengersTap,
    required this.onSearchTap,
  });

  final String fromName;
  final String toName;
  final String dateText;
  final String passengerText;
  final VoidCallback onFromTap;
  final VoidCallback onToTap;
  final VoidCallback onSwapTap;
  final VoidCallback onDateTap;
  final VoidCallback onPassengersTap;
  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.onboardingHeadingNavy.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Stack(
            alignment: Alignment.centerRight,
            children: <Widget>[
              Column(
                children: <Widget>[
                  _SearchFieldRow(
                    rowKey: const Key('home_from_field'),
                    icon: Icons.location_on_rounded,
                    label: l10n.fromLabel,
                    value: fromName,
                    onTap: onFromTap,
                    rightPadding: 48.w,
                  ),
                  Divider(
                    color: AppColors.homeSurfaceBorder,
                    height: 16.h,
                    endIndent: 52.w,
                  ),
                  _SearchFieldRow(
                    rowKey: const Key('home_to_field'),
                    icon: Icons.location_on_rounded,
                    label: l10n.toLabel,
                    value: toName,
                    onTap: onToTap,
                    rightPadding: 48.w,
                  ),
                ],
              ),
              Positioned(
                right: 0,
                child: Material(
                  color: AppColors.homeIconBgBlue,
                  shape: const CircleBorder(
                    side: BorderSide(
                      color: AppColors.languageCardSelectedBorder,
                      width: 1,
                    ),
                  ),
                  child: InkWell(
                    key: const Key('home_swap_button'),
                    onTap: onSwapTap,
                    customBorder: const CircleBorder(),
                    child: SizedBox(
                      width: 40.w,
                      height: 40.w,
                      child: Icon(
                        Icons.swap_vert_rounded,
                        color: AppColors.secondary,
                        size: 22.sp,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Divider(color: AppColors.homeSurfaceBorder, height: 16.h),
          _SearchFieldRow(
            rowKey: const Key('home_date_field'),
            icon: Icons.calendar_today_rounded,
            label: l10n.dateLabel,
            value: dateText,
            onTap: onDateTap,
          ),
          Divider(color: AppColors.homeSurfaceBorder, height: 16.h),
          _SearchFieldRow(
            rowKey: const Key('home_passengers_field'),
            icon: Icons.person_outline_rounded,
            label: l10n.passengersLabel,
            value: passengerText,
            onTap: onPassengersTap,
          ),
          AppSpacing.verticalLg,
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              key: const Key('home_search_button'),
              onPressed: onSearchTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.onboardingButtonNavy,
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: const StadiumBorder(),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    l10n.searchBuses,
                    style: TextStyle(
                      fontSize: 16.5.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 19.sp,
                    color: AppColors.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchFieldRow extends StatelessWidget {
  const _SearchFieldRow({
    required this.rowKey,
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.rightPadding = 0,
  });

  final Key rowKey;
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  final double rightPadding;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: rowKey,
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Padding(
        padding: EdgeInsets.only(right: rightPadding, top: 2.h, bottom: 2.h),
        child: Row(
          children: <Widget>[
            Container(
              width: 36.w,
              height: 36.w,
              decoration: const BoxDecoration(
                color: AppColors.homeIconBgBlue,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.secondary,
                size: 19.sp,
              ),
            ),
            AppSpacing.horizontalMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    label,
                    style: TextStyle(
                      color: AppColors.homeTextMuted,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.onboardingHeadingNavy,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PopularRouteCard extends StatelessWidget {
  const _PopularRouteCard({
    required this.route,
    required this.onTap,
    this.fareText,
  });

  final PopularRouteEntity route;
  final String? fareText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          width: 172.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.homeSurfaceBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 76.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: <Color>[
                      AppColors.homeHeroStart,
                      AppColors.homeHeroEnd,
                    ],
                  ),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(13.r),
                  ),
                ),
                padding: EdgeInsets.all(AppSpacing.sm),
                child: Image.asset(
                  AppAssets.busLogo,
                  fit: BoxFit.contain,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.w,
                  vertical: 8.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '${route.originStop.name} → ${route.destinationStop.name}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.onboardingHeadingNavy,
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (fareText != null) ...<Widget>[
                      SizedBox(height: 2.h),
                      Text(
                        fareText!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PopularBusCard extends StatelessWidget {
  const _PopularBusCard({
    required this.bus,
    required this.fareFormatted,
    required this.departureFormatted,
    required this.seatsText,
  });

  final PopularBusEntity bus;
  final String fareFormatted;
  final String departureFormatted;
  final String seatsText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 236.w,
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.homeSurfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 44.w,
                height: 36.h,
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppColors.homeIconBgBlue,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Image.asset(
                  AppAssets.busLogo,
                  fit: BoxFit.contain,
                ),
              ),
              AppSpacing.horizontalSm,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      bus.busName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.onboardingHeadingNavy,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      bus.operatorName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.homeTextMuted,
                        fontSize: 11.5.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Text(
            '${bus.originName} → ${bus.destinationName}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.onboardingHeadingNavy,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                departureFormatted,
                style: TextStyle(
                  color: AppColors.homeTextMuted,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                fareFormatted,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: AppColors.homeIconBgTeal,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              seatsText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.accent,
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureShortcutCard extends StatelessWidget {
  const _FeatureShortcutCard({
    required this.cardKey,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final Key cardKey;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        key: cardKey,
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 12.w,
            vertical: 12.h,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.homeSurfaceBorder),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 21.sp,
                ),
              ),
              AppSpacing.horizontalSm,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.onboardingHeadingNavy,
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w700,
                        height: 1.18,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.homeTextMuted,
                        fontSize: 10.5.sp,
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeBottomNavBar extends StatelessWidget {
  const _HomeBottomNavBar();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAuthenticated = context.watch<SessionBloc>().state.isAuthenticated;

    return NavigationBarTheme(
      data: NavigationBarThemeData(
        backgroundColor: AppColors.white,
        indicatorColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
          (Set<WidgetState> states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              color: selected ? AppColors.secondary : AppColors.homeTextMuted,
              fontSize: 12.sp,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            );
          },
        ),
      ),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.homeSurfaceBorder),
          ),
        ),
        child: NavigationBar(
          key: const Key('home_bottom_nav'),
          selectedIndex: 0,
          height: 64.h,
          backgroundColor: AppColors.white,
          elevation: 0,
          onDestinationSelected: (int index) {
            switch (index) {
              case 0:
                break;
              case 1:
                context.go(RoutePath.search);
              case 2:
                if (isAuthenticated) {
                  context.go(RoutePath.myTickets);
                } else {
                  context.go(RoutePath.login);
                }
              case 3:
                if (isAuthenticated) {
                  context.go(RoutePath.profile);
                } else {
                  context.go(RoutePath.login);
                }
            }
          },
          destinations: <NavigationDestination>[
            NavigationDestination(
              icon: const Icon(
                Icons.home_outlined,
                color: AppColors.homeTextMuted,
              ),
              selectedIcon: const Icon(
                Icons.home_rounded,
                color: AppColors.secondary,
              ),
              label: l10n.navHome,
            ),
            NavigationDestination(
              icon: const Icon(
                Icons.search_rounded,
                color: AppColors.homeTextMuted,
              ),
              label: l10n.navSearch,
            ),
            NavigationDestination(
              icon: const Icon(
                Icons.confirmation_number_outlined,
                color: AppColors.homeTextMuted,
              ),
              label: l10n.navMyTickets,
            ),
            NavigationDestination(
              icon: const Icon(
                Icons.person_outline_rounded,
                color: AppColors.homeTextMuted,
              ),
              label: l10n.navProfile,
            ),
          ],
        ),
      ),
    );
  }
}
