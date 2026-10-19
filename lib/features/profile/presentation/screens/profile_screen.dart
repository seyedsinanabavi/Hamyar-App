import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hamyar/core/theme/app_theme.dart';
import 'package:hamyar/core/constants/api_constants.dart';
import 'package:hamyar/core/network/api_client.dart';
import 'package:hamyar/features/auth/presentation/providers/auth_provider.dart';
import 'package:hamyar/shared/widgets/trust_badge.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('پروفایل'), automaticallyImplyLeading: false),
      body: authState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (user) {
          if (user == null) {
            return Center(
              child: ElevatedButton(
                onPressed: () => context.go('/login'),
                child: const Text('ورود به حساب'),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.primary.withOpacity(0.15),
                  child: Text(
                    user.displayName[0],
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      user.displayName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(width: 6),
                    TrustBadge(trustBadge: user.trustBadge, size: 22),
                  ],
                ),
                const SizedBox(height: 4),
                Text(user.phone, style: const TextStyle(color: AppColors.textSecondary)),
                if (user.hasVerifiedBadge)
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Text(
                      'هویت توسط هم‌یار تأیید شده',
                      style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                    ),
                  )
                else if (user.hasTrustedBadge)
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Text(
                      'کاربر مورد اعتماد',
                      style: TextStyle(fontSize: 12, color: Colors.amber, fontWeight: FontWeight.w600),
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  user.ratingCount > 0
                      ? '${user.rating.toStringAsFixed(1)} (${user.ratingCount} نظر)'
                      : 'هنوز نظری ثبت نشده',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),

                // Help stats
                Row(
                  children: [
                    _StatCard(label: 'کمک داده‌ام', value: '${user.helpsGiven}'),
                    const SizedBox(width: 12),
                    _StatCard(label: 'کمک گرفته‌ام', value: '${user.helpsReceived}'),
                    const SizedBox(width: 12),
                    _StatCard(label: 'امتیاز', value: user.rating.toStringAsFixed(1)),
                  ],
                ),
                const SizedBox(height: 20),

                const SafetyDisclaimer(compact: true),
                const SizedBox(height: 16),

                // Verification request
                if (!user.isIdentityVerified) ...[
                  if (user.verificationStatus == 'pending')
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'درخواست تأیید هویت شما در حال بررسی است.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    )
                  else if (user.verificationStatus == 'rejected')
                    Column(
                      children: [
                        const Text(
                          'درخواست قبلی رد شد. می‌توانید دوباره درخواست دهید.',
                          style: TextStyle(color: AppColors.error, fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: () => _requestVerification(context, ref),
                          icon: const Icon(Icons.verified_user_outlined),
                          label: const Text('درخواست مجدد تأیید هویت'),
                        ),
                      ],
                    )
                  else
                    OutlinedButton.icon(
                      onPressed: () => _requestVerification(context, ref),
                      icon: const Icon(Icons.verified_user_outlined),
                      label: const Text('درخواست تأیید هویت'),
                    ),
                  const SizedBox(height: 12),
                ],

                ListTile(
                  leading: const Icon(Icons.refresh_rounded),
                  title: const Text('بروزرسانی پروفایل'),
                  onTap: () => ref.read(authStateProvider.notifier).refreshUser(),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout_rounded, color: AppColors.error),
                  title: const Text('خروج از حساب', style: TextStyle(color: AppColors.error)),
                  onTap: () async {
                    await ref.read(authStateProvider.notifier).logout();
                    if (context.mounted) context.go('/login');
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _requestVerification(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('درخواست تأیید هویت'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'تیم هم‌یار هویت شما را بررسی می‌کند. نام کامل در پروفایل لازم است. کد ملی الزامی نیست.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'پیام اختیاری برای تیم بررسی...',
              ),
              maxLines: 3,
              maxLength: 500,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('انصراف')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('ارسال درخواست'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      final client = ref.read(apiClientProvider);
      final response = await client.post(ApiConstants.requestVerification, data: {
        if (controller.text.trim().isNotEmpty) 'message': controller.text.trim(),
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.data['message']?.toString() ?? 'درخواست ثبت شد'),
            backgroundColor: AppColors.success,
          ),
        );
        ref.read(authStateProvider.notifier).refreshUser();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    }
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
