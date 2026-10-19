import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hamyar/core/theme/app_theme.dart';
import 'package:hamyar/core/security/security_utils.dart';
import 'package:hamyar/features/listing/data/listing_repository.dart';
import 'package:hamyar/features/home/presentation/providers/home_provider.dart';
import 'package:hamyar/shared/widgets/trust_badge.dart';

class CreateListingScreen extends ConsumerStatefulWidget {
  const CreateListingScreen({super.key});

  @override
  ConsumerState<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends ConsumerState<CreateListingScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _type = 'offer';
  int? _categoryId;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('دسته‌بندی را انتخاب کنید')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(listingRepositoryProvider).createListing(
            categoryId: _categoryId!,
            type: _type,
            title: SecurityUtils.sanitizeText(_titleController.text, maxLength: 120),
            description: _descController.text.trim().isEmpty
                ? null
                : SecurityUtils.sanitizeText(_descController.text),
          );
      ref.invalidate(listingsProvider);
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('آگهی با موفقیت ثبت شد'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('ثبت آگهی جدید'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('نوع آگهی', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _TypeButton(
                      label: 'پیشنهاد می‌کنم',
                      icon: Icons.volunteer_activism_rounded,
                      isSelected: _type == 'offer',
                      color: AppColors.offer,
                      onTap: () => setState(() => _type = 'offer'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TypeButton(
                      label: 'درخواست دارم',
                      icon: Icons.handshake_rounded,
                      isSelected: _type == 'request',
                      color: AppColors.request,
                      onTap: () => setState(() => _type = 'request'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text('دسته‌بندی', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              categoriesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => _buildFallbackCategories(),
                data: (categories) {
                  if (categories.isEmpty) return _buildFallbackCategories();
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final cat in categories)
                        ChoiceChip(
                          label: Text(cat.name),
                          selected: _categoryId == cat.id,
                          onSelected: (_) => setState(() => _categoryId = cat.id),
                          selectedColor: AppColors.primary.withOpacity(0.15),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              Text('عنوان', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(hintText: 'مثلاً: ژنراتور دارم برای قرض دادن'),
                maxLength: 120,
                validator: (v) {
                  if (v == null || v.trim().length < 5) return 'عنوان باید حداقل ۵ کاراکتر باشد';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text('توضیحات (اختیاری)', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(hintText: 'جزئیات بیشتر بنویسید...'),
                maxLines: 4,
                maxLength: 2000,
              ),
              const SizedBox(height: 32),
              const SafetyDisclaimer(compact: true),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(height: 22, width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                    : const Text('ثبت آگهی'),
              ),
            ],
          ),
        ),
      ),
    );

  Widget _buildFallbackCategories() {
    const items = [
      (1, 'برق و انرژی'),
      (2, 'آب'),
      (3, 'دارو'),
      (4, 'ابزار'),
      (5, 'حمل‌ونقل'),
      (6, 'خوراکی'),
      (7, 'سایر'),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final cat in items)
          ChoiceChip(
            label: Text(cat.$2),
            selected: _categoryId == cat.$1,
            onSelected: (_) => setState(() => _categoryId = cat.$1),
            selectedColor: AppColors.primary.withOpacity(0.15),
          ),
      ],
    );
  }
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.12) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? color : AppColors.border, width: isSelected ? 1.5 : 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : AppColors.textSecondary, size: 28),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? color : AppColors.textPrimary,
                )),
          ],
        ),
      ),
    );
  }
}
