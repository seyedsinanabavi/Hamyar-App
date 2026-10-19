import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hamyar/core/theme/app_theme.dart';
import 'package:hamyar/features/home/presentation/providers/home_provider.dart';
import 'package:hamyar/features/home/presentation/widgets/listing_card.dart';
import 'package:hamyar/features/home/presentation/widgets/category_chips.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsAsync = ref.watch(listingsProvider);
    final selectedType = ref.watch(selectedTypeProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'هم‌یار',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded, size: 16, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              'محله شما',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => ref.invalidate(listingsProvider),
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
            ),
            CategoryChips(
              selectedId: selectedCategory?.toString(),
              onSelected: (id) {
                ref.read(selectedCategoryProvider.notifier).state =
                    id == null ? null : int.tryParse(id);
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _TypeChip(
                    label: 'همه',
                    isSelected: selectedType == null,
                    onTap: () => ref.read(selectedTypeProvider.notifier).state = null,
                  ),
                  const SizedBox(width: 8),
                  _TypeChip(
                    label: 'پیشنهادها',
                    isSelected: selectedType == 'offer',
                    color: AppColors.offer,
                    onTap: () => ref.read(selectedTypeProvider.notifier).state = 'offer',
                  ),
                  const SizedBox(width: 8),
                  _TypeChip(
                    label: 'درخواست‌ها',
                    isSelected: selectedType == 'request',
                    color: AppColors.request,
                    onTap: () => ref.read(selectedTypeProvider.notifier).state = 'request',
                  ),
                ],
              ),
            ),
            Expanded(
              child: listingsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(e.toString(), textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.textSecondary)),
                      ),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(listingsProvider),
                        child: const Text('تلاش مجدد'),
                      ),
                    ],
                  ),
                ),
                data: (listings) {
                  if (listings.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.handshake_outlined, size: 72,
                              color: AppColors.primary.withOpacity(0.3)),
                          const SizedBox(height: 16),
                          Text('هنوز آگهی‌ای در محله شما نیست',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.textSecondary)),
                          const SizedBox(height: 8),
                          const Text('اولین نفر باشید که کمک می‌کند!',
                              style: TextStyle(color: AppColors.textSecondary)),
                          const SizedBox(height: 20),
                          TextButton.icon(
                            onPressed: () => ref.invalidate(listingsProvider),
                            icon: const Icon(Icons.refresh),
                            label: const Text('بروزرسانی'),
                          ),
                        ],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async => ref.invalidate(listingsProvider),
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 100),
                      itemCount: listings.length,
                      itemBuilder: (context, index) {
                        final listing = listings[index];
                        return ListingCard(
                          listing: listing,
                          onTap: () => context.push('/listing/${listing.id}'),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.isSelected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? AppColors.primary).withOpacity(0.12)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? (color ?? AppColors.primary) : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected
                ? (color ?? AppColors.primary)
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
