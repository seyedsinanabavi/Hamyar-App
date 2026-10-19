import 'package:flutter/material.dart';
import 'package:hamyar/core/theme/app_theme.dart';

class TrustBadge extends StatelessWidget {
  final String trustBadge; // verified | trusted | none
  final double size;

  const TrustBadge({
    super.key,
    required this.trustBadge,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    if (trustBadge == 'verified') {
      return Tooltip(
        message: 'هویت توسط هم‌یار تأیید شده',
        child: Icon(Icons.verified, size: size, color: AppColors.primary),
      );
    }
    if (trustBadge == 'trusted') {
      return Tooltip(
        message: 'کاربر مورد اعتماد (بر اساس امتیاز و کمک‌ها)',
        child: Icon(Icons.workspace_premium, size: size, color: Colors.amber.shade700),
      );
    }
    return const SizedBox.shrink();
  }
}

/// هشدار ثابت: هم‌یار واسطه مالی نیست
class SafetyDisclaimer extends StatelessWidget {
  final bool compact;

  const SafetyDisclaimer({super.key, this.compact = false});

  static const text =
      'هم‌یار فقط بستر ارتباط محلی است و واسطه مالی، ضمانت معامله یا مسئولیت تحویل نیست. با احتیاط و در محله خود تعامل کنید.';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 10 : 14),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withOpacity(0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: compact ? 18 : 22, color: AppColors.warning),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: compact ? 11 : 12,
                height: 1.5,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
