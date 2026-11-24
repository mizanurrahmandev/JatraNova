import 'package:flutter/material.dart';
import 'package:jatra_nova/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/entities/filter_criteria_entity.dart';

class FilterSortSheet extends StatefulWidget {
  final FilterCriteriaEntity currentFilters;
  final ValueChanged<FilterCriteriaEntity> onApply;

  const FilterSortSheet({
    super.key,
    required this.currentFilters,
    required this.onApply,
  });

  static Future<FilterCriteriaEntity?> show({
    required BuildContext context,
    required FilterCriteriaEntity currentFilters,
  }) {
    return showModalBottomSheet<FilterCriteriaEntity>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return FilterSortSheet(
          currentFilters: currentFilters,
          onApply: (f) => Navigator.of(ctx).pop(f),
        );
      },
    );
  }

  @override
  State<FilterSortSheet> createState() => _FilterSortSheetState();
}

class _FilterSortSheetState extends State<FilterSortSheet> {
  late SortOption _sortBy;
  bool? _onlyAc;

  @override
  void initState() {
    super.initState();
    _sortBy = widget.currentFilters.sortBy;
    _onlyAc = widget.currentFilters.onlyAc;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
              Text(l10n.filter_title, style: AppTextStyles.titleMedium),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Sort By Section
          Text(l10n.filter_sort_by, style: AppTextStyles.labelLarge),
          const SizedBox(height: 8),
          _buildSortTile(
            title: l10n.filter_sort_earliest,
            value: SortOption.earliestDeparture,
          ),
          _buildSortTile(
            title: l10n.filter_sort_lowest_fare,
            value: SortOption.lowestFare,
          ),
          _buildSortTile(
            title: l10n.filter_sort_duration,
            value: SortOption.fastest,
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),

          // Bus Type Filter
          Text(l10n.filter_bus_type, style: AppTextStyles.labelLarge),
          const SizedBox(height: 8),
          Row(
            children: [
              FilterChip(
                label: Text(l10n.filter_ac),
                selected: _onlyAc == true,
                selectedColor: AppColors.primaryLight.withValues(alpha: 0.2),
                checkmarkColor: AppColors.primary,
                labelStyle: AppTextStyles.labelMedium.copyWith(
                  color: _onlyAc == true ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: _onlyAc == true ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: (selected) {
                  setState(() {
                    _onlyAc = selected ? true : null;
                  });
                },
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: Text(l10n.filter_non_ac),
                selected: _onlyAc == false,
                selectedColor: AppColors.primaryLight.withValues(alpha: 0.2),
                checkmarkColor: AppColors.primary,
                labelStyle: AppTextStyles.labelMedium.copyWith(
                  color: _onlyAc == false ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: _onlyAc == false ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: (selected) {
                  setState(() {
                    _onlyAc = selected ? false : null;
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Apply and Reset Actions
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: l10n.filter_reset,
                  onPressed: () {
                    setState(() {
                      _sortBy = SortOption.earliestDeparture;
                      _onlyAc = null;
                    });
                  },
                  variant: AppButtonVariant.outline,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  text: l10n.filter_apply,
                  onPressed: () {
                    widget.onApply(FilterCriteriaEntity(
                      sortBy: _sortBy,
                      onlyAc: _onlyAc,
                    ));
                  },
                  variant: AppButtonVariant.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildSortTile({required String title, required SortOption value}) {
    final isSelected = _sortBy == value;
    return InkWell(
      onTap: () {
        setState(() {
          _sortBy = value;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: AppTextStyles.bodyMedium),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
