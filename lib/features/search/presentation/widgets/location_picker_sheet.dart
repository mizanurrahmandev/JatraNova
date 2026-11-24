import 'package:flutter/material.dart';
import 'package:jatra_nova/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/location_entity.dart';

class LocationPickerSheet extends StatefulWidget {
  final List<LocationEntity> locations;
  final LocationEntity? initialSelected;
  final ValueChanged<LocationEntity> onSelected;

  const LocationPickerSheet({
    super.key,
    required this.locations,
    this.initialSelected,
    required this.onSelected,
  });

  static Future<LocationEntity?> show({
    required BuildContext context,
    required List<LocationEntity> locations,
    LocationEntity? initialSelected,
  }) {
    return showModalBottomSheet<LocationEntity>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return LocationPickerSheet(
          locations: locations,
          initialSelected: initialSelected,
          onSelected: (loc) => Navigator.of(ctx).pop(loc),
        );
      },
    );
  }

  @override
  State<LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<LocationPickerSheet> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    final filteredLocations = widget.locations.where((loc) {
      final query = _searchQuery.toLowerCase();
      return loc.nameEn.toLowerCase().contains(query) ||
          loc.nameBn.contains(query) ||
          loc.code.toLowerCase().contains(query);
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
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

          // Title & Close
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.search_select_city_title, style: AppTextStyles.titleMedium),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Search text field
          TextField(
            controller: _searchController,
            onChanged: (val) {
              setState(() {
                _searchQuery = val.trim();
              });
            },
            decoration: InputDecoration(
              hintText: l10n.search_city_search_hint,
              prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),

          // Popular cities pills
          Text(l10n.search_popular_cities, style: AppTextStyles.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.locations.take(4).map((loc) {
              final isSelected = widget.initialSelected?.id == loc.id;
              return ActionChip(
                label: Text(loc.localizedName(locale)),
                backgroundColor: isSelected ? AppColors.primary : AppColors.background,
                labelStyle: AppTextStyles.labelMedium.copyWith(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : AppColors.divider,
                  ),
                ),
                onPressed: () => widget.onSelected(loc),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Divider(),

          // All cities list
          Expanded(
            child: ListView.separated(
              itemCount: filteredLocations.length,
              separatorBuilder: (_, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final loc = filteredLocations[index];
                final isSelected = widget.initialSelected?.id == loc.id;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.primary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        loc.code,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: isSelected ? Colors.white : AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    loc.localizedName(locale),
                    style: AppTextStyles.titleSmall.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    locale == 'bn' ? loc.nameEn : loc.nameBn,
                    style: AppTextStyles.bodySmall,
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: AppColors.primary)
                      : null,
                  onTap: () => widget.onSelected(loc),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
