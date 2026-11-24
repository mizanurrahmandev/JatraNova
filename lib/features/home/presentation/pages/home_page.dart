import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jatra_nova/l10n/app_localizations.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../../core/session/session_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.app_name),
        actions: [
          // Language toggle button
          TextButton.icon(
            onPressed: () {
              context.read<LocaleCubit>().toggleLocale();
            },
            icon: const Icon(Icons.language, size: 18, color: AppColors.primary),
            label: Text(
              currentLocale == 'bn' ? 'English' : 'বাংলা',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
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
                      style: AppTextStyles.labelMedium.copyWith(color: AppColors.info),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tagline & greeting
            Text(
              l10n.tagline,
              style: AppTextStyles.displayMedium.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            BlocBuilder<SessionCubit, SessionState>(
              builder: (context, session) {
                final greeting = session.isAuthenticated
                    ? 'Hello, ${session.userName}!'
                    : 'Browsing as Guest';
                return Text(
                  greeting,
                  style: AppTextStyles.titleMedium.copyWith(color: AppColors.textSecondary),
                );
              },
            ),
            const SizedBox(height: 20),

            // Sample formatted items using core utilities
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Foundation Verification (Phase 1)',
                    style: AppTextStyles.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Sample Fare (BDT):', style: AppTextStyles.bodyMedium),
                      Text(
                        MoneyFormatter.formatBdt(1450, locale: currentLocale),
                        style: AppTextStyles.titleMedium.copyWith(color: AppColors.secondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Sample Date:', style: AppTextStyles.bodyMedium),
                      Text(
                        DateFormatter.formatFullDate(
                          DateTime.now().toUtc().millisecondsSinceEpoch,
                          locale: currentLocale,
                        ),
                        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: 'Toggle Language',
                          onPressed: () {
                            context.read<LocaleCubit>().toggleLocale();
                          },
                          variant: AppButtonVariant.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton(
                          text: 'Guest Mode',
                          onPressed: () {
                            context.read<SessionCubit>().continueAsGuest();
                          },
                          variant: AppButtonVariant.outline,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTabIndex,
        onTap: (index) {
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
  }
}
