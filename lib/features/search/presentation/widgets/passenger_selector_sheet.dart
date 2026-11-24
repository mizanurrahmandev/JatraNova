import 'package:flutter/material.dart';
import 'package:jatra_nova/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';

class PassengerSelectorSheet extends StatefulWidget {
  final int initialCount;
  final ValueChanged<int> onCountSelected;

  const PassengerSelectorSheet({
    super.key,
    required this.initialCount,
    required this.onCountSelected,
  });

  static Future<int?> show({
    required BuildContext context,
    required int initialCount,
  }) {
    return showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return PassengerSelectorSheet(
          initialCount: initialCount,
          onCountSelected: (count) => Navigator.of(ctx).pop(count),
        );
      },
    );
  }

  @override
  State<PassengerSelectorSheet> createState() => _PassengerSelectorSheetState();
}

class _PassengerSelectorSheetState extends State<PassengerSelectorSheet> {
  late int _count;

  @override
  void initState() {
    super.initState();
    _count = widget.initialCount;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.search_passenger_counter_title, style: AppTextStyles.titleMedium),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Passengers (Seats)', style: AppTextStyles.titleMedium),
                  const SizedBox(height: 4),
                  Text('Age 2+ years', style: AppTextStyles.bodySmall),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: _count > 1
                        ? () {
                            setState(() {
                              _count--;
                            });
                          }
                        : null,
                    icon: const Icon(Icons.remove_circle_outline),
                    color: AppColors.primary,
                    iconSize: 32,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$_count',
                    style: AppTextStyles.displayMedium.copyWith(color: AppColors.primary),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _count < 4
                        ? () {
                            setState(() {
                              _count++;
                            });
                          }
                        : null,
                    icon: const Icon(Icons.add_circle_outline),
                    color: AppColors.primary,
                    iconSize: 32,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.infoLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: AppColors.info),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.search_passenger_limit_note,
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.info),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          AppButton(
            text: l10n.common_apply,
            onPressed: () => widget.onCountSelected(_count),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
