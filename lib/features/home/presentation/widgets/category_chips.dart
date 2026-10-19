import 'package:flutter/material.dart';
import 'package:hamyar/core/theme/app_theme.dart';

class CategoryChips extends StatelessWidget {
  final String? selectedId;
  final ValueChanged<String?> onSelected;

  const CategoryChips({
    super.key,
    this.selectedId,
    required this.onSelected,
  });

  static const categories = [
    {'id': null, 'name': 'همه', 'icon': Icons.apps_rounded},
    {'id': '1', 'name': 'برق و انرژی', 'icon': Icons.bolt_rounded},
    {'id': '2', 'name': 'آب', 'icon': Icons.water_drop_rounded},
    {'id': '3', 'name': 'دارو', 'icon': Icons.medical_services_rounded},
    {'id': '4', 'name': 'ابزار', 'icon': Icons.build_rounded},
    {'id': '5', 'name': 'حمل‌ونقل', 'icon': Icons.directions_car_rounded},
    {'id': '6', 'name': 'خوراکی', 'icon': Icons.restaurant_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = selectedId == cat['id'];

          return GestureDetector(
            onTap: () => onSelected(cat['id'] as String?),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    cat['icon'] as IconData,
                    size: 18,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    cat['name'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
